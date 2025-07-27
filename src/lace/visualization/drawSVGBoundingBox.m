function drawSVGBoundingBox(svgPaths, corners, color)
% DRAWSVGBOUNDINGBOX Dibuja los paths del SVG y su bounding box rotado
%
% Entrada:
%   - svgPaths: celda de Nx2 matrices de puntos del SVG
%   - corners:  4x2 matriz con las esquinas del bounding box rotado
%   - color:    color del bounding box (por ejemplo, 'g' o [0 1 0])

    if nargin < 3, color = 'g'; end

    % Crear figura
    figure; hold on; axis equal;
    title("BoundingBox Modelo SVG");

    % Dibujar paths
    for k = 1:numel(svgPaths)
        pts = svgPaths{k};
        if ~isempty(pts)
            plot(pts(:,1), pts(:,2), 'Color', [0.8 0.8 0.8], 'LineWidth', 0.75);
        end
    end

    % Dibujar bounding box
    drawBoundingBox(corners, color);
end
