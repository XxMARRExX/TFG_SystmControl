clear; clc; close all;
totalStart = tic;
configParams = config();


disp("1 -- Paso de la imagen a gris --")
image = imread(configParams.pathImagen);
grayImage = convertToGrayScale(image);



disp("2 -- Rescalado de la imagen --")
rescaledImage = imresize(image, configParams.subpixelEdges.scale);



disp("3 -- Detección de bordes en imagen reescalada --")
edges = subpixelEdges(rescaledImage, configParams.subpixelEdges.threshold_Phase1, ...
    'SmoothingIter', configParams.subpixelEdges.smoothingIter_Phase1);

% visualizeImageWithEdges(rescaledImage, edges, "SubpixelEdges (Imagen reescalada)");
% fig = gcf;
% title("Capa 3: Detección bordes imagen reescalada");
% capa = "03_Bordes_Detectados_Imagen_Reescalada";
% saveImage(fig, configParams.nombreImagenDoc, configParams.nombreActualFlujo, capa);



disp("4 -- Cálculo Bbox mínimo --")
bBoxRescaled = minBoundingBox([edges.x, edges.y]');

% drawBoundingBoxOnImage(rescaledImage, bBoxRescaled);
% fig = gcf;
% title("Capa 4: Cálculo del Bbox imagen reescalada");
% capa = "04_Calculo_Bbox_imagen_reescalada";
% saveImage(fig, configParams.nombreImagenDoc, configParams.nombreActualFlujo, capa);



disp("5 -- Cálculo del Bbox imagen sin reescalado --")
BboxPiece = calculateExpandedBoundingBox(edges, ...
    configParams.subpixelEdges.scale, configParams.BboxPiece.margin);

% drawBoundingBoxOnImage(grayImage, BboxPiece);
% fig = gcf;
% title("Capa 5: Cálculo del Bbox imagen sin reescalado");
% capa = "05_Calculo_Bbox_imagen_sin_reescalado";
% saveImage(fig, configParams.nombreImagenDoc, configParams.nombreActualFlujo, capa);



disp("6 -- Recorte de la imagen según el Bbox --");
cropImage = cropImageByBoundingBox(grayImage, BboxPiece);



disp("7 -- Sombras en píxeles que son ruido --");
cropImage = eraseRegionInImage(cropImage, configParams.pathImagen);



disp("8 -- Detección de bordes sobre imagen recortada --")
edges = subpixelEdges(cropImage, configParams.subpixelEdges.threshold_Phase2, ...
    'SmoothingIter', configParams.subpixelEdges.smoothingIter_Phase2);

% visualizeImageWithEdges(cropImage, edges, "Bordes sobre imagen recortada");
% fig = gcf;
% title("Capa 8: Detección de bordes sobre imagen recortada");
% capa = "08_Deteccion_bordes_imagen_recortada";
% saveImage(fig, configParams.nombreImagenDoc, configParams.nombreActualFlujo, capa);



disp("9 -- Bbox recalculado en imagen recortada --");
BboxPieceCropImage = calculateExpandedBoundingBox(edges, 1, 0);
edgesFiltered = filterEdgesByBoundingBox(edges, BboxPieceCropImage);

% drawBoundingBoxOnImage(cropImage, BboxPieceCropImage);
% showFilteredPoints(edges, edgesFiltered);
% fig = gcf;
% title("Capa 9: Bordes dentro del Bbox recalculado");
% capa = "09_Deteccion_bordes_Bbox_recalculado";
% saveImage(fig, configParams.nombreImagenDoc, configParams.nombreActualFlujo, capa);



disp("10 -- Agrupación mediante clusters --")
[clusters, noise] = analyzeSubstructuresWithDBSCAN(edgesFiltered, ...
    configParams.analyzeSubstructures.eps, ...
    configParams.analyzeSubstructures.minPts);

% visClusters(cropImage, clusters);
% fig = gcf;
% title("Capa 10: Agrupación mediante clusters");
% capa = "10_Agrupacion_mediante_clusters";
% saveImage(fig, configParams.nombreImagenDoc, configParams.nombreActualFlujo, capa);



disp("11 -- Búsqueda de piezas en la imagen --")
[pieceClusters, pieceEdges, numPieces, remainingClusters] = findPieceClusters(clusters);

% visClusters(cropImage, pieceClusters);
% fig = gcf;
% title("Capa 11: Búsqueda piezas en la imagen");
% capa = "11_Busqueda_piezas_en_la_imagen";
% saveImage(fig, configParams.nombreImagenDoc, configParams.nombreActualFlujo, capa);



disp("12 -- Extracción máscara de la pieza/s --")
maskPieza = createPieceMask(cropImage, pieceClusters);

% imshow(maskPieza);
% fig = gcf;
% title("Capa 12: Extracción máscara de la pieza");
% capa = "12_Mascara_binaria_pieza";
% saveImage(fig, configParams.nombreImagenDoc, configParams.nombreActualFlujo, capa);



disp("13 -- Filtrado de clusters dentro de la pieza --")
filteredClusters = filterClustersInsideMask(remainingClusters, maskPieza);

% visClusters(cropImage, filteredClusters);
% fig = gcf;
% title("Capa 13: Filtrado de clusters dentro de la pieza");
% capa = "13_Filtrado_clusters_internos";
% saveImage(fig, configParams.nombreImagenDoc, configParams.nombreActualFlujo, capa);



disp("14 -- Búsqueda de contornos internos --")
piecesInnerContours = findInnerContours(filteredClusters, size(cropImage), ...
    configParams.findInnerContours.refImgSize, ...
    configParams.findInnerContours.maxMeanDist);

% visClusters(cropImage, piecesInnerContours);
% fig = gcf;
% title("Capa 14: Búsqueda de contornos internos");
% capa = "14_Busqueda_contornos_internos";
% saveImage(fig, configParams.nombreImagenDoc, configParams.nombreActualFlujo, capa);



disp("15 -- Asociación de contornos internos a pieza/s --")
pieceClusters = associateInnerContoursToPieces(pieceClusters, piecesInnerContours, maskPieza);

% showImageWithEdges(cropImage, pieceClusters);
% fig = gcf;
% title("Capa 15: Asociación de contornos internos a pieza/s");
% capa = "15_Asociacion_contornos_internos_piezas";
% saveImage(fig, configParams.nombreImagenDoc, configParams.nombreActualFlujo, capa);




%% Proceso de encaje
disp("16 -- Carga del plano SVG --")
configParams = config();
svgPaths = importSVG(configParams.pathSVG);

plotSVGModel(svgPaths)
% fig = gcf;
% title("Capa 16: Carga del plano SVG");
% capa = "16_Carga_SVG";
% saveImage(fig, configParams.nombreImagenDoc, configParams.nombreActualFlujo, capa);



disp("17 -- Cálculo BoundingBox del SVG --")
cornersSVG = calculateBboxSVG(svgPaths);

% drawSVGBoundingBox(svgPaths, cornersSVG);
% fig = gcf;
% title("Capa 17: Cálculo BoundingBox del SVG");
% capa = "17_Calculo_Bbox_SVG";
% saveImage(fig, configParams.nombreImagenDoc, configParams.nombreActualFlujo, capa);



disp("18 -- Cálculo BoundingBox de la pieza --")
points = [pieceClusters{1}.edges.exterior.x, pieceClusters{1}.edges.exterior.y];
bBoxFinal = minBoundingBox(points');
cornersPiece = formatCorners(bBoxFinal);

% drawPieceBoundingBox(pieceClusters, cornersPiece);
% fig = gcf;
% title("Capa 18: Cálculo BoundingBox de la pieza");
% capa = "18_Calculo_Bbox_pieza";
% saveImage(fig, configParams.nombreImagenDoc, configParams.nombreActualFlujo, capa);



disp("19 -- Encaje de ambos Bboxes --")
cornersPieceAligned = alignBoundingBoxCorners(cornersSVG, cornersPiece);
[d, Z, transform] = procrustes(cornersSVG, cornersPieceAligned, ...
    'Scaling', true, 'Reflection', false);

% drawBoundingBoxesAlignment(cornersSVG, Z);
% fig = gcf;
% title("Capa 19: Encaje de ambos Bboxes");
% capa = "19_Encaje_Bboxes";
% saveImage(fig, configParams.nombreImagenDoc, configParams.nombreActualFlujo, capa);



disp("20 -- Aplicar transformación procrustes --")
[pieceClustersTransformed, cornersPieceTransformed] = applyProcrustesTransform(pieceClusters, cornersPiece, transform);



disp("21 -- Rectificación de orientación --")
[edgesOk, oriDeg, err] = pickBestEdgeOrientation(cornersPieceTransformed, pieceClustersTransformed, svgPaths);



disp("22 -- Encaje entre SVG y pieza --")
% drawPieceOnSVG(edgesOk, svgPaths);

% fig = gcf;
% title("Capa 22: Encaje entre SVG y pieza ");
% capa = "22_Encaje_SVG_pieza";
% saveImage(fig, configParams.nombreImagenDoc, configParams.nombreActualFlujo, capa);



disp("23 -- Extracción máscara binaria del SVG --")
svgMaskParameters = svgBinaryMask(svgPaths, configParams.svgBinaryMask.pxlTomm);

% visualizeSVGBinaryMask(svgMaskParameters.mask);
% fig = gcf;
% title("Capa 23: Extracción máscara binaria del SVG ");
% capa = "23_Mascara_binaria_SVG";
% saveImage(fig, configParams.nombreImagenDoc, configParams.nombreActualFlujo, capa);



disp("24 -- Cálculo del error de los puntos --")
edgesWithError = pointsError(edgesOk, svgMaskParameters);

plotErrorOnSVG(svgPaths, edgesWithError, configParams.errorTolerancemm);
% fig = gcf;
% title("Capa 24: Cálculo del error de los puntos ");
% capa = "24_Calculo_error_puntos";
% saveImage(fig, configParams.nombreImagenDoc, configParams.nombreActualFlujo, capa);


%% Tiempo total
disp(['Tiempo total del programa: ' num2str(toc(totalStart)) ' segundos'])
