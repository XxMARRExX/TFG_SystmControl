clear; clc; close all;
totalStart = tic;
configParams = config();


%% Cargar la imagen
nombreImagen = "Imagen8";
disp("1 -- Paso de la imagen a gris --")
image = imread("pictures/Imagen8.png");
rescaledImage = imresize(image, 0.8);
grayImage = convertToGrayScale(rescaledImage);

figure;
subplot(1,2,1);
imshow(image);
title('Imagen original');

subplot(1,2,2);
imshow(rescaledImage);
title('Imagen reescalada (80%)');

%% Detección de bordes subpíxel
disp("2 -- Detección de bordes --")
edges = subpixelEdges(grayImage, configParams.subpixelEdges.threshold, ...
    'SmoothingIter', configParams.subpixelEdges.smoothingIter);
%{
fig = figure(); visEdges(edges);
title("Capa 1: DetectedEdges");
grupo = "01_Bordes_Detectados";
subgrupo = "";
saveImage(fig, nombreImagen, grupo, subgrupo);
%}


%% Filtrado de puntos
disp("3 -- Filtrado por la normal del punto --")
newEdges = filterByNormalThreshold(edges, ...
    configParams.filterByNormal.normalThreshold);
%{
fig = figure(); visEdges(newEdges);
title("Capa 2: FilterByNormal");
grupo = "02_Filtros";
subgrupo = "02_4-Filtro_OrtcnNormal";
saveImage(fig, nombreImagen, grupo, subgrupo);
%}

disp("4 -- Filtro por franjas horizontales --")
newEdges = filterByHorizontalDensity(newEdges, ...
    configParams.filterByHorizontalDensity.minPoints, ...
    configParams.filterByHorizontalDensity.range, ...
    configParams.filterByHorizontalDensity.tolerance);
%{
fig = figure(); visEdges(newEdges);
title("Capa 3: FilterByHorizontalDensity");
grupo = "02_Filtros";
subgrupo = "02_5-Filter_HorzntlDensity";
saveImage(fig, nombreImagen, grupo, subgrupo);
%}


%% Reconstrucción de la pieza
disp("5 -- Generación de bordes verticales --")
edgesPiece = generateVerticalRegionFromEdges(edges, newEdges, ...
    configParams.generateVerticalRegionFromEdges.expansionX , ...
    configParams.generateVerticalRegionFromEdges.expansionY);
%{
showFilteredPoints(edges,edgesPiece);
fig = gcf;
title("Capa 4: generateVerticalRegionFromEdges");
grupo = "03_Heuristicas";
subgrupo = "03_4-GenerateVerticalRegion";
saveImage(fig, nombreImagen, grupo, subgrupo);
%}


%% Extracción de clusterés
disp("6 -- Agrupamiento mediante clusters --")
[clusters, noise] = analyzeSubstructuresWithDBSCAN(edgesPiece, ...
    configParams.analyzeSubstructures.eps, ...
    configParams.analyzeSubstructures.minPts);
%{
visClusters(grayImage, clusters);
fig = gcf;
title("Capa 5: GroupByCluster");
grupo = "03_Heuristicas";
subgrupo = "03_2-DBSCAN";
saveImage(fig, nombreImagen, grupo, subgrupo);
%}

disp("7 -- Búsqueda de piezas --")
[pieceClusters, pieceEdges, numPieces, remainingClusters] = findPieceClusters(clusters);
%{
visClusters(grayImage, pieceClusters);
fig = gcf;
title("Capa 6: FindPieceCluster");
grupo = "02_Filtros";
subgrupo = "02_6-Filter_FindPieceCluster";
saveImage(fig, nombreImagen, grupo, subgrupo);
%}

% Crear la máscara binaria de las piezas
disp("8 -- Extracción máscara de la pieza/s --")
maskPieza = createPieceMask(grayImage, pieceClusters);

%{
imshow(maskPieza);
fig = gcf;
title("Capa 7: CreatePieceMask");
grupo = "03_Heuristicas";
subgrupo = "03_3-PieceMask";
saveImage(fig, nombreImagen, grupo, subgrupo);
%}

% Filtrar los clusters internos candidatos
disp("9 -- Filtrado de clusters dentro de la pieza --")
filteredClusters = filterClustersInsideMask(remainingClusters, maskPieza);
%{
visClusters(grayImage, filteredClusters);
fig = gcf;
title("Capa 8: FindInnerContoursPiece");
grupo = "02_Filtros";
subgrupo = "02_7-InnerCountoursPieceFound";
saveImage(fig, nombreImagen, grupo, subgrupo);
%}

disp("10 -- Búsqueda de contornos internos --")
piecesInnerContours = findInnerContours(filteredClusters, size(grayImage), ...
    configParams.findInnerContours.refImgSize, ...
    configParams.findInnerContours.maxMeanDist);
%{
visClusters(grayImage, piecesInnerContours);
fig = gcf;
title("Capa 9: DetectedInnerContours");
grupo = "02_Filtros";
subgrupo = "02_8-RealInnerCountoursPiece";
saveImage(fig, nombreImagen, grupo, subgrupo);
%}

disp("11 -- Asociación de contornos internos a pieza/s --")
pieceClusters = associateInnerContoursToPieces(pieceClusters, piecesInnerContours, maskPieza);



%% Análisis de la pieza/s
disp("12 -- Cálculo de la geometría --")
results = analyzePieceGeometry(pieceClusters);


%{
showImageWithEdges(grayImage, results);
fig = gcf;
title("Capa 10: Results");
grupo = "04_Resultados";
subgrupo = "TFG - ResultadosDeteccion_v14062025";
saveImage(fig, nombreImagen, grupo, subgrupo);
%}



%% Proceso de encaje
disp("13 -- Carga del modelo .svg --")
svgFile = 'data/models/Pieza-patron.svg';
svgPaths = importSVG(svgFile);

%plotSVGModel(svgPaths)
fig = gcf;
title("Capa 11: LoadSVG");
grupo = "07_Encaje";
subgrupo = "07_1-CargaSVG";
%saveImage(fig, nombreImagen, grupo, subgrupo);


disp("14 -- BoundingBox de la pieza --")
modelSVG = fitSVGPathsBoundingBox(svgPaths);
cornersSVG = computeBoundingBox(modelSVG.Center, modelSVG.Dimensions, modelSVG.Orientation);
cornersSVG   = reorderCorners(cornersSVG);
%drawSVGBoundingBox(svgPaths, cornersSVG, 'g');

%fig = gcf;
title("Capa 12: Bbox SVG");
grupo = "07_Encaje";
subgrupo = "07_7-BboxSVG";
%saveImage(fig, nombreImagen, grupo, subgrupo);


disp("15 -- BoundingBox de la pieza detectada --")
modelPieza = fitDetectedPieceBoundingBox(results.edges);
cornersPieza = computeBoundingBox(modelPieza.Center, modelPieza.Dimensions, modelPieza.Orientation);
cornersPieza = reorderCorners(cornersPieza);
%drawPieceBoundingBox(results.edges, cornersPieza, 'r');

%fig = gcf;
title("Capa 13: Bbox Pieza");
grupo = "07_Encaje";
subgrupo = "07_8-BboxPieza";
%saveImage(fig, nombreImagen, grupo, subgrupo);


disp("16 -- Superposición de ambos Bboxes --")
[d, Z, transform] = procrustes(cornersSVG, cornersPieza, 'Scaling', true, 'Reflection', false);
drawBoundingBoxesAlignment(cornersSVG, Z);

%fig = gcf;
title("Capa 14: Superposición de ambos Bboxes");
grupo = "07_Encaje";
subgrupo = "07_9-AlineacionBboxes";
%saveImage(fig, nombreImagen, grupo, subgrupo);



%% Prueba de error
computePieceErrors(results.edges, svgPaths);



disp("17 -- Visualización de puntos alineados sobre SVG --")
drawPieceOnSVG(results.edges, svgPaths, transform);

fig = gcf;
grupo = "07_Encaje";
subgrupo = "07_5-ResultadoEncaje";  
%saveImage(fig, nombreImagen, grupo, subgrupo);

%% Tiempo total
disp(['Tiempo total del programa: ' num2str(toc(totalStart)) ' segundos'])
