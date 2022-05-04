function epath = Hierholzer(g)
%% Hierholzer algorithm for finding an Euler path; runs in O(E) where E is the number of edges
% Works only if the truss has no more than two nodes with odd degree
% Follows this website: https://slaystudy.com/hierholzers-algorithm/
    
    if sum(mod(degree(g),2))==0 % all even degree nodes
        startnode = randsample(numnodes(g),1);
        cpath = [startnode];
    elseif sum(mod(degree(g),2))==1 % one node with odd degree
        startnode = find(mod(degree(g),2)==1);
        cpath = [startnode];
    elseif sum(mod(degree(g),2))==2 % two nodes with odd degree
        oddnodes = find(mod(degree(g),2)==1);
        startnode = randsample(oddnodes,1); % randomly chooses one out of two nodes with odd degree
        cpath = [startnode];
    end
    epath = [];
    while ~isempty(cpath)
        u = cpath(end);
        if isempty(neighbors(g,u))
            cpath(end) = [];
            epath = [epath, u];
        else
            if length(neighbors(g,u))==1
                v = neighbors(g,u);
            else
                v = randsample(neighbors(g,u),1); % pick neighbor node at random
            end
            cpath = [cpath, v];
            gedges = table2array(g.Edges);
            edgeindxtorm = find(ismember(gedges,[u,v],'rows')); % find index of edge to remove
            if isempty(edgeindxtorm)
                edgeindxtorm = find(ismember(gedges,[v,u],'rows'));
            end
            g = rmedge(g,edgeindxtorm(1)); % remove only one edge
%             figure()
%             plot(g, 'XData', pos(:,1), 'YData', pos(:,2), 'Zdata', pos(:,3))
        end
    end
    epath = epath';
end