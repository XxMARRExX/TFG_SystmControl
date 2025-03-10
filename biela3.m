% calculando la recta de regresión para ver la orientación de la pieza y
% eliminar outlayers

% load image
image = imread('pictures\Imagen3.png');
%image = imread('1_5463_1693302561957_cam0.png');
% image = imread('0_13884_1694616555942_cam0.png');
figure(1); imshow(image);

% subpixel detection
threshold = 10;
edges = subpixelEdges(image, threshold, 'SmoothingIter', 1); 
visEdges(edges);

% nos quedamos con los bordes más o menos horizontales
cond = abs(edges.ny)>0.95;
edgesC = subsetEdges(edges, cond);
figure(2);
clf;
visEdges(edgesC);

% calculamos la recta de regresión sin outlayers
[line, x_filtrado, y_filtrado, idx_valido] = filteredOutliers(edgesC.x, edgesC.y, true);

% dibujamos la recta
x = [0 5320];
y = polyval(line, x);
figure(2);
hold on;
plot(x,y,'g-');
hold off;
figure(1);
hold on;
plot(x,y,'g-');
hold off;

