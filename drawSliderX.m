function [val,Pt,txt] = drawSliderX(varargin)

    [parent,varargin] = Geomatplot.extractGeomatplot(varargin);    
    [label, varargin] = parent.extractLabel(varargin,'sliderx');

    args = parse_slider(varargin{:});
    Seg = Segment(parent,...
        Point(parent,"Aend"+label,@() args.startPos,'LabelV','off','Visible',args.Visible),...
        Point(parent,"Bend"+label,@() args.startPos+[args.slideLen,0],'LabelV','off','Visible',args.Visible),...
        'Visible',args.Visible);
    
    Pt = Point(parent,label,args.startPos + [args.slideLen*((args.startVal-args.range(1))/diff(args.range)), 0],Seg,'LabelV','off','Visible',args.Visible);
    val = Scalar(parent,Pt, @(dp) (dp(1)-args.startPos(1))/args.slideLen*diff(args.range)+args.range(1));
    txt = Text(parent,Point(parent,Pt+[-0.16 -0.04],'Visible','off'), val, @(v) Pt.label + " = " + num2str(v),'Visible',args.Visible);
end

function params = parse_slider(range,startPos,slideLen,startVal,params)
    arguments
        range    (1,2) double = [0,1]
        startPos (1,2) double = [0 0]
        slideLen (1,1) double = 1
        startVal (1,1) double = range(1)
        params.Visible      (1,:) char   {mustBeMember(params.Visible,{'on','off'})} = 'on'
    end
    params.range = range;
    params.startPos = startPos;
    params.slideLen = slideLen;
    params.startVal = startVal;
end