classdef DownloadFilesController
    
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
            fb = self.feedbackManager;
        
            try
                % --- 1. Verificar estado ---
                if ~self.stateApp.getStatusState('errorOnPieceCalculated')
                    fb.showWarning("Se debe calcular el error sobre las piezas antes de exportar el archivo.");
                    return;
                end
        
                % --- 2. Obtener Bounding Boxes ---
                bboxes = self.modelImage.getbBoxes();
                numPieces = numel(bboxes);
        
                if numPieces == 0
                    fb.showWarning("No se han definido BoundingBoxes.");
                    return;
                end
        
                % --- 3. Seleccionar ruta destino ---
                [file, path] = uiputfile('*.xlsx', 'Guardar puntos con error como...');
                if isequal(file, 0)
                    fb.showWarning("Exportación cancelada por el usuario.");
                    return;
                end
        
                fullPath = fullfile(path, file);
        
                % --- 4. Inicialización del progreso ---
                fb.startProgress("Exportando datos", "Preparando exportación a Excel...");
                totalSteps = numPieces;
                step = 0;
        
                % --- 5. Recorrer todas las piezas ---
                for i = 1:numPieces
                    step = step + 1;
                    currentBBox = bboxes(i);
        
                    % Actualizar barra de progreso
                    progressMsg = sprintf("Exportando pieza %d de %d...", i, numPieces);
                    fb.updateProgress(step/totalSteps, progressMsg);
        
                    % Obtener los bordes con error (ya calculados)
                    edgesWithError = currentBBox.getEdgesWithError();
        
                    if isempty(edgesWithError)
                        fb.showWarning(sprintf("La pieza %d no tiene datos de error.", i));
                        continue;
                    end
        
                    % --- Unificar puntos exteriores + interiores ---
                    allX = [];
                    allY = [];
                    allE = [];
        
                    % Contorno exterior
                    if isfield(edgesWithError, 'exterior')
                        ex = edgesWithError.exterior;
                        allX = [allX; ex.x(:)];
                        allY = [allY; ex.y(:)];
                        allE = [allE; ex.e(:)];
                    end
        
                    % Contornos interiores
                    if isfield(edgesWithError, 'innerContours') && ~isempty(edgesWithError.innerContours)
                        for j = 1:numel(edgesWithError.innerContours)
                            inC = edgesWithError.innerContours{j};
                            allX = [allX; inC.x(:)];
                            allY = [allY; inC.y(:)];
                            allE = [allE; inC.e(:)];
                        end
                    end
        
                    % --- Crear tabla y escribir hoja ---
                    T = table(allX, allY, allE, 'VariableNames', {'x', 'y', 'e'});
                    sheetName = currentBBox.getLabel();
        
                    writetable(T, fullPath, 'Sheet', sheetName);
                end
        
                % --- 6. Finalización ---
                fb.updateProgress(1, "Exportación completada.");
                fb.showWarning(sprintf("Se exportaron %d piezas correctamente a:\n%s", numPieces, fullPath));
                fb.closeProgress();

            catch ME
                fb.showError("Error durante la exportación de datos a Excel: " + ME.message);
                fb.closeProgress();
            end
        end


        function downloadXLSXPointsOverSVG(self)
            fb = self.feedbackManager;
        
            try
                % --- 1. Verificar estado ---
                if ~self.stateApp.getStatusState('errorOnPieceCalculated')
                    fb.showWarning("Se debe calcular el error sobre las piezas antes de exportar el archivo.");
                    return;
                end
        
                % --- 2. Obtener Bounding Boxes ---
                bboxes = self.modelImage.getbBoxes();
                numPieces = numel(bboxes);
        
                if numPieces == 0
                    fb.showWarning("No se han definido BoundingBoxes.");
                    return;
                end
        
                % --- 3. Seleccionar ruta destino ---
                [file, path] = uiputfile('*.xlsx', 'Guardar puntos con error como...');
                if isequal(file, 0)
                    fb.showWarning("Exportación cancelada por el usuario.");
                    return;
                end
        
                fullPath = fullfile(path, file);
        
                % --- 4. Inicialización del progreso ---
                fb.startProgress("Exportando datos", "Preparando exportación a Excel...");
                totalSteps = numPieces;
                step = 0;
        
                % --- 5. Recorrer todas las piezas ---
                for i = 1:numPieces
                    step = step + 1;
                    currentBBox = bboxes(i);
        
                    % Actualizar barra de progreso
                    progressMsg = sprintf("Exportando pieza %d de %d...", i, numPieces);
                    fb.updateProgress(step/totalSteps, progressMsg);
        
                    % Obtener los bordes con error (ya calculados)
                    edgesWithError = currentBBox.getEdgesWithErrorOverSVG();
        
                    if isempty(edgesWithError)
                        fb.showWarning(sprintf("La pieza %d no tiene datos de error.", i));
                        continue;
                    end
        
                    % --- Unificar puntos exteriores + interiores ---
                    allX = [];
                    allY = [];
                    allE = [];
        
                    % Contorno exterior
                    if isfield(edgesWithError, 'exterior')
                        ex = edgesWithError.exterior;
                        allX = [allX; ex.x(:)];
                        allY = [allY; ex.y(:)];
                        allE = [allE; ex.e(:)];
                    end
        
                    % Contornos interiores
                    if isfield(edgesWithError, 'innerContours') && ~isempty(edgesWithError.innerContours)
                        for j = 1:numel(edgesWithError.innerContours)
                            inC = edgesWithError.innerContours{j};
                            allX = [allX; inC.x(:)];
                            allY = [allY; inC.y(:)];
                            allE = [allE; inC.e(:)];
                        end
                    end
        
                    % --- Crear tabla y escribir hoja ---
                    T = table(allX, allY, allE, 'VariableNames', {'x', 'y', 'e'});
                    sheetName = currentBBox.getLabel();
        
                    writetable(T, fullPath, 'Sheet', sheetName);
                end
        
                % --- 6. Finalización ---
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

