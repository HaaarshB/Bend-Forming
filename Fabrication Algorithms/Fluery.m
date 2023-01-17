function epath = Fluery(g)
%% Fluery algorithm for finding an Euler path; runs in O(E^2) where E is the number of edges
% Works only if the truss has no more than two nodes with odd degree
% Follows these websites: https://slaystudy.com/fleurys-algorithm/, https://www.geeksforgeeks.org/fleurys-algorithm-for-printing-eulerian-path/

    if sum(mod(degree(g),2))==0 % all even degree nodes
        startnode = randsample(numnodes(g),1);
        epath = startnode;
    elseif sum(mod(degree(g),2))==2 % one or two nodes with odd degree
        oddnodes = find(mod(degree(g),2)==1);
        if length(oddnodes)==1
            startnode = oddnodes;
        else
            startnode = randsample(oddnodes,1);
        end
        epath = startnode;
    else % more than two nodes with odd degree
        epath = 0;
    end
    
    gog = g;
    while length(epath)~=(numedges(gog)+1)
        u = epath(end);
        if length(neighbors(g,u))==1
            v = neighbors(g,u);
        else
            v = randsample(neighbors(g,u),1); % pick neighbor node at random
        end
        % Count number of reachable vertices before and after removing neighboring edge
        count1 = dfsearch(g,u);
        gedges = table2array(g.Edges);
        edgeindxtorm = find(ismember(gedges,[u,v],'rows')); % find index of edge to remove
        if isempty(edgeindxtorm)
            edgeindxtorm = find(ismember(gedges,[v,u],'rows'));
        end
        g = rmedge(g,edgeindxtorm(1)); % remove edge u-v
        if isempty(neighbors(g,u))
            singularnode = 1;
        else
            singularnode = 0;
        end
        count2 = dfsearch(g,u);
        g = addedge(g,u,v);
        if length(count2)>=length(count1) || singularnode % check if edge is a bridge - if not add it to euler path
            epath = [epath;v];
            g = rmedge(g,u,v); % remove only one edge
%             plot(g, 'XData', pos(:,1), 'YData', pos(:,2), 'ZData', pos(:,3))
        end
    end

end