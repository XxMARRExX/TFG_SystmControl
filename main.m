%% Mostrar bordes detectados con ROI dinámica
clear; clc; close all;

% Cargar la imagen
image = imread("pictures\Imagen2.png");
grayImage = convertToGrayScale(image);

% Detección de bordes subpíxel
threshold = 10;  % Ajusta el umbral según la calidad de la imagen
edges = subpixelEdges(grayImage, threshold, 'SmoothingIter', 1);

% Filtrar outliers y obtener los índices válidos
[line, x_filtrado, y_filtrado, idx_valido] = filteredOutliers(edges.x, edges.y, true);

% Aplicar la misma filtración a los otros vectores de 'edges'
edges.x = x_filtrado;
edges.y = y_filtrado;
edges.nx = edges.nx(idx_valido);
edges.ny = edges.ny(idx_valido);
edges.curv = edges.curv(idx_valido);
edges.i0 = edges.i0(idx_valido);
edges.i1 = edges.i1(idx_valido);

[x_filtrado, y_filtrado, idx_valido] = filteredOutliers_2(edges.x, edges.y, true);

edges.x = x_filtrado;
edges.y = y_filtrado;
edges.nx = edges.nx(idx_valido);
edges.ny = edges.ny(idx_valido);
edges.curv = edges.curv(idx_valido);
edges.i0 = edges.i0(idx_valido);
edges.i1 = edges.i1(idx_valido);

pointsPlotX(edges);
pointsPlotY(edges);
%showImageWithEdges(grayImage, edges);
analyzePieceOrientation(grayImage, edges);
drawBoundingBox(grayImage, edges);
