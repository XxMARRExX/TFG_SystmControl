function regionMap = classifyPixelRegions(grayImage, maskPieza, verbose)
% CLASSIFYPIXELREGIONS Clasifica cada píxel según su intensidad y pertenencia a la pieza
%
%   regionMap(i,j) = 0  → exterior (fuera de la pieza o transición)
%                 = 1  → interior brillante (estructura sólida)
%                 = 2  → interior oscuro (posible agujero)
%
%   Entradas:
%       grayImage  - Imagen en escala de grises (uint8 o double)
%       maskPieza  - Máscara lógica donde es verdadera la zona de la pieza
%       verbose    - (opcional) true para mostrar información y visualizar resultado
%
%   Salida:
%       regionMap  - Mapa de regiones clasificado

    if nargin < 3
        verbose = false;
    end

    % Convertir imagen a tipo double para procesamiento
    grayImage = double(grayImage);

    % Inicializar mapa con ceros (exterior por defecto)
    regionMap = zeros(size(grayImage));

    % Obtener índices de los píxeles dentro de la pieza
    insideIdx = find(maskPieza);
    intensities = grayImage(insideIdx);

    % Definir umbrales de clasificación
    darkThreshold = 80;     % Intensidad menor → agujero
    brightThreshold = 160;  % Intensidad mayor o igual → zona sólida

    % Clasificar píxeles dentro de la pieza
    darkPixels = intensities < darkThreshold;
    brightPixels = intensities >= brightThreshold;

    regionMap(insideIdx(darkPixels)) = 2;   % Interior oscuro (agujero)
    regionMap(insideIdx(brightPixels)) = 1; % Interior brillante (pieza sólida)

    % Opcional: información de depuración
    if verbose
        fprintf("Total de píxeles dentro de la pieza: %d\n", numel(intensities));
        fprintf("Clasificados como agujero: %d\n", sum(darkPixels));
        fprintf("Clasificados como sólidos: %d\n", sum(brightPixels));
        fprintf("En transición (entre umbrales): %d\n", sum(~darkPixels & ~brightPixels));

        % Visualización rápida
        figure;
        imagesc(regionMap);
        colormap([0 0 0; 1 1 1; 1 0 0]); % 0: negro (exterior/transición), 1: blanco (sólido), 2: rojo (agujero)
        colorbar;
        title('Mapa de regiones');
        axis image;
    end
end
