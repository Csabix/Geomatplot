function retFunc = GetDefinedCallback(name, inputs, ownerLabel)
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
            % not the best, it always writes the output to value attribute,
            % there should be a function determining which attribute to
            % change
            
            a = inputs{1};
            b = inputs{2};
            out = ownerLabel;
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
        
        case 'equidistpoint'
            a = string(inputs{1}.label);
            b = string(inputs{2}.label);
            c = string(inputs{3}.label);
            out = string(ownerLabel);
            retFunc = "temp = new MutationObserver((mutationList, observer) => {for (const mutation of mutationList) {if (mutation.type === 'attributes') {\n" + ...
                      "let a = math.matrixFromRows([document.getElementById('"+a+"').getAttributeNS(null, 'cx'),document.getElementById('"+a+"').getAttributeNS(null, 'cy')])\n" + ...
			          "let b = math.matrixFromRows([document.getElementById('"+b+"').getAttributeNS(null, 'cx'),document.getElementById('"+b+"').getAttributeNS(null, 'cy')])\n" + ...
			          "let c = math.matrixFromRows([document.getElementById('"+c+"').getAttributeNS(null, 'cx'),document.getElementById('"+c+"').getAttributeNS(null, 'cy')])\n" + ...
			          "let n = math.subtract(a, b);let m = math.subtract(b, c);\n" + ...
    		          "let v = math.multiply(0.5, math.divide(math.matrixFromColumns(math.multiply(math.add(a,b),math.transpose(n)), math.multiply(math.add(b,c),math.transpose(m))), math.matrixFromColumns(n,m)))\n" + ...
			          "document.getElementById('"+out+"').setAttributeNS(null, 'cx', v.at(0)[0]);document.getElementById('"+out+"').setAttributeNS(null, 'cy', v.at(0)[1]);}}});\n" + ...
                      "temp.observe(document.getElementById('"+a+"'), config);temp.observe(document.getElementById('"+b+"'), config);temp.observe(document.getElementById('"+c+"'), config);\n";
        
        case 'midpoint_'
            out = string(ownerLabel);
            retFunc = "temp = new MutationObserver((mutationList, observer) => {for (const mutation of mutationList) {if (mutation.type === 'attributes') {\n";
            retFunc = retFunc + "let x = math.matrixFromRows([document.getElementById('"+string(inputs{1}.label)+"').getAttributeNS(null, 'cx'),document.getElementById('"+string(inputs{1}.label)+"').getAttributeNS(null, 'cy')])\n";
            retFunc = retFunc + "let n = math.size(x)[0];let v = math.mean(x, 0);let n1;";
            for i = 2:length(inputs)
                retFunc = retFunc + "x = math.matrixFromRows([document.getElementById('"+string(inputs{i}.label)+"').getAttributeNS(null, 'cx'),document.getElementById('"+string(inputs{i}.label)+"').getAttributeNS(null, 'cy')])\n";
                retFunc = retFunc + "n1 = math.size(x)[0];v = math.add(math.multiply(v, (n/(n+n1))), math.multiply(math.mean(x, 0), (n1/(n+n1))));n = n + n1;\n";    
            end
            retFunc = retFunc + "document.getElementById('"+out+"').setAttributeNS(null, 'cx', v[0]);document.getElementById('"+out+"').setAttributeNS(null, 'cy', v[1]);}}});\n";
            for i = 1:length(inputs)
                retFunc = retFunc + "temp.observe(document.getElementById('"+string(inputs{i}.label)+"'), config);";
            end

        case 'angle_bisector3'
            a = string(inputs{1}.label);
            b = string(inputs{2}.label);
            c = string(inputs{3}.label);
            retFunc = "temp = new MutationObserver((mutationList, observer) => {for (const mutation of mutationList) {if (mutation.type === 'attributes') {\n" + ...
            "let a = math.matrixFromRows([document.getElementById('"+a+"').getAttributeNS(null, 'cx'),document.getElementById('"+a+"').getAttributeNS(null, 'cy')])\n" + ...
			"let b = math.matrixFromRows([document.getElementById('"+b+"').getAttributeNS(null, 'cx'),document.getElementById('"+b+"').getAttributeNS(null, 'cy')])\n" + ...
			"let c = math.matrixFromRows([document.getElementById('"+c+"').getAttributeNS(null, 'cx'),document.getElementById('"+c+"').getAttributeNS(null, 'cy')])\n" + ...
            "let ab = math.subtract(a,b);let cb = math.subtract(c,b);" + ...
            "let v = math.add(b, math.dotMultiply(math.add(math.divide(ab, math.sqrt(math.dot(math.transpose(ab),math.transpose(ab)))), math.divide(cb, math.sqrt(math.dot(math.transpose(cb),math.transpose(cb))))),math.matrixFromColumns([-1e8,-1e4,0,1,1e4,1e8])));\n"+...
            "let line = document.getElementById('"+ownerLabel+"');let segments = line.querySelectorAll('line');"+ ...
            "for (let i = 0; i < v.length-1; ++i) {segments[i].setAttributeNS(null, 'x1', v[i][0]);segments[i].setAttributeNS(null, 'y1', v[i][1]);" + ...
            "segments[i].setAttributeNS(null, 'x2', v[i+1][0]);segments[i].setAttributeNS(null, 'y2', v[i+1][1]);}}}});\n" + ...
            "temp.observe(document.getElementById('"+a+"'), config);temp.observe(document.getElementById('"+b+"'), config);temp.observe(document.getElementById('"+c+"'), config);\n";

        case 'dcircleDefaultCallback'
            a = inputs{1};
            b = inputs{2};
            out = ownerLabel;
            retFunc = "temp = new MutationObserver((mutationList, observer) => {for (const mutation of mutationList) {if (mutation.type === 'attributes') {\n";
            retFunc = retFunc + "document.getElementById('"+string(out)+"').setAttributeNS(null, 'cx', document.getElementById('"+string(a.label)+"').getAttributeNS(null, 'cx'));\n";
            retFunc = retFunc + "document.getElementById('"+string(out)+"').setAttributeNS(null, 'cy', document.getElementById('"+string(a.label)+"').getAttributeNS(null, 'cy'));\n";
            retFunc = retFunc + "document.getElementById('"+string(out)+"').setAttributeNS(null, 'r', document.getElementById('"+string(b.label)+"').getAttributeNS(null, 'value'));}}});\n";
            retFunc = retFunc + "temp.observe(document.getElementById('"+string(a.label)+"'), config);temp.observe(document.getElementById('"+string(b.label)+"'), config);\n";

        otherwise
            retFunc = "\n";
    end
end

