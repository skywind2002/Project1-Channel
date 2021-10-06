function [crc]=CRC(x0,len)
g=[1 0 0 1 1];   %CRC polynomial
crc=[];
rest=mod(length(x0),len);

if rest~=0
    x0=[x0,zeros(1,len-rest)];
end

for m=1:length(x0)/len
    sub=x0((m-1)*len+1:m*len);  %get d(x)
    sub_temp=[sub,zeros(1,length(g)-1)];  %shift get d(x)*x^m
    for n=1:length(sub)
        if sub_temp(n)
            sub_temp(n:n+length(g)-1)=xor(sub_temp(n:n+length(g)-1),g);  %do mod
        end
    end
    r=sub_temp(end-length(g)+2:end);
    c=[sub,r];
    crc=[crc,c];
end
end