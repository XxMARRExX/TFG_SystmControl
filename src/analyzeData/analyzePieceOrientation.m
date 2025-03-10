function analyzePieceOrientation(image, edges)
    % Filtrar bordes más o menos horizontales
    cond = abs(edges.ny) > 0.95;
    edgesC = subsetEdges(edges, cond);
    
    % Visualizar los bordes filtrados
    figure;
    clf;
    visEdges(edgesC);
    title('Bordes horizontales detectados');

    % Calcular la recta de regresión sin outliers
    line = filteredOutliers(edgesC.x, edgesC.y, true);

    % Dibujar la recta de regresión
    x = [0, size(image, 2)]; % Extremos de la imagen en X
    y = polyval(line, x);
    
    % Superponer la recta en la imagen de bordes filtrados
    figure;
    hold on;
    visEdges(edgesC);
    plot(x, y, 'g-', 'LineWidth', 2);
    title('Recta de regresión sobre bordes horizontales');
    hold off;

    % Superponer la recta en la imagen original
    figure;
    imshow(image);
    hold on;
    plot(x, y, 'g-', 'LineWidth', 2);
    title('Imagen original con recta de regresión');
    hold off;
end
