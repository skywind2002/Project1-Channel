function result = f_binaryArray2int(input)
    result = 0;
    for i=1:length(input)
        result = result  + input(i) * 2^(length(input) - i);
    end
    return 
end