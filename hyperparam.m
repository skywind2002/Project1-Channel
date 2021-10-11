%% hyperparameters

% crc config
crc_g = '100000111' - '0'; crc_len = 25;
% channel config
if(channel_mode == 1)
    b = 0; rho = 0; sigma = 0.1;
elseif(channel_mode == 2)
    b = 1; rho = 1; sigma = 0.1;
else
    b = .7; rho = 0.98; sigma = 0.1;
end
% module config
% P 是信号功率，r = sqrt(P)
if(exist('SNR', 'var')) % 如果定义了信噪比，则根据信噪比计算应当使用的功率 P
    if(beta_corr_mode == 3) % 已知 beta 时
        P = SNR * sigma^2 / (1 - b^2 + b^2 * sigma^2);
    else % 未知 beta 时
        P = SNR * sigma^2 / (1 - b^2 - b^2 * sigma^2 * SNR);
    end
else
    P = 1; 
end

%% coding parameters
if (conv_mode == 2)
    n = 2; k = 1; m = 4;
    A = permute([1 1 0 1; 1 1 1 1], [3, 1, 2]); % size = [k, n, m]
elseif (conv_mode == 3)
    n = 3; k = 1; m = 4;
    A = permute([1 0 1 1; 1 1 0 1; 1 1 1 1], [3, 1, 2]); % size = [k, n, m]
end

%% modulation parameters
% 生成调制步骤的星座图，对应modulation=1/2/3，我们采用BPSK，QPSK和8-PSK调制
if (modulation_mode == 1)
    N = 1;
    Gray_code = [0 1];
    mapping = sqrt(P) * exp(1j * pi * Gray_code);
elseif (modulation_mode == 2)
    N = 2;
    Gray_code = [0 1 3 2];
    mapping = sqrt(P) * exp(1j * pi * (Gray_code + .5) / 2);
elseif (modulation_mode == 3)
    N = 3;
    Gray_code = [0 1 3 2 7 6 4 5];
    mapping = sqrt(P) * exp(1j * pi * Gray_code / 4);
end
