function configParams = config()

    disp('Configurando el entorno de trabajo...');
    addpath(genpath('src'));
    addpath(genpath('data'));
    savepath;
    disp('Configurando variables de entorno...');
    
    %% Parámetros de documentación del proyecto
    configParams.nombreActualFlujo = "Flujo_20250818";

    %% Imagen
    configParams.pathImagen = "pictures/Pieza5/Imagen1_test.png";

    %% SVG
    configParams.pathSVG = "data/models/Pieza5.svg";

    % Doc imagenes
    [pathBase, nombreImagen, ~] = fileparts(configParams.pathImagen);
    relPath = extractAfter(pathBase, "pictures/");
    relPath = strrep(relPath, "/", "_");
    configParams.nombreImagen = nombreImagen;
    configParams.nombreImagenDoc = relPath + "_" + nombreImagen;

    %% SubpixelEdges
    configParams.subpixelEdges.threshold_Phase1 = 15;
    configParams.subpixelEdges.threshold_Phase2 = 10;
    configParams.subpixelEdges.smoothingIter_Phase1 = 5;
    configParams.subpixelEdges.smoothingIter_Phase2 = 3;
    configParams.subpixelEdges.scale = 0.05;
    
    %% BboxPiece margin
    configParams.BboxPiece.margin = 15;
    
    %% analyzeSubstructuresWithDBSCAN
    configParams.analyzeSubstructures.eps = 6;
    configParams.analyzeSubstructures.minPts = 4;
    
    %% findInnerContours
    configParams.findInnerContours.maxMeanDist = 20;
    configParams.findInnerContours.refImgSize = [7000 9344];

    %% Relacion mm a px
    configParams.svgBinaryMask.pxlTomm = 15;

    %% Tolerancia de error
    configParams.errorTolerancemm = 0.3;
    
    disp('Variables de entorno listo');
    disp('Entorno listo.');

end

