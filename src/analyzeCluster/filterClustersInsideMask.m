function insideClusters = filterClustersInsideMask(clusters, mask, minInclusionRatio)
% Filtra los clusters que están suficientemente contenidos en la máscara binaria

if nargin < 3
    minInclusionRatio = 1; % Por defecto, al menos el 90% de los puntos deben estar dentro
end

insideClusters = {};
for i = 1:length(clusters)
    c = clusters{i};
    % Redondear las coordenadas a píxeles válidos
    x = round(c.x);
    y = round(c.y);
    
    % Eliminar puntos fuera de rango
    valid = x >= 1 & x <= size(mask,2) & y >= 1 & y <= size(mask,1);
    x = x(valid);
    y = y(valid);
    
    % Ver cuántos puntos están dentro de la máscara
    idx = sub2ind(size(mask), y, x);
    numInside = sum(mask(idx));
    ratio = numInside / length(x);
    
    if ratio >= minInclusionRatio
        insideClusters{end+1} = c; %#ok<AGROW>
    end
end
end
