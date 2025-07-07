function resultados = analyzePieceGeometry(pieceClusters)
% ANALYZEPIECEGEOMETRY Calcula la regresión y el bounding box para cada pieza detectada.
%
% Entrada:
%   - pieceClusters: celda de estructuras con campos x, y, nx, ny, curv, i0, i1
%
% Salida:
%   - resultados: array de structs con .edges, .linea, .boundingBox por pieza

    numPiezas = numel(pieceClusters);
    resultados = struct('edges', {}, 'linea', {}, 'boundingBox', {});

    for i = 1:numPiezas
        pieza = pieceClusters{i};
        
        % Calcular regresión lineal
        linea = computeLinearRegression(pieza);

        % Calcular bounding box rotado
        box = computeRotatedBoundingBox(pieza, linea);

        resultados(i).edges = pieza;
        resultados(i).linea = linea;
        resultados(i).boundingBox = box;
    end
end