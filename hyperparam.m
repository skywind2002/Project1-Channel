DEBUG = 1;

%% hyperparameters
len = 20000;
% module config
modulation = 2; r = 1;
% crc config
crc_ENB = 0; % 0 不实用CRC添加冗余
crc_g = '100000111' - '0'; crc_len = 25;
% conv config
conv = 2;
% channel config
b = 0.25; rho = 0.9; sigma = 0.1; %channel parameters;
% b = 1; rho = 1; sigma = 0.1;
% b = 0; rho = 0; sigma = 0.1;
% beta correct config
beta_corr_mode = 1; % 1,2: known beta, 3: unknown beta
% viterbi config
Viterbi_mode = 0; % 0: Hard Vierbi, 1: Soft Viterbi

%% coding parameters
if (conv == 2)
    n = 2; k = 1; m = 4;
    A = permute([1 1 0 1; 1 1 1 1], [3, 1, 2]); % size = [k, n, m]
elseif (conv == 3)
    n = 3; k = 1; m = 4;
    A = permute([1 0 1 1; 1 1 0 1; 1 1 1 1], [3, 1, 2]); % size = [k, n, m]
end

%% modulation parameters
% 生成调制步骤的星座图，对应modulation=1/2/3，我们采用BPSK，QPSK和8-PSK调制
if (modulation == 1)
    N = 1;
    Gray_code = [0 1];
    mapping = r * exp(1j * pi * Gray_code);
elseif (modulation == 2)
    N = 2;
    Gray_code = [0 1 3 2];
    mapping = r * exp(1j * pi * (Gray_code + .5) / 2);
elseif (modulation == 3)
    N = 3;
    Gray_code = [0 1 3 2 7 6 4 5];
    mapping = r * exp(1j * pi * Gray_code / 4);
end
