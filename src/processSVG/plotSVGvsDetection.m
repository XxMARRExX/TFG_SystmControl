function plotSVGvsDetection(contours, transformadas)
%PLOTSVGVSDETECTION Dibuja los contornos del SVG y los contornos detectados transformados
%   - contours: celda de contornos SVG {x, y}
%   - transformadas: struct array con campos:
%       .x_svg, .y_svg               → contorno exterior
%       .x_svg_interior{j}, .y_svg_interior{j} → interiores

    % Extraer contornos del SVG
    [X, Y] = deal(contours(:,1), contours(:,2));
    [idxExt, idxInt] = identifyContours(X, Y);

    % Crear figura
    figure; hold on; axis equal; grid on;
    title('Contornos: SVG (rojo) vs Detección (azul)');

    % --- SVG ---
    plot(X{idxExt}, Y{idxExt}, 'r', 'LineWidth', 1.5);  % exterior
    for i = idxInt
        plot(X{i}, Y{i}, 'r--', 'LineWidth', 1.2);       % interiores
    end

    % --- Detección ---
    for i = 1:numel(transformadas)
        % Exterior
        plot(transformadas(i).x_svg, transformadas(i).y_svg, '.b', 'LineWidth', 1.5);

        % Interiores
        if isfield(transformadas(i), 'x_svg_interior')
            for j = 1:numel(transformadas(i).x_svg_interior)
                plot(transformadas(i).x_svg_interior{j}, transformadas(i).y_svg_interior{j}, 'b--');
            end
        end
    end
end
