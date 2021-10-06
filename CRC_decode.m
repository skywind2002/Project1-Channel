%% 本函数对信息流 y 分段后分别进行 CRC 解码（去冗余）并拼接。如果发现错
% 误，则将该段进行纠错/清零/丢弃。（现在用的是纠错，如果要用后两者请手动改代
% 码取消注释）
function [x, err, e] = CRC_decode(y, n, g, p)
% y - 行向量，待解码信息流
% n - 分组长度
% g - 生成多项式，长度为 m+1
% p - 有限域中符号数，默认为 2
% x - 行向量，解码后信息流，已去除冗余。
% err - 列向量，指示各个分组是否出现错误。
% e - 行向量，错误图案。如果对错误分段清零/丢弃，则得不到错误图案 e。
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
[tmp, err, e] = CRC_correct_error(y, n, g, p); % 纠错
tmp = reshape(tmp, n, [])';

% err = CRC_detect_error(y, n, g, p);
% tmp = ~err' .* y; % 清零
% e = [];

% err = CRC_detect_error(y, n, g, p);
% tmp = y(~err, :); % 丢弃
% e = [];

m = length(g) - 1;
x = tmp(:, 1:end-m);
x = reshape(x', 1, []); % 转换为行向量