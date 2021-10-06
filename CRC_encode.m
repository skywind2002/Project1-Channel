%% 本函数对信息流 x 分段后分别进行 CRC 编码并拼接。
function y = CRC_encode(x, k, g, p)
    % x - 行向量，待编码信息流
    % k - 分组长度
    % g - 生成多项式，长度为 m+1
    % p - 有限域中符号数，默认为 2
    % y - 行向量，编码后信息流。长度为 (m+k) * ceil(length(x)/k)
    % 作者：于子涵
    % 更新：2021/10/3

    % == 数据验证与预处理 ==
    if (nargin == 3)
        p = 2;
    end

    if (isempty(k))
        k = length(x);
    end

    tmp = find(g);

    if (tmp > 1)
        warning("g 的前导零已被删除")
        g = g(tmp:end);
    end

    tmp = mod(length(x), k);

    if (tmp)
        warning("length(x) 不是 k 的整数倍，已在结尾补零")
        x = [x, zeros(1, k - tmp)];
    end

    % == 计算 ==
    x = reshape(x, k, [])';
    m = length(g) - 1;
    xm = mod([-x, zeros(size(x, 1), m)], p);
    [~, s] = GFp_deconv(xm, g, p);
    y = [x, s];
    y = reshape(y', 1, []); % 转换为行向量
end