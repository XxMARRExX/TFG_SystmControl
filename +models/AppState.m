classdef AppState < handle
    % AppState  Centralized application state manager.
    %
    %   Properties (private):
    %       - imageDisplayed: Boolean flag indicating whether an image is currently
    %           displayed on the canvas.
    %       - activeTool: Save what is the active tool from the toolBar

    properties (Access = private)
        imageDisplayed logical;
        activeTool matlab.ui.container.toolbar.ToggleTool;
    end
    
    methods
        function self = AppState(activeTool)
            self.imageDisplayed = false;
            self.activeTool = activeTool;
        end


        function setImageDisplayed(self, state)
            self.imageDisplayed = logical(state);
        end


        function state = getImageDisplayed(self)
            state = self.imageDisplayed;
        end


        function activeTool = getActiveTool(self)
            activeTool = self.activeTool;
        end


        function state = getStateActiveTool(self)
            state = self.activeTool.State;
        end


        function setActiveTool(self, newActiveTool)
        % setActiveTool() Set a new active tool in the application state.
        %
        %   Inputs:
        %       - newActiveTool: Handle to the new uitoggletool that should be set
        %                        as active.
            if self.activeTool == newActiveTool
                return;
            end
               
            if ~isempty(self.activeTool) && isvalid(self.activeTool)
                self.activeTool.State = "off";
            end
        
            newActiveTool.State = "on";
            self.activeTool = newActiveTool;
        end


        function forceReactivateTool(self)
        % forceReactivateTool() Schedule reactivation of the current tool.
        %
        %   -Notes: This method uses a short-delay timer to call activateTool(), 
        %       ensuring the currently selected tool is visually and programmatically 
        %       reactivated.
            t = timer( ...
                'StartDelay', 0.02, ...
                'TimerFcn', @(~,~)self.activateTool(), ...
                'ExecutionMode', 'singleShot');
            start(t);
        end
    
        
        function activateTool(self)
        % activateTool() Force the current tool to remain active.
            if isvalid(self.activeTool)
                self.activeTool.State = "on";
            end
        end
        
    end
end
