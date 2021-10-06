%% notes
%message: input 01 array
%modulation: modulation mode(1,2,3)
%r: modulation radius
% (n, k, m), A: conv parameters
%len : CRC poly length
%% message conv code utlization
%message self implemetation (add head/tail,add CRC?)
function [y, n, k, m, A] = transmitter(x, modulation, r, n, k, m, A)

%% CONV
x = [zeros(1, m-1), x]; % 前面补零，从零状态开始
x = [x, zeros(1, mod(-length(x), k))]; % 后面补零，使得 x 长度为 k 的整数倍
A = reshape(permute(A, [3, 1, 2]), m*k, n); % 化为 m*k 行 n 列矩阵方便后续计算
y = zeros(length(x)/k-m+1, n);
for t = m:length(x)/k
    y(t-m+1,:) = mod(double(x((t-m)*k+1:t*k)) * A, 2);
end
y = reshape(y', 1, []);

%% MODULATION
% message constellation mapping (PSK modulation)
% easy to change to QAM modulation
if (modulation == 1)  %BPSK
    mapping_2 = [-r, r];
    y = mapping_2(x + 1);
elseif (modulation == 2) %QPSK
    mapping_4 = r * exp(1j * pi * [1 3 7 5] / 4); %Gray code constraint
    x = [x, zeros(1, mod(-length(x), 2))];
    y = mapping_4(bin2dec(char(reshape(x, 2, [])'+'0'))' + 1);
elseif (modulation == 3)
    mapping_8 = r * exp(1j * pi * [0 1 3 2 7 6 4 5] / 4);
    x = [x, zeros(1, mod(-length(x), 3))];
    y = mapping_8(bin2dec(char(reshape(x, 3, [])'+'0'))' + 1);
end