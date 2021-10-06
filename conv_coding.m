%% 对 x 计算以 A 为参数的 (n, k, m) 卷积码。A 是 m*k*n 矩阵，x 是行向量，表示待编码码流。
% 注：如果有 m 个 n*k 的矩阵 A1, A2, ..., Am，如 m = 5，则可以调用
% A = permute(cat(3, A1, A2, A3, A4, A5), [3, 1, 2]);
% 得到这里的参数 A。
function y = conv_coding(n, k, m, A, x, p)
if(nargin == 5) 
    p = 2;
end
assert(size(x, 1)==1, "x 应为行向量！")
assert(all(size(A)==[m, k, n]), "A 应为 m*k*n 矩阵！")
A = reshape(A, m*k, n); % 化为 m*k 行 n 列矩阵方便后续计算
x = [zeros(1, m-1), x]; % 前面补零，从零状态开始
x = [x, zeros(1, mod(-length(x), k))]; % 后面补零，使得 x 长度为 k 的整数倍
y = [];
for t = m:size(x, 1)/k
    y = [y, mod(x((t-m)*k+1:t*k) * A, p)];
end