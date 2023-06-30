classdef geomatplot < handle
    
properties (Access=public)
   ax    (1,1)  %matlab.ui.Axes;
   figs  %(1,1) containers.Map; % todo struct for 5 times speedup?
   data  %(1,1) containers.Map;
   unlabeled (1,1) int64 = 0;
end

methods (Access=public)
        
    function o = geomatplot(ax)
        if nargin == 0
            o.ax = gca;
        elseif isa(ax,'matlab.ui.Figure')
            if isempty(ax.Children)
                o.ax = axes(ax);
            else
                o.ax = ax.Children(1);
            end
        elseif isa(ax,'matlab.ui.Axes')
            o.ax = ax;
        end
        o=buildMap(o);
        axis(o.ax,'equal');
        axis(o.ax,'manual');
    end
    
    function disp(o)
        keys = o.figs.keys;
        vals = o.figs.values;
        fprintf('%10s %20s\n','labels','plot type ');
        for i=1:length(keys)
            fprintf('%10s %20s\n',['''' keys{i} ''''],vals{i}.Type);
        end
    end
    
    function o = addPoint(o,label,varargin)
        args = geomatplot.parseinputs(label,varargin{:});
        o.deleteIfExists(label);
        o.figs(label) = drawpoint(args{:});
    end
    
    function o = addPolygon(o,label,varargin)
       args = geomatplot.parseinputs(label,varargin{:});
       o.deleteIfExists(label);
       o.figs(label) = drawpolygon(args{:});
    end

    function h = drawLine(o,varargin)
        [label,labels,callback,args] = o.parseDrawInputs('line',varargin{:});
        o.deleteIfExists(label);
        outs = cell(1,abs(nargout(callback)));
        [outs{:}]= o.callCallback(labels,callback);
        [xdata,ydata] = geomatplot.parseLineOutputs(outs);
        hold(o.ax,'on');
        h = line(o.ax,xdata,ydata,args{:});
        o.figs(label) = h;
        hold(o.ax,'off');
        o.addCallback(label,labels,callback);
    end

    function h = drawImage(o,varargin)
        [label,labels,callback,args] = o.parseDrawInputs('image',varargin{:});
        o.deleteIfExists(label);
        outs = cell(1,abs(nargout(callback)));
        [outs{:}]= o.callCallback(labels,callback);
        C = geomatplot.parseImageOutputs(outs);
        hold(o.ax,'on');
        args
        h = imagesc(o.ax,'CData',C,args{:});
        o.figs(label) = h;
        hold(o.ax,'off');
        %o.addCallback(label,labels,callback);
    end

    function varargout=subsref(o,subs)
        switch subs(1).type
            case '()'
                if length(o) > 1 || length(subs) > 1 || length(subs.subs) > 1
                    error 'not supported indexing';
                end                
                varargout = {o.getElement(subs.subs{1})};
            otherwise   
              [varargout{1:nargout}]=builtin('subsref',o,subs);
        end
    end

    function ret = getElement(o,label)
        if ~isKey(o.figs,label)
            error(['label ''' label ''' not found']);
        end
        h = o.figs(label);
        if contains(class(h),'images.roi.')
            switch h.Type(12:end)
            case {'point','polygon','polyline','line','crosshair','rectangle','cuboid'}
                ret = h.Position;
            case 'circle'
                ret = struct('Center',h.Center,'Radius',h.Radius);
                case 'ellipse'
                ret = struct('Center',h.Center,'SemiAxes',h.SemiAxes,...
                          'RotationAngle',h.RotationAngle,'AspectRatio',h.AspectRatio);
            otherwise
                ret = h; % any other type
            end
        else
            ret = h; % any other type
        end
    end

end % public member functions

methods (Access=protected)
    
    function o = buildMap(o)
        untagged = 1;
        o.figs = containers.Map('KeyType','char','ValueType','any');
        o.data = containers.Map('KeyType','char','ValueType','any');
        for i=1:length(o.ax.Children)
            h = o.ax.Children(i);
            if contains(class(h),'images.roi')
                label = h.Label;
            elseif contains(class(h),'matlab.graphics.primitive') ...
                || contains(class(h),'matlab.graphics.chart.primitive')
                if isempty(h.Tag)
                    h.Tag = ['tag' int2str(untagged)];
                    warning(['Tag property is undefined, assigning tag ''' h.Tag '''']);
                    untagged = untagged + 1;
                end
                label = h.Tag;
            end
            if o.figs.isKey(label) || o.data.isKey(label)
               warning(['label ''' label ''' exists already, deleting old entry']);
               delete(o.figs(label));
            end
            o.figs(label) = h;
        end
    end

    function updateCallback(o,label,labels,callback)
        % todo measure time to execute
        outs = cell(1,abs(nargout(callback)));
        [outs{:}]= o.callCallback(labels,callback);
        h = o.figs(label);
        % todo type check
        [xdata,ydata] = geomatplot.parseLineOutputs(outs);
        h.XData = xdata; h.YData = ydata;
    end

    function addCallback(o,label,labels,callback)
        if o.data.isKey(label)
            s = o.data(label);
            if ~isempty(s.Callback)
                warning(['Overwriting previous callback for label ''' label '''.']);
            end
        end
        for i=1:length(labels)
            l = labels{i};
            h = o.figs(l);
            callfun = @(~,~) o.updateCallback(label,labels,callback);
            addlistener(h,'ROIMoved',callfun);
            addlistener(h,'MovingROI',callfun);
        end
        s.Callback = callback;
        s.Labels = labels;
        o.data(label) = s;
    end

    function [varargout] = callCallback(o,labels,callback)
        args = cell(1,length(labels));
        for i = 1:length(labels)
            args{i} = o.getElement(labels{i});
        end
        [varargout{1:nargout}] = callback(args{:});
    end
    
    function o = deleteIfExists(o,label)
       if o.figs.isKey(label)
           warning(['label ''' label ''' exists already, deleting old entry']);
           delete(o.figs(label));
           remove(o.figs,label);
       end
    end

    function [label,labels,callback,args] = parseDrawInputs(o,option,varargin)
       p = inputParser;
       p.addRequired('Labels',@(x) iscell(x));
       p.addRequired('Callback',@(x) isa(x,'function_handle'));
       p.addParameter('Label',[],@ischar);
       switch option
       case {'image'}
           islim = @(x) isnumeric(x) && length(x)==2 && x(1) <= x(2);
           p.addOptional('XData',[0 1],islim);
           p.addOptional('YData',[0 1],islim);
       case {'line'}
           % Do nothing
       end
       p.KeepUnmatched = true;
       p.parse(varargin{:});
       label = p.Results.Label; labels = p.Results.Labels; callback = p.Results.Callback;
       if isempty(label)
           o.unlabeled = o.unlabeled + 1;
           label = ['label' int2str(o.unlabeled)];
       end
       names = fieldnames(p.Unmatched); values = struct2cell(p.Unmatched);
       n = length(names)*2;
       args(1:2:n) = names; args(2:2:n) = values;
       switch option
       case {'image'}
           args = [{'XData',p.Results.XData,'YData',p.Results.XData},args(:)];
       case {'line'}
           % Do nothing
       end
    end
    

end % protected member functions

methods (Static)

    function args = parseinputs(label,varargin)
       p = inputParser;
       p.addRequired('Label',@ischar);
       p.addOptional('Position',[],@isnumeric);
       shorcolnames = 'rgbcmykw';
       longcolnames = ["red","green","blue","cyan","magenta","yellow","black","white"];
       iscolor = @(x) ...
           isnumeric(x) && (length(x)==3) ||...
           ischar(x) && (length(x)==1) && any(x==shorcolnames) || ...
           (isstring(x) || ischar(x)) && any(strcmp(x,longcolnames));
       p.addOptional('Color','k',iscolor);
       ispositive = @(x)isnumeric(x) && isscalar(x) && x>=0;
       p.addParameter('MarkerSize',7,ispositive);
       p.addParameter('LabelAlpha',0,ispositive);
       p.KeepUnmatched = true;
       p.parse(label,varargin{:});
       Results = p.Results;
       if isempty(p.Results.Position)
           Results = rmfield(p.Results,'Position');
       end
       Results.LabelTextColor = p.Results.Color;
       names = [fieldnames(Results) fieldnames(p.Unmatched)];
       values = [struct2cell(Results) struct2cell(p.Unmatched)];
       n = length(names)*2;
       args(1:2:n) = names(:);
       args(2:2:n) = values(:);
    end

    function [xdata,ydata] = parseLineOutputs(args)
        if length(args) == 1
            xy = args{1};
            if size(xy,2) == 2
                xdata = xy(:,1);
                ydata = xy(:,2);
            elseif size(xy,1) == 2
                xdata = xy(1,:);
                ydata = xy(2,:);
            end
        elseif length(args) == 2
            xdata = args{1};
            ydata = args{2};
        else
            error 'Callback has too many outputs.'
        end
    end

    function C = parseImageOutputs(args)
        if length(args) == 1
            C = args{1};
        elseif length(args) ==3
            C = cat(3,args{1},args{2},args{3}); %rgb
        else
            error 'Callback has the wrong number of outputs.'
        end
    end

end % static member functions
    
end