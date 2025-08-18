function hBox = drawBoundingBox(corners, color, style)
% DRAWBOUNDINGBOX Dibuja el rectángulo definido por sus esquinas
%
%   hBox = drawBoundingBox(corners, color, style)
%   - corners: 4x2 matriz con las esquinas del rectángulo
%   - color: color para plot/fill
%   - style: línea opcional para plot (ej. '--')

    if nargin < 3, style = '-'; end
    hBox = fill(corners(:,1), corners(:,2), color, ...
             'FaceAlpha', 0.1, ...
             'EdgeColor', color, ...
             'LineStyle', style, ...
             'LineWidth', 1.5);
end
