clear; clc; close all;

%% Cargar la imagen
image = imread("pictures/Imagen4.png");
grayImage = convertToGrayScale(image);

% muestra 1 de cada 5 píxeles
showPixelIntensities(grayImage); 


%% Detección de bordes subpíxel
threshold = 10;  % Ajusta el umbral según la calidad de la imagen
edges = subpixelEdges(grayImage, threshold, 'SmoothingIter', 1);


%% Filtrado de puntos
% Filtrado basado en la normal de los puntos
newEdges = filterByNormalThreshold(edges);

% Filtrado basado en la densidad de puntos sobre un intervalo horizontal 
% (rotado o no)
newEdges = filterByHorizontalDensity(newEdges, 450, 200, 0.05);


%% Reconstrucción de la pieza
edgesPiece = generateVerticalRegionFromEdges(edges, newEdges,0.1,0.05);
%showFilteredPoints(edges,edgesPiece);


%% Extracción de clusterés
[clusters, noise] = analyzeSubstructuresWithDBSCAN(edgesPiece, 6, 4);

% Búsqueda de clusters que sean piezas
[pieceClusters, pieceEdges, numPieces, remainingClusters] = findPieceClusters(clusters);

% Crear la máscara binaria de las piezas
maskPieza = createPieceMask(grayImage, pieceClusters);

% Filtrar los clusters internos candidatos
filteredClusters = filterClustersInsideMask(remainingClusters, maskPieza);

% Clasificación: Pieza, Fondo, Agujero y transición
regionMap = classifyPixelRegions(grayImage, maskPieza);

%{
imagesc(regionMap);
colormap([0 0 0; 0.5 0.5 0.5; 1 0 0]); % fondo, pieza, agujero
axis equal tight;
title('Mapa de regiones (0: fondo, 1: pieza, 2: agujero)');
%}

% Detección de los contornos interiores de cada pieza
innerContours = findInnerContours(regionMap, remainingClusters, pieceClusters, ...
                                  'RingRadius',20,'MinPointsRing',5);

%% Análisis de la pieza/s

% Calcular geometría para cada pieza detectada
results = analyzePieceGeometry(pieceClusters);

% Mostrar cada pieza con su análisis
showImageWithEdges(grayImage, results, innerContours);
