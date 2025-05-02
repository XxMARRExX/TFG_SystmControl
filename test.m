clear; clc; close all;
totalStart = tic;

configParams = config();

%% Cargar la imagen
disp("1 -- Paso de la imagen a gris --")
image = imread("pictures/Imagen1.png");
grayImage = convertToGrayScale(image);


%% Detección de bordes subpíxel
disp("2 -- Detección de bordes --")
edges = subpixelEdges(grayImage, configParams.subpixelEdges.threshold, ...
    'SmoothingIter', configParams.subpixelEdges.smoothingIter);


%% Filtrado de puntos
disp("3 -- Filtrado por la normal del punto --")
newEdges = filterByNormalThreshold(edges, ...
    configParams.filterByNormal.normalThreshold);

disp("4 -- Filtro por franjas horizontales --")
newEdges = filterByHorizontalDensity(newEdges, ...
    configParams.filterByHorizontalDensity.minPoints, ...
    configParams.filterByHorizontalDensity.range, ...
    configParams.filterByHorizontalDensity.tolerance);


%% Reconstrucción de la pieza
disp("5 -- Generación de bordes verticales --")
edgesPiece = generateVerticalRegionFromEdges(edges, newEdges, ...
    configParams.generateVerticalRegionFromEdges.expansionX , ...
    configParams.generateVerticalRegionFromEdges.expansionY);
%showFilteredPoints(edges,edgesPiece);


%% Extracción de clusterés
disp("6 -- Agrupamiento mediante clusters --")
[clusters, noise] = analyzeSubstructuresWithDBSCAN(edgesPiece, ...
    configParams.analyzeSubstructures.eps, ...
    configParams.analyzeSubstructures.minPts);


%% Búsqueda de clusters que sean piezas
disp("7 -- Búsqueda de piezas --")
[pieceClusters, pieceEdges, numPieces, remainingClusters] = findPieceClusters(clusters);
%visClusters(grayImage, remainingClusters)

% Crear la máscara binaria de las piezas
disp("8 -- Extracción máscara de la pieza/s --")
maskPieza = createPieceMask_2(grayImage, pieceClusters);

% Filtrar los clusters internos candidatos
disp("9 -- Filtrado de clusters dentro de la pieza --")
filteredClusters = filterClustersInsideMask(remainingClusters, maskPieza);
visClusters(grayImage, filteredClusters)

disp("10 -- Limpieza morfológica de clusters restantes --")
cleanClusters = findInnerContours_2(filteredClusters, size(grayImage), ...
    configParams.findInnerContours_2.refImgSize, ...
    configParams.findInnerContours_2.maxMeanDist);
visClusters(grayImage, cleanClusters);


%% Tiempo total
disp(['Tiempo total del programa: ' num2str(toc(totalStart)) ' segundos'])