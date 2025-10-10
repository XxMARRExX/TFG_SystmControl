classdef StageViewer < handle
    % StageViewer  Manages a sequential list of filtering stages (images).
    %
    %   Allows adding, navigating and retrieving images representing
    %   processing stages. Designed to be attached to a BBox object.
    %
    %   Example:
    %       viewer = StageViewer();
    %       viewer.addStage(img1);
    %       viewer.addStage(img2);
    %       current = viewer.getCurrent();  % returns img1
    %       nextImg = viewer.next();        % returns img2
    %       prevImg = viewer.prev();        % returns img1

    properties (Access = private)
        stages cell = {};
        currentIndex int32;
    end

    methods
        function self = StageViewer()
            self.currentIndex = 0;
        end


        function addStage(self, image)
            self.stages{end+1} = image;
        end


        function clear(self)
            self.stages = {};
            self.currentIndex = 1;
        end


        function img = startStage(self)
            if isempty(self.stages)
                img = [];
                return;
            else
                self.currentIndex = 1;
                img = self.stages{self.currentIndex};
            end
        end


        function img = next(self)
            img = [];

            if self.currentIndex < numel(self.stages)
                self.currentIndex = self.currentIndex + 1;
            end
            img = self.stages{self.currentIndex};
            fprintf('Index: %d / %d\n', self.currentIndex, numel(self.stages));
        end


        function img = prev(self)
            img = [];

            if self.currentIndex > 1
                self.currentIndex = self.currentIndex - 1;
            end
            img = self.stages{self.currentIndex};
            fprintf('Index: %d / %d\n', self.currentIndex, numel(self.stages));
        end


        function tf = hasNext(self)
            tf = self.currentIndex < numel(self.stages);
        end


        function tf = hasPrev(self)
            tf = self.currentIndex > 1;
        end


        function idx = getIndex(self)
            idx = self.currentIndex;
        end


        function n = numStages(self)
            n = numel(self.stages);
        end
    end
end
