clear; clc; close all;
totalStart = tic;
configParams = config();



nombreImagen = "";
disp("1 -- Paso de la imagen a gris --")
image = imread("pictures/Pieza2/OLD/Imagen4.png");
grayImage = convertToGrayScale(image);



disp("2 -- Rescalado de la imagen --")
rescaledImage = imresize(grayImage, configParams.subpixelEdges.scale);



disp("3 -- Detección de bordes para Bbox --")
edges = subpixelEdges(rescaledImage, configParams.subpixelEdges.threshold_Phase1, ...
    'SmoothingIter', configParams.subpixelEdges.smoothingIter_Phase1);
bBoxRescaled = minBoundingBox([edges.x, edges.y]');

% visualizeImageWithEdges(rescaledImage, edges, "Subpixel edges (rescaled)");
% drawBoundingBoxOnImage(rescaledImage, bBoxRescaled);
% fig = gcf;
% title("Capa 1: Cálculo del Bbox pieza");
% grupo = "01_Bordes_Detectados";
% subgrupo = "01_1-BordersForBbox";
% saveImage(fig, nombreImagen, grupo, subgrupo);



disp("4 -- Cálculo del Bbox de la posible pieza --")
BboxPiece = calculateExpandedBoundingBox(edges, ...
    configParams.subpixelEdges.scale, configParams.BboxPiece.margin);

% drawBoundingBoxOnImage(grayImage, BboxPiece);
% fig = gcf;
% title("Capa 2: FindPieceCluster");
% grupo = "03_Heuristicas";
% subgrupo = "03_5-RescaledBbox";
% saveImage(fig, nombreImagen, grupo, subgrupo);



disp("5 -- Detección de bordes para contornos internos --")
edges = subpixelEdges(grayImage, configParams.subpixelEdges.threshold_Phase2, ...
    'SmoothingIter', configParams.subpixelEdges.smoothingIter_Phase2);
edgesFiltered = filterEdgesByBoundingBox(edges, BboxPiece);

% visualizeImageWithEdges(grayImage, edgesFiltered, "Subpixel edges");
% showFilteredPoints(edges, edgesFiltered);
% fig = gcf;
% title("Capa 3: PointsInsidePiece");
% grupo = "02_Filtros";
% subgrupo = "02_9-FilterPointsInsidePiece";
% saveImage(fig, nombreImagen, grupo, subgrupo);



disp("6 -- Agrupamiento mediante clusters --")
[clusters, noise] = analyzeSubstructuresWithDBSCAN(edgesFiltered, ...
    configParams.analyzeSubstructures.eps, ...
    configParams.analyzeSubstructures.minPts);

% visClusters(grayImage, clusters);
% fig = gcf;
% title("Capa 4: PointsInsidePiece");
% grupo = "03_Heuristicas";
% subgrupo = "03_6-FoundedClusters";
% saveImage(fig, nombreImagen, grupo, subgrupo);



disp("7 -- Búsqueda de piezas --")
[pieceClusters, pieceEdges, numPieces, remainingClusters] = findPieceClusters(clusters);

% visClusters(grayImage, pieceClusters);
% fig = gcf;
% title("Capa 5: FindPieceCluster");
% grupo = "02_Filtros";
% subgrupo = "02_6-Filter_FindPieceCluster";
% saveImage(fig, nombreImagen, grupo, subgrupo);



disp("8 -- Extracción máscara de la pieza/s --")
maskPieza = createPieceMask(grayImage, pieceClusters);

% imshow(maskPieza);
% fig = gcf;
% title("Capa 6: CreatePieceMask");
% grupo = "03_Heuristicas";
% subgrupo = "03_3-PieceMask";
% saveImage(fig, nombreImagen, grupo, subgrupo);



disp("9 -- Filtrado de clusters dentro de la pieza --")
filteredClusters = filterClustersInsideMask(remainingClusters, maskPieza);

% visClusters(grayImage, filteredClusters);
% fig = gcf;
% title("Capa 7: FindInnerContoursPiece");
% grupo = "02_Filtros";
% subgrupo = "02_7-InnerCountoursPieceFound";
% saveImage(fig, nombreImagen, grupo, subgrupo);



disp("10 -- Búsqueda de contornos internos --")
piecesInnerContours = findInnerContours(filteredClusters, size(grayImage), ...
    configParams.findInnerContours.refImgSize, ...
    configParams.findInnerContours.maxMeanDist);

% visClusters(grayImage, piecesInnerContours);
% fig = gcf;
% title("Capa 8: DetectedInnerContours");
% grupo = "02_Filtros";
% subgrupo = "02_8-RealInnerCountoursPiece";
% saveImage(fig, nombreImagen, grupo, subgrupo);



disp("11 -- Asociación de contornos internos a pieza/s --")
pieceClusters = associateInnerContoursToPieces(pieceClusters, piecesInnerContours, maskPieza);

% showImageWithEdges(grayImage, pieceClusters);
% fig = gcf;
% title("Capa 9: Results");
% grupo = "04_Resultados";
% subgrupo = "TFG - ResultadosDeteccion_v14062025";
% saveImage(fig, nombreImagen, grupo, subgrupo);




%% Proceso de encaje
disp("12 -- Carga del modelo .svg --")
svgFile = 'data/models/Pieza2.svg';
svgPaths = importSVG(svgFile);

% plotSVGModel(svgPaths)
% fig = gcf;
% title("Capa 10: LoadSVG");
% grupo = "07_Encaje";
% subgrupo = "07_1-CargaSVG";
% saveImage(fig, nombreImagen, grupo, subgrupo);



disp("13 -- BoundingBox del SVG --")
cornersSVG = calculateBboxSVG(svgPaths);

% drawSVGBoundingBox(svgPaths, cornersSVG, 'g');
% fig = gcf;
% title("Capa 11: Bbox SVG");
% grupo = "07_Encaje";
% subgrupo = "07_7-BboxSVG";
% saveImage(fig, nombreImagen, grupo, subgrupo);



disp("14 -- BoundingBox de la pieza detectada --")
points = [pieceClusters{1}.edges.exterior.x, pieceClusters{1}.edges.exterior.y];
bBoxFinal = minBoundingBox(points');
cornersPiece = formatCorners(bBoxFinal);

% drawPieceBoundingBox(pieceClusters, cornersPiece, 'r');
% fig = gcf;
% title("Capa 12: Bbox Pieza");
% grupo = "07_Encaje";
% subgrupo = "07_8-BboxPieza";
% saveImage(fig, nombreImagen, grupo, subgrupo);



disp("15 -- Superposición de ambos Bboxes --")
[d, Z, transform] = procrustes(cornersSVG, cornersPiece, 'Scaling', true, 'Reflection', false);

% drawBoundingBoxesAlignment(cornersSVG, Z);
% fig = gcf;
% title("Capa 13: Superposición de ambos Bboxes");
% grupo = "07_Encaje";
% subgrupo = "07_9-AlineacionBboxes";
% saveImage(fig, nombreImagen, grupo, subgrupo);



disp("16 -- Rectificación de orientación --")
[edgesOk, oriDeg, err] = pickBestEdgeOrientation(pieceClusters, svgPaths);
fprintf('Orientación final %d°, RMSE %.4f\n', oriDeg, err);
% fig = gcf;
% title("Capa 14: ");
% grupo = "";
% subgrupo = "";  
% saveImage(fig, nombreImagen, grupo, subgrupo);



disp("17 -- Visualización de puntos alineados sobre SVG --")
drawPieceOnSVG(edgesOk, svgPaths, transform);

% fig = gcf;
% title("Capa 15: Resultados encaje");
% grupo = "07_Encaje";
% subgrupo = "07_5-ResultadoEncaje";  
%saveImage(fig, nombreImagen, grupo, subgrupo);

% disp("19 -- Extracción máscara binaria .svg --")
% visualizeBinaryMask(svgFile);




%% Tiempo total
disp(['Tiempo total del programa: ' num2str(toc(totalStart)) ' segundos'])