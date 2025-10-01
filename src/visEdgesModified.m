function visEdgesModified(edges, ax, varargin)
%VISEDGESAPP displays a list of edges on a given axes (uiaxes or axes)
%
%   visEdgesApp(EDGES, AX) draws the list of EDGES (from subpixelEdges) on AX
%
%   visEdgesApp(EDGES, AX, 'param', val, ...) supports the same parameters as visEdges:
%       - 'showEdges': true/false
%       - 'showNormals': true/false
%       - 'lineWidth': numeric
%       - 'condition': logical array

    hold(ax, 'on');
    
    % Default options
    showEdges = true;
    showNormals = true;
    lineWidth = 1;
    condition = [];
    
    % Parse optional input parameters
    v = 1;
    while v < numel(varargin)
        switch varargin{v}
            case 'showEdges'
                assert(v+1<=numel(varargin));
                showEdges = varargin{v+1};
            case 'showNormals'
                assert(v+1<=numel(varargin));
                showNormals = varargin{v+1};
            case 'lineWidth'
                assert(v+1<=numel(varargin));
                lineWidth = varargin{v+1};
            case 'condition'
                assert(v+1<=numel(varargin));
                condition = varargin{v+1};
                if length(condition) ~= length(edges.position)
                    error('condition must be the same size as edges');
                end
            otherwise
                error('Unsupported parameter: %s',varargin{v});
        end
        v = v+2;
    end
    
    % Apply condition if needed
    if ~isempty(condition)
        edges.position = edges.position(condition);
        edges.x = edges.x(condition);
        edges.y = edges.y(condition);
        edges.nx = edges.nx(condition);
        edges.ny = edges.ny(condition);
        edges.curv = edges.curv(condition);
        edges.i0 = edges.i0(condition);
        edges.i1 = edges.i1(condition);
    end
    
    % Display edge segments
    if showEdges
        seg = 0.6;
        quiver(ax, edges.x - seg/2 * edges.ny, edges.y + seg/2 * edges.nx, ...
            seg * edges.ny, -seg * edges.nx, 0, 'r.', 'LineWidth', lineWidth);
    end
    
    % Display normal vectors
    if showNormals
        quiver(ax, edges.x, edges.y, edges.nx, edges.ny, 0, 'b', 'LineWidth', lineWidth);
    end
    
    hold(ax, 'off');
end
