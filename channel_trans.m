function [y,beta]=channel_trans(x,b,rho,sigma)
%channel transmit function
x = [x,0];
len=length(x);
beta=zeros(1,len);
y=zeros(1,len);
z=normrnd(0,sqrt(0.5),[1,len])+1j*normrnd(0,sqrt(0.5),[1,len]);
n=normrnd(0,sigma/sqrt(2),[1,len])+1j*normrnd(0,sigma/sqrt(2),[1,len]);

beta(1)=normrnd(0,sqrt(0.5))+1j*normrnd(0,sqrt(0.5));
y(1)=sqrt(1-b^2)*x(1)+n(1);
for i=2:len
    beta(i)=rho*beta(i-1)+sqrt(1-rho^2)*z(i);
    y(i)=sqrt(1-b^2)*x(i)+b*beta(i)*x(i-1)+n(i);
end