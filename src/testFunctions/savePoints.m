function savePoints(points, nombreArchivo, grupo, subgrupo)
% SAVEPOINTS Guarda puntos 2D en la misma estructura de carpetas que las imágenes

    % BasePath sincronizado con saveImage
    basePath = fullfile("D:", "Universidad", "II - Ingeniería informática", ...
                        "Año 4", "40991 - Trabajo de fin de grado", ...
                        "TFG - Imagenes memoria");

    % Construir ruta final
    folder = fullfile(basePath, grupo, subgrupo);
    if ~exist(folder, 'dir')
        mkdir(folder);
    end

    % Guardar archivo
    filePath = fullfile(folder, nombreArchivo + ".txt");
    writematrix(points, filePath, 'Delimiter', 'tab');
end
