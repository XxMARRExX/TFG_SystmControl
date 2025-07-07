function showImageWithEdges(grayImage, resultados)
% SHOWIMAGEWITHEDGES Muestra múltiples piezas con sus bordes, rectas y cajas en una sola figura

    fig = figure;
    movegui(fig, 'center');
    imshow(grayImage, 'InitialMagnification', 'fit');
    hold on;

    colores = lines(numel(resultados));  % Color único por pieza

    for i = 1:numel(resultados)
        color = colores(i,:);  % ✅ Asignar color a esta pieza

        % Dibujar bordes
        plot(resultados(i).edges.x, resultados(i).edges.y, '.', 'Color', color);

        % Dibujar recta
        [height, width] = size(grayImage);
        xLine = [1, width];
        yLine = resultados(i).linea.m * xLine + resultados(i).linea.b;
        
        plot(xLine, yLine, '-', 'Color', color, 'LineWidth', 1.25);
    end

    title('Imagen original con detección de piezas, rectas y cajas');
    hold off;
end