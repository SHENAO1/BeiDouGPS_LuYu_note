%% main_boc_gen_step1.m
% BOC signal generation - Step 1
% 目标：先固定 BOC 信号生成所需的基础参数

clear; clc; close all;

%% 1. 基准频率
f0 = 1.023e6;              % GPS/BOC 常用基准频率，单位 Hz

%% 2. BOC(n,m) 参数
n = 1;                     % 子载波频率倍数
m = 1;                     % 扩频码速率倍数

f_sc = n * f0;             % BOC 子载波频率
R_c  = m * f0;             % 扩频码速率 chip rate

%% 3. 仿真采样参数
fs = 16 * f0;              % 采样频率，先取 16.368 MHz
Ts = 1 / fs;               % 采样周期

T_sim = 10e-3;              % 仿真时长，先生成 1 ms
N = round(T_sim * fs);     % 总采样点数

t = (0:N-1) / fs;          % 时间轴

%% 4. 打印参数
fprintf('===== BOC Signal Parameter Check =====\n');
fprintf('BOC(%d,%d)\n', n, m);
fprintf('Reference frequency f0 = %.3f MHz\n', f0/1e6);
fprintf('Subcarrier frequency f_sc = %.3f MHz\n', f_sc/1e6);
fprintf('Code rate R_c = %.3f Mcps\n', R_c/1e6);
fprintf('Sampling frequency fs = %.3f MHz\n', fs/1e6);
fprintf('Simulation time T_sim = %.3f ms\n', T_sim*1e3);
fprintf('Total samples N = %d\n', N);
fprintf('Samples per code chip = %.2f\n', fs/R_c);
fprintf('Samples per subcarrier period = %.2f\n', fs/f_sc);

%% 5. 生成扩频码序列 c(t)

prn = 1;                         % 先选择 GPS PRN 1
ca_1ms = generate_ca_code_prn1(); % 生成 1 ms 的 C/A 码，长度 1023

num_chips = ceil(T_sim * R_c);    % 仿真时间内需要的总码片数

repeat_num = ceil(num_chips / length(ca_1ms)); % 需要重复多少次 C/A 码
code_chips = repmat(ca_1ms, 1, repeat_num); % 重复 C/A 码
% repmat 函数第二个1表示按行复制，第三个参数 repeat_num 表示复制的次数
code_chips = code_chips(1:num_chips); % 截取所需
% 这里为什么要截取？因为重复后可能会多出一些码片，我们只需要仿真时间内的码片数，
% 比如仿真时间是 10 ms，码速率是 1.023 Mcps，那么需要 10230 个码片，但 C/A 码只有 1023 个，所以需要重复至少 10 次，

% 将码片序列转换为时间采样点序列
chip_index = floor(t * R_c) + 1; % 每个采样点对应的码片索引
% 注意：chip_index 从 1 开始，因为 MATLAB 索引从 1 开始
% floor(t * R_c) 是因为 t 从 0 开始，第一段时间对应第一个码片
chip_index(chip_index > num_chips) = num_chips; % 防止索引越界

c_t = code_chips(chip_index); % 生成 c(t) 序列






















function ca_code = generate_ca_code_prn1()
% 生成 GPS PRN 1 的 C/A 码
% C/A 码长度为 1023，使用两个 10 位移位寄存器 G1 和 G2 生成
% G1 的反馈多项式为 x^10 + x^3 + 1
% G2 的反馈多项式为 x^10 + x^9 + x^8 + x^6 + x^3 + x^2 + 1
% PRN 1 的 G2 输出为 G2(2) XOR G2(6)
% 这里使用 -1 表示逻辑 1，1 表示逻辑 0，这样乘法就相当于 XOR 操作
    G1 = -ones(1, 10); % G1 寄存器初始状态，-1 表示逻辑 1
    G2 = -ones(1, 10); % G2 寄存器初始状态

    ca_code = zeros(1, 1023); % C/A 码序列

    for i = 1:1023
        ca_code(i) = G1(end) * (G2(2) * G2(6)); % C/A 码输出

        % 更新 G1 寄存器
        feedback_G1 = G1(3) * G1(10); % x^10 + x^3 + 1
        G1 = [feedback_G1, G1(1:end-1)]; % 将新的反馈位放在寄存器的最前面，原来的位向右移动一位

        % 更新 G2 寄存器
        feedback_G2 = G2(2) * G2(3) * G2(6) * G2(8) * G2(9) * G2(10); % x^10 + x^9 + x^8 + x^6 + x^3 + x^2 + 1
        G2 = [feedback_G2, G2(1:end-1)]; % 同样更新 G2 寄存器
    end
end
