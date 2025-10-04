% Prueba independiente de la clase Canvas
f = uifigure('Name','Prueba Canvas','Position',[100 100 800 600]);
ax = uiaxes(f, 'Position',[50 50 700 500]);

% Crear objeto Canvas
c = viewWrapper.Canvas(ax);

% Cargar una imagen de prueba
I = imread('pictures/Pieza1/Imagen1.png');
c.showImage(I);
