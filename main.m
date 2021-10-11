%main program,run this to get full result
clear all; close all; clc;

% config
DEBUG = 1;
len = 10000; % message length
crc_ENB = 0; % 0: not use CRC, 1: use CRC
conv_mode = 3; % 2: (2, 1, 4), 3: (3, 1, 4)
channel_mode = 3; % 1: b = 0, 2: b = rho = 1, 3: b = 0.7, rho = 0.98
beta_corr_mode = 3; % 1,2: known beta, 3: unknown beta
modulation_mode = 3; % 1: mapping-2, 2: mapping-4, 3: mapping-8
Viterbi_mode = 1; % 0: Hard Vierbi, 1: Soft Viterbi
hyperparam; % load parameters
simulate; % simulate

% data analysis
fprintf("【结果分析】\n")

BE = decode_message ~= CRC_message; % 传输的错误矩阵
BER = sum(BE) / length(BE);
fprintf("传输的总误比特率: %f\n", BER)

if crc_ENB == 1
    BLE = CRC_detect_error(decode_message, crc_len + length(crc_g) - 1, crc_g); % 传输后经过CRC检错
    BLER = sum(BLE) / length(BLE);
    fprintf("CRC检查得到的误块率: %.4f (%dbit/块)\n", BLER, crc_len)
end
