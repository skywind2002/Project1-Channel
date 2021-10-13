% 判断复数 z 与调制前行向量 y 的距离
function d = soft_distance(z, y, mapping, p)
    b = base2dec(char(y + '0'), p) + 1;
    m = mapping(b).';
    dis = log(abs(m - z) + 1);
    d = sum(dis, 2);
end