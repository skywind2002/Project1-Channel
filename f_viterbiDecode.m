function [decodedResult, minError] = f_viterbiDecode(n, k, m, A, r)
    DEBUG = 0; % show message?
    decodedResult = zeros(1, length(r) / n); % 解码得到的长度为length(r)/n

    % 分别统计所有状态结点的error,route和解码得到的decodedResult
    % m=3四种m=4八种: 0123 or 01234567 注意index=State数+1
    nodesState = 0:(2^(m - 1) - 1);
    errorMax = 2^14;
    % 之前的状态 相当于当前i的初值
    oldNodesError = zeros(1, length(nodesState)) + errorMax; % 初值最大
    oldNodesError(1) = 0; % 全零的状态error是零，这样后续才能开展
    oldNodesRoute = zeros(length(r) / n, length(nodesState)) - 1; % 初值全-1（最后更新为0和1）
    % 状态迭代（动态规划）
    % 对每一份收到的码字进行解码
    for i = 1:(length(r) / n)
        newNodesError = zeros(1, length(nodesState)) + errorMax; % 最开始让距离最大，逐渐减少
        newNodesRoute = zeros(length(r) / n, length(nodesState)) - 1; % 对应列记录对应状态的解码值（共8列或16列）

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
                        fprintf("enter state %d\n", s - 1)
                    end

                    % 对于一条延伸的路径 得到了新的状态和output
                    [nextState, output] = f_getNextState(n, k, m, A, currentState, input);
                    nextStateIndex = f_binaryArray2int(nextState) + 1;

                    % 计算output与收到的信号之间的distance得到并更新error和route
                    r_index = (1:n) + ((i - 1) * n);
                    rPart = r(r_index);
                    distance_rPart_output = f_distanceBetweenBinaryArray(rPart, output);

                    if DEBUG
                        fprintf("updated %d -> %d\n", currentStateIndex - 1, nextStateIndex - 1)
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
            disp(newNodesError)
            disp(newNodesRoute)
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
        disp(decodedResult)
    end

end
