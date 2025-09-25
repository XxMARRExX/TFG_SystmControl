classdef AppState < handle
    % AppState  Centralized application state manager.
    %
    %   Properties (private):
    %       - imageDisplayed: Boolean flag indicating whether an image is currently
    %           displayed on the canvas.

    properties (Access = private)
        imageDisplayed logical;
    end
    
    methods
        function self = AppState()
            self.imageDisplayed = false;
        end

        function setImageDisplayed(self, state)
            self.imageDisplayed = logical(state);
        end

        function state = getImageDisplayed(self)
            state = self.imageDisplayed;
        end
    end
end
