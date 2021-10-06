clear,close,clc;

n = 2; k = 1; m = 3;
A = cat(3, [1 1], [0 1], [1 1]); % A_2 ~ A_0的拼接 A2=[1 1] A1=[0 1] A0=[1 1]
r = [1 1 0 1 1 0 1 1 0 0];

[decodedResult, minError] = viterbi_decode(n, k, m, A, r) % 应该得到 11000 2 这里译码结果为收尾的情况 去掉最后两个0 得到 110
