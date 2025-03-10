function pointsPlotX(edges)
    % Asegurar que las figuras sean movibles
    set(0, 'DefaultFigureWindowStyle', 'normal');  

    % Gráfica de las coordenadas X en una recta real
    figX = figure;
    movegui(figX, 'northwest'); % Mueve la ventana a la esquina superior izquierda
    scatter(edges.x, zeros(size(edges.x)), 'b.', 'MarkerEdgeAlpha', 0.5);
    xlabel('Coordenada X');
    yticks([]); % Ocultar eje Y
    title('Distribución de coordenadas X de los bordes detectados');
    grid on;
end
