classdef AppState < handle
    
    properties (Access = private)
        imageDisplayed logical = false;

    end
    
    methods (Static)

        function appState = getInstance()
            % getInstance() Returns the unique singleton instance of AppState.
            persistent uniqueInstance
            if isempty(uniqueInstance) || ~isvalid(uniqueInstance)
                uniqueInstance = models.AppState();
            end
            appState = uniqueInstance;
        end
    end


    methods (Access = public)
        
        function setImageDisplayed(self, state)
            self.imageDisplayed = state;
        end


        function state = getImageDisplayed(self)
            state = self.imageDisplayed;
        end

    end
end

