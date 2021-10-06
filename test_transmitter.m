clear,close,clc;

n = 2; k = 1; m = 3;
A = cat(3, [1 1], [0 1], [1 1]); % A_2 ~ A_0的拼接 A2=[1 1] A1=[0 1] A0=[1 1]

x = [1 1 0]; % 不收尾
binaryMessage = conv_encoding(n, k, m, A, x) % 应该是 11 10 10

modulation = 1; r = 1;
[messageBeforeTransmitted, n, k, m, A] = transmitter(binaryMessage, modulation, r, n, k, m, A);
disp(messageBeforeTransmitted)

modulation = 1; r = 2;
[messageBeforeTransmitted, n, k, m, A] = transmitter(binaryMessage, modulation, r, n, k, m, A);
disp(messageBeforeTransmitted)

modulation = 2; r = 1;
[messageBeforeTransmitted, n, k, m, A] = transmitter(binaryMessage, modulation, r, n, k, m, A);
disp(messageBeforeTransmitted)

modulation = 3; r = 1;
[messageBeforeTransmitted, n, k, m, A] = transmitter(binaryMessage, modulation, r, n, k, m, A);
disp(messageBeforeTransmitted)

