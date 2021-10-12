% 判断行向量 a 原来其实是行向量 b 的概率
function p = hard_distance(a, b, p)
    d = mod(a - b, p);
    p = 0.1 .^ sum(d, 2);
end