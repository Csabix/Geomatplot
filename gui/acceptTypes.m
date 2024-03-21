classdef acceptTypes
    % Contains the functions for accepting different geometries

    methods (Access = public,Static)
        function accepted = acceptSelect(data)
            accepted = (numel(data) == 1);          
        end
        
        function accepted = acceptPoint(data)
            if numel(data) ~= 1; accepted = 0; return; end
            
            point = data{1};
            if isa(point,'struct'); accepted = 1;
            else; accepted = -1; end
        end

        function accepted = acceptSegmentorLine(data)
            accepted = acceptTypes.acceptGeometryOnlyPoints(data,2);
        end

        function accepted = acceptCircle3(data)
            accepted = acceptTypes.acceptGeometryOnlyPoints(data,3);
        end

        function accepted = acceptCircle2(data)
            accepted = acceptTypes.acceptGeometryOnlyPoints(data,2);
        end

        function accepted = acceptMidpoint2(data)
            accepted = acceptTypes.acceptGeometryOnlyPoints(data,2);
        end

        function accepted = acceptPerpendicularBisector(data)
            accepted = acceptTypes.acceptGeometryOnlyPoints(data,2);
        end

        function accepted = acceptAngleBisector3(data)
            accepted = acceptTypes.acceptGeometryOnlyPoints(data,3);
        end

        function accepted = acceptPolygon(data)
            if acceptTypes.checkForDuplicates(data(1:end-1)) || ~all(cellfun(@(x) isa(x, 'point_base'), data))
                acceptTypes.resetDataSelection(data);
                accepted = -1; 
                return;
            end

            if numel(data) < 4 || data{1} ~= data{end}
                acceptTypes.setSelected(data{end},true);
                accepted = 0;
            else
                acceptTypes.resetDataSelection(data);
                accepted = 1;
            end    
        end

        function accepted = acceptAngleBisector4(data)
            accepted = acceptTypes.acceptGeometryOnlyPoints(data,4);
        end

        function accepted = acceptCircularArc(data)
            accepted = acceptTypes.acceptGeometryOnlyPoints(data,3);
        end
    end

    methods(Access = public,Static)
        function accepted = acceptGeometryOnlyPoints(data, amount)
            if acceptTypes.checkForDuplicates(data) || ~all(cellfun(@(x) isa(x, 'point_base'), data))
                acceptTypes.resetDataSelection(data);
                accepted = -1; 
                return;
            end

            if numel(data) ~= amount
                acceptTypes.setSelected(data{end},true);
                accepted = 0;
            else
                acceptTypes.resetDataSelection(data);
                accepted = 1;
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

        function selectGeometry(elem)
            acceptTypes.setSelected(elem,true);
        end

        function deselectGeometry(elem)
            acceptTypes.setSelected(elem,false);
        end

        function setSelected(elem,selected)
            if isa(elem,'point_base')
                point = elem.fig;
                if selected
                    point.MarkerSize = 10;
                else
                    point.MarkerSize = 8;
                end
            end
        end

        function resetDataSelection(list)
            for i = 1:numel(list)
                acceptTypes.setSelected(list{i},false);
            end
        end
    end
end

