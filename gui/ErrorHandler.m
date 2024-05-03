classdef ErrorHandler    
    methods(Access=public,Static)
        function pointError(o,data)
            ErrorHandler.createErrorMsg(o,"''struct''","''"+class(data{1})+"''");
        end

        function segmentOrLineError(o,data)
            expected = "{''point_base'',{''point_base'',''dvector''}}";
            ErrorHandler.decideError(o,data,expected);
        end

        function circle3Error(o,data)
            expected = "{''point_base'',''point_base'',''point_base''}";
            ErrorHandler.decideError(o,data,expected);
        end

        function circle2Error(o,data)
            expected = "{''point_base''," + ...
                "{''point_base'',''dpointlineseq'',''polygon_base'',''dscalar''}}";
            ErrorHandler.decideError(o,data,expected);
        end

        function midpointError(o,data)
            expected = "{''point_base'',''point_base''}";
            ErrorHandler.decideError(o,data,expected);
        end

        function perpendicularBisectorError(o,data)
            expected = "{''point_base'',''point_base''}";
            ErrorHandler.decideError(o,data,expected);
        end

        function angleBisector3Error(o,data)
            expected = "{''point_base'',''point_base'',''point_base''}";
            ErrorHandler.decideError(o,data,expected);
        end

        function polygonError(o,data)
            expected = "{''point_base'',''dpointseq'',''polygon_base''}";
            ErrorHandler.decideError(o,data,expected);
        end

        function angleBisector4Error(o,data)
            expected = "{''point_base'',''point_base'',''point_base'',''point_base''}";
            ErrorHandler.decideError(o,data,expected);
        end

        function circularArcError(o,data)
            expected = "{''point_base'',''point_base'',{''point_base'',''dscalar''}}";
            ErrorHandler.decideError(o,data,expected);
        end

        function perpendicularLine3Error(o,data)
            expected = "{''point_base'',''point_base'',''point_base''}";
            ErrorHandler.decideError(o,data,expected);
        end

        function perpendicularLine2Error(o,data)
            expected = "{''point_base'',{''point_base'',''drawing''}}";
            ErrorHandler.decideError(o,data,expected);
        end

        function rayError(o,data)
            expected = "{''point_base'',{''point_base'',''dvector''}}";
            ErrorHandler.decideError(o,data,expected);
        end

        function vectorError(o,data)
            expected = "{''point_base'',''point_base''}";
            ErrorHandler.decideError(o,data,expected);
        end

        function intersectionError(o,data)
            expected = "{''dcircle'',''dcircle''}," + newline + ...
                "{''dcircle'',{''dlines'',''polygon_base''}}," + ...
                "{{''dlines'',''polygon_base''},''dcircle''}," + ...
                "{{''dlines'',''polygon_base''},{''dlines'',''polygon_base''}}";
            ErrorHandler.decideError(o,data,expected);
        end

        function mirrorError(o,data)
            expected = "{''point_base''," + ...
                "{''point_base'',''dpointseq'',''dcircle'',''dlines'',''polygon_base''}}," + newline + ...
                "{''dcircle'',''point_base''}," + newline + ...
                "{''dlines'',''point_base''}";
            ErrorHandler.decideError(o,data,expected);
        end

        function closestPointError(o,data)
            expected = "{''point_base'',{''point_base'',''dpointseq'',''dcircle'',''dlines'',''polygon_base''}}";
            ErrorHandler.decideError(o,data,expected);
        end

        function segmentSequenceStripError(o,data)
            expected = "{''point_base'',''dpointseq'',''polygon_base''}";
            check = length(data) < 2;
            ErrorHandler.decideSequenceError(o,data,expected,check,"Not enough input!");
        end

        function segmentSequenceLinesError(o,data)
            expected = "{''point_base'',''dpointseq'',''polygon_base''}";
            check = mod(length(data),2) == 1 || isempty(data);
            ErrorHandler.decideSequenceError(o,data,expected,check,"Input length needs to be divisible by 2!");
        end

        function segmentSequenceTrianglesError(o,data)
            expected = "{''point_base'',''dpointseq'',''polygon_base''}";
            check = mod(length(data),3) ~= 0 || isempty(data);
            ErrorHandler.decideSequenceError(o,data,expected,check,"Input length needs to be divisible by 3!");
        end

        function centroidPointError(o,data)
            expected = "{''drawing''}";
            check = length(data) < 2;
            for i = 1:length(data)
                l = data{i};
                if isa(l,'dcurve') || isa(l,'dimage') || isa(l,'dnumeric'); check = true; break; end
            end
            errorMsg = "Types: ''dcurve'',''dimage'',''dnumeric'' are not supported" + newline + ...
                "and input length should be bigger than 2!";
            ErrorHandler.decideSequenceError(o,data,expected,check,errorMsg);
        end

        function mirrorSegmentError(o,data)
            expected = "{{''point_base'',''dcircle'',''dlines'',''polygon_base''},''point_base'',''point_base''}";
            ErrorHandler.decideError(o,data,expected);
        end
    end

    methods(Access=private,Static)
        function decideSequenceError(o,data,expected,seqCheck,seqMsg)
            if Utils.checkForDuplicates(data)
                uialert(o.ax.Parent,"Duplicate selection!","Parsing Error");
            else
                if seqCheck
                    uialert(o.ax.Parent,seqMsg,"Parsing Error");
                else
                    actual = ErrorHandler.stringizeActualData(data);
                    ErrorHandler.createErrorMsg(o,expected,actual);
                end
            end
        end
        function decideError(o,data,expected)
            if Utils.checkForDuplicates(data)
                uialert(o.ax.Parent,"Duplicate selection!","Parsing Error");
            else
                actual = ErrorHandler.stringizeActualData(data);
                ErrorHandler.createErrorMsg(o,expected,actual);
            end
        end

        function ret = stringizeActualData(data)
            ret = "{";
            for i = 1:length(data)
                    ret = ret + "''" + class(data{i}) + "'',";
            end
            ret = strip(ret,'right',',') + "}";
        end

        function createErrorMsg(o,expected,actual)
            uialert(o.ax.Parent,"Expected: " + expected + ","+ newline +"but got: " + actual + "!","Parsing Error");
        end
    end
end

