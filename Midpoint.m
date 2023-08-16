function h = Midpoint(varargin)
% Midpoint  creates a midpoint or centroid between two points or more points
%
%   Midpoint({A,B}) creates a dependent Geomatplot point that is a midpoint between A and B points.
%
%   Midpoint({A,B,C,...}) creates the centroid point of any number of points or polygons or curves.
%       For curves, it uses its automatic polygonization.
%
%   Midpoint(label,___)  provides a label for the point.
%
%   Midpoint(parent,___)  draws onto the given geomatplot, axes, or figure instead of
%       the current one. Thus must preceed the label argument if that is given also.
%
%   Midpoint(___,color)  specifies the color of the point and its label, the default is 'b'. This may
%       be a colorname or a three element vector.
%
%   Midpoint(___,Name,Value)  specifies additional properties using one or more Name,
%       Value pairs arguments.
%
%   h = Midpoint(___)  returns the created handle.
%
%   See also POINT, SEGMENT, CIRCLE

    [parent,label,inputs,args] = dpoint.parse_inputs(varargin);

    if length(inputs)==1 && isa(inputs{1},'dcircle')
        h_ = inputs{1}.center;
    else
        for i = 1:length(inputs)
            l = inputs{i};
            if isa(l,'dcurve') || isa(l,'dimage') || isa(l,'dnumeric')
                throw(MException('Midpoint:invalidInput','The input cannot be of this type.'));
            end
        end
        h_ = dpoint(parent,label,inputs,@midpoint_,args);
    end
    
    if nargout >=1; h=h_; end
end

function v = midpoint_(varargin)
    x = varargin{1}.value;
    n = size(x,1);
    v = mean(x,1);
    for j=2:nargin
        x = varargin{j}.value;
        n1 = size(x,1);
        v = v*n/(n+n1) + mean(x,1)*n1/(n+n1);
        n = n + n1;
    end
end
