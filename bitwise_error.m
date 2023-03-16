
function [bit_error_cnt] = bitwise_error(num1, num2)
    bit_error_cnt = sum(bitget(bitxor(num1,num2), 3:-1:1, 'int8'));
end