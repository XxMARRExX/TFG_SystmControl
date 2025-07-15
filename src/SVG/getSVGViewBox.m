function [XLim, YLim, width, height] = getSVGViewBox(filename)
    doc = xmlread(filename);
    svgNode = doc.getElementsByTagName('svg').item(0);

    % Leer atributo viewBox
    viewBoxStr = char(svgNode.getAttribute('viewBox'));
    if ~isempty(viewBoxStr)
        vals = sscanf(viewBoxStr, '%f');
        x0 = vals(1);
        y0 = vals(2);
        w = vals(3);
        h = vals(4);
    else
        % Si no hay viewBox, intenta leer width y height
        w = str2double(svgNode.getAttribute('width'));
        h = str2double(svgNode.getAttribute('height'));
        x0 = 0;
        y0 = 0;
    end

    XLim = [x0, x0 + w];
    YLim = [y0, y0 + h];

    width = ceil(w);
    height = ceil(h);
end
