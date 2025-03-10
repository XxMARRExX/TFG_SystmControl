function pointsPlotY(edges)
    % Asegurar que las figuras sean movibles
    set(0, 'DefaultFigureWindowStyle', 'normal');  

    % Gráfica de las coordenadas Y en una recta real
    figY = figure;
    movegui(figY, 'northeast'); % Mueve la ventana a la esquina superior derecha
    scatter(edges.y, zeros(size(edges.y)), 'r.', 'MarkerEdgeAlpha', 0.5);
    xlabel('Coordenada Y');
    yticks([]); % Ocultar eje Y
    title('Distribución de coordenadas Y de los bordes detectados');
    grid on;
end