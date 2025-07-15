function transformadas = transformToSVG(resultados, viewBox, debugMode)
%TRANSFORMALLPIECESTOSVG Transforma piezas y contornos interiores al sistema SVG
%
% Entrada:
%   - resultados: struct array con .edges, .linea, .boundingBox, .interiores
%   - viewBox: vector [xmin ymin width height]
%   - debugMode: true/false para visualización paso a paso
%
% Salida:
%   - transformadas: struct array con campos:
%       .x_svg, .y_svg            (puntos transformados del contorno exterior)
%       .x_svg_interior{j}, .y_svg_interior{j}  (cada agujero transformado)


    numPiezas = numel(resultados);
    transformadas = struct('x_svg', {}, 'y_svg', {}, 'x_svg_interior', {}, 'y_svg_interior', {});
    centerSVG = [viewBox(1) + viewBox(3)/2, viewBox(2) + viewBox(4)/2];

    for i = 1:numPiezas
        pieza = resultados(i);
        x = pieza.edges.x(:)';
        y = pieza.edges.y(:)';
        slope = pieza.linea.m;

        % Paso 1: centrar y alinear
        [x_rot, y_rot, theta, center] = alignDetectedPoints(x, y, slope);

        % Paso 2: escalar
        bbox = pieza.boundingBox;
        scaleX = viewBox(3) / bbox(3);
        scaleY = viewBox(4) / bbox(4);
        scale = min(scaleX, scaleY);

        x_scaled = x_rot * scale;
        y_scaled = y_rot * scale;

        % Paso 3: rotar de nuevo a su orientación original
        R = [cos(theta), -sin(theta); sin(theta), cos(theta)];
        rotatedBack = R * [x_scaled; y_scaled];
        x_back = rotatedBack(1, :);
        y_back = rotatedBack(2, :);

        % Paso 4: trasladar al centro del SVG
        x_svg = x_back + centerSVG(1);
        y_svg = y_back + centerSVG(2);

        transformadas(i).x_svg = x_svg;
        transformadas(i).y_svg = y_svg;

        % ✳️ Paso 5: transformar también los contornos interiores
        interiores = pieza.interiores;
        for j = 1:numel(interiores)
            xi = interiores{j}.x(:)';
            yi = interiores{j}.y(:)';
            
            [xi, yi] = ordenarContornoCircular(xi, yi);

            % Aplicar mismo pipeline
            xi_rot = (xi - center(1)) * cos(-theta) - (yi - center(2)) * sin(-theta);
            yi_rot = (xi - center(1)) * sin(-theta) + (yi - center(2)) * cos(-theta);

            xi_scaled = xi_rot * scale;
            yi_scaled = yi_rot * scale;

            interiorBack = R * [xi_scaled; yi_scaled];
            xi_svg = interiorBack(1, :) + centerSVG(1);
            yi_svg = interiorBack(2, :) + centerSVG(2);

            transformadas(i).x_svg_interior{j} = xi_svg;
            transformadas(i).y_svg_interior{j} = yi_svg;
        end
    end
end