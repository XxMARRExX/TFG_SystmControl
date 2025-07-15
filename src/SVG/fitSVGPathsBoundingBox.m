function modelSVG = fitSVGPathsBoundingBox(svgPaths)
% FITSVGPATHSBOUNDINGBOX Ajusta un rectángulo mínimo rotado a un conjunto de paths SVG
%
% Entrada:
%   - svgPaths: celda de Nx2 matrices con puntos del SVG
%
% Salida:
%   - modelSVG: estructura con campos:
%       - Center:     1x2, centro del rectángulo
%       - Dimensions: 1x2, [ancho, alto]
%       - Angle:      escalar en radianes
%       - Orientation: 2x2 matriz de rotación

    % Unir todos los puntos
    allSVGPoints = vertcat(svgPaths{:});  % Nx2
    
    % Ajustar el rectángulo rotado
    modelSVG = fitrect2D(allSVGPoints);
end
