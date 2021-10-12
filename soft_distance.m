% 判断复数 z 来自于调制前行向量 y 的概率
function probability = soft_distance(z, y, mapping, p)
    b = base2dec(char(y + '0'), p) + 1;
    m = mapping(b)';
    d = abs(m - z);
    probability = prod(exp(-d), 2);
end