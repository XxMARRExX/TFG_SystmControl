function configParams = config()

    disp('Configurando el entorno de trabajo...');
    addpath(genpath('src'));
    addpath(genpath('data'));
    savepath;
    disp('Configurando variables de entorno...');
    
    %% SubpixelEdges
    configParams.subpixelEdges.threshold_Phase1 = 40;
    configParams.subpixelEdges.threshold_Phase2 = 20;
    configParams.subpixelEdges.smoothingIter_Phase1 = 3;
    configParams.subpixelEdges.smoothingIter_Phase2 = 1;
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

