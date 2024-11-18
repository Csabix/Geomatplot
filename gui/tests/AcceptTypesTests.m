classdef AcceptTypesTests

    methods (Access = public,Static)
        function runTests()
            clf;
            PA = Point([0 0]);
            PB = Point([1 1]);
            C = Circle(PA,PB);
            S = Segment(PA,PB);

            AcceptTypesTests.geom_by_pattern_cor(PA,PB,C,S);
            AcceptTypesTests.geom_by_pattern_wait(PA,PB,C,S);
            AcceptTypesTests.geom_by_pattern_fail(PA,PB,C,S);

            AcceptTypesTests.geom_by_patterns_cor(PA,PB,C,S);
            AcceptTypesTests.geom_by_patterns_wait(PA,PB,C,S);
            AcceptTypesTests.geom_by_patterns_fail(PA,PB,C,S);

            AcceptTypesTests.seq_in_patterns_cor(PA,PB,C,S);
            AcceptTypesTests.seq_in_patterns_wait(PA,PB,C,S);
            AcceptTypesTests.seq_in_patterns_fail_ch(PA,PB,C,S);
            AcceptTypesTests.seq_in_patterns_fail_t(PA,PB,C,S);

            disp("Tests are successful!");
        end
    end


    methods(Access=private,Static)
        function geom_by_pattern_cor(PA,~,C,S)
            data = {PA,S,C};
            pattern = {'point_base','dlines',{'point_base','dcircle'}};
            accepted = AcceptTypes.acceptGeometryByPattern(data,pattern);
            assert(accepted == 1);
        end

        function geom_by_pattern_wait(PA,~,C,S)
            data = {PA,S,C};
            pattern = {'point_base','dlines',{'point_base','dcircle'},{'dcircle'}};
            accepted = AcceptTypes.acceptGeometryByPattern(data,pattern);
            assert(accepted == 0);
        end

        function geom_by_pattern_fail(PA,PB,C,S)
            data = {PA,S,C,PB};
            pattern = {'point_base','dlines',{'point_base','dcircle'},{'dcircle'}};
            accepted = AcceptTypes.acceptGeometryByPattern(data,pattern);
            assert(accepted == -1);
        end

        function geom_by_patterns_cor(PA,~,~,S)
            data = {PA,S};
            patterns = {
                {'dcircle','dcircle'}
                {'point_base',{'dlines','polygon_base'}}
                };
            accepted = AcceptTypes.acceptGeometryByPatterns(data,patterns);
            assert(accepted == 1);
        end

        function geom_by_patterns_wait(PA,~,~,S)
            data = {PA,S};
            patterns = {
                {'dcircle','dcircle','dlines'}
                {'point_base',{'dlines','polygon_base'},'point_base'}
                };
            accepted = AcceptTypes.acceptGeometryByPatterns(data,patterns);
            assert(accepted == 0);
        end

        function geom_by_patterns_fail(PA,PB,~,S)
            data = {PA,S,PB};
            patterns = {
                {'dcircle','dcircle','dlines'}
                {'polygon_base',{'dlines','polygon_base'},'point_base'}
                };
            accepted = AcceptTypes.acceptGeometryByPatterns(data,patterns);
            assert(accepted == -1);
        end

        function seq_in_patterns_cor(PA,~,~,S)
            data = {PA,S};
            types = {'point_base','dlines','polygon_base'};
            checks = length(data) < 2;
            accepted = AcceptTypes.acceptSequencedInputGeometry(data,true,types,checks);
            assert(accepted == 1);
        end

        function seq_in_patterns_wait(PA,~,~,S)
            data = {PA,S};
            types = {'point_base','dlines','polygon_base'};
            checks = length(data) < 2;
            accepted = AcceptTypes.acceptSequencedInputGeometry(data,false,types,checks);
            assert(accepted == 0);
        end

        function seq_in_patterns_fail_ch(PA,~,~,S)
            data = {PA,S};
            types = {'point_base','dlines','polygon_base'};
            checks = length(data) < 3;
            accepted = AcceptTypes.acceptSequencedInputGeometry(data,true,types,checks);
            assert(accepted == -1);
        end

        function seq_in_patterns_fail_t(~,~,C,~)
            data = {C};
            types = {'point_base','polygon_base'};
            checks = isempty(data);
            accepted = AcceptTypes.acceptSequencedInputGeometry(data,true,types,checks);
            assert(accepted == -1);
        end
    end

end