function plotPercentiles()
% plotPercentiles - Visualiza percentiles y exporta PNG a 1800x1000 px.
% Etiquetas a la derecha de cada línea y alineadas abajo.

    data = 100 * randn(900,1);                 % Datos normales
    outliers = 1000 + 200 * randn(100,1);      % Grupo de outliers
    data = [data; outliers];

    percentiles = [2 25 70 95 98];
    perc_values = prctile(data, percentiles);

    % Colores
    color_barras = [113 233 50]/255;
    color_edge_barras = [54 129 14]/255;
    color_percentiles = [168 0 255]/255;
    color_barras_iluminado = min(color_barras * 1.2, 1.0);

    % Crear figura con fondo blanco
    figure('Color', 'w');
    histogram(data, 30, ...
        'FaceColor', color_barras_iluminado, ...
        'EdgeColor', color_edge_barras, ...
        'FaceAlpha', 0.9, ...
        'LineWidth', 1.2);
    hold on;

    % Límites y desplazamientos
    y_limits = ylim;
    y_range = y_limits(2) - y_limits(1);
    y_text = y_limits(1) + 0.02 * y_range;  % Parte baja del gráfico
    x_offset = 0.01 * (max(data) - min(data));  % Pequeño desplazamiento a la derecha

    % Dibujar líneas y etiquetas
    for i = 1:numel(percentiles)
        x = perc_values(i);
        labelStr = sprintf('P%d = %.2f', percentiles(i), round(x, 2));

        xline(x, '--', ...
            'Color', color_percentiles, ...
            'LineWidth', 1.5);

        text(x + x_offset, y_text, labelStr, ...
            'HorizontalAlignment', 'left', ...
            'VerticalAlignment', 'bottom', ...
            'Color', color_percentiles, ...
            'FontWeight', 'bold', ...
            'FontSize', 7, ...
            'Clipping', 'on');
    end

    % Estética
    xlabel('Valor', 'FontSize', 11);
    ylabel('Frecuencia', 'FontSize', 11);
    legend('Datos', 'Location', 'northeast');
    box on; grid off;

    % Fijar tamaño físico exacto → 1800 x 1000 px a 300 dpi
    set(gcf, 'Units', 'inches', 'PaperUnits', 'inches', ...
             'PaperPosition', [0 0 6 3.33], ...
             'PaperSize', [6 3.33]);

    % Exportar PNG
    print(gcf, '../TFG - Imagenes memoria/06_DocumentacionMemoria/TFG - percentiles.png', ...
          '-dpng', '-r300');
end
