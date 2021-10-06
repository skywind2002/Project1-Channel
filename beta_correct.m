%% 收方利用已知的 beta 对收到的复向量 y 进行校正，得到复向量 x 作为收到
% 的信号。beta = [] 时视为不知道 beta。
function x = beta_correct(y, b, beta)
% y - 行向量，表示收到的复向量
% b - 标量，为题目中的参数
% beta - 行向量，为题目中的参数。长度与 y 相同。
% x - 行向量。长度为 length(y) 或 length(y)-1
% 作者：于子涵
% 更新：2021/10/5

if(isempty(beta))
    x = y;
elseif(b==1)
    t = y./beta;
    x = t(2:end);
else    
    x = zeros(1, length(y)-1);
    x(1) = y(1)/sqrt(1-b^2);
    for i = 2:length(x)
        x(i) = (y(i) - b*beta(i)*x(i-1))/sqrt(1-b^2);
    end 
end