clear,close,clc;

n = 2; k = 1; m = 3;
A = [1 1 0 1 1 1]; % A_2 ~ A_0的拼接 A2=[1 1] A1=[0 1] A0=[1 1]
r = [1 1 0 1 1 0 1 1 0 0];

[decodedResult, minError] = f_viterbiDecode(n, k, m, A, r)
