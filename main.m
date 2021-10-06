%main program,run this to get full result
clear all;
clc;

%% hyperparameters
len=12000;
modulation=3;  %modulation mod:1,2,3
r=1;  %modulation radius
b=0.7; rho=0.98; sigma=0.1; %channel parameters;
conv=3; %conv code mod:2,3
crc_len=5; %CRC poly length
crc_ENB=1;  %if or not to enable CRC check: 1 enable;0 disable

%% bitstream generation
message=rand(1,len);
message=double(message>0.5);  %generater 01 bit stream

%% system simulation
x=transmitter(message,modulation,r,conv,crc_len,crc_ENB);
[y,beta]=channel_trans(x,b,rho,sigma);

%y=beta_correct(y,b,beta);

scatterplot(y(1:end-1));
%x_decode=receiver(y);  % viterbi decoding(to be completed)

