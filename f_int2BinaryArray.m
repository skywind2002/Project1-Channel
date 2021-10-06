function result = f_int2BinaryArray(input, len)
    result = zeros(1, len);

    a = input;

    for i = 1:len
        result(i) = floor(a / 2^(len - i));
        a = mod(a, 2^(len - i));
    end

end
