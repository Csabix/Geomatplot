classdef AcceptTypes
    % Contains the functions for accepting different geometries

    methods (Access = public,Static)
        function selectGeometry(elem)
            AcceptTypes.setSelected(elem,true);
        end

        function deselectGeometry(elem)
            AcceptTypes.setSelected(elem,false);
        end

        function resetDataSelection(list)
            for i = 1:numel(list)
                AcceptTypes.setSelected(list{i},false);
            end
        end
        
        function accepted = acceptSelect(data)
            accepted = (numel(data) == 1);          
        end
        
        function accepted = acceptPoint(data)
            if numel(data) ~= 1; accepted = 0; return; end
            if isa(data{1},'struct'); accepted = 1;
            else; accepted = -1; end
        end

        function accepted = acceptSegmentorLine(data)
            accepted = AcceptTypes.acceptGeometryByPattern(data,{'point_base',{'point_base','dvector'}});
        end

        function accepted = acceptCircle3(data)
            accepted = AcceptTypes.acceptGeometryByPattern(data,{'point_base','point_base','point_base'});
        end

        function accepted = acceptCircle2(data)
            accepted = AcceptTypes.acceptGeometryByPattern(data,{'point_base','point_base'});
        end

        function accepted = acceptMidpoint2(data)
            accepted = AcceptTypes.acceptGeometryByPattern(data,{'point_base','point_base'});
        end

        function accepted = acceptPerpendicularBisector(data)
            accepted = AcceptTypes.acceptGeometryByPattern(data,{'point_base','point_base'});
        end

        function accepted = acceptAngleBisector3(data)
            accepted = AcceptTypes.acceptGeometryByPattern(data,{'point_base','point_base','point_base'});
        end

        function accepted = acceptPolygon(data)
            if AcceptTypes.checkForDuplicates(data(1:end-1)) || ~all(cellfun(@(x) isa(x, 'point_base'), data))
                AcceptTypes.resetDataSelection(data);
                accepted = -1; 
                return;
            end

            AcceptTypes.setSelected(data{end},true);
            accepted = numel(data) >= 4 && data{1} == data{end};
            if accepted; AcceptTypes.resetDataSelection(data); end    
        end

        function accepted = acceptAngleBisector4(data)
            accepted = AcceptTypes.acceptGeometryByPattern(data,{'point_base','point_base','point_base','point_base'});
        end

        function accepted = acceptCircularArc(data)
            accepted = AcceptTypes.acceptGeometryByPattern(data,{'point_base','point_base','point_base'});
        end

        function accepted = acceptPerpendicularLine3(data)
            accepted = AcceptTypes.acceptGeometryByPattern(data,{'point_base','point_base','point_base'});
        end

        function accepted = acceptPerpendicularLine2(data)
            accepted = AcceptTypes.acceptGeometryByPattern(data,{'point_base',{'point_base','drawing'}});
        end

        function accepted = acceptRay(data)
            accepted = AcceptTypes.acceptGeometryByPattern(data,{'point_base',{'point_base','dvector'}});
        end

        function accepted = acceptVector(data)
            accepted = AcceptTypes.acceptGeometryByPattern(data,{'point_base','point_base'});
        end

        function accepted = acceptIntersection(data)
            patterns = {
                {'dcircle','dcircle'}
                {'dcircle',{'dlines','mpolygon'}}
                {{'dlines','mpolygon'},'dcircle'}
                {{'dlines','mpolygon'},{'dlines','mpolygon'}}
                };
            accepted = AcceptTypes.acceptGeometryByPatterns(data,patterns);
        end

        function accepted = acceptMirror(data)
            patterns = {
                {'point_base',{'point_base','dpointseq','dcircle','dlines','mpolygon'}}
                {'dcircle','point_base'}
                {'dlines','point_base'}
                };
            accepted = AcceptTypes.acceptGeometryByPatterns(data,patterns);
        end

        function accepted = acceptClosestPoint(data)
            pattern = {'point_base',{'point_base','dpointseq','dcircle','dlines','mpolygon'}};
            accepted = AcceptTypes.acceptGeometryByPattern(data,pattern);
        end
    end

    methods(Access = private,Static)
        function accepted = acceptGeometryByPattern(data,pattern)
            accepted = 1;
            AcceptTypes.setSelected(data{end},true);

            if numel(data) ~= length(pattern); accepted = 0;
            elseif AcceptTypes.checkForDuplicates(data) || ~AcceptTypes.checkInputPattern(data,pattern); accepted = -1; end

            if accepted ~= 0; AcceptTypes.resetDataSelection(data); end            
        end

        function accepted = acceptGeometryByPatterns(data,patterns)
            AcceptTypes.setSelected(data{end},true);

            for i = 1:length(patterns)
                pattern = patterns{i};
                accepted = 1;

                if numel(data) ~= length(pattern); accepted = 0;
                elseif AcceptTypes.checkForDuplicates(data) || ~AcceptTypes.checkInputPattern(data,pattern); accepted = -1;
                else; break; 
                end
            end

            if accepted ~= 0; AcceptTypes.resetDataSelection(data); end

        end

        function match = checkInputPattern(data,pattern)
            match = true;
            for i = 1:length(data)
                pat = pattern{i};
                in = data{i};
                if iscell(pat)
                    cmatch = false;
                    for j=1:length(pat)
                        cmatch = cmatch || isa(in,pat{j});
                    end
                    match = match && cmatch;
                else
                   match = match && isa(in,pat);
                end
            end
        end

        function hasDuplicates = checkForDuplicates(list)
            hasDuplicates = false;
            for i = 1:numel(list)
                for j = (i + 1):numel(list)
                    if isequal(list{i}, list{j})
                        hasDuplicates = true;
                        return;
                    end
                end
            end
        end

        function setSelected(elem,selected)
            if isa(elem,'point_base')
                fig = elem.fig;
                if selected; fig.MarkerSize = fig.MarkerSize + 2;
                else; fig.MarkerSize = fig.MarkerSize - 2; end
            elseif isa(elem,'dlines')
                fig = elem.fig;
                if selected; fig.LineWidth = fig.LineWidth + 1;
                else; fig.LineWidth = fig.LineWidth - 1; end
            end
        end
    end
end
