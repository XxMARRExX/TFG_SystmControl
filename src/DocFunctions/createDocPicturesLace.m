clear; clc; close all;
totalStart = tic;
configParams = config();


%% Cargar la imagen
nombreImagen = "Imagen5";
disp("1 -- Paso de la imagen a gris --")
image = imread("pictures/Imagen5.png");
grayImage = convertToGrayScale(image);



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
[bboxSVG, centerSVG] = getSVGDimensions(svgFile);
exteriorContour = getLargestSVGPath(svgPaths);

plotSVGModel(svgPaths, exteriorContour)
fig = gcf;
title("Capa 11: LoadSVG");
grupo = "07_Encaje";
subgrupo = "07_1-CargaSVG";
saveImage(fig, nombreImagen, grupo, subgrupo);


disp("14 -- BoundingBox de la pieza --")
pieza = results.edges.exterior;
points2D = [pieza.x(:), pieza.y(:)];
model = fitrect2D(points2D);
center = model.Center;          
dims = model.Dimensions;       
angle = model.Angle;

plotPieceBoundingBox(points2D, model)
fig = gcf;
title("Capa 12: CalculateBbox");
grupo = "07_Encaje";
subgrupo = "07_2-CalculoBbox";
savePoints(points2D, "PuntosDetectados_Imagen5", grupo, subgrupo);
saveImage(fig, nombreImagen, grupo, subgrupo);


disp("15 -- Cambio de S.R. de los puntos detectados --")
[pointsTransformed, transform] = transformPointsToSVG(points2D, bboxSVG, dims, angle, center, centerSVG);

plotTransformedPoints(points2D, pointsTransformed)
fig = gcf;
title("Capa 13: CalculateBbox");
grupo = "07_Encaje";
subgrupo = "07_3-CambioSistRef";
saveImage(fig, nombreImagen, grupo, subgrupo);


disp("16 -- Resampleo de puntos del .svg --")
numDetected = size(pointsTransformed, 1);
contornoExteriorResampled = resamplePath(exteriorContour, numDetected);

plotResampledSVG(exteriorContour, contornoExteriorResampled)
fig = gcf;
title("Capa 14: RemuestrearContorno");
grupo = "07_Encaje";
subgrupo = "07_4-ResamppleContour";
saveImage(fig, nombreImagen, grupo, subgrupo);


disp("17 -- Optimización del encaje contorno exterior --")
[pointsAligned, tform, errors] = ICP2D(contornoExteriorResampled, pointsTransformed, ...
    'MaxIterations', 500, 'Tolerance', 1e-6, 'Verbose', false);

% Aplicar transformación final a los contornos internos ya pasados a SVG
disp("17.1 -- Transformación de contornos internos --")
contornosInternos = results.edges.innerContours;
contornosInternosAlineados = transformInnerContours(contornosInternos, ...
    bboxSVG, dims, angle, center, centerSVG, tform);


disp("18 -- Visualización encaje --")
visualizarAjusteICP(pointsAligned, svgPaths, contornosInternosAlineados);
fig = gcf;
title("Capa 15: Encaje");
grupo = "07_Encaje";
subgrupo = "07_5-ResultadoEncaje";
saveImage(fig, nombreImagen, grupo, subgrupo);

%% Tiempo total
disp(['Tiempo total del programa: ' num2str(toc(totalStart)) ' segundos'])