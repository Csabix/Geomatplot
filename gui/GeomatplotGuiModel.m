classdef GeomatplotGuiModel < handle
    %GEOMATPLOTGUIMODEL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        axes
        GMP
    end
    
    methods (Access = public)
        function o = GeomatplotGuiModel(appAxes)
            %GEOMATPLOTGUIMODEL Construct an instance of this class
            %   Detailed explanation goes here
            o.axes = appAxes;
            o.GMP = Geomatplot(o.axes);
            o.GMP.setState('select',1,@o.receive);
        end
        
        function setState(o,newState)
            %SETSTATE set the geomatplot state
            reqp = 1;
            switch(newState)
                case 'segment'
                    reqp = 2;
                case 'line'
                    reqp = 2;
                case 'circle3'
                    reqp = 3;
                case 'circle2'
                    reqp = 2;
                case 'midpoint2'
                    reqp = 2;
            end

            o.GMP.setState(newState,reqp,@o.receive);
        end
    end

    methods (Access = protected)
        function receive(o,type,data)
            switch type
                case 'point'
                    pdata = data{1};
                    Point(o.GMP,[pdata.x,pdata.y],'b');
                case 'select'
                    %TODO: Open property editor (notify view?)
                    %testapp.openPropertyEditor(data(1));
                case 'segment'
                    Segment(o.GMP,data{1},data{2});
                case 'line'
                    Line(o.GMP,data{1},data{2});
                case 'circle3'
                    Circle(o.GMP,data{1},data{2},data{3});
                case 'circle2'
                    Circle(o.GMP,data{1},data{2});
                case 'midpoint2'
                    Midpoint(o.GMP,data{1},data{2});
                otherwise
                    throw(MException('GeomatplotGuiModel:invalidType','Unknown state type.'))
            end
        end
    end
end

