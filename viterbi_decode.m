function [decodedResult, minError] = viterbi_decode(n, k, m, A, r)
    DEBUG = 0; % show message?
    r = [r, zeros(1, mod(-length(r), n))];
    decodedResult = zeros(1, length(r) / n); % 解码得到的长度为length(r)/n

    nodesState = 0:(2^(m - 1) - 1);
    errorMax = 2^14;
    oldNodesError = zeros(1, length(nodesState)) + errorMax; % 初值最大
    oldNodesError(1) = 0; % 全零的状态error是零，这样后续才能开展
    oldNodesRoute = zeros(length(r) / n, length(nodesState)) - 1; % 初值全-1（最后更新为0和1）
    StateIndex = 1:2^(m - 1);
    State = f_int2BinaryArray(0:2^(m - 1) - 1, m - 1);
    newNodesError = zeros(1, length(nodesState));
    newNodesRoute = zeros(length(r) / n, length(nodesState));
    for i = 1:(length(r) / n)
        newNodesError = 0 * newNodesError + errorMax;
        newNodesRoute = 0 * newNodesRoute - 1;
        currentStateIndexLst = StateIndex(oldNodesError ~= errorMax);
        currentStateLst = State(oldNodesError ~= errorMax, :);
        [nextStateLst0, outputLst0] = get_next_state(n, k, m, A, currentStateLst, 0);
        [nextStateLst1, outputLst1] = get_next_state(n, k, m, A, currentStateLst, 1);
        nextStateIndexLst0 = f_binaryArray2int(nextStateLst0) + 1;
        nextStateIndexLst1 = f_binaryArray2int(nextStateLst1) + 1;
        r_index = (1:n) + ((i - 1) * n);
        rPart = r(r_index);
        distance_rPart_outputLst0 = f_distanceBetweenBinaryArray(rPart, outputLst0);
        distance_rPart_outputLst1 = f_distanceBetweenBinaryArray(rPart, outputLst1);
        for t = 1:length(currentStateIndexLst)
            currentStateIndex = currentStateIndexLst(t);
            % input = 0
            nextStateIndex = nextStateIndexLst0(t);
            distance_rPart_output = distance_rPart_outputLst0(t);
            if distance_rPart_output + oldNodesError(currentStateIndex) < newNodesError(nextStateIndex)
                newNodesError(nextStateIndex) = distance_rPart_output + oldNodesError(currentStateIndex); % 路径行进 error在原有的基础上增加
                newNodesRoute(:, nextStateIndex) = oldNodesRoute(:, currentStateIndex); % 只更新对应state的
                newNodesRoute(i, nextStateIndex) = 0; % 向前走了一步
            end
            % input = 0
            nextStateIndex = nextStateIndexLst1(t);
            distance_rPart_output = distance_rPart_outputLst1(t);
            if distance_rPart_output + oldNodesError(currentStateIndex) < newNodesError(nextStateIndex)
                newNodesError(nextStateIndex) = distance_rPart_output + oldNodesError(currentStateIndex); % 路径行进 error在原有的基础上增加
                newNodesRoute(:, nextStateIndex) = oldNodesRoute(:, currentStateIndex); % 只更新对应state的
                newNodesRoute(i, nextStateIndex) = 1; % 向前走了一步
            end
        end

        oldNodesError = newNodesError;
        oldNodesRoute = newNodesRoute;

    end

    [minError, minErrorPosition] = min(newNodesError);
    decodedResult = oldNodesRoute(:, minErrorPosition);
end
