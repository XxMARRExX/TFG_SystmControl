function viewBox = getViewBoxFromSVG(filename)
%GETVIEWBOXFROMSVG Extrae el atributo viewBox de un archivo SVG
%   Entrada:
%       - filename: ruta al archivo .svg
%   Salida:
%       - viewBox: vector [x_min, y_min, width, height]

    % Leer el archivo SVG como XML
    doc = xmlread(filename);

    % Obtener la etiqueta <svg>
    svgTags = doc.getElementsByTagName('svg');
    if svgTags.getLength == 0
        error('No se encontró la etiqueta <svg> en el archivo.');
    end

    % Obtener el atributo 'viewBox' (puede estar vacío)
    viewBoxStr = char(svgTags.item(0).getAttribute('viewBox'));
    if isempty(viewBoxStr)
        error('El archivo SVG no contiene el atributo viewBox.');
    end

    % Convertir el string a números
    viewBox = sscanf(viewBoxStr, '%f')';
    if numel(viewBox) ~= 4
        error('El atributo viewBox no tiene 4 valores válidos.');
    end
end

