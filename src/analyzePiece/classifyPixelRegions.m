function regionMap = classifyPixelRegions(grayImage, maskPieza)
% CLASSIFYPIXELREGIONS Clasifica cada píxel según intensidad y pertenencia a la pieza
%
%   Salidas:
%     regionMap(i,j) = 0  → exterior (fuera de la pieza)
%                    = 1  → interior brillante (estructura sólida)
%                    = 2  → interior oscuro (posible agujero)

    I = double(grayImage);

    % Inicializar con ceros (exterior)
    regionMap = zeros(size(I));

    % Aplicar clasificación solo dentro de la pieza
    inside = find(maskPieza);
    intensity = I(inside);

    % Umbrales sugeridos
    darkThreshold = 80;    % debajo = agujero
    brightThreshold = 160; % encima = zona sólida

    regionMap(inside(intensity < darkThreshold)) = 2; % agujero
    regionMap(inside(intensity >= brightThreshold)) = 1; % zona brillante (pieza)

    % Lo que queda (entre 80 y 160) sigue como 0 → zona dudosa (transición)
end
