% Cargar una imagen de prueba
I = imread('pictures/Pieza1/Imagen1.png');

% Generar imagen con título y descripción
img = pipeline.analyze.generateStageImage(I, ...
    "Stage 3: Edge Filtering", ...
    "Subpixel edges detected and filtered using orientation criteria." );

% Mostrar el resultado
imshow(img);
