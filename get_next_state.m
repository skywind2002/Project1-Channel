%% 计算 (n,k,m) 卷积码的下一个状态和输出
% m - 延时拍数加1。不延时值为1
% A - 卷积码参数。A(k,n,m)
% currentState - 长度为 (m-1)k 的行向量 (一种状态长度为k 有m-1种之前的状态)
% nextState - 长度为 (m-1)k 的行向量 (计算下一次状态)
% input - 长度为 k 的行向量 (需要和当前状态拼接得到完整状态)
% output - 长度为 n 的行向量
function [nextState, output] = get_next_state(n, k, m, A, currentState, input)
    fullState = [currentState, repmat(input, size(currentState, 1), 1)]; % 长度为 m*k 的行向量 最新加入的状态在最右边 这是课件上的状态转换方法
    nextState = fullState(:, (k + 1):(m * k)); % 长度为 (m-1)*k 的行向量

    % 用静态变量避免大量重复计算
    persistent static_A;
    if(isempty(static_A))
        static_A = reshape(permute(A, [3, 1, 2]), m * k, n);
    end
    output = mod(fullState * static_A, 2);
end

