function pieceClusters = associateInnerContoursToPieces(pieceClusters, innerClusters, maskLabel)
% ASSOCIATEINNERCONTOURSTOPIECES Asocia contornos interiores a las piezas correspondientes
%
% Entrada:
%   - pieceClusters: celda de clusters exteriores (estructuras con campos x, y)
%   - innerClusters: celda de contornos interiores
%   - maskLabel: máscara etiquetada (1, 2, 3, ...) con ID de cada pieza
%
% Salida:
%   - pieceClusters: estructuras reorganizadas con:
%       - edges.exterior: contorno exterior
%       - edges.innerContours: celdas de contornos interiores

    numPieces = numel(pieceClusters);
    
    % Inicializar campo .edges.innerContours vacío
    for i = 1:numPieces
        pieceClusters{i}.edges.innerContours = {};
    end

    % Asociar cada contorno interior a la pieza correspondiente
    for i = 1:numel(innerClusters)
        cluster = innerClusters{i};
        x = round(cluster.x(:));
        y = round(cluster.y(:));
        
        valid = x >= 1 & x <= size(maskLabel, 2) & y >= 1 & y <= size(maskLabel, 1);
        x = x(valid);
        y = y(valid);
        
        if isempty(x)
            continue;
        end
        
        % Centroide aproximado
        x_c = round(mean(x));
        y_c = round(mean(y));
        
        piezaId = maskLabel(y_c, x_c);
        
        if piezaId == 0
            continue;
        end
        
        % Añadir el contorno interior a la pieza correspondiente
        pieceClusters{piezaId}.edges.innerContours{end+1} = cluster;
    end

    % Reorganizar contornos exteriores dentro de .edges.exterior
    for i = 1:numPieces
        piece = pieceClusters{i};

        % Mover x, y al nuevo subcampo exterior
        pieceClusters{i}.edges.exterior = struct( ...
            'x', piece.x(:), ...
            'y', piece.y(:) ...
        );
        
        % Eliminar campos antiguos innecesarios
        pieceClusters{i} = rmfield(pieceClusters{i}, {'x', 'y'});
    end
end
