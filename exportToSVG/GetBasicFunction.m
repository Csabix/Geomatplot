function retFunc = GetBasicFunction(name, inputs)
    switch name
        case 'makeDraggable'
        retFunc = "\tfunction makeDraggable(evt) {\n";
        retFunc = retFunc + "\t\tvar svg = evt.target;\n";
        retFunc = retFunc + "\t\tsvg.addEventListener('mousedown', startDrag);\n";
        retFunc = retFunc + "\t\tsvg.addEventListener('mousemove', drag);\n";
        retFunc = retFunc + "\t\tsvg.addEventListener('mouseup', endDrag);\n";
        retFunc = retFunc + "\t\tsvg.addEventListener('mouseleave', endDrag);\n";
    
        retFunc = retFunc + "\t\tlet selectedElement;\n";
    
        retFunc = retFunc + "\t\tfunction startDrag(evt) {\n";
            retFunc = retFunc + "\t\t\tif (evt.target.classList.contains('draggable')) {\n";
                retFunc = retFunc + "\t\t\t\tselectedElement = evt.target;\n";
                retFunc = retFunc + "\t\t\t\toffset = getMousePosition(evt);\n";
                retFunc = retFunc + "\t\t\t\toffset.x -= parseFloat(selectedElement.getAttributeNS(null, 'cx'));\n";
                retFunc = retFunc + "\t\t\t\toffset.y -= parseFloat(selectedElement.getAttributeNS(null, 'cy'));\n";
            retFunc = retFunc + "\t\t\t}\n";
        retFunc = retFunc + "\t\t}\n";
        retFunc = retFunc + "\t\tfunction drag(evt) {\n";
            retFunc = retFunc + "\t\t\tif (selectedElement) {\n";
                retFunc = retFunc + "\t\t\t\tevt.preventDefault();\n";
                retFunc = retFunc + "\t\t\t\tlet coord = getMousePosition(evt);\n";
                retFunc = retFunc + "\t\t\t\tselectedElement.setAttributeNS(null, 'cx', coord.x - offset.x);\n";
                retFunc = retFunc + "\t\t\t\tselectedElement.setAttributeNS(null, 'cy', coord.y - offset.y);\n";
    
            retFunc = retFunc + "\t\t\t}\n";
        retFunc = retFunc + "\t\t}\n";
        retFunc = retFunc + "\t\tfunction endDrag(evt) {\n";
            retFunc = retFunc + "\t\t\tselectedElement = null;\n";
        retFunc = retFunc + "\t\t}\n";
    
        retFunc = retFunc + "\t\tfunction getMousePosition(evt) {\n";
            retFunc = retFunc + "\t\t\tlet CTM = svg.getScreenCTM();\n";
            retFunc = retFunc + "\t\t\treturn {\n";
                retFunc = retFunc + "\t\t\t\tx: (evt.clientX - CTM.e) / CTM.a,\n";
                retFunc = retFunc + "\t\t\t\ty: (evt.clientY - CTM.f) / CTM.d\n";
            retFunc = retFunc + "\t\t\t};\n";
        retFunc = retFunc + "\t\t}\n";
    retFunc = retFunc + "\t}\n";

        case 'dist_point2pointseq'
            a = inputs{1};
            b = inputs{2};
            out = inputs{3}.label;
            retFunc = "temp = new MutationObserver((mutationList, observer) => {for (const mutation of mutationList) {if (mutation.type === 'attributes') {\n";
            retFunc = retFunc + "let a = math.matrixFromRows([document.getElementById('"+string(a.label)+"').getAttributeNS(null, 'cx'), document.getElementById('"+string(a.label)+"').getAttributeNS(null, 'cy')]);\n";

            if (isequal(class(b), 'dpointseq'))
                % collect all points in a matrix HAVE TO TEST THIS
                retFunc = retFunc + "let b = math.matrixFromRows(";
                for k = 1:length(b.inputs) % have to get all the points in pointseq and make a matrix
                    retFunc = retFunc + "[document.getElementById('"+string(b.inputs{k}.label)+"').getAttributeNS(null, 'cx'), document.getElementById('"+string(b.inputs{k}.label)+"').getAttributeNS(null, 'cy')]";
                    if isequal(k, length(b.inputs)) == false
                        retFunc = retFunc + ", ";
                    end
                end
                retFunc = retFunc + ");\n";
            else % in case second input is a point
                retFunc = retFunc + "let b = math.matrixFromRows([document.getElementById('"+string(b.label)+"').getAttributeNS(null, 'cx'), document.getElementById('"+string(b.label)+"').getAttributeNS(null, 'cy')]);\n";
            end % end of second input type check
            retFunc = retFunc + "let c = math.subtract(a, b);\n";
            retFunc = retFunc + "document.getElementById('"+string(out)+"').setAttributeNS(null, 'value', math.sqrt(math.min(math.add(math.dotPow(math.column(c, 0),2), math.dotPow(math.column(c, 1),2)))));}}});\n";
            retFunc = retFunc + "temp.observe(document.getElementById('"+string(a.label)+"'), config);temp.observe(document.getElementById('"+string(b.label)+"'), config);\n";
        otherwise
            retFunc = "\n";
    end
end

