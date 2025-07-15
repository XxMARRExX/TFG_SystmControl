clear; clc; close all;

totalStart = tic;

configParams = config();

%% Cargar la imagen
disp("1 -- Paso de la imagen a gris --")
image = imread("pictures/Imagen5.png");
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


%% Extracción de clusterés
disp("6 -- Agrupamiento mediante clusters --")
[clusters, noise] = analyzeSubstructuresWithDBSCAN(edgesPiece, ...
    configParams.analyzeSubstructures.eps, ...
    configParams.analyzeSubstructures.minPts);


%% Generación de la pieza
disp("7 -- Búsqueda de piezas --")
[pieceClusters, pieceEdges, numPieces, remainingClusters] = findPieceClusters(clusters);
%visClusters(grayImage, remainingClusters)

% Crear la máscara binaria de las piezas
disp("8 -- Extracción máscara de la pieza/s --")
maskPieza = createPieceMask(grayImage, pieceClusters);

% Filtrar los clusters internos candidatos
disp("9 -- Filtrado de clusters dentro de la pieza --")
filteredClusters = filterClustersInsideMask(remainingClusters, maskPieza);

disp("10 -- Búsqueda de contornos internos --")
piecesInnerContours = findInnerContours(filteredClusters, size(grayImage), ...
    configParams.findInnerContours.refImgSize, ...
    configParams.findInnerContours.maxMeanDist);

disp("11 -- Asociación de contornos internos a pieza/s --")
pieceClusters = associateInnerContoursToPieces(pieceClusters, piecesInnerContours, maskPieza);


%% Análisis de la pieza/s
disp("12 -- Cálculo de la geometría --")
results = analyzePieceGeometry(pieceClusters);



%% Proceso de encaje
disp("13 -- Carga del modelo .svg --")
svgFile = 'data/models/Pieza-patron.svg';
svgPaths = importSVG(svgFile);
[bboxSVG, centerSVG] = getSVGDimensions(svgFile);
exteriorCountour = getLargestSVGPath(svgPaths);


disp("14 -- BoundingBox de la pieza --")
pieza = results.edges.exterior;
points2D = [pieza.x(:), pieza.y(:)];
linea = results.linea;
pointsRectified = rectifyOrientationByRegression(points2D, linea);
plotRectificationComparison(points2D, pointsRectified)

% Nuevo centro (media de los puntos rotados)
center = mean(pointsRectified);

% Dimensiones: ancho y alto del bounding box no rotado
xrange = max(pointsRectified(:,1)) - min(pointsRectified(:,1));
yrange = max(pointsRectified(:,2)) - min(pointsRectified(:,2));
dims = [xrange, yrange];

% El ángulo ya está corregido, así que es 0
angle = 0;


%{
model = fitrect2D(points2D);
center = model.Center;          
dims = model.Dimensions;       
angle = model.Angle;
%}


disp("15 -- Cambio de S.R. de los puntos detectados --")
[pointsTransformed, transform] = transformPointsToSVG(pointsRectified, bboxSVG, dims, angle, center, centerSVG);


disp("16 -- Resampleo de puntos del .svg --")
numDetected = size(pointsTransformed, 1);
contornoExteriorResampled = resamplePath(exteriorCountour, numDetected);

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


%% Tiempo total
disp(['Tiempo total del programa: ' num2str(toc(totalStart)) ' segundos'])