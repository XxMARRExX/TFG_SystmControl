function analyzePieceOrientation(image, edges)

    % Calcular la recta de regresión
    line = filteredOutliers(edges.x, edges.y, true);

    % Dibujar la recta
    x_range = [0, size(image, 2)];
    y_range = polyval(line, x_range);

    % Dibujar la recta sobre la imagen original
    figure;
    imshow(image);
    hold on;
    plot(x_range, y_range, 'g-', 'LineWidth', 0.75);
    title('Imagen original con orientación estimada de la pieza');
    hold off;

    % Mostrar pendiente y ángulo en consola
    pendiente = line(1);
    angulo_deg = atan(pendiente) * (180 / pi);
    fprintf('Pendiente de la recta ajustada: %.6f\n', pendiente);
    fprintf('Ángulo de inclinación respecto al eje horizontal: %.2f grados\n', angulo_deg);
end
