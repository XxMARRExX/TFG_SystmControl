function result = svgBinaryMask(svgPaths, pxPerUnit, marginMm)
% svgBinaryMask() Genera una imagen binaria de la pieza a partir del SVG.
% Cada contorno se rasteriza a resolución pxPerUnit y se rellena con paridad.
%
%   Entrada:
%       - svgPaths: cell array de Nx2 coordenadas reales (en mm)
%       - pxPerUnit: cantidad de píxeles por unidad (ej. 10 px/mm)
%       - marginMm: margen extra alrededor de la pieza en milímetros (default = 5)
%
%   Salida:
%       - result: estructura con los campos:
%           - mask: imagen binaria (1 = pieza, 0 = fondo)
%           - xmin: coordenada mínima en x (real)
%           - ymin: coordenada mínima en y (real)
%           - pxPerUnit: resolución usada (píxeles por unidad)

    if nargin < 3
        marginMm = 5; % por defecto 5 mm
    end

    % --- 1. Concatenar todos los puntos válidos para calcular el bounding box ---
    allPoints = [];

    for i = 1:numel(svgPaths)
        path = svgPaths{i};

        % Ignorar rutas vacías o mal definidas
        if isempty(path) || size(path,2) < 2
            continue;
        end

        % Limpiar NaN e Inf
        x = path(:,1);
        y = path(:,2);
        validIdx = isfinite(x) & isfinite(y);
        if any(validIdx)
            allPoints = [allPoints; x(validIdx), y(validIdx)]; %#ok<AGROW>
        end
    end

    if isempty(allPoints)
        error('svgBinaryMask:NoValidPoints', ...
              'No se encontraron coordenadas válidas en svgPaths (NaN, Inf o vacías).');
    end

    % --- 2. Calcular bounding box en unidades reales con margen ---
    xmin = floor(min(allPoints(:,1)) - marginMm);
    xmax = ceil(max(allPoints(:,1)) + marginMm);
    ymin = floor(min(allPoints(:,2)) - marginMm);
    ymax = ceil(max(allPoints(:,2)) + marginMm);

    % --- 3. Calcular tamaño en píxeles ---
    width  = round((xmax - xmin) * pxPerUnit) + 3;
    height = round((ymax - ymin) * pxPerUnit) + 3;

    % --- 4. Inicializar máscara binaria ---
    pieceMask = false(height, width);

    % --- 5. Rasterizar cada contorno del SVG ---
    for i = 1:numel(svgPaths)
        pts = svgPaths{i};

        % Saltar rutas vacías o inválidas
        if isempty(pts) || size(pts,2) < 2
            continue;
        end

        % Limpiar coordenadas
        x = pts(:,1);
        y = pts(:,2);
        validIdx = isfinite(x) & isfinite(y);
        x = x(validIdx);
        y = y(validIdx);

        % Si no hay suficientes puntos, saltar
        if numel(x) < 3
            continue;
        end

        % Convertir a coordenadas de píxel
        x = round((x - xmin) * pxPerUnit) + 2;
        y = round((y - ymin) * pxPerUnit) + 2;

        % Recortar a los límites válidos de la máscara
        x = max(min(x, width), 1);
        y = max(min(y, height), 1);

        % Generar la máscara de este contorno
        mask = poly2mask(x, y, height, width);

        % Relleno por paridad (maneja agujeros)
        pieceMask = xor(pieceMask, mask);
    end

    % --- 6. Resultado ---
    result.mask = pieceMask;
    result.xmin = xmin;
    result.ymin = ymin;
    result.pxPerUnit = pxPerUnit;
end
