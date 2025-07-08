function showPixelIntensities(grayImage, varargin)
% SHOWINTENSITYMATRIX Muestra los valores de una imagen como una cuadrícula de celdas coloreadas
%
% Cada celda:
% - Tiene el color correspondiente al nivel de gris
% - Muestra el valor de intensidad centrado

    p = inputParser;
    addParameter(p, 'MaxSize', 60); % tamaño máximo por lado para visualizar todo
    parse(p, varargin{:});
    maxSize = p.Results.MaxSize;

    % Asegurar que la imagen es double
    I = double(grayImage);

    % Redimensionar si es muy grande
    [h, w] = size(I);
    if max(h, w) > maxSize
        scale = maxSize / max(h, w);
        I = imresize(I, scale, 'nearest');
        fprintf('⚠️  Imagen redimensionada a %dx%d para visualización clara.\n', size(I,1), size(I,2));
    end

    [rows, cols] = size(I);

    figure;
    imagesc(I);
    colormap(gray);
    axis equal;
    axis tight;
    set(gca, 'XTick', 1:cols, 'YTick', 1:rows);
    grid on;
    set(gca, 'GridColor', 'k', 'GridAlpha', 0.3, 'LineWidth', 0.5);

    % Escribir los valores
    for r = 1:rows
        for c = 1:cols
            val = I(r, c);
            text(c, r, sprintf('%d', round(val)), ...
                'HorizontalAlignment', 'center', ...
                'VerticalAlignment', 'middle', ...
                'Color', (val > 128)*[0 0 0] + (val <= 128)*[1 1 1], ...
                'FontWeight', 'bold');
        end
    end

    title('Matriz de intensidades (modo cuadrícula)');
end
