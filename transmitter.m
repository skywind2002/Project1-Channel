function [y]=transmitter(message,modulation,r,conv,len,crc_ENB)
%% notes
%message: input 01 array
%modulation: modulation mode(1,2,3)
%r: modulation radius
%conv: conv code mode(2,3)
%len : CRC poly length
%% message conv code utlization
%message self implemetation (add head/tail,add CRC?)


if crc_ENB==1
    message=CRC(message,len);
end

len=length(message);
x=[];
input=[[0,0,0],message];  %set all states to 0

for i=1:len
    if (conv==2)
        x_1=input(i)+input(i+2)+input(i+3);   % the poly of conv codes is needed
        x_2=input(i)+input(i+1)+input(i+2)+input(i+3);
        x=[x,x_1,x_2];  %coefficient (15,17)
    elseif (conv==3)
        x_1=input(i)+input(i+1)+input(i+3);
        x_2=input(i)+input(i+2)+input(i+3);
        x_3=input(i)+input(i+1)+input(i+2)+input(i+3); %coefficient (13,15,17)
        x=[x,x_1,x_2,x_3];
    end
end

x=mod(x,2);
%output array x
%% message constellation mapping (PSK modulation)
% easy to change to QAM modulation
mapping_2=[-r,r];
mapping_4=[r*exp(1j*pi/4),r*exp(1j*pi*3/4),r*exp(1j*pi*7/4),r*exp(1j*pi*5/4)]; %Gray code constraint
mapping_8=[r*exp(1j*pi*0/4),r*exp(1j*pi*1/4),r*exp(1j*pi*3/4),r*exp(1j*pi*2/4),r*exp(1j*pi*7/4),r*exp(1j*pi*6/4),r*exp(1j*pi*4/4),r*exp(1j*pi*5/4)];
len=length(x);
y=[];

if (modulation==1)  %BPSK
    for i=1:len
        y=[y,mapping_2(x(i)+1)];
    end
elseif (modulation==2) %QPSK
    if (mod(modulation,2)==1)
        x=[x,0];
        len=len+1;
    end
    for m=1:len/2
        y=[y,mapping_4((x(2*i)-1)*2+x(2*i)+1)];
    end
elseif (modulation==3)
    if (mod(modulation,3)==1)
        x=[x,0,0];
        len=len+2;
    elseif (mod(modulation,3)==2)
        x=[x,0];
        len=len+1;
    end
    for i=1:len/3
        y=[y,mapping_8(x(3*i-2)*4+x(3*i-1)*2+x(3*i)+1)];
    end
end

end