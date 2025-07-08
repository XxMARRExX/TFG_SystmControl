function pieceClusters = associateInnerContoursToPieces(pieceClusters, innerClusters, maskLabel)
% ASSOCIATEINNERCONTOURSTOPIECES Asocia contornos interiores a las piezas correspondientes
%
% Entrada:
%   - pieceClusters: celda de clusters exteriores (estructuras)
%   - innerClusters: celda de contornos interiores
%   - maskLabel: máscara etiquetada (1, 2, 3, ...) con ID de cada pieza
%
% Salida:
%   - pieceClusters: igual que entrada, pero cada pieza tiene un campo adicional .innerContours

    numPieces = numel(pieceClusters);
    
    % Inicializar campo innerContours vacío
    for i = 1:numPieces
        pieceClusters{i}.innerContours = {};
    end

    % Asociar cada contorno interior
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
        pieceClusters{piezaId}.innerContours{end+1} = cluster;
    end
end
