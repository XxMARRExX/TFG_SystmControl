function regionMap = classifyPixelRegions_2(grayImage, maskPieza, numPieces, verbose)
% CLASSIFYPIXELREGIONS_2 Clasifica píxeles como exterior, sólido o agujero adaptativamente por pieza
%
%   regionMap(i,j) = 0  → exterior (fuera de la pieza)
%                 = 1  → interior brillante (estructura sólida)
%                 = 2  → interior oscuro (posible agujero)
%
%   Entradas:
%       grayImage   - Imagen en escala de grises (uint8 o double)
%       maskPieza   - Máscara con etiquetas de pieza (1,2,3,...)
%       numPieces   - Número total de piezas (máximo valor en maskPieza)
%       verbose     - true para mostrar info
%
%   Salida:
%       regionMap   - Mapa de regiones clasificado

    if nargin < 4
        verbose = false;
    end

    grayImage = double(grayImage);
    regionMap = zeros(size(grayImage));

    for p = 1:numPieces

        % Crear máscara de la pieza p
        pieceMask = maskPieza == p;
        insideIdx = find(pieceMask);

        if isempty(insideIdx)
            continue;
        end

        intensities = grayImage(insideIdx);

        % Calcular percentil 20 dinámicamente → umbral de agujero
        perc20 = prctile(intensities, 20);

        % Calcular percentil 80 dinámicamente → umbral de sólido (opcional)
        perc80 = prctile(intensities, 80);

        % Clasificar
        isHole = intensities <= perc20;
        isSolid = intensities > perc20;

        regionMap(insideIdx(isHole)) = 2;
        regionMap(insideIdx(isSolid)) = 1;

        if verbose
            fprintf("[Pieza %d] Total píxeles: %d\n", p, numel(intensities));
            fprintf("[Pieza %d] Umbral agujero (P20): %.2f\n", p, perc20);
            fprintf("[Pieza %d] Clasificados como agujero: %d\n", p, sum(isHole));
            fprintf("[Pieza %d] Clasificados como sólidos: %d\n", p, sum(isSolid));
        end
    end

    if verbose
        figure;
        imagesc(regionMap);
        colormap([0 0 0; 1 1 1; 1 0 0]);
        colorbar;
        title('Mapa de regiones adaptativo por pieza');
        axis image;
    end
end
