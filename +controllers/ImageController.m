classdef ImageController

    methods (Static)

        function imageData = loadImageFromDialog(previewLoadedImage, canvas)
        % loadImageFromDialog() Opens a file dialog to load an image and displays it on a canvas.
        %
        %   Inputs:
        %       - previewLoadedImage: UI component (Image) to show a thumbnail
        %       - canvas: UIAxes to display the full image

            % Allowed files
            [file, path] = uigetfile({'*.png;*.jpg;*.jpeg;', ...
                'Imágenes (*.png, *.jpg, *.jpeg)'}, ...
                'Selecciona una imagen');

            % Not selected file
            if isequal(file, 0)
                imageData = struct('fileName','', 'fullPath','', 'matrix',[]);
                previewLoadedImage.ImageSource = '';                                 
                return;
            end
            
            filePath  = fullfile(path, file);

            % Process model
            imageData = services.image.readImage(filePath);
            
            % Update view
            previewLoadedImage.ImageSource = imageData.fullPath;
            gui.canvas.showPicture(canvas, imageData.matrix);
        end

    end

end
