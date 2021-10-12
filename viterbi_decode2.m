function decode = viterbi_decode2(n, k, m, A, r, distance, mode, p)
    if(mode == 0) % Hard Viterbi
        r = [r, zeros(1, mod(-length(r), n))]; % 补零变成 n 的倍数
        r = reshape(r, n, []); % 化为若干列，每一列都对应于 k 个原符号（共依赖于 m*k 个原符号）
    end
    n_decode = size(r, 2) * k; % 最终输出的码流长度
    
    n_state = p^(m - 1); % 米利机状态数，p种情形在输入中，p^{m-1} 种情形在状态中
    state = dec2base(0:n_state - 1, p, m-1) - '0'; % n_state * (m-1) 矩阵，每一行对应一个长度为 m-1 的状态
    probability = [1, zeros(1, n_state - 1)]'; % 先验概率。因为从状态为 0 开始，所以取第一个为 1、其余的为 0。
    route = zeros(n_state, size(r, 2)); % 存储最优路径，每一行都是一条走到相应 state 的最优路径。

    for i = 1:size(r, 2)
        input = r(:, i).'; % 当前处理的输入
        next_probability = zeros(size(probability)); % 缓存下一个状态的最大概率
        next_route = zeros(size(route)); % 缓存下一个状态的最优路径

        try_input = 0:p - 1; % 假想的输入，这里默认了 k = 1
        full_input = reshape(repmat(try_input, n_state, 1), [], 1); % 每个元素重复 n_state 次
        full_state = [repmat(state, p, 1), full_input]; % 状态+假想输入得到的完整输入，第 k * n_state + s + 1 行表示第 s 个状态和第 k 个输入的组合
        pro_probability = repmat(probability, p, 1); % 每个 full_state 对应的先验概率
        output = convs(n, k, m, A, full_state, p);
        shift_probability = distance(input, output); % 根据实际的 input 和假想的 output 之间的距离计算转移到各个状态的概率
        next_state = full_state(:, 2:end); % 各个状态在 try_input 的假想输入下对应的下一个状态
        next_state = base2dec(char(next_state + '0'), p) + 1; % 转换为索引，next_state 中各种状态应恰好出现 p 次
        
        for s = 1:n_state % 遍历各个次状态
            state_k = (next_state == s); % 取出 next_state 中的 p 个相应状态
            pp = pro_probability(state_k); % 先验概率 
            sp = shift_probability(state_k); % 转移概率
            ap = pp .* sp; % 后验概率
            [next_probability(s), I] = max(ap); % 最大后验概率作为状态 s 的概率
            tmp = find(state_k, I(1));
            index = mod(tmp(end) - 1, n_state) + 1;
            route_k = route(index, :);
            input_k = full_input(state_k);
            next_route(s, 1:i) = [route_k(1:i-1), input_k(I(1))];
        end
    
        route = next_route;
        
        probability = next_probability;
    end

    decode = route(1, :);
end