function retFunc = GetDefinedCallback(name, inputs, ownerLabel)
    switch name
        case 'makeDraggable'
        retFunc = "function makeDraggable(evt) {\n" + ...
        "var svg = evt.target;svg.addEventListener('mousedown', startDrag);svg.addEventListener('mousemove', drag);\n" + ...
        "svg.addEventListener('mouseup', endDrag);svg.addEventListener('mouseleave', endDrag);let selectedElement;\n" + ...
        "function startDrag(evt) {if (evt.target.classList.contains('draggable')) {\n" + ...
        "selectedElement = evt.target;offset = getMousePosition(evt);\n" + ...
        "offset.x -= parseFloat(selectedElement.getAttributeNS(null, 'cx'));offset.y -= parseFloat(selectedElement.getAttributeNS(null, 'cy'));}}\n" + ...
        "function drag(evt) {if (selectedElement) {evt.preventDefault();let coord = getMousePosition(evt);\n" + ...
        "selectedElement.setAttributeNS(null, 'cx', coord.x - offset.x);selectedElement.setAttributeNS(null, 'cy', coord.y - offset.y);}}\n" + ...
        "function endDrag(evt) {selectedElement = null;}\n" + ...
        "function getMousePosition(evt) {let CTM = svg.getScreenCTM();return {x: (evt.clientX - CTM.e) / CTM.a,y: (evt.clientY - CTM.f) / CTM.d};}}\n";

        case 'dist_point2pointseq'
            % Testing needed as well for the other pointseq functions
            
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
            retFunc = retFunc + "temp.observe(document.getElementById('"+string(a.label)+"'), config);\n";
            % MINDENT FIGYELNI KELL OBSERVERREL
            if (isequal(class(b), 'dpointseq'))
                % observe all points of pointseq
                
                for k = 1:length(b.inputs) % have to get all the points in pointseq and make a matrix
                    retFunc = retFunc + "temp.observe(document.getElementById('"+string(b.inputs{k}.label)+"'), config);";
                end
                
            else % in case second input is a point
                retFunc = retFunc + "temp.observe(document.getElementById('"+string(b.label)+"'), config);\n";
            end % end of second input type check

        case 'closest_point2circle'
            a = string(inputs{1}.label);
            b = string(inputs{2}.label);
            retFunc = "temp = new MutationObserver((mutationList, observer) => {for (const mutation of mutationList) {if (mutation.type === 'attributes') {\n" + ...
            "let p = math.matrixFromRows([document.getElementById('"+a+"').getAttributeNS(null, 'cx'),document.getElementById('"+a+"').getAttributeNS(null, 'cy')])\n" + ...
            "let cp = math.matrixFromRows([document.getElementById('"+b+"').getAttributeNS(null, 'cx'),document.getElementById('"+b+"').getAttributeNS(null, 'cy')])\n" + ...
            "let cr = document.getElementById('"+b+"').getAttributeNS(null, 'r');p = math.subtract(p,cp);\n" + ...
            "p = math.add(math.multiply(math.divide(cr, math.sqrt(math.add(math.pow(p[0][0],2),math.pow(p[0][1],2)))),p),cp);" + ...
            "document.getElementById('"+ownerLabel+"').setAttributeNS(null, 'cx', p[0][0]);document.getElementById('"+ownerLabel+"').setAttributeNS(null, 'cy', p[0][1]);}}});\n" + ...
            "temp.observe(document.getElementById('"+a+"'), config);temp.observe(document.getElementById('"+b+"'), config);\n";

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
            "let a = math.matrixFromRows([document.getElementById('"+a+"').getAttributeNS(null, 'cx'),document.getElementById('"+a+"').getAttributeNS(null, 'cy')]);\n" + ...
			"let b = math.matrixFromRows([document.getElementById('"+b+"').getAttributeNS(null, 'cx'),document.getElementById('"+b+"').getAttributeNS(null, 'cy')]);\n" + ...
			"let c = math.matrixFromRows([document.getElementById('"+c+"').getAttributeNS(null, 'cx'),document.getElementById('"+c+"').getAttributeNS(null, 'cy')]);\n" + ...
            "let ab = math.subtract(a,b);let cb = math.subtract(c,b);" + ...
            "let v = math.add(b, math.dotMultiply(math.add(math.divide(ab, math.sqrt(math.dot(math.transpose(ab),math.transpose(ab)))), math.divide(cb, math.sqrt(math.dot(math.transpose(cb),math.transpose(cb))))),math.matrixFromColumns([-1e8,-1e4,0,1,1e4,1e8])));\n"+...
            "let line = document.getElementById('"+ownerLabel+"');let segments = line.querySelectorAll('line');"+ ...
            "for (let i = 0; i < v.length-1; ++i) {segments[i].setAttributeNS(null, 'x1', v[i][0]);segments[i].setAttributeNS(null, 'y1', v[i][1]);" + ...
            "segments[i].setAttributeNS(null, 'x2', v[i+1][0]);segments[i].setAttributeNS(null, 'y2', v[i+1][1]);}}}});\n" + ...
            "temp.observe(document.getElementById('"+a+"'), config);temp.observe(document.getElementById('"+b+"'), config);temp.observe(document.getElementById('"+c+"'), config);\n";

        case 'angle_bisector4'
            a = string(inputs{1}.label);
            b = string(inputs{2}.label);
            c = string(inputs{3}.label);
            d = string(inputs{4}.label);
            retFunc = "temp = new MutationObserver((mutationList, observer) => {for (const mutation of mutationList) {if (mutation.type === 'attributes') {\n" + ...
            "let a = math.matrixFromRows([document.getElementById('"+a+"').getAttributeNS(null, 'cx'),document.getElementById('"+a+"').getAttributeNS(null, 'cy')]);\n" + ...
			"let b = math.matrixFromRows([document.getElementById('"+b+"').getAttributeNS(null, 'cx'),document.getElementById('"+b+"').getAttributeNS(null, 'cy')]);\n" + ...
			"let c = math.matrixFromRows([document.getElementById('"+c+"').getAttributeNS(null, 'cx'),document.getElementById('"+c+"').getAttributeNS(null, 'cy')]);\n" + ...
            "let d = math.matrixFromRows([document.getElementById('"+d+"').getAttributeNS(null, 'cx'),document.getElementById('"+d+"').getAttributeNS(null, 'cy')]);\n" + ...
            "let na = math.multiply(math.subtract(b,a),math.matrixFromRows([0,1],[-1,0]));\n" + ...
            "let nb = math.multiply(math.subtract(d,c),math.matrixFromRows([0,1],[-1,0]));\n" + ...
            "let p0 = math.transpose(math.lusolve(math.matrixFromRows(na,nb), math.matrixFromRows(math.multiply(na,math.transpose(a)),math.multiply(nb, math.transpose(c)))));\n" + ...
            "let v1 = math.add(math.divide(na,math.sqrt(math.multiply(na, math.transpose(na)).at(0)[0])), math.divide(nb,math.sqrt(math.multiply(nb, math.transpose(nb)).at(0)[0])));\n" + ...
            "let v2 = math.multiply(v1, math.matrixFromRows([0,1],[-1,0]));\n" + ...
            "let vv = math.add(p0,math.concat(math.dotMultiply(v1,math.matrixFromColumns([-1e8,-1e4,0,1,1e4,1e8])),math.matrixFromColumns([NaN],[NaN]),math.dotMultiply(v2,math.matrixFromColumns([-1e8,-1e4,0,1,1e4,1e8])), 0));\n" + ...
            "let line = document.getElementById('"+ownerLabel+"');let segments = line.querySelectorAll('line');let j = 0;" + ...
            "for (let i = 0; i < vv.length-1; ++i) {if ( isNaN(vv[i][0]) || isNaN(vv[i+1][0])){continue;}segments[j].setAttributeNS(null, 'x1', vv[i][0]);segments[j].setAttributeNS(null, 'y1', vv[i][1]);" + ...
            "segments[j].setAttributeNS(null, 'x2', vv[i+1][0]);segments[j].setAttributeNS(null, 'y2', vv[i+1][1]);++j;}}}});\n" + ...
            "temp.observe(document.getElementById('"+a+"'), config);temp.observe(document.getElementById('"+b+"'), config);temp.observe(document.getElementById('"+c+"'), config);temp.observe(document.getElementById('"+d+"'), config);\n";
    
        case 'closest_point2pointseq'
            a = inputs{1};
            b = inputs{2};
            out = ownerLabel;
            retFunc = "temp = new MutationObserver((mutationList, observer) => {for (const mutation of mutationList) {if (mutation.type === 'attributes') {\n";
            retFunc = retFunc + "let p = math.matrixFromRows([document.getElementById('"+string(a.label)+"').getAttributeNS(null, 'cx'), document.getElementById('"+string(a.label)+"').getAttributeNS(null, 'cy')]);\n";

            if (isequal(class(b), 'dpointseq'))
                % collect all points in a matrix HAVE TO TEST THIS
                retFunc = retFunc + "let s = math.matrixFromRows(";
                for k = 1:length(b.inputs) % have to get all the points in pointseq and make a matrix
                    retFunc = retFunc + "[document.getElementById('"+string(b.inputs{k}.label)+"').getAttributeNS(null, 'cx'), document.getElementById('"+string(b.inputs{k}.label)+"').getAttributeNS(null, 'cy')]";
                    if isequal(k, length(b.inputs)) == false
                        retFunc = retFunc + ",\n";
                    end
                end
                retFunc = retFunc + ");\n";
            else % in case second input is a point
                retFunc = retFunc + "let s = math.matrixFromRows([document.getElementById('"+string(b.label)+"').getAttributeNS(null, 'cx'), document.getElementById('"+string(b.label)+"').getAttributeNS(null, 'cy')]);\n";
            end % end of second input type check
            retFunc = retFunc + "s = math.subtract(s, p);let helpArr = math.add(math.dotPow(math.column(s,0),2),math.dotPow(math.column(s,1),2));" + ...
                "let min = math.min(helpArr);let id = helpArr.findIndex(x => x == min);p = math.add(s[id],p);\n" + ...
                "document.getElementById('"+out+"').setAttributeNS(null, 'cx', p[0][0]);document.getElementById('"+out+"').setAttributeNS(null, 'cy', p[0][1]);}}});\n" + ...
                "temp.observe(document.getElementById('"+string(a.label)+"'), config);";
            
            if (isequal(class(b), 'dpointseq'))
                % observe all points of pointseq
                
                for k = 1:length(b.inputs) % have to get all the points in pointseq and make a matrix
                    retFunc = retFunc + "temp.observe(document.getElementById('"+string(b.inputs{k}.label)+"'), config);";
                end
                
            else % in case second input is a point
                retFunc = retFunc + "temp.observe(document.getElementById('"+string(b.label)+"'), config);\n";
            end % end of second input type check

        case 'perpendicular_bisector'
            a = string(inputs{1}.label);
            b = string(inputs{2}.label);
            retFunc = "temp = new MutationObserver((mutationList, observer) => {for (const mutation of mutationList) {if (mutation.type === 'attributes') {\n" + ...
            "let a = math.matrixFromRows([document.getElementById('"+a+"').getAttributeNS(null, 'cx'),document.getElementById('"+a+"').getAttributeNS(null, 'cy')]);\n" + ...
			"let b = math.matrixFromRows([document.getElementById('"+b+"').getAttributeNS(null, 'cx'),document.getElementById('"+b+"').getAttributeNS(null, 'cy')]);\n" + ...
            "let v = math.add(math.dotMultiply(math.multiply(math.subtract(a, b),math.matrixFromRows([0,1],[-1,0])), math.subtract(0.5, math.matrixFromColumns([-1e8,-1e4,0,1,1e4,1e8]))), math.multiply(math.add(a,b), 0.5));" + ...
            "let line = document.getElementById('"+ownerLabel+"');let segments = line.querySelectorAll('line');" + ...
            "for (let i = 0; i < v.length-1; ++i) {segments[i].setAttributeNS(null, 'x1', v[i][0]);segments[i].setAttributeNS(null, 'y1', v[i][1]);" + ...
            "segments[i].setAttributeNS(null, 'x2', v[i+1][0]);segments[i].setAttributeNS(null, 'y2', v[i+1][1]);}}}});\n" + ...
            "temp.observe(document.getElementById('"+a+"'), config);temp.observe(document.getElementById('"+b+"'), config);\n";
        
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

