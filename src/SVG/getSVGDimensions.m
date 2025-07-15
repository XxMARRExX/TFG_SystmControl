function [bboxSVG, centerSVG] = getSVGDimensions(filename)
% Obtiene dimensiones y centro del viewBox en SVG

    xml = xmlread(filename);
    svgNode = xml.getElementsByTagName('svg').item(0);
    viewBoxStr = char(svgNode.getAttribute('viewBox'));

    tokens = regexp(viewBoxStr, '[-\d\.eE]+', 'match');
    viewBoxValues = str2double(tokens);

    if numel(viewBoxValues) ~= 4
        error('No se pudo interpretar correctamente el atributo viewBox.');
    end

    x_min = viewBoxValues(1);
    y_min = viewBoxValues(2);
    width = viewBoxValues(3);
    height = viewBoxValues(4);

    bboxSVG = [width, height];
    centerSVG = [x_min + width/2, y_min + height/2];
end
