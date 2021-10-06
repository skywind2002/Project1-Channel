%% MODULATION
% x: input 01 array
% N: 1(mapping_2) or 2(mapping_4) or 3(mapping_8)
% mapping: mapping_2 or mapping_4 or mapping_8
function y = transmitter(x, N, mapping)
    x = [x, zeros(1, mod(-length(x), N))];
    y = mapping(bin2dec(char(reshape(x, N, [])' + '0'))' + 1);
end