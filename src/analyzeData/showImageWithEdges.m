function showImageWithEdgesMulti(grayImage, resultados)
% SHOWIMAGEWITHEDGESMULTI Muestra múltiples piezas con sus bordes, rectas y cajas en una sola figura.
%
% Entrada:
%   - grayImage: imagen original en escala de grises
%   - resultados: array de estructuras con campos .edges, .linea, .boundingBox

    fig = figure;
    movegui(fig, 'center');
    imshow(grayImage, 'InitialMagnification', 'fit');
    hold on;

    colores = lines(numel(resultados));

    for i = 1:numel(resultados)
        e = resultados(i).edges;
        linea = resultados(i).linea;
        
        % Dibujar bordes de la pieza
        plot(e.x, e.y, '.', 'Color', colores(i,:), 'DisplayName', sprintf('Pieza %d', i));

        % Dibujar la recta de regresión
        plot(linea.X, linea.Y, 'g-', 'LineWidth', 0.75);

        % Dibujar el bounding box
        box = computeRotatedBoundingBox(e, linea, 0.10, 0.05);
        plot(box(:,1), box(:,2), '-', 'Color', colores(i,:), 'LineWidth', 1.25);
    end

    title('Imagen original con detección de piezas, rectas y cajas');
    legend show;
    hold off;
end
