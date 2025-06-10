function innerContoursOut = transformInnerContours(innerContoursIn, bboxSVG, dims, angle, center, centerSVG, tform)
% TRANSFORMINNERCONTOURS Transforma contornos internos al sistema SVG y aplica el encaje ICP
%
% Entrada:
%   - innerContoursIn: celda de contornos interiores (struct con x, y)
%   - bboxSVG, dims, angle, center, centerSVG: parámetros del cambio de sistema de referencia
%   - tform: estructura con campos .Rotation, .Scale, .Translation
%
% Salida:
%   - innerContoursOut: celda de contornos transformados y alineados

    innerContoursOut = cell(size(innerContoursIn));

    for i = 1:numel(innerContoursIn)
        c = innerContoursIn{i};
        pts = [c.x(:), c.y(:)];

        % Paso 1: cambio de sistema de referencia
        ptsSVG = transformPointsToSVG(pts, bboxSVG, dims, angle, center, centerSVG);

        % Paso 2: aplicar transformación de similitud (s * R * x + t)
        ptsFinal = tform.Scale * (ptsSVG * tform.Rotation) + tform.Translation;

        % Guardar resultado
        innerContoursOut{i} = struct('x', ptsFinal(:,1), 'y', ptsFinal(:,2));
    end
end
