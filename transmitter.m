function [y]=transmitter(message,modulation,r,conv,len,crc_ENB)
%% notes
%message: input 01 array
%modulation: modulation mode(1,2,3)
%r: modulation radius
%conv: conv code mode(2,3)
%len : CRC poly length
%% message conv code utlization
%message self implemetation (add head/tail,add CRC?)

if(crc_ENB==1)
    message=CRC(message,len);
end

if(conv == 2)
    A = [1 1 0 1; 1 1 1 1]; % size = [n, m, (k)]
    A = permute(A, [2, 3, 1]); % size = [m, k, n]
    x = conv_coding(2, 1, 4, A, message);
elseif(conv == 3)
    A = [1 0 1 1; 1 1 0 1; 1 1 1 1];
    A = permute(A, [2, 3, 1]);
    x = conv_coding(3, 1, 4, A, message);
end

%% message constellation mapping (PSK modulation)
% easy to change to QAM modulation
mapping_2=[-r,r];
mapping_4=r*exp(1j*pi*[1 3 7 5]/4); %Gray code constraint
mapping_8=r*exp(1j*pi*[0 1 3 2 7 6 4 5]/4);
if (modulation==1)  %BPSK
    y = mapping_2(x+1);
elseif (modulation==2) %QPSK
    x = [x, zeros(1, mod(-length(x), 2))];
    y = mapping_4(bin2dec(char(reshape(x, 2, [])'+'0'))'+1);
elseif (modulation==3)
    x = [x, zeros(1, mod(-length(x), 3))];
    y = mapping_8(bin2dec(char(reshape(x, 3, [])'+'0'))'+1);
end

end