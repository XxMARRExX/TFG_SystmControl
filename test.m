clear; clc; close all;

%% Cargar la imagen
%stepStart = tic;
image = imread("pictures/Imagen2.png");
grayImage = convertToGrayScale(image);
disp("1 -- Imagen pasada a gris --")
%disp(['Tiempo: ' num2str(toc(stepStart)) ' segundos'])

% muestra 1 de cada 5 píxeles
%showPixelIntensities(grayImage); 


%% Detección de bordes subpíxel
threshold = 10;  % Ajusta el umbral según la calidad de la imagen
edges = subpixelEdges(grayImage, threshold, 'SmoothingIter', 1);
disp("2 -- Bordes detectados --")


%% Filtrado de puntos
% Filtrado basado en la normal de los puntos
filteredEdges = filterByNormalThreshold(edges);
disp("3 -- Filtro de la normal --")

% Filtrado basado en la densidad de puntos sobre un intervalo horizontal 
% (rotado o no)
filteredEdges = filterByHorizontalDensity(filteredEdges, 450, 200, 0.05);
disp("4 -- Filtro bordes horizontales --")
visEdges(filteredEdges);

%% Reconstrucción de los bordes verticales de la pieza
edgesPiece = generateVerticalRegionFromEdges(edges, filteredEdges, 0.1, 0.05);
%showFilteredPoints(edges, edgesPiece);
%visEdges(edgesPiece)
disp("5 -- Generación de bordes verticales --")


%% Extracción de clusterés
[clusters, noise] = analyzeSubstructuresWithDBSCAN(edgesPiece, 6, 4);
disp("6 -- Agrupamiento mediante clusters --")
visClusters(grayImage, clusters);

% Búsqueda de clusters que sean piezas
[pieceClusters, pieceEdges, numPieces, remainingClusters] = findPieceClusters(clusters);
disp("7 -- Búsqueda de piezas --")

% Crear la máscara binaria de las piezas
maskPieza = createPieceMask(grayImage, pieceClusters);
%imshow(maskPieza);
disp("8 -- Máscara de la pieza --")

% Filtrar los clusters internos candidatos
filteredClusters = filterClustersInsideMask(remainingClusters, maskPieza);
disp("9 -- Filtrado de clusters dentro de la pieza --")

% Clasificación: Pieza, Fondo, Agujero y transición
stepStart = tic;
regionMap = classifyPixelRegions(grayImage, maskPieza);
disp("10 -- Clasificación de las regiones --")
disp(['Tiempo: ' num2str(toc(stepStart)) ' segundos'])

imshow(regionMap)