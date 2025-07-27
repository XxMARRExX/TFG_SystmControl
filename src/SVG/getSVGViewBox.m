function [XLim, YLim, width, height] = getSVGViewBox(filename)
% GETSVGVIEWBOX Extracts coordinate limits and size from the viewBox (or width/height) of an SVG file.
%
% Input:
%   - filename: path to the .svg file
%
% Outputs:
%   - XLim:    [x_min, x_max] limits in the X-axis
%   - YLim:    [y_min, y_max] limits in the Y-axis
%   - width:   width of the viewBox (rounded to integer)
%   - height:  height of the viewBox (rounded to integer)

    % 1. Load SVG as XML
    doc = xmlread(filename);
    svgNode = doc.getElementsByTagName('svg').item(0);

    % 2. Try to read the viewBox attribute
    viewBoxStr = char(svgNode.getAttribute('viewBox'));

    if ~isempty(viewBoxStr)
        % 2.a Parse viewBox: "x y width height"
        vals = sscanf(viewBoxStr, '%f');
        x0 = vals(1);
        y0 = vals(2);
        w  = vals(3);
        h  = vals(4);
    else
        % 2.b Fallback: try width and height attributes
        w  = str2double(svgNode.getAttribute('width'));
        h  = str2double(svgNode.getAttribute('height'));
        x0 = 0;
        y0 = 0;
    end

    % 3. Compute coordinate limits and dimensions
    XLim = [x0, x0 + w];
    YLim = [y0, y0 + h];
    width  = ceil(w);
    height = ceil(h);
end
