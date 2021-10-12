%main program,run this to get full result
clear all; close all; clc;

SNR = logspace(-1, 2, 10);
BER = zeros(size(SNR));
BLER = zeros(size(SNR));

hyperparam; % load parameters
DEBUG = 0;
beta_corr_mode = 1;

%% bitstream generation
raw_message = double(rand(1, len) > 0.5); % generater 01 bit stream

if DEBUG
    fprintf("随机生成原信息: length(raw_message) = %d\n", length(raw_message))
    % disp(raw_message)
end

%% system simulation

% transmitter
% CRC
CRC_message = CRC(raw_message, crc_len, crc_g, crc_ENB);

if DEBUG && crc_ENB == 1
    fprintf("CRC编码添加冗余校验码：每%d为一组 共%d组 ", crc_len, length(raw_message) / crc_len)
    fprintf("每组在后面加%dbit的校验位 ", length(crc_g) - 1)
    fprintf("length(CRC_message) = %d\n", length(CRC_message))
    % disp(CRC_message)
else
    fprintf("未使用CRC\n")
end

% CONV
conv_message = conv_encoding(n, k, m, A, CRC_message, 1); % 增加了 (m-1) 个收尾零 % TODO: 是否还需要考虑不收尾的情况

if DEBUG
    fprintf("(%d,%d,%d)卷积编码: 每%dbit映射为%dbit的符号 收尾补%d个零 ", n, k, m, k, n, (m - 1) * n)
    fprintf("length(conv_message) = %d\n", length(conv_message))
    % disp(conv_message)
end

% MODULATION
modul_symbol = transmitter(conv_message, N, mapping);

if DEBUG
    fprintf("调制模式: modulation = %d 即%d个散点图在复平面分布 length(modul_symbol) = %d\n", modulation, length(Gray_code), length(modul_symbol))
    % disp(modul_symbol)
    subplot(1, 3, 1)
    scatter(real(modul_symbol), imag(modul_symbol)); title("moduled symbol"); axis equal; ylim([-2, 2]); xlim([-2, 2]);
end

for t=1:length(SNR)
    if(beta_corr_mode == 3) % 两种情形下信噪比的公式不一样。
        sigma = sqrt((1 - b^2) * P ./ (1 + P * b^2) ./ SNR(t));
    else
        sigma = sqrt((1 - b^2) * P ./ (SNR(t) - b^2 * P));
    end
    fprintf("信干噪比：%f dB，噪声功率：sigma = %f\n", 20*log10(SNR(t)), sigma)
    % channel
    [receive_symbol, beta] = channel_trans(modul_symbol, b, rho, sigma);

    if DEBUG
        fprintf("接收到通过信道的序列: length(receive_symbol) = %d\n", length(receive_symbol))
        % disp(receive_symbol)
        subplot(1, 3, 2)
        scatter(real(receive_symbol), imag(receive_symbol)); title("received symbol"); axis equal; ylim([-2, 2]); xlim([-2, 2]);
    end

    % receiver
    % correct received symbol with known beta
    corr_symbol = beta_correct(receive_symbol, b, beta, beta_corr_mode);

    if DEBUG
        fprintf("通过对信道已知的信息对收到的序列进行修正: 模式beta_corr_mode %d length(corr_symbol) = %d\n", beta_corr_mode, length(corr_symbol))
        % disp(corr_symbol)
        subplot(1, 3, 3)
        scatter(real(corr_symbol), imag(corr_symbol)); title("beta corrected symbol"); axis equal; ylim([-2, 2]); xlim([-2, 2]);
    end

    % decode with Viterbi
    if (Viterbi_mode == 0) % hard Viterbi decode
        [~, I] = sort(Gray_code);
        anti_Gray_code = I - 1; % Gray_code 以码字为下标获得相位，而 anti_Gray_code 以相位为下标获得相应的码字。
        phase = round((angle(corr_symbol) / pi * 2^N - mod(N - 1, 2)) / 2); % 离散化的相位
        receive_message = reshape(dec2bin(anti_Gray_code(mod(phase, 2^N) + 1), N)' - '0', 1, []);

        if DEBUG
            fprintf("格雷码反映射: 得到长度为%d的01序列\n", length(receive_message))
            % disp(receive_message)
        end

        decode_message = viterbi_decode(n, k, m, A, receive_message)';
    else % 软 Viterbi 译码
        % TODO

        % (2,1,4) conv=2 N=1(mapping_2 -1/1)
        % (3,1,4) conv=3 N=1(mapping_2 -1/1)

        % (2,1,4) conv=2 N=2(mapping_4)
        % (3,1,4) conv=3 N=3(mapping_8)
    end

    decode_message = decode_message(1:end - m + 1); %decode message去尾

    if DEBUG
        fprintf("Viterbi解码并去尾: length(decode_message) = %d\n", length(decode_message))
    end

    % data analysis

    BE = decode_message ~= CRC_message; % 传输的错误矩阵
    BER(t) = sum(BE) / length(BE);
    fprintf("传输的总误比特率: %f\n", BER(t))

    if crc_ENB == 1
        BLE = CRC_detect_error(decode_message, crc_len + length(crc_g) - 1, crc_g); % 传输后经过CRC检错
        BLER(t) = sum(BLE) / length(BLE);
        fprintf("CRC检查得到的误块率: %f (%dbit/块)\n", BLER(t), crc_len)
    end
end

semilogy(20*log10(SNR), BER, "b-*", LineWidth=2)
title("误比特率和信干噪比的关系")
xlabel("信干噪比SNR/dB")
ylabel("误比特率BER")
grid