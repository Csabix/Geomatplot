classdef Utils
    methods(Access=public,Static)
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

        function renamed = renameLabel(geometry,newLabel)
            oldLabel = geometry.label;
            go = geometry.parent;
            if ~all(isstrprop(newLabel, 'alphanum'))
                uialert(go.ax.Parent,'The new label is not alphanumeric!','Label Rename Error');
                renamed = false;
                return;
            end

            renamed = ~go.isLabel(newLabel);
            if renamed
                Utils.changeGeomatplotLabel(go,oldLabel,newLabel);
                if isprop(geometry.fig,'Label'); geometry.fig.Label = newLabel; end
                geometry.label = newLabel;
            else
                uialert(go.ax.Parent,'This label already exists!','Label Rename Error');
            end
        end
    end

    methods(Access=private,Static)
        function struct = renameField(struct,oldLabel,newLabel)
            struct.(newLabel) = struct.(oldLabel);
            struct = rmfield(struct, oldLabel);
        end

        function changeGeomatplotLabel(Geomatplot,oldLabel,newLabel)
            if isfield(Geomatplot.movs,oldLabel)
                Geomatplot.movs = Utils.renameField(Geomatplot.movs,oldLabel,newLabel);
                depFields = fieldnames(Geomatplot.deps);
                for i = 1:length(depFields)
                    dep = Geomatplot.deps.(depFields{i});
                    if isfield(dep.movs,oldLabel)
                        dep.movs = Utils.renameField(dep.movs,oldLabel,newLabel);
                    end
                end
            elseif isfield(Geomatplot.deps,oldLabel)
                Geomatplot.deps = Utils.renameField(Geomatplot.deps,oldLabel,newLabel);
                movFields = fieldnames(Geomatplot.movs);
                for i = 1:length(movFields)
                    mov = Geomatplot.movs.(movFields{i});
                    if isfield(mov.deps,oldLabel)
                        mov.deps = Utils.renameField(mov.deps,oldLabel,newLabel);
                    end
                end
            end
        end
    end
end

