%% Mostrar bordes detectados con ROI dinámica
clear; clc; close all;

%% Cargar la imagen
image = imread("pictures\Imagen2.png");
grayImage = convertToGrayScale(image);

%% Detección de bordes subpíxel
threshold = 10;  % Ajusta el umbral según la calidad de la imagen
edges = subpixelEdges(grayImage, threshold, 'SmoothingIter', 1);

%% Filtrado basado en la normal de los puntos
newEdges = filterByNormalThreshold(edges);

%% Filtrado basado en la densidad de puntos sobre un intervalo horizontal
newEdges = filterByHorizontalDensity(newEdges, 450, 1000);

%% Reconstrucción de los bordes de la pieza
edgesPiece = generateVerticalRegionFromEdges(edges, newEdges,0.1,0.05);

regressionLine = computeLinearRegression(edgesPiece);

%% Se muestra el análisis de la imagen
showImageWithEdges(grayImage, edgesPiece, regressionLine);
visEdges(edgesPiece);
