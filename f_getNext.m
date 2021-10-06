%% 计算 (n,k,m) 卷积码的下一个状态和输出
% m - 延时拍数加1。不延时值为1
% A - 卷积码参数。A(k,n,m)
% currentState - 长度为 (m-1)k 的行向量 (一种状态长度为k 有m-1种之前的状态)
% nextState - 长度为 (m-1)k 的行向量 (计算下一次状态)
% input - 长度为 k 的行向量 (需要和当前状态拼接得到完整状态)
% output - 长度为 n 的行向量
function [nextState, output] = f_getNextState(n, k, m, A, currentState, input)
    assert(all(size(input) == [1, k]), "input 应为长度为 k 的行向量")
    assert(all(size(A) == [k, n, m]), "size(A) 应为[k,n,m]")

    fullState = [currentState, input]; % 长度为 m*k 的行向量 最新加入的状态在最右边 这是课件上的状态转换方法
    nextState = fullState((k + 1):(m * k)); % 长度为 (m-1)*k 的行向量

    output = zeros(1, n);

    % A作用于x求和
    for i = 1:m
        output = output + fullState(i) * A(:, :, i); % 1*k k*n
        output = mod(output, 2);
    end

end
