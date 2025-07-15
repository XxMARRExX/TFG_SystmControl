function resultados = analyzePieceGeometry(pieceClusters)
% ANALYZEPIECEGEOMETRY Calcula la regresión y el bounding box para cada pieza detectada.
%
% Entrada:
%   - pieceClusters: celda de estructuras con campo .edges
%       - .edges.exterior: struct con campos x, y, ...
%       - .edges.innerContours: celda de contornos interiores (opcional)
%
% Salida:
%   - resultados: array de structs con campos:
%       - .edges: toda la estructura original (exterior + interiores)
%       - .linea: regresión sobre el contorno exterior
%       - .boundingBox: bounding box rotado sobre el contorno exterior

    numPiezas = numel(pieceClusters);
    resultados = struct('edges', {}, 'linea', {}, 'boundingBox', {});

    for i = 1:numPiezas
        pieza = pieceClusters{i};

        % Obtener solo el contorno exterior para análisis geométrico
        exterior = pieza.edges.exterior;

        % Calcular regresión lineal sobre el exterior
        linea = computeLinearRegression(exterior);

        % Calcular bounding box rotado sobre el exterior
        box = computeRotatedBoundingBox(exterior, linea);

        resultados(i).edges = pieza.edges;     % Guardar toda la información (exterior + interiores)
        resultados(i).linea = linea;
        resultados(i).boundingBox = box;

        % Añadir los contornos interiores si existen
        if isfield(pieza, 'interiores')
            resultados(i).interiores = pieza.interiores;
        else
            resultados(i).interiores = {};
        end
    end
end
