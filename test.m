clear; clc; close all;
totalStart = tic;
configParams = config();



pathImagen = "pictures/Pieza2/OLD/Imagen3.png";
% pathImagen = "pictures/Pieza5/Imagen1_test.png";
[~, nombreImagen, extension] = fileparts(pathImagen);
nombreImagen = strcat(nombreImagen, extension);

disp("1 -- Paso de la imagen a gris --")
image = imread(pathImagen);
grayImage = convertToGrayScale(image);



disp("2 -- Rescalado de la imagen --")
rescaledImage = imresize(grayImage, configParams.subpixelEdges.scale);



disp("3 -- Detección de bordes para Bbox --")
edges = subpixelEdges(rescaledImage, configParams.subpixelEdges.threshold_Phase1, ...
    'SmoothingIter', configParams.subpixelEdges.smoothingIter_Phase1);
bBoxRescaled = minBoundingBox([edges.x, edges.y]');

% visualizeImageWithEdges(rescaledImage, edges, "SubpixelEdges (Imagen reescalada)");
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



disp("5 -- Recorte de la imagen según el Bbox --");
cropImage = cropImageByBoundingBox(grayImage, BboxPiece);

% fig = gcf;
% title("");
% grupo = "";
% subgrupo = "";
% saveImage(fig, nombreImagen, grupo, subgrupo);



disp("5.5 -- Coloreado de pixeles a negro --");
cropImage = eraseRegionInImage(cropImage, nombreImagen);



disp("6 -- Detección de bordes para contornos internos --")
edges = subpixelEdges(cropImage, configParams.subpixelEdges.threshold_Phase2, ...
    'SmoothingIter', configParams.subpixelEdges.smoothingIter_Phase2);

% visualizeImageWithEdges(cropImage, edges, "edges sobre imagen recortada");
% fig = gcf;
% title("");
% grupo = "";
% subgrupo = "";
% saveImage(fig, nombreImagen, grupo, subgrupo);



disp("7 -- Nuevo Bbox tras recorte --");
BboxPieceCropImage = calculateExpandedBoundingBox(edges, 1, 0);
edgesFiltered = filterEdgesByBoundingBox(edges, BboxPieceCropImage);

% drawBoundingBoxOnImage(cropImage, BboxPieceCropImage);
% showFilteredPoints(edges, edgesFiltered);
% fig = gcf;
% title("Capa 3: PointsInsidePiece");
% grupo = "02_Filtros";
% subgrupo = "02_9-FilterPointsInsidePiece";
% saveImage(fig, nombreImagen, grupo, subgrupo);



disp("8 -- Agrupamiento mediante clusters --")
[clusters, noise] = analyzeSubstructuresWithDBSCAN(edgesFiltered, ...
    configParams.analyzeSubstructures.eps, ...
    configParams.analyzeSubstructures.minPts);

% visClusters(cropImage, clusters);
% fig = gcf;
% title("Capa 4: PointsInsidePiece");
% grupo = "03_Heuristicas";
% subgrupo = "03_6-FoundedClusters";
% saveImage(fig, nombreImagen, grupo, subgrupo);



disp("9 -- Búsqueda de piezas --")
[pieceClusters, pieceEdges, numPieces, remainingClusters] = findPieceClusters(clusters);

% visClusters(cropImage, pieceClusters);
% fig = gcf;
% title("Capa 5: FindPieceCluster");
% grupo = "02_Filtros";
% subgrupo = "02_6-Filter_FindPieceCluster";
% saveImage(fig, nombreImagen, grupo, subgrupo);



disp("10 -- Extracción máscara de la pieza/s --")
maskPieza = createPieceMask(cropImage, pieceClusters);

% imshow(maskPieza);
% fig = gcf;
% title("Capa 6: CreatePieceMask");
% grupo = "03_Heuristicas";
% subgrupo = "03_3-PieceMask";
% saveImage(fig, nombreImagen, grupo, subgrupo);



disp("11 -- Filtrado de clusters dentro de la pieza --")
filteredClusters = filterClustersInsideMask(remainingClusters, maskPieza);

% visClusters(cropImage, filteredClusters);
% fig = gcf;
% title("Capa 7: FindInnerContoursPiece");
% grupo = "02_Filtros";
% subgrupo = "02_7-InnerCountoursPieceFound";
% saveImage(fig, nombreImagen, grupo, subgrupo);



disp("12 -- Búsqueda de contornos internos --")
piecesInnerContours = findInnerContours(filteredClusters, size(cropImage), ...
    configParams.findInnerContours.refImgSize, ...
    configParams.findInnerContours.maxMeanDist);

% visClusters(cropImage, piecesInnerContours);
% fig = gcf;
% title("Capa 8: DetectedInnerContours");
% grupo = "02_Filtros";
% subgrupo = "02_8-RealInnerCountoursPiece";
% saveImage(fig, nombreImagen, grupo, subgrupo);



disp("13 -- Asociación de contornos internos a pieza/s --")
pieceClusters = associateInnerContoursToPieces(pieceClusters, piecesInnerContours, maskPieza);

% showImageWithEdges(cropImage, pieceClusters);
% fig = gcf;
% title("Capa 9: Results");
% grupo = "04_Resultados";
% subgrupo = "TFG - ResultadosDeteccion_v14062025";
% saveImage(fig, nombreImagen, grupo, subgrupo);




%% Proceso de encaje
disp("14 -- Carga del modelo .svg --")
svgFile = 'data/models/Pieza2.svg';
svgPaths = importSVG(svgFile);

% plotSVGModel(svgPaths)
% fig = gcf;
% title("Capa 10: LoadSVG");
% grupo = "07_Encaje";
% subgrupo = "07_1-CargaSVG";
% saveImage(fig, nombreImagen, grupo, subgrupo);



disp("15 -- BoundingBox del SVG --")
cornersSVG = calculateBboxSVG(svgPaths);

% drawSVGBoundingBox(svgPaths, cornersSVG, 'g');
% fig = gcf;
% title("Capa 11: Bbox SVG");
% grupo = "07_Encaje";
% subgrupo = "07_7-BboxSVG";
% saveImage(fig, nombreImagen, grupo, subgrupo);



disp("16 -- BoundingBox de la pieza detectada --")
points = [pieceClusters{1}.edges.exterior.x, pieceClusters{1}.edges.exterior.y];
bBoxFinal = minBoundingBox(points');
cornersPiece = formatCorners(bBoxFinal);

% drawPieceBoundingBox(pieceClusters, cornersPiece, 'r');
% fig = gcf;
% title("Capa 12: Bbox Pieza");
% grupo = "07_Encaje";
% subgrupo = "07_8-BboxPieza";
% saveImage(fig, nombreImagen, grupo, subgrupo);



disp("17 -- Superposición de ambos Bboxes --")
% Ajustar correspondencia de esquinas antes de Procrustes
X = cornersSVG;      % 4x2 (objetivo)
Y = cornersPiece;    % 4x2 (a alinear)

best = inf; bestY = Y;
for s = 0:3
    Ys = circshift(Y, s, 1);  % permuta filas
    d_try = sum(vecnorm(X - Ys, 2, 2).^2); % SSE previo
    if d_try < best
        best = d_try;
        bestY = Ys;
    end
end

[d, Z, transform] = procrustes(cornersSVG, cornersPiece, 'Scaling', true, ...
    'Reflection', false);

% drawBoundingBoxesAlignment(cornersSVG, Z);
% fig = gcf;
% title("Capa 13: Superposición de ambos Bboxes");
% grupo = "07_Encaje";
% subgrupo = "07_9-AlineacionBboxes";
% saveImage(fig, nombreImagen, grupo, subgrupo);



disp("NEW -- Aplicar transformación --")
[pieceClustersTransformed, cornersPieceTransformed] = applyProcrustesTransform(pieceClusters, cornersPiece, transform);



disp("18 -- Rectificación de orientación --")
[edgesOk, oriDeg, err] = pickBestEdgeOrientation(cornersPieceTransformed, pieceClustersTransformed, svgPaths);
fprintf('Orientación final %d°, RMSE %.4f\n', oriDeg, err);
% fig = gcf;
% title("Capa 14: ");
% grupo = "";
% subgrupo = "";  
% saveImage(fig, nombreImagen, grupo, subgrupo);



disp("19 -- Visualización de puntos alineados sobre SVG --")
% drawPieceOnSVG(edgesOk, svgPaths, transform);

% fig = gcf;
% title("Capa 15: Resultados encaje");
% grupo = "07_Encaje";
% subgrupo = "07_5-ResultadoEncaje";  
%saveImage(fig, nombreImagen, grupo, subgrupo);



disp("20 -- Extracción máscara binaria del SVG --")
svgMaskParameters = svgBinaryMask(svgPaths, configParams.svgBinaryMask.pxlTomm);

% visualizeSVGBinaryMask(svgMaskParameters.mask);



disp("21 -- Cálculo del error de los puntos --")
edgesWithError = pointsError(edgesOk, svgMaskParameters);

plotErrorOnSVG(svgPaths, edgesWithError, configParams.errorTolerancemm);


%% Tiempo total
disp(['Tiempo total del programa: ' num2str(toc(totalStart)) ' segundos'])
