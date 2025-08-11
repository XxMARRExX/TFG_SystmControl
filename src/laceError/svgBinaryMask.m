function result = svgBinaryMask(svgPaths, pxPerUnit, marginMm)
% SVGBINARYMASK Genera una imagen binaria de la pieza a partir del SVG.
% Cada contorno se rasteriza a resolución pxPerUnit y se rellena con paridad.
%
% Entrada:
%   - svgPaths: cell array de Nx2 coordenadas reales (ej. en mm)
%   - pxPerUnit: cantidad de píxeles por unidad (ej. 10 px/mm)
%   - marginMm: margen extra alrededor de la pieza en milímetros (default = 5)
%
% Salida:
%   - result: estructura con los campos:
%       - mask: imagen binaria (1 = pieza, 0 = fondo)
%       - xmin: coordenada mínima en x (real)
%       - ymin: coordenada mínima en y (real)
%       - pxPerUnit: resolución usada (píxeles por unidad)

    if nargin < 3
        marginMm = 5; % por defecto 5 mm
    end

    % Calcular bounding box en unidades reales con margen
    allPts = vertcat(svgPaths{:});
    xmin = floor(min(allPts(:,1)) - marginMm);
    xmax = ceil(max(allPts(:,1)) + marginMm);
    ymin = floor(min(allPts(:,2)) - marginMm);
    ymax = ceil(max(allPts(:,2)) + marginMm);

    % Calcular tamaño en píxeles
    width  = round((xmax - xmin) * pxPerUnit) + 3;
    height = round((ymax - ymin) * pxPerUnit) + 3;

    % Inicializar máscara binaria
    pieceMask = false(height, width);

    % Rasterizar cada contorno
    for i = 1:numel(svgPaths)
        pts = svgPaths{i};
        x = round((pts(:,1) - xmin) * pxPerUnit) + 2;
        y = round((pts(:,2) - ymin) * pxPerUnit) + 2;
        mask = poly2mask(x, y, height, width);
        pieceMask = xor(pieceMask, mask); % Relleno por paridad
    end

    % Resultado
    result.mask = pieceMask;
    result.xmin = xmin;
    result.ymin = ymin;
    result.pxPerUnit = pxPerUnit;
end
