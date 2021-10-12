%% bitstream generation
raw_message = double(rand(1, len) > 0.5); % generater 01 bit stream

if DEBUG
    fprintf("【随机生成原信息】length(raw_message)=%d\n", length(raw_message))
    % disp(raw_message)
end

%% system simulation

% transmitter
% CRC
CRC_message = CRC(raw_message, crc_len, crc_g, crc_ENB);

if DEBUG && crc_ENB == 1
    fprintf("【CRC添加冗余校验】每%d为一组 共%d组 ", crc_len, length(raw_message) / crc_len)
    fprintf("每组在后面加%dbit的校验位 ", length(crc_g) - 1)
    fprintf("length(CRC_message)=%d\n", length(CRC_message))
    % disp(CRC_message)
else
    fprintf("【未使用CRC】\n")
end

% CONV
conv_message = conv_encoding(n, k, m, A, CRC_message); % 增加了 (m-1) 个收尾零 % TODO: 是否还需要考虑不收尾的情况

if DEBUG
    fprintf("【(%d,%d,%d)卷积编码】每%dbit映射为%dbit的符号 收尾补%d个零 ", n, k, m, k, n, (m - 1) * n)
    fprintf("length(conv_message)=%d\n", length(conv_message))
    % disp(conv_message)
end

% MODULATION
modul_symbol = transmitter(conv_message, N, mapping);

if DEBUG
    fprintf("【调制】模式modulation=%d 即%d个散点图在复平面分布 P=%.2f length(modul_symbol) = %d\n", modulation_mode, length(Gray_code), P, length(modul_symbol))
    % disp(modul_symbol)

    if(~exist('SNR', 'var'))
        if(beta_corr_mode == 3)
            SNR = (1 - b^2) * P / sigma^2 + b^2 * P;
        else
            SNR = (1 - b^2) * P / (b^2 * sigma^2 * P + sigma^2);
        end
    end
    fprintf("【信道传输】b=%.2f rho=%.2f sigma=%.2f SNR = %.2fdB\n", b, rho, sigma, 20*log10(SNR))
end

% channel
[receive_symbol, beta] = channel_trans(modul_symbol, b, rho, sigma);

if DEBUG
    fprintf("【接收序列】length(receive_symbol)=%d\n", length(receive_symbol))
    % disp(receive_symbol)
end

% receiver
% correct received symbol with known beta
corr_symbol = beta_correct(receive_symbol, b, beta, beta_corr_mode);

if DEBUG
    fprintf("【通过已知信息对接收序列作修正】模式beta_corr_mode=%d length(corr_symbol)=%d\n", beta_corr_mode, length(corr_symbol))
    % disp(corr_symbol)
end

% decode with Viterbi
if (Viterbi_mode == 0) % hard Viterbi decode
    [~, I] = sort(Gray_code);
    anti_Gray_code = I - 1; % Gray_code 以码字为下标获得相位，而 anti_Gray_code 以相位为下标获得相应的码字。
    phase = round((angle(corr_symbol) / pi * 2^N - mod(N - 1, 2)) / 2); % 离散化的相位
    receive_message = reshape(dec2bin(anti_Gray_code(mod(phase, 2^N) + 1), N)' - '0', 1, []); % 这里与sqrt(P)没关系是因为仅通过相位进行判断

    decode_message = viterbi_decode2(n, k, m, A, receive_message, 2);
    %decode_message = viterbi_decode(n, k, m, A, receive_message)';

    if DEBUG
        % disp(receive_message)
        fprintf("【Hard Viterbi】格雷码反映射: 得到长度为%d的01序列\n length(decode_message)=%d\n", length(receive_message), length(decode_message))
    end

else % 软 Viterbi 译码
    % TODO

    % (2,1,4) conv=2 N=1(mapping_2 -1/1)
    % (3,1,4) conv=3 N=1(mapping_2 -1/1)

    decode_message = viterbi_decode(n, k, m, A, corr_symbol, Viterbi_mode, modulation_mode, P)';

    % (2,1,4) conv=2 N=2(mapping_4)
    % (3,1,4) conv=3 N=3(mapping_8)

    if DEBUG
        fprintf("【Soft Viterbi】length(decode_message)=%d\n", length(decode_message))
    end

end

decode_message = decode_message(1:end - m + 1); %decode message去尾

if DEBUG
    fprintf("【去尾零】length(decode_message)=%d\n", length(decode_message))
end