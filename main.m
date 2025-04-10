%% Mostrar bordes detectados con ROI dinámica
clear; clc; close all;

%% Cargar la imagen
image = imread("pictures/Imagen7.png");
grayImage = convertToGrayScale(image);

%% Detección de bordes subpíxe
threshold = 10;  % Ajusta el umbral según la calidad de la imagen
edges = subpixelEdges(grayImage, threshold, 'SmoothingIter', 1);

%% Filtrado basado en la normal de los puntos
newEdges = filterByNormalThreshold(edges);

%% Filtrado basado en la densidad de puntos sobre un intervalo horizontal
newEdges = filterByHorizontalDensity(newEdges, 450, 1000);

%% Reconstrucción de los bordes de la pieza
edgesPiece = generateVerticalRegionFromEdges(edges, newEdges,0.1,0.05);

%% Extracción de clusterés
[clusters, noise] = analyzeSubstructuresWithDBSCAN(edgesPiece, 6, 4);
visClusters(grayImage, clusters);

% Clusters de piezas
[pieceClusters, pieceEdges, numPieces] = findPieceClusters(clusters);

% Visualización (opcional)
%visClusters(grayImage, pieceClusters);

%% Análisis de la imagen

% Calcular geometría para cada pieza detectada
resultados = analyzePieceGeometry(pieceClusters);

% Mostrar cada pieza con su análisis
showImageWithEdges(grayImage, resultados);