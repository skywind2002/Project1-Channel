%% 收方利用已知的 beta 对收到的复向量 r 进行校正，得到复向量 x 作为收到
% 的信号。
function x = beta_correct(r, b, beta, beta_corr_mode, add_zero, add_pre_seq)
    % r - 行向量，表示收到的复向量
    % b - 标量，为题目中的参数
    % beta - 行向量，为题目中的参数。长度与 r 相同。
    % x - 行向量。长度为 length(r)
    x = r;
    if (beta_corr_mode == 3) % beta 未知
        if(add_pre_seq ~= 0)
            x = r ./ beta;
        end
        if(b == 1)
            x = [x(2:end), 0];
        end
    elseif (b == 1)
        t = r ./ beta ./ b;
        x = [t(2:end), 0];
    elseif (b == 0)
        x = r;
    else
        alpha = -b / sqrt(1 - b^2) * beta;
        % 将 alpha 中第 (1:n) * (add_zero+1) + 1 位置零
        if(add_zero ~= 0)
            tmp = reshape([alpha(2:end), 0], add_zero + 1, []);
            tmp(end, :) = 0;
            tmp = reshape(tmp, 1, []);
            alpha(2:end) = tmp(1:end-1);
        end
        x = zeros(size(r));
        for i = 1:length(x)
            Ai = [1, cumprod(alpha(i:-1:2))];
            x(i) = r(1:i) * Ai(end:-1:1).';
        end
        x = x / sqrt(1 - b^2);
    end
end