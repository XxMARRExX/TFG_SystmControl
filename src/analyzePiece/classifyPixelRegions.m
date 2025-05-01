function regionMap = classifyPixelRegions(grayImage, maskPieza)
% CLASSIFYPIXELREGIONS Clasifica píxeles basándose en muestreo estructurado y clasificación localizada

    I = double(grayImage);
    [h, w] = size(I);
    regionMap = zeros(h, w);

    % --- Bounding box de la pieza ---
    stats = regionprops(maskPieza, 'BoundingBox');
    if isempty(stats)
        return;
    end
    bbox = round(stats(1).BoundingBox);
    xStart = max(bbox(1), 1);
    yStart = max(bbox(2), 1);
    xEnd = min(xStart + bbox(3) - 1, w);
    yEnd = min(yStart + bbox(4) - 1, h);

    % --- Recortar la imagen y la máscara ---
    maskCrop = maskPieza(yStart:yEnd, xStart:xEnd);
    ICrop = I(yStart:yEnd, xStart:xEnd);

    % --- Dividir la región en 12 bloques verticales ---
    [hCrop, wCrop] = size(ICrop);
    numRegions = 24;
    nSamplesPerRegion = 100;

    regionWidth = round(wCrop / numRegions);

    pieceSamples = [];
    backgroundSamples = [];

    rng(1); % Semilla fija

    for i = 1:numRegions
        xRegionStart = (i-1)*regionWidth + 1;
        xRegionEnd = min(i*regionWidth, wCrop);

        pieceMaskRegion = maskCrop(:, xRegionStart:xRegionEnd);
        backgroundMaskRegion = ~maskCrop(:, xRegionStart:xRegionEnd);

        pieceRegion = ICrop(:, xRegionStart:xRegionEnd);
        backgroundRegion = ICrop(:, xRegionStart:xRegionEnd);

        % Extraer píxeles válidos
        piecePixels = pieceRegion(pieceMaskRegion);
        backgroundPixels = backgroundRegion(backgroundMaskRegion);

        % Muestreo aleatorio dentro de cada región
        if ~isempty(piecePixels)
            idxPiece = randperm(length(piecePixels), min(nSamplesPerRegion, length(piecePixels)));
            pieceSamples = [pieceSamples; piecePixels(idxPiece)];
        end
        if ~isempty(backgroundPixels)
            idxBackground = randperm(length(backgroundPixels), min(nSamplesPerRegion, length(backgroundPixels)));
            backgroundSamples = [backgroundSamples; backgroundPixels(idxBackground)];
        end
    end

    % --- Filtrado de outliers ---
    if isempty(pieceSamples) || isempty(backgroundSamples)
        return; % Si no hay muestras suficientes, salir
    end

    pieceLow = prctile(pieceSamples, 5);
    pieceHigh = prctile(pieceSamples, 95);
    pieceSamplesFiltered = pieceSamples(pieceSamples >= pieceLow & pieceSamples <= pieceHigh);

    backgroundLow = prctile(backgroundSamples, 5);
    backgroundHigh = prctile(backgroundSamples, 95);
    backgroundSamplesFiltered = backgroundSamples(backgroundSamples >= backgroundLow & backgroundSamples <= backgroundHigh);

    % --- Estadísticas ---
    meanPiece = mean(pieceSamplesFiltered);
    stdPiece = std(pieceSamplesFiltered);

    meanBackground = mean(backgroundSamplesFiltered);
    stdBackground = std(backgroundSamplesFiltered);

    % --- Umbrales dinámicos ---
    darkThreshold = meanBackground + stdBackground;
    brightThreshold = meanPiece - stdPiece;

    % --- Clasificación solo dentro del recorte ---
    regionMapCrop = zeros(hCrop, wCrop);

    regionMapCrop(maskCrop & (ICrop < darkThreshold)) = 2; % Agujero
    regionMapCrop(maskCrop & (ICrop >= brightThreshold)) = 1; % Pieza sólida
    % Zona intermedia se queda como 0

    % --- Copiar de vuelta en el mapa global ---
    regionMap(yStart:yEnd, xStart:xEnd) = regionMapCrop;
end