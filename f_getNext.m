%% 计算一个卷积码的下一个状态和输出
% (n,k,m)卷积码 m为延时拍数加1 不延时值为1
% A 卷积码参数 A_m-1~A_0 单个是k行n列
% currentState nextState 为(m-1)位 2^(m-1)种
% input 位数等于k k为1时 input为0/1
function [nextState, output] = f_getNext(n, k, m, A, currentState, input)
    assert(all(size(input) == [1, k], "input 应为长度为 k 的行向量"))
    assert(all(size(A) == [m, k, n], "size(A) 应为[m, k, n]"))
    
    fullState = reshape([currentState, input], k, m)'; % m 行 k 列
    nextState = [currentState(k+1:end), input];
    
    output = zeros(1, n);
    for mm = 1:m
        output = output +fullState(mm, :) * A(mm, :, :);
end
