function iq_orthogonality_demo()
%IQ_ORTHOGONALITY_DEMO Show cos/sin orthogonality in the cos-sin plane.
% Run this file in MATLAB. It opens one figure and does not create output files.

close all;

fc = 1;
T = 1 / fc;
fs = 2400;
t = linspace(0, T, fs + 1);

x = cos(2*pi*fc*t);             % Horizontal axis: cos carrier
y = sin(2*pi*fc*t);             % Vertical axis: sin carrier
xy = x .* y;                    % Integrand for the inner product
innerFull = trapz(t, xy);
cumulativeInner = cumtrapz(t, xy);

posColor = [0.20 0.55 0.90];
negColor = [0.88 0.30 0.22];
gray = [0.25 0.25 0.25];

figure('Name', 'cos-sin orthogonality', 'Color', 'w', ...
    'Position', [120 100 1120 640]);
tiledlayout(1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');

nexttile(1);
hold on;
axis equal;
grid on;
box on;

patch([0 1.15 1.15 0], [0 0 1.15 1.15], posColor, ...
    'FaceAlpha', 0.08, 'EdgeColor', 'none', 'HandleVisibility', 'off');
patch([-1.15 0 0 -1.15], [-1.15 -1.15 0 0], posColor, ...
    'FaceAlpha', 0.08, 'EdgeColor', 'none', 'HandleVisibility', 'off');
patch([-1.15 0 0 -1.15], [0 0 1.15 1.15], negColor, ...
    'FaceAlpha', 0.08, 'EdgeColor', 'none', 'HandleVisibility', 'off');
patch([0 1.15 1.15 0], [-1.15 -1.15 0 0], negColor, ...
    'FaceAlpha', 0.08, 'EdgeColor', 'none', 'HandleVisibility', 'off');

plot([-1.15 1.15], [0 0], '-', 'Color', gray, 'LineWidth', 1.0, ...
    'HandleVisibility', 'off');
plot([0 0], [-1.15 1.15], '-', 'Color', gray, 'LineWidth', 1.0, ...
    'HandleVisibility', 'off');

posMask = xy >= 0;
negMask = xy < 0;
hPosArc = plotMaskedArc(x, y, posMask, posColor);
hNegArc = plotMaskedArc(x, y, negMask, negColor);

hCos = quiver(0, 0, 1, 0, 0, 'Color', [0.00 0.36 0.72], ...
    'LineWidth', 2.0, 'MaxHeadSize', 0.20);
hSin = quiver(0, 0, 0, 1, 0, 'Color', [0.86 0.24 0.15], ...
    'LineWidth', 2.0, 'MaxHeadSize', 0.20);

plot(1, 0, 'ko', 'MarkerFaceColor', 'w', 'MarkerSize', 6, ...
    'HandleVisibility', 'off');
text(1.03, 0.06, 't = 0', 'FontSize', 10, 'Color', gray);
text(0.55, 0.55, 'cos·sin > 0', 'Color', posColor, ...
    'HorizontalAlignment', 'center', 'FontWeight', 'bold');
text(-0.55, 0.55, 'cos·sin < 0', 'Color', negColor, ...
    'HorizontalAlignment', 'center', 'FontWeight', 'bold');
text(-0.55, -0.55, 'cos·sin > 0', 'Color', posColor, ...
    'HorizontalAlignment', 'center', 'FontWeight', 'bold');
text(0.55, -0.55, 'cos·sin < 0', 'Color', negColor, ...
    'HorizontalAlignment', 'center', 'FontWeight', 'bold');

xlabel('cos(2\pi f_c t)');
ylabel('sin(2\pi f_c t)');
title('横轴为 cos，纵轴为 sin：一个周期扫过单位圆');
xlim([-1.15 1.15]);
ylim([-1.15 1.15]);
legend([hPosArc hNegArc hCos hSin], ...
    {'cos·sin > 0 的轨迹', 'cos·sin < 0 的轨迹', ...
    'cos 基向量', 'sin 基向量'}, 'Location', 'southoutside');

nexttile(2);
yyaxis left;
area(t/T, max(xy, 0), 'FaceColor', posColor, ...
    'EdgeColor', 'none', 'FaceAlpha', 0.35);
hold on;
area(t/T, min(xy, 0), 'FaceColor', negColor, ...
    'EdgeColor', 'none', 'FaceAlpha', 0.35);
plot(t/T, xy, 'k', 'LineWidth', 1.4);
yline(0, '-', 'Color', gray);
ylabel('cos(2\pi f_c t) · sin(2\pi f_c t)');
ylim([-0.58 0.58]);

yyaxis right;
plot(t/T, cumulativeInner, 'LineWidth', 2.0, 'Color', [0.10 0.55 0.25]);
ylabel('累计内积');
ylim([-0.02 0.18]);

grid on;
box on;
xlabel('时间 / 周期 T');
title(sprintf('正负面积抵消：∫_0^T cos(2πf_ct)sin(2πf_ct)dt ≈ %.2g', innerFull));
text(0.55, 0.145, '累计积分最后回到 0', ...
    'Color', [0.10 0.55 0.25], 'FontWeight', 'bold', ...
    'BackgroundColor', 'w', 'Margin', 4);
xlim([0 1]);

sgtitle('sin 与 cos 的正交性：在一段时间上的内积为 0', ...
    'FontWeight', 'bold');
end

function h = plotMaskedArc(x, y, mask, color)
arcX = x;
arcY = y;
arcX(~mask) = NaN;
arcY(~mask) = NaN;
h = plot(arcX, arcY, 'Color', color, 'LineWidth', 4.0);
end
