classdef DownloadFilesController
% DownloadFilesController  Manages data export operations for analyzed pieces.
%
%   Properties:
%       - stateApp: application state manager that tracks logical workflow states.
%       - resultsConsoleWrapper: manages the result tab views for each analyzed piece.
%       - modelImage: stores image data, bounding boxes, and computed results.
%       - feedbackManager: handles user feedback, progress indicators, and warnings.
    properties
        stateApp;
        resultsConsoleWrapper;
        modelImage;
        feedbackManager
    end
    
    methods
        function self = DownloadFilesController(stateApp, ...
                resultsConsoleWrapper, modelImage, feedbackManager)
            self.stateApp = stateApp;
            self.resultsConsoleWrapper = resultsConsoleWrapper;
            self.modelImage = modelImage;
            self.feedbackManager = feedbackManager;
        end


        function downloadXLSXPointsOverImage(self)
        % downloadXLSXPointsOverImage()  Exports point-wise error data 
        %       (in image coordinates) to an Excel file.
            fb = self.feedbackManager;
        
            try
                % --- 1. Verify processing state ---
                if ~self.stateApp.getStatusState('errorOnPieceCalculated')
                    fb.showWarning("Se debe calcular el error sobre las piezas antes de exportar el archivo.");
                    return;
                end
        
                % --- 2. Retrieve BBoxes ---
                bboxes = self.modelImage.getbBoxes();
                numPieces = numel(bboxes);
        
                if numPieces == 0
                    fb.showWarning("No se han definido BoundingBoxes.");
                    return;
                end
        
                % --- 3. Select destination file ---
                [file, path] = uiputfile('*.xlsx', 'Guardar puntos con error como...');
                if isequal(file, 0)
                    fb.showWarning("Exportación cancelada por el usuario.");
                    return;
                end
        
                fullPath = fullfile(path, file);
        
                % --- 4. Initialize progress ---
                fb.startProgress("Exportando datos", "Preparando exportación a Excel...");
                totalSteps = numPieces;
                step = 0;
        
                % --- 5. Process each piece ---
                for i = 1:numPieces
                    step = step + 1;
                    currentBBox = bboxes(i);
        
                    progressMsg = sprintf("Exportando pieza %d de %d...", i, numPieces);
                    fb.updateProgress(step/totalSteps, progressMsg);
        
                    edgesWithError = currentBBox.getEdgesWithError();
        
                    if isempty(edgesWithError)
                        fb.showWarning(sprintf("La pieza %d no tiene datos de error.", i));
                        continue;
                    end
        
                    allX = [];
                    allY = [];
                    allE = [];

                    if isfield(edgesWithError, 'exterior')
                        ex = edgesWithError.exterior;
                        allX = [allX; ex.x(:)];
                        allY = [allY; ex.y(:)];
                        allE = [allE; ex.e(:)];
                    end
        
                    if isfield(edgesWithError, 'innerContours') && ~isempty(edgesWithError.innerContours)
                        for j = 1:numel(edgesWithError.innerContours)
                            inC = edgesWithError.innerContours{j};
                            allX = [allX; inC.x(:)];
                            allY = [allY; inC.y(:)];
                            allE = [allE; inC.e(:)];
                        end
                    end
        
                    T = table(allX, allY, allE, 'VariableNames', {'x', 'y', 'e'});
                    sheetName = currentBBox.getLabel();
        
                    writetable(T, fullPath, 'Sheet', sheetName);
                end
        
                fb.updateProgress(1, "Exportación completada.");
                fb.showWarning(sprintf("Se exportaron %d piezas correctamente a:\n%s", numPieces, fullPath));
                fb.closeProgress();

            catch ME
                fb.showError("Error durante la exportación de datos a Excel: " + ME.message);
                fb.closeProgress();
            end
        end


        function downloadXLSXPointsOverSVG(self)
        % downloadXLSXPointsOverSVG()  Exports point-wise error data 
        %       (in SVG coordinates) to an Excel file.
            fb = self.feedbackManager;
        
            try
                % --- 1. Verify processing state ---
                if ~self.stateApp.getStatusState('errorOnPieceCalculated')
                    fb.showWarning("Se debe calcular el error sobre las piezas antes de exportar el archivo.");
                    return;
                end
        
                % --- 2. Retrieve BBoxes ---
                bboxes = self.modelImage.getbBoxes();
                numPieces = numel(bboxes);
        
                if numPieces == 0
                    fb.showWarning("No se han definido BoundingBoxes.");
                    return;
                end
        
                % --- 3. Select destination file ---
                [file, path] = uiputfile('*.xlsx', 'Guardar puntos con error como...');
                if isequal(file, 0)
                    fb.showWarning("Exportación cancelada por el usuario.");
                    return;
                end
        
                fullPath = fullfile(path, file);
        
                % --- 4. Initialize progress ---
                fb.startProgress("Exportando datos", "Preparando exportación a Excel...");
                totalSteps = numPieces;
                step = 0;
        
                % --- 5. Process each piece ---
                for i = 1:numPieces
                    step = step + 1;
                    currentBBox = bboxes(i);

                    progressMsg = sprintf("Exportando pieza %d de %d...", i, numPieces);
                    fb.updateProgress(step/totalSteps, progressMsg);

                    edgesWithError = currentBBox.getEdgesWithErrorOverSVG();
        
                    if isempty(edgesWithError)
                        fb.showWarning(sprintf("La pieza %d no tiene datos de error.", i));
                        continue;
                    end

                    allX = [];
                    allY = [];
                    allE = [];

                    if isfield(edgesWithError, 'exterior')
                        ex = edgesWithError.exterior;
                        allX = [allX; ex.x(:)];
                        allY = [allY; ex.y(:)];
                        allE = [allE; ex.e(:)];
                    end

                    if isfield(edgesWithError, 'innerContours') && ~isempty(edgesWithError.innerContours)
                        for j = 1:numel(edgesWithError.innerContours)
                            inC = edgesWithError.innerContours{j};
                            allX = [allX; inC.x(:)];
                            allY = [allY; inC.y(:)];
                            allE = [allE; inC.e(:)];
                        end
                    end

                    T = table(allX, allY, allE, 'VariableNames', {'x', 'y', 'e'});
                    sheetName = currentBBox.getLabel();
        
                    writetable(T, fullPath, 'Sheet', sheetName);
                end

                fb.updateProgress(1, "Exportación completada.");
                fb.showWarning(sprintf("Se exportaron %d piezas correctamente a:\n%s", numPieces, fullPath));
                fb.closeProgress();

            catch ME
                fb.showError("Error durante la exportación de datos a Excel: " + ME.message);
                fb.closeProgress();
            end
        end

    end
end

