function [val,Pt,txt] = drawSliderX(label, range, startPos, slideLen)

arguments
    label    (1,:) char
    range    (1,2) double = [0,1];
    startPos (1,2) double = [0 0];
    slideLen (1,1) double = 1;
end

Segment(...
    Point("Aend"+label,@() startPos   ,'LabelV','off'),...
    Point("Bend"+label,@() startPos+[slideLen,0],'LabelV','off')...
    );

Pt = Point(label,startPos,'LabelV','off');
function v = slidercallb(dp)
    v = min(startPos(1)+slideLen,max(startPos(1),dp(1)));
    Pt.fig.Position = [v startPos(2)];
    v = (v-startPos(1))/slideLen*diff(range)+range(1);
end
val = Scalar(Pt,@slidercallb);
txt = Text(Point(Pt+[-0.16 -0.04],'Visible','off'), val, @(v) label + " = " + num2str(v));

end