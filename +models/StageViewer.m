classdef StageViewer < handle
% StageViewer  Manages a sequential list of filtering stages (images).
%
%   Properties (private):
%       - stages: cell array storing the sequence of stage images in
%           chronological order (each element is an image matrix).
%       - currentIndex: integer indicating the index of the currently
%           active stage within the stages list.

    properties (Access = private)
        stages cell = {};
        currentIndex int32;
    end

    methods
        function self = StageViewer()
            self.currentIndex = 0;
        end


        function addStage(self, image)
        % addStage() Adds a new stage image to the list.
        %
        %   Inputs:
        %       - image: image matrix representing the current processing stage.
            self.stages{end+1} = image;
        end


        function clear(self)
        % clear() Removes all stored stages and resets the current index.
            self.stages = {};
            self.currentIndex = 1;
        end


        function img = startStage(self)
        % startStage() Returns the first stored stage image.
        %
        %   Output:
        %       - img: image matrix of the first stage, or empty if no stages exist.
            if isempty(self.stages)
                img = [];
                return;
            else
                self.currentIndex = 1;
                img = self.stages{self.currentIndex};
            end
        end


        function img = next(self)
        % next() Advances to the next stage image.
        %
        %   Output:
        %       - img: image matrix of the next stage.
            img = [];

            if self.currentIndex < numel(self.stages)
                self.currentIndex = self.currentIndex + 1;
            end
            img = self.stages{self.currentIndex};
        end


        function img = prev(self)
        % prev() Moves back to the previous stage image.
        %
        %   Output:
        %       - img: image matrix of the previous stage.
            img = [];

            if self.currentIndex > 1
                self.currentIndex = self.currentIndex - 1;
            end
            img = self.stages{self.currentIndex};
        end


        function tf = hasNext(self)
        % hasNext() Checks if there is a next stage available.
        %
        %   Output:
        %       - tf: logical true if the current index is not at the last stage.
            tf = self.currentIndex < numel(self.stages);
        end


        function tf = hasPrev(self)
        % hasPrev() Checks if there is a previous stage available.
        %
        %   Output:
        %       - tf: logical true if the current index is greater than 1.
            tf = self.currentIndex > 1;
        end


        function idx = getIndex(self)
        % getIndex() Returns the current stage index.
        %
        %   Output:
        %       - idx: integer representing the current position within the stages list.
            idx = self.currentIndex;
        end


        function n = numStages(self)
        % numStages() Returns the total number of stored stages.
        %
        %   Output:
        %       - n: integer representing the total number of stages.
            n = numel(self.stages);
        end
    end
end
