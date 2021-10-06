clear,close,clc;

n = 2; k = 1; m = 3;
A = cat(3, [1 1], [0 1], [1 1]); % A_2 ~ A_0的拼接 A2=[1 1] A1=[0 1] A0=[1 1]
r = [1 1 0 1 1 0 1 1 0 0];

currentState = [0 0];
input = 1;
[nextState, output] = get_next_state(n, k, m, A, currentState, input) % 应该是 01 11

currentState = [1 0];
input = 0;
[nextState, output] = get_next_state(n, k, m, A, currentState, input) % 应该是 00 11

currentState = [1 1];
input = 1;
[nextState, output] = get_next_state(n, k, m, A, currentState, input) % 应该是 11 01
