function insideClusters = filterClustersInsideMask(clusters, mask, minInclusionRatio)
% FILTRO DE CLUSTERS -> Devuelve solo los clusters suficientemente contenidos en la máscara
%
% Entrada:
%   clusters: celda de clusters (estructuras con campos x, y, nx, ny, curv, i0, i1, ...)
%   mask: máscara binaria o etiquetada
%   minInclusionRatio: proporción mínima de puntos dentro para aceptar el cluster (default 1)
%
% Salida:
%   insideClusters: clusters filtrados con todos los campos coherentes

    if nargin < 3
        minInclusionRatio = 1;
    end

    insideClusters = {};

    for i = 1:length(clusters)
        c = clusters{i};
        
        % Redondear coordenadas
        x = round(c.x);
        y = round(c.y);
        
        % Validar que estén dentro de la imagen
        valid = x >= 1 & x <= size(mask,2) & y >= 1 & y <= size(mask,1);
        
        % Si no quedan puntos válidos, saltar
        if sum(valid) == 0
            continue;
        end
        
        x = x(valid);
        y = y(valid);
        
        % Calcular ratio dentro de la máscara
        idx = sub2ind(size(mask), y, x);
        numInside = sum(mask(idx));
        ratio = numInside / length(x);
        
        if ratio >= minInclusionRatio
            % Crear cluster limpio
            filteredCluster = struct();
            fields = fieldnames(c);
            
            for f = 1:numel(fields)
                campo = fields{f};
                valor = c.(campo);
                
                if numel(valor) == numel(valid)
                    % Filtrar vectores (x, y, nx, ny, curv, i0, i1, etc.)
                    valor = valor(valid);
                end
                
                filteredCluster.(campo) = valor;
            end
            
            insideClusters{end+1} = filteredCluster;
        end
    end
end
