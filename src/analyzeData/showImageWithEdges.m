function showImageWithEdges(grayImage, resultados)
% SHOWIMAGEWITHEDGES Muestra las piezas con sus contornos exteriores e interiores
% usando el mismo color por pieza, claramente visible sobre fondo gris.

    figure;
    imshow(grayImage, 'InitialMagnification', 'fit');
    hold on;

    % Colores suficientemente vivos para fondo gris
    colores = lines(numel(resultados));

    for i = 1:numel(resultados)
        color = colores(i,:);

        % --- Contorno exterior ---
        exterior = resultados(i).edges.exterior;
        plot(exterior.x, exterior.y, '.', ...
             'Color', color, 'MarkerSize', 8);

        % --- Línea de orientación de la pieza ---
        [~, width] = size(grayImage);
        xLine = [1, width];
        yLine = resultados(i).linea.m * xLine + resultados(i).linea.b;
        plot(xLine, yLine, '-', 'Color', color, 'LineWidth', 1.5);

        % --- Contornos interiores ---
        if isfield(resultados(i).edges, 'innerContours') && ~isempty(resultados(i).edges.innerContours)
            for j = 1:numel(resultados(i).edges.innerContours)
                c = resultados(i).edges.innerContours{j};
                plot(c.x, c.y, '.', 'Color', color, 'MarkerSize', 6); % mismo color
            end
        end
    end

    title('Piezas y contornos interiores (color por pieza)');
    hold off;
end
