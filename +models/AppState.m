classdef AppState < handle
    % AppState Simple state container (no singleton).
    
    properties (Access = private)
        imageDisplayed logical;
    end
    
    methods
        function self = AppState()
            % Constructor opcional: inicia con estado por defecto
            self.imageDisplayed = false;
        end

        function setImageDisplayed(self, state)
            % setImageDisplayed() Set logical flag for image displayed
            self.imageDisplayed = logical(state);
        end

        function state = getImageDisplayed(self)
            % getImageDisplayed() Return logical flag
            state = self.imageDisplayed;
        end
    end
end
