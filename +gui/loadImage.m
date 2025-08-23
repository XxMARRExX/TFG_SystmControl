function img = loadImage(app)
% gui.loadImage - Muestra un diálogo para cargar una imagen y la devuelve.
% También actualiza el eje correspondiente si se pasa desde el app.

    [file, path] = uigetfile({'*.png;*.jpg;*.bmp;*.tif', ...
        'Imágenes (*.png, *.jpg, *.bmp, *.tif)'}, ...
        'Selecciona una imagen');

    if isequal(file, 0)
        img = [];
        return;
    end

    % Leer imagen
    fullPath = fullfile(path, file);
    img = imread(fullPath);

    % Mostrar imagen en el eje si se desea
    if isvalid(app.UIAxes)
        imshow(img, 'Parent', app.UIAxes);
    end

    % (Opcional) Guardar la ruta o nombre dentro del app si quieres
    if isprop(app, 'RutaImagen')
        app.RutaImagen = fullPath;
    end
end
