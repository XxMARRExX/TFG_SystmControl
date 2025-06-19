function saveImage(fig, nombreImagen, nombreBloque, nombreExperimento)
    % Ruta base: ../TFG - Imagenes memoria/{bloque}/{experimento}/
    baseDir = fullfile("..", "TFG - Imagenes memoria", nombreBloque, nombreExperimento);

    % Crear carpeta si no existe
    if ~exist(baseDir, 'dir')
        mkdir(baseDir);
    end

    % Nombre del archivo: Imagen4_Capa3_DetectedEdges.png
    nombreArchivo = sprintf("%s.png", nombreImagen);
    rutaFinal = fullfile(baseDir, nombreArchivo);

    % Guardar figura
    saveas(fig, rutaFinal);
end
