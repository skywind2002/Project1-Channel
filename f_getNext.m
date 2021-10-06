% 计算一个卷积码的下一个状态和输出
% (n,k,m)卷积码 m为延时拍数加1 不延时值为1
% A 卷积码参数 A_m-1~A_0 单个是k行n列
% currentState nextState 为(m-1)位 2^(m-1)种
% input 位数等于k k为1时 input为0/1

function [nextState, output] = f_getNext(n, k, m, A, currentState, input)
    % 目前默认k=1
    fullState = [currentState, input];
    nextState = fullState(2:m);
    output = zeros(1, n);

    for i = 1:m
        A_index = (1:n) + (i - 1) * n; % 要加括号 不然不知道什么问题
        output = output + fullState(i) * A(A_index);
        output = mod(output, 2);
    end

end
