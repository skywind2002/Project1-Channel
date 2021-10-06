clear,close,clc;

n = 2; k = 1; m = 3;
A = cat(3, [1 1], [0 1], [1 1]); % A_2 ~ A_0的拼接 A2=[1 1] A1=[0 1] A0=[1 1]

% 课件上的例子 收尾与不收尾
x = [1 1 0];
y = conv_encoding(n, k, m, A, x) % 应该是 11 10 10
x = [1 1 0 0 0]; % 收尾
y = conv_encoding(n, k, m, A, x) % 应该是 11 10 10 11 00