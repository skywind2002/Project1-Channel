% 判断行向量 a 变成行向量 b 的概率
function p = distance(a, b)
    p = 0.1 .^ sum(a ~= b, 2);
end