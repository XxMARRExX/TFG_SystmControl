clear; clc; close all;
totalStart = tic;

%% Cargar la imagen
image = imread("pictures/Imagen5.png");
grayImage = convertToGrayScale(image);
disp("1 -- Imagen pasada a gris --")


%% Detección de bordes subpíxel
threshold = 20;  % Ajusta el umbral según la calidad de la imagen
edges = subpixelEdges(grayImage, threshold, 'SmoothingIter', 1);
disp("2 -- Bordes detectados --")


%% Filtrado de puntos
% Filtrado basado en la normal de los puntos
newEdges = filterByNormalThreshold(edges);
disp("3 -- Filtro de la normal --")

% Filtrado basado en la densidad de puntos sobre un intervalo horizontal 
% (rotado o no)
newEdges = filterByHorizontalDensity(newEdges, 450, 200, 0.05);
disp("4 -- Filtro bordes horizontales --")


%% Reconstrucción de la pieza
edgesPiece = generateVerticalRegionFromEdges(edges, newEdges,0.1,0.05);
%showFilteredPoints(edges,edgesPiece);
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
regionMap = classifyPixelRegions(grayImage, maskPieza, true);
disp("10 -- Clasificación de las regiones --")


%{
imagesc(regionMap);
colormap([0 0 0; 0.5 0.5 0.5; 1 0 0]); % fondo, pieza, agujero
axis equal tight;
title('Mapa de regiones (0: fondo, 1: pieza, 2: agujero)');
%}

% Detección de los contornos interiores de cada pieza
pieceClusters  = findInnerContours(regionMap, remainingClusters, pieceClusters, ...
                                  'RingRadius',20,'MinPointsRing',5);
disp("11 -- Búsqueda de contornos internos --")

%% Análisis de la pieza/s

% Calcular geometría para cada pieza detectada
results = analyzePieceGeometry(pieceClusters);
disp("12 -- Cálculo de la geometría --")

% Mostrar cada pieza con su análisis
showImageWithEdges(grayImage, results);
disp("13 -- Visualización de los resultados --")

%% Tiempo total
disp(['Tiempo total del programa: ' num2str(toc(totalStart)) ' segundos'])

