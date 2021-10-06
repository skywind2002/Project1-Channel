%% 计算有限域 GF(p) 上的多项式除法
% 此函数类似于 deconv，但是是在有限域 GF(p) 上进行的。最终返回商 q 和余数 r，
% 使得 u=GFp_deconv(v,q)+r。
function [q, r] = GFp_deconv(u, v, p)
% u,v - 输入行向量，最大权重位在最前面。
% u 可以有多行，返回用多行分别运算后拼成的矩阵。
% p - 域中元素的个数，默认为 2。
% q,r - 输出行向量，最大权重位在最前面。
% 若 u 有多行，则 q,r 也有相同的行数。
% 作者：于子涵
% 更新：2021/10/3
if(nargin == 2)
    p = 2;
end
if(any(~ismember([u(:);v(:)], 0:p-1)))
    warning("u/v 的元素不在 GF(p) 中")
end
if(~isprime(p))
    warning("p不是素数，v(1) 可能不存在乘法逆")
end
assert(size(v,1)==1, "v应为行向量")
tmp = find(v);
if(tmp > 1)
    warning("v 的前导零已被删除")
    v = v(tmp:end);
end

vinv = 0;
for k = 1:p-1
    if(mod(v(1)*k, p)==1)
        vinv = k; % 计算 ax==1(mod p) 的解 x，其中 a=v(1)。
        break;
    end
end
assert(vinv > 0, "v(1) 不存在乘法逆")

vlen = size(v, 2);
ulen = size(u, 2);
q = zeros(size(u, 1), ulen - vlen + 1);
for t = 1:ulen-vlen+1
    q(:, t) = mod(vinv*u(:, t), p);
    u(:, t:t+vlen-1) = mod(u(:, t:t+vlen-1)-mod(v.*q(:, t), p), p);
end
r = u(:, ulen-vlen+2:ulen);