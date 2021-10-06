% 计算两个BinaryArray之间的距离
function d = f_distanceBetweenBinaryArray(a, b)
    d = sum(a ~= b);
    return
end

% eg.
% a = [1 1 1 0]; b = [0 0 1 1]; d = f_distanceBetweenBinaryArray(a, b) % 3
