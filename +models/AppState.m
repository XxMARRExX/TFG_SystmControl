classdef AppState < handle
% AppState  Centralized application state manager.
%
%   Properties (private):
%       - states: containers.Map storing all logical application states.
%       - activeState: name (char) of the currently active state.
%       - activeTool: handle to the currently active uitoggletool in the toolbar.

    properties (Access = private)
        states containers.Map
        activeState char
        activeTool matlab.ui.container.toolbar.ToggleTool;
        currentBBoxId;
    end
    
    methods
        function self = AppState(activeTool)
            self.states = containers.Map('KeyType', 'char', 'ValueType', 'logical');
            self.initializeAppStates();
            self.activeTool = activeTool;
        end


        function setActiveState(self, name)
        % setActiveState() Activate one state and deactivate the previous.
        %
        %   Inputs:
        %       - name: string name of the state to activate.
            if strcmp(self.activeState, name)
                return;
            end

            self.states(self.activeState) = false;

            self.states(name) = true;
            self.activeState = name;
        end


        function activeState = getActiveState(self)
            activeState = self.activeState;
        end


        function activateState(self, name)
        % activateState() Activate one state.
        %
        %   Inputs:
        %       - name: string name of the state to activate.
            self.states(name) = true;
        end


        function status = getStatusState(self, name)
            status = self.states(name);
        end


        function activeTool = getActiveTool(self)
            activeTool = self.activeTool;
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


        function state = getStateActiveTool(self)
            state = self.activeTool.State;
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


        function setCurrentBBox(self, bboxId)
            self.currentBBoxId = bboxId;
        end
    
        function bboxId = getCurrentBBox(self)
            bboxId = self.currentBBoxId;
        end
        
    end



    methods(Access = private)
        
        function initializeAppStates(self)
            self.states('initialized') = true;
            self.states('imageDisplayed') = false;
            self.states('svgUploaded')    = false;
            self.states('svgDisplayed') = false;
            self.states('croppedImageByUserDisplayed') = false;
            self.states('detectedEdgesDisplayed') = false;
            self.states('filteredEdgesDisplayed') = false;
            self.states('filteredStagesDisplayed') = false;
            self.states('errorOnPieceDisplayed') = false;
            self.states('errorStagesDisplayed') = false;

            self.activeState = 'initialized';
        end

    end

end
