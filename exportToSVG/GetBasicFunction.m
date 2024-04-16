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

        case '@dist_point2pointseq'
            a = inputs{1};
            b = inputs{2};

            switch class(b)
                case 'dpointseq'
                    % have to collect the svg group point coordinates into
                    % an array to make a matrix from


                    

                otherwise
                    % distance of 2 points

                    
                    
    end
end

