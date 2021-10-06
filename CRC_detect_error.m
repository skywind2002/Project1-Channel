%% 本函数对信息流 y 分段后分别进行 CRC 检错，并给出一个布尔向量表示各段
% 的检错结果。
function err = CRC_detect_error(y, n, g, p)
% y - 行向量，待检错信息流
% n - 分组长度
% g - 生成多项式，长度为 m+1
% p - 有限域中符号数，默认为 2
% err - 列向量，指示各组是否发生错误。长度为 ceil(length(y)/k)
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
[~, s] = GFp_deconv(y, g, p);
err = any(s, 2);