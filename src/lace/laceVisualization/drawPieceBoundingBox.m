function drawPieceBoundingBox(edges, corners, color)
% DRAWPIECEBOUNDINGBOX Dibuja los puntos de la pieza y su bounding box rotado
%
% Entrada:
%   - edges:   estructura con campo .exterior (con campos .x, .y)
%   - corners: 4x2 matriz con las esquinas del bounding box
%   - color:   color del bounding box (por ejemplo, 'r')

    if nargin < 3, color = 'r'; end

    % Extraer puntos
    exterior = edges.exterior;
    pointsPieza = [exterior.x(:), exterior.y(:)];

    % Dibujar figura
    figure; hold on; axis equal;
    title("BoundingBox Pieza Detectada");

    % Dibujar puntos
    plot(pointsPieza(:,1), pointsPieza(:,2), '.', 'Color', [0.2 0.2 0.8]);

    % Dibujar bounding box
    drawBoundingBox(corners, color, '--');
end
