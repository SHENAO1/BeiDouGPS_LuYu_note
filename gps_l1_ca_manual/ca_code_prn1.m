%CA_CODE_PRN1 Generate GPS L1 C/A code for PRN 1.
% Run this script in MATLAB.

clear;
clc;
close all;

% A register vector means:
% g1(1) is stage 1, g1(10) is stage 10.
g1 = ones(1, 10);
g2 = ones(1, 10);

% Store the C/A code as 0/1 first.
ca01 = zeros(1, 1023);

for k = 1:1023
    % G1 output is stage 10.
    g1_out = g1(10);

    % PRN 1 uses G2 taps 2 and 6.
    g2_prn1_out = xor(g2(2), g2(6));

    % C/A code bit for this chip.
    ca01(k) = xor(g1_out, g2_prn1_out);

    % Feedback bits.
    g1_feedback = xor(g1(3), g1(10));
    g2_feedback = xor(xor(xor(g2(2), g2(3)), xor(g2(6), g2(8))), xor(g2(9), g2(10)));

    % Shift right. New feedback enters stage 1.
    g1 = [g1_feedback, g1(1:9)];
    g2 = [g2_feedback, g2(1:9)];
end

% Convert 0/1 chips to +1/-1 chips.
% 0 becomes +1, 1 becomes -1.
ca = 1 - 2 * ca01;

disp('First 20 C/A chips as 0/1:');
disp(ca01(1:20));

disp('First 20 C/A chips as +1/-1:');
disp(ca(1:20));

figure('Name', 'GPS L1 C/A PRN 1', 'Color', 'w');
stem(ca(1:80), 'filled');
grid on;
xlabel('Chip index');
ylabel('Chip value');
title('First 80 chips of GPS L1 C/A PRN 1');
ylim([-1.2 1.2]);
