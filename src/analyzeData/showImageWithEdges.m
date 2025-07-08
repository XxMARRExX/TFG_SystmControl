function showImageWithEdges(grayImage, resultados, innerContours)
% SHOWIMAGEWITHEDGES Muestra las piezas con sus contornos exteriores e interiores
% usando el mismo color por pieza, claramente visible sobre fondo gris.

    if nargin < 3
        innerContours = {};
    end

    figure;
    imshow(grayImage, 'InitialMagnification', 'fit');
    hold on;

    % Colores suficientemente vivos para fondo gris
    colores = lines(numel(resultados));

    for i = 1:numel(resultados)
        color = colores(i,:);

        % --- Contorno exterior ---
        plot(resultados(i).edges.x, resultados(i).edges.y, '.', ...
             'Color', color, 'MarkerSize', 8);

        % --- Línea de orientación de la pieza ---
        [~, width] = size(grayImage);
        xLine = [1, width];
        yLine = resultados(i).linea.m * xLine + resultados(i).linea.b;
        plot(xLine, yLine, '-', 'Color', color, 'LineWidth', 1.5);

        % --- Contornos interiores ---
        if i <= numel(innerContours)
            for j = 1:numel(innerContours{i}.contornos)
                c = innerContours{i}.contornos{j};
                plot(c.x, c.y, '.', 'Color', color, 'MarkerSize', 6); % mismo color
            end
        end
    end

    title('Piezas y contornos interiores (color por pieza)');
    hold off;
end
