function configParams = config()

    disp('Configurando el entorno de trabajo...');
    addpath(genpath('src'));
    addpath(genpath('data'));
    savepath;
    disp('Configurando variables de entorno...');
    
    %% SubpixelEdges
    configParams.subpixelEdges.threshold = 10;
    configParams.subpixelEdges.smoothingIter = 1;
    
    %% FilterByNormalThreshold
    configParams.filterByNormal.normalThreshold = 0.9;
    
    %% FilterByHorizontalDensity
    configParams.filterByHorizontalDensity.minPoints = 450;
    configParams.filterByHorizontalDensity.range = 200;
    configParams.filterByHorizontalDensity.tolerance = 0.05;

    %% generateVerticalRegionFromEdges
    configParams.generateVerticalRegionFromEdges.expansionX = 0.10;
    configParams.generateVerticalRegionFromEdges.expansionY = 0.05;
    
    %% analyzeSubstructuresWithDBSCAN
    configParams.analyzeSubstructures.eps = 6;
    configParams.analyzeSubstructures.minPts = 4;
    
    %% findInnerContours_2
    configParams.findInnerContours_2.maxMeanDist = 20;
    configParams.findInnerContours_2.refImgSize = [7000 9344];
    
    disp('Variables de entorno listo');
    disp('Entorno listo.');

end

