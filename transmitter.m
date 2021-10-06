%% notes
% message: input 01 array
% modulation: modulation mode(1,2,3)
% r: modulation radius
% (n, k, m), A: conv parameters
% len : CRC poly length
%% message conv code utlization
% message self implemetation (add head/tail,add CRC?)
function [y, n, k, m, A] = transmitter(x, modulation, r, n, k, m, A)

    %% CONV
    y = conv_encoding(n, k, m, A, x);

    %% MODULATION
    % message constellation mapping (PSK modulation)
    % easy to change to QAM modulation
    if (modulation == 1) %BPSK
        mapping_2 = [-r, r];
        y = mapping_2(x + 1);
    elseif (modulation == 2) %QPSK
        mapping_4 = r * exp(1j * pi * [1 3 7 5] / 4); %Gray code constraint
        x = [x, zeros(1, mod(-length(x), 2))];
        y = mapping_4(bin2dec(char(reshape(x, 2, [])' + '0'))' + 1);
    elseif (modulation == 3)
        mapping_8 = r * exp(1j * pi * [0 1 3 2 7 6 4 5] / 4);
        x = [x, zeros(1, mod(-length(x), 3))];
        y = mapping_8(bin2dec(char(reshape(x, 3, [])' + '0'))' + 1);
    end
end