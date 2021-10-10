% Viterbi decode
% 接收参数:
% 只有前五个 硬Viterbi解码 不关心信道传输
% isSoft = 1:
% modulation == 1 为-r/+r的传输 每n个复数做一次判断
% modulation == n 每一个复数计算一次距离
function [decodedResult, minError] = viterbi_decode(n, k, m, A, r, isSoft, modulation, P)
    DEBUG = 0; % show message?

    if (nargin == 5)
        isSoft = 0; % 默认为hard viterbi
        modulation = 1; P = 1; % 不会用到 随便给值
    end

    %% modulation parameters
    % 生成调制步骤的星座图，对应modulation=1/2/3，我们采用BPSK，QPSK和8-PSK调制
    if (modulation == 1)
        N = 1;
        Gray_code = [0 1];
        mapping = sqrt(P) * exp(1j * pi * Gray_code);
    elseif (modulation == 2)
        N = 2;
        Gray_code = [0 1 3 2];
        mapping = sqrt(P) * exp(1j * pi * (Gray_code + .5) / 2);
    elseif (modulation == 3)
        N = 3;
        Gray_code = [0 1 3 2 7 6 4 5];
        mapping = sqrt(P) * exp(1j * pi * Gray_code / 4);
    end

    if (isSoft) && (modulation ~= 1)
        routeLayerAmount = length(r);
    else
        routeLayerAmount = length(r) / n;
    end

    % r = [r, zeros(1, mod(-length(r), n))]; % TODO 这一句是什么意思？
    decodedResult = zeros(1, routeLayerAmount); % 解码得到的长度为routeLayerAmount

    % 分别统计所有状态结点的error,route和解码得到的decodedResult
    % m=3四种m=4八种: 0123 or 01234567 注意index=State数+1
    nodesState = 0:(2^(m - 1) - 1);

    errorMax = 2^14;

    

    % 之前的状态 相当于当前i的初值
    oldNodesError = zeros(1, length(nodesState)) + errorMax; % 初值最大
    oldNodesError(1) = 0; % 全零的状态error是零，这样后续才能开展
    oldNodesRoute = zeros(routeLayerAmount, length(nodesState)) - 1; % 初值全-1（最后更新为0和1）

    % 状态迭代（动态规划）
    % 对每一份收到的码字进行解码
    for i = 1:routeLayerAmount
        newNodesError = zeros(1, length(nodesState)) + errorMax; % 最开始让距离最大，逐渐减少
        newNodesRoute = zeros(routeLayerAmount, length(nodesState)) - 1; % 对应列记录对应状态的解码值（共8列或16列）

        if DEBUG
            fprintf("layer %d\n", i)
        end

        % 对每一种可能的状态进行遍历
        for s = 1:2^(m - 1)
            % 对状态的合法性进行检查，只要error不是max就可以了
            if oldNodesError(s) ~= errorMax
                currentStateIndex = s;
                currentState = f_int2BinaryArray(s - 1, m - 1);

                % 一个状态会有两条路可以走（k=1）
                % 输入可能是0可能是1
                for input = 0:1

                    if DEBUG
                        % fprintf("enter state %d\n", s - 1)
                    end

                    % 对于一条延伸的路径 得到了新的状态和output
                    [nextState, output] = get_next_state(n, k, m, A, currentState, input);
                    nextStateIndex = f_binaryArray2int(nextState) + 1;

                    if ~isSoft
                        % 计算output与收到的信号之间的distance得到并更新error和route
                        r_index = (1:n) + ((i - 1) * n);
                        rPart = r(r_index);

                        % hard viterbi直接计算error的数量得到distance
                        distance_rPart_output = f_distanceBetweenBinaryArray(rPart, output);
                    else

                        if modulation == 1
                            % 计算output与收到的信号之间的distance得到并更新error和route
                            r_index = (1:n) + ((i - 1) * n);
                            rPart = r(r_index);

                            expectedRecieve = zeros(1, length(output)); % 一组复数 后面计算均方距离

                            for kk = 1:length(output)
                                expectedRecieve(kk) = mapping(f_binaryArray2int(output(kk)) + 1); % 映射到1/-1
                            end

                            % disp(expectedRecieve)

                            distance_rPart_output = f_distanceBetweenComplex(rPart, expectedRecieve);

                            %% TODO 移出去
                        else
                            % 计算output与收到的信号之间的distance得到并更新error和route
                            r_index = i;
                            rPart = r(r_index);
                            % 要求modulation为n 且只处理这种情况
                            expectedRecieveComplex = mapping(f_binaryArray2int(output) + 1);
                            distance_rPart_output = f_distanceBetweenComplex(rPart, expectedRecieveComplex);

                        end

                    end

                    if DEBUG
                        % fprintf("updated %d -> %d\n", currentStateIndex - 1, nextStateIndex - 1)
                    end

                    %  若新的路径比现有路径（没有路径就是最大值）误差小，更新
                    if distance_rPart_output + oldNodesError(currentStateIndex) < newNodesError(nextStateIndex)
                        newNodesError(nextStateIndex) = distance_rPart_output + oldNodesError(currentStateIndex); % 路径行进 error在原有的基础上增加
                        newNodesRoute(:, nextStateIndex) = oldNodesRoute(:, currentStateIndex); % 只更新对应state的
                        newNodesRoute(i, nextStateIndex) = input; % 向前走了一步
                    end

                end

            end

        end

        if DEBUG
            % disp(newNodesError)
            % disp(newNodesRoute)
        end

        oldNodesError = newNodesError;
        oldNodesRoute = newNodesRoute;

    end

    [minError, minErrorPosition] = min(newNodesError);
    decodedResult = oldNodesRoute(:, minErrorPosition);

    if DEBUG
        fprintf("解码结束")
        fprintf("解码结果: 最优解码路径的总error为%d\n", minError)
        fprintf("解码结果:\n")
        % disp(decodedResult)
    end

end
