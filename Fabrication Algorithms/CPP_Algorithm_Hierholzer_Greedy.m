function [geulerian,dupedges,edgesadded,lengthadded,epath] = CPP_Algorithm_Hierholzer_Greedy(g,pos)
%% Solution algorithm for Chinese Postman Problem (CPP) or Route Inspection Problem
% Finds the shortest path which visits every edge of a graph
% Follows this website: https://freakonometrics.hypotheses.org/53694

    if sum(mod(degree(g),2))<=2 % two or less nodes with odd degree
        geulerian = g;
        dupedges = 0;
        edgesadded = 0;
        lengthadded = 0;
        fprintf('Truss is Eulerian. No duplicate edges added.\n')
        epath = Hierholzer_Greedy_CM(geulerian,pos);
    else % more than two nodes with odd degree
        [geulerian,dupedges,edgesadded,lengthadded] = MakeEulerian_Greedy(g,pos); % make truss Eulerian then run Hierholzer algorithm
        fprintf(append('Truss not Eulerian.\n', num2str(dupedges), ' duplicate edges added.\n', num2str(lengthadded), ' mm extra wire added.\n'));
        epath = Hierholzer_Greedy_CM(geulerian,pos);
    end
end