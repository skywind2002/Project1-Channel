%main program,run this to get full result
clear all;
clc;

%% hyperparameters
len = 12000;
modulation = 3; %modulation mod:1,2,3
r = 1; %modulation radius
b = 0.7; rho = 0.98; sigma = 0.1; %channel parameters;
b = 0; rho = 1; sigma = 0.1;
%conv = 3; %conv code mod:2,3
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

%% bitstream generation
raw_message = double(rand(1, len) > 0.5); %generater 01 bit stream

%% system simulation
if (crc_ENB)
    message = CRC_encode(raw_message, crc_len, crc_g);
end

x = transmitter(message, modulation, r, n, k, m, A);

[y, beta] = channel_trans(x, b, rho, sigma);

if (any(beta_corr_mode == [1, 2])) % correct y with known beta
    y = beta_correct(y, b, beta);
end
if (Viterbi_mode == 0) % 硬 Viterbi 译码
    Gray_code = [0 1 3 2 6 7 5 4];
    y2 = reshape(dec2bin(Gray_code(mod(round(mod(angle(y) / pi, 2) * 4), 8) + 1), 3)' - '0', 1, []);
    z = viterbi_decode(n, k, m, A, y2)';
else % 软 Viterbi 译码

end

e = CRC_detect_error(z, crc_len+length(crc_g)-1, crc_g);

%% data statistis
scatterplot(y(1:end - 1));
