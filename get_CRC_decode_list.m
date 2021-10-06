%% 本函数生成以 g(x) 为生成多项式的 n 位循环冗余码的译码码表 corr_lst，
% 并同时得到最小自由距 d。对于校验子 s，首先 t = base2dec(s+'0', p) 转换为十
% 进制数，然后错误图案为 corr_lst(t, :)，原信号为 x = mod(y - corr_lst(s, :
% ),p)。
% ！注意：在 n 较大时，运行效率会极低。
function [corr_lst, d] = get_CRC_decode_list(n, g, p)
    % n - 含校验码的码长
    % g - 生成多项式
    % p - 有限域中元素个数，默认为 2
    % corr_lst - (p^m-1) 行 n 列矩阵，表示第 i 个矫正子对应的最轻误码图案
    % d 最小自由距
    % 作者：于子涵
    % 更新：2021/10/3

    % == 数据校验与预处理 ==
    if (nargin == 2)
        p = 2;
    end

    tmp = find(g);

    if (tmp > 1)
        warning("g 的前导零已被删除")
        g = g(tmp:end);
    end

    if (n > 10)
        warning("n 的值太大，计算时间可能会很长甚至无法计算")
    end

    % == 计算 ==
    m = length(g) - 1;
    n_lst = 1:p^n - 1; % 生成所有可能的错误图案（数字形式）
    v_lst = dec2base(n_lst, p, n) - '0'; % 所有可能的错误图案（转换为向量形式）
    [~, s] = GFp_deconv(v_lst, g); % 生成所有错误图案对应的矫正子
    s = base2dec(s + '0', p); % 将矫正子转换为 1~p^m-1 之间的十进制整数。
    weight = sum(v_lst, 2); % 计算各个错误图案的重量
    [weight, I] = sort(weight); % 将重量从小到大排列。
    s = s(I);
    corr_lst = zeros(p^m - 1, 1);
    d = inf;

    for k = 1:p^m - 1 % 遍历所有矫正子
        tmp = find(s == k, 1);
        corr_lst(k) = I(tmp);

        if (weight(tmp) < d)
            d = weight(tmp);
        end

    end

    corr_lst = dec2base(corr_lst, p, n) - '0';
end