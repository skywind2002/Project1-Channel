function crc = CRC(x, len, g, ENB)
    if(ENB)
        crc = CRC_encode(x, len, g);
    else
        crc = x;
    end
end
