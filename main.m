%main program,run this to get full result
clear all;
clc;

%% hyperparameters
len = 12000;
modulation = 3; %modulation mod:1,2,3
r = 1; %modulation radius
%b = 0.7; rho = 0.98; sigma = 0.1; %channel parameters;
b = 0; rho = 1; sigma = 0.1;
conv = 3; %conv code mod:2,3
crc_g = '100000111' - '0';
crc_len = 200; %CRC poly length
crc_ENB = 1; %if or not to enable CRC check: 1 enable;0 disable
beta_corr_mode = 0; % 1,2: known beta, 3: unknown beta
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
if(modulation == 1)
    N = 1;
    Gray_code = [0 1];
    mapping = r * exp(1j * pi * Gray_code);
elseif(modulation == 2)
    N = 2;
    Gray_code = [0 1 3 2];
    mapping = r * exp(1j * pi * (Gray_code + .5) / 2);
elseif(modulation == 3)
    N = 3;
    Gray_code = [0 1 3 2 7 6 4 5];
    mapping = r * exp(1j * pi * Gray_code / 4);
end

%% bitstream generation
raw_message = double(rand(1, len) > 0.5); %generater 01 bit stream

%% system simulation

% transmitter
% CRC
CRC_message = CRC(raw_message, crc_len, crc_g, crc_ENB);
% CONV
conv_message = conv_encoding(n, k, m, A, CRC_message);
% MODULATION
modul_symbol = transmitter(conv_message, N, mapping);

% channel
[receive_symbol, beta] = channel_trans(modul_symbol, b, rho, sigma);

% receiver
% correct received symbol with known beta
corr_symbol = beta_correct(receive_symbol, b, beta, beta_corr_mode);
% decode with Viterbi
if (Viterbi_mode == 0) % hard Viterbi decode
    [~, I] = sort(Gray_code);
    anti_Gray_code = I - 1; % Gray_code 以码字为下标获得相位，而 anti_Gray_code 以相位为下标获得相应的码字。
    phase = round((angle(corr_symbol) / pi * 2^N - mod(N - 1, 2)) / 2); % 离散化的相位
    receive_message = reshape(dec2bin(anti_Gray_code(mod(phase, 2^N) + 1), N)' - '0', 1, []);
    decode_message = viterbi_decode(n, k, m, A, receive_message)';
else % 软 Viterbi 译码
    
end

err = CRC_detect_error(decode_message, crc_len + length(crc_g) - 1, crc_g);

%% data statistis
figure; scatterplot(corr_symbol(1:end - 1));
figure; stem(err);