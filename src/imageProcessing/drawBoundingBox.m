function drawBoundingBox(image, edges)
    displacement = 12; % Desplazamiento base para la caja

    % Ordenar las coordenadas X
    sorted_x = sort(edges.x);

    % Ajustar cuantiles en X para incluir más puntos
    x_min = quantile(sorted_x, 0.02); % Captura más puntos en el lado izquierdo
    x_max = quantile(sorted_x, 0.98); % Captura más puntos en el lado derecho

    % Mantener el eje Y tal como estaba
    y_min = quantile(edges.y, 0.05) - displacement; % Borde superior
    y_max = quantile(edges.y, 0.95) + displacement; % Borde inferior

    % Asegurar que los valores estén dentro del tamaño de la imagen
    y_min = max(y_min, 1);
    y_max = min(y_max, size(image, 1));
    x_min = max(x_min, 1);
    x_max = min(x_max, size(image, 2));

    % Depuración: imprimir los valores
    fprintf('x_min: %f, x_max: %f\n', x_min, x_max);
    fprintf('y_min: %f, y_max: %f\n', y_min, y_max);

    % Visualizar la imagen con ejes
    figure;
    imshow(image);
    hold on;

    % Dibujar líneas horizontales (bordes superior e inferior)
    plot([x_min, x_max], [y_min, y_min], 'g-', 'LineWidth', 0.5);
    plot([x_min, x_max], [y_max, y_max], 'g-', 'LineWidth', 0.5);

    % Dibujar líneas verticales (bordes izquierdo y derecho)
    plot([x_min, x_min], [y_min, y_max], 'g-', 'LineWidth', 0.5);
    plot([x_max, x_max], [y_min, y_max], 'g-', 'LineWidth', 0.5);

    % Mostrar ejes en la imagen
    ax = gca;
    ax.XColor = 'w'; 
    ax.YColor = 'w';
    ax.XAxisLocation = 'top';
    ax.YAxisLocation = 'left';
    ax.XLabel.String = 'Coordenada X';
    ax.YLabel.String = 'Coordenada Y';

    % Agregar grid para referencia
    grid on;

    title('Caja delimitadora de la pieza (Ajuste en X y Y)');
    hold off;
end
