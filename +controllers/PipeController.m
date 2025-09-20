classdef PipeController

    properties (Access = private)
        stateApp;
        imageModel;
        svgModel;
        canvasWrapper;
        resultsConsoleWrapper;
    end
    
    methods (Access = public)
        
        function self = PipeController(stateApp, imageModel, svgModel, ...
                canvasWrapper, resultsConsoleWrapper)

            self.stateApp = stateApp;
            self.imageModel = imageModel;
            self.svgModel = svgModel;
            self.canvasWrapper = canvasWrapper;
            self.resultsConsoleWrapper = resultsConsoleWrapper;
            
        end
        

        function canvasWrapper = getCanvasWrapper(self)
            canvasWrapper = self.canvasWrapper;
        end


        function detectEdges(self, configParams)
            
            bBoxes = self.imageModel.getbBoxes();
            if isempty(bBoxes)
                return;
            end
        
            for k = 1:numel(bBoxes)
                croppedImage = bBoxes(k).getCroppedImage();
        
                edges = subpixelEdges(croppedImage, ...
                    configParams.subpixel.threshold, ...
                    'SmoothingIter', configParams.subpixel.smoothIters);

                bBoxes(k).setDetectedEdges(edges);


            end

            if ~isempty(self.resultsConsoleWrapper)
                self.resultsConsoleWrapper.renderDetectedEdges( ...
                    self.imageModel.getbBoxes(), ...
                    self.getCanvasWrapper());
                drawnow limitrate
            end

        end
    end

end

