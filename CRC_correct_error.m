%% 本函数对信息流 y 分段后分别进行 CRC 纠错，并给出一个布尔向量表示各段
% 的检错结果。
% 注：写的时候发现没有高效算法，而且课件里也没要求 CRC 纠错，所以就保留了低
% 效的算法。该算法在 n 很大时将无法运行。
function [z, err, e] = CRC_correct_error(y, n, g, p)
% y - 行向量，待纠错信息流
% k - 分组长度
% g - 生成多项式，长度为 m+1
% p - 有限域中符号数，默认为 2
% z - 行向量，纠错后的信息流
% err - 列向量，各个分组是否出现错误
% e - 行向量，错误图案
% 作者：于子涵
% 更新：2021/10/3

% == 数据验证与预处理 ==
if(nargin == 3) 
    p = 2; 
end
if(isempty(n))
    n = length(y);
end
tmp = find(g);
if(tmp > 1)
    warning("g 的前导零已被删除")
    g = g(tmp:end);
end
tmp = mod(length(y), n);
if(tmp)
    warning("length(y) 不是 n 的整数倍，已在结尾补零")
    y = [y, zeros(1, n-tmp)];
end

% == 计算 ==
y = reshape(y, n, [])';
corr_lst = get_CRC_decode_list(n, g, p); % 生成纠错码表
[~, s] = GFp_deconv(y, g, p);
t = base2dec(s+'0', p);
err = t > 0;
e = zeros(size(y));
e(err, :) = corr_lst(t(err), :); % 错误图案
z = mod(y - e, p);
e = reshape(e', 1, []); % 转换为行向量
z = reshape(z', 1, []); % 转换为行向量