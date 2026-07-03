function calculate_LLE_from_LBE(LBE_ts, t_min, t_max)

    if nargin < 2
        t_min = 0;
    end

    if nargin < 3
        t_max = 0.5;
    end

    % Extrai tempo e dados
    t = LBE_ts.Time;
    LBE = squeeze(LBE_ts.Data);

    % Garante formato de vetor coluna
    t = t(:);
    LBE = LBE(:);

    % Recorta intervalo desejado
    idx = t >= t_min & t <= t_max;

    t = t(idx);
    LBE = LBE(idx);

    % Remove NaN/Inf
    valid = isfinite(t) & isfinite(LBE);
    t = t(valid);
    LBE = LBE(valid);

    if numel(t) < 2
        error('Dados insuficientes no intervalo selecionado.');
    end

    % Figura para selecionar pontos
    fig = figure( ...
        'Name', 'Select Two Points on LBE Curve', ...
        'Units', 'pixels');

    plot(t, LBE, 'k', 'LineWidth', 1.2);

    xlabel('Time (s)', 'Interpreter', 'latex');
    ylabel('$\log_2(\delta_{\alpha,n})$', 'Interpreter', 'latex');

    title(sprintf('LLE'), ...
        'Interpreter', 'latex');

    grid on;
    box on;

    [x_click, y_click] = ginput(2);

    if numel(x_click) < 2
        close(fig);
        error('Dois pontos não foram selecionados.');
    end

    % Garante ordem crescente no tempo
    [x_click, order] = sort(x_click);
    y_click = y_click(order);

    % Calcula LLE como inclinação da reta
    LLE = diff(y_click) / diff(x_click);

    % Calcula intercepto da reta: y = LLE*t + b
    b = y_click(1) - LLE*x_click(1);

    % Equação da reta
    line_eq = sprintf('$y = %.6g t %+ .6g$', LLE, b);

    % Cria pontos da reta apenas entre os dois cliques
    t_line = linspace(x_click(1), x_click(2), 200);
    LBE_line = LLE*t_line + b;

    hold on;

    % Plota reta estimada
    plot(t_line, LBE_line, 'r', 'LineWidth', 2);

    % Plota pontos selecionados
    plot(x_click, y_click, 'ro', 'MarkerFaceColor', 'r');

    % Escreve a equação da reta no gráfico
    x_text = mean(x_click);
    y_text = mean(y_click);

    text(x_text, y_text, line_eq, ...
        'Interpreter', 'latex', ...
        'Color', 'r', ...
        'FontSize', 12, ...
        'FontWeight', 'bold', ...
        'BackgroundColor', 'w', ...
        'EdgeColor', 'r', ...
        'Margin', 5);

    hold off;

    fprintf('\nIntervalo usado: %.6g s até %.6g s\n', t_min, t_max);
    fprintf('Ponto 1: (%.6g, %.6g)\n', x_click(1), y_click(1));
    fprintf('Ponto 2: (%.6g, %.6g)\n', x_click(2), y_click(2));
    fprintf('Equação da reta: y = %.8g*t %+ .8g\n', LLE, b);
    fprintf('LLE = %.8g\n\n', LLE);

    % Salva no workspace
    assignin('base', 'LLE_value', LLE);
    assignin('base', 'LLE_intercept', b);
    assignin('base', 'LLE_line_equation', line_eq);
    assignin('base', 'LLE_points_x', x_click);
    assignin('base', 'LLE_points_y', y_click);
    assignin('base', 'LBE_time_used', t);
    assignin('base', 'LBE_used', LBE);
    assignin('base', 'LLE_line_time', t_line);
    assignin('base', 'LLE_line_values', LBE_line);

end