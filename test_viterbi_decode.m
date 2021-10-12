n = 2; k = 1; m = 3;
A = cat(3, [1 1], [0 1], [1 1]); % A_2 ~ A_0的拼接 A2=[1 1] A1=[0 1] A0=[1 1]
c = [1 1 0 0 0 1 0 1 0 1];
% r = [1 1 0 1 1 0 1 1 0 0];
r = conv_encoding(n, k, m, A, c, 2)
e = rand(size(r)) < 0.1
r = r + e;
decode2 = viterbi_decode2(n, k, m, A, r, 2)