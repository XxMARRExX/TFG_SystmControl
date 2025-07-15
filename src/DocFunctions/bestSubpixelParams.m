clear; clc; close all;
totalStart = tic;

configParams = config();

% Cargar imagen base
nombreImagen = "Imagen1";
image = imread("pictures/" + nombreImagen + ".png");
grayImage = convertToGrayScale(image);

% Combinaciones (smoothingIter, threshold)
paramComb = [
    1, 20;
    1, 15;
    3, 20;
    3, 15;
    3, 10;
    5, 20;
    5, 10
];

newParamComb_Imagen4_1 = [
    1, 25
    1, 30
    1, 35
];

newParamComb_Imagen4_2 = [
    1, 21
    1, 22
    1, 23
    1, 24
];

newParamComb_Imagen1 = [
    5, 15
    7, 15
    9, 15
    10, 15
];

% Crear carpeta si no existe
outputDir = fullfile("..", "TFG - Imagenes memoria", "05_Pruebas", "05_1-SuavizadoSubpixel");
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

% Ejecutar para cada combinación
for k = 1:size(newParamComb_Imagen1,1)
    smth = newParamComb_Imagen1(k,1);
    thres = newParamComb_Imagen1(k,2);

    disp("---------------------------------------------------")
    fprintf("Procesando: smoothingIter = %d, threshold = %d\n", smth, thres);

    % Calcular bordes
    edges = subpixelEdges(grayImage, thres, 'SmoothingIter', smth);

    % Visualizar en figura oculta
    fig = figure('Visible','on');
    visEdges(edges);
    title(sprintf("Imagen: %s | SmoothingIter = %d | Threshold = %d", nombreImagen, smth, thres));

    % Formato del nombre: 05_1-_Imagen2_SmoothingIter-5_Threshld_20.png
    filename = sprintf("05_1-_Imagen1_SmoothingIter-%d_Threshld_%d.png", smth, thres);
    filepath = fullfile(outputDir, filename);

    % Guardar figura
    saveas(fig, filepath);
end

toc(totalStart);
