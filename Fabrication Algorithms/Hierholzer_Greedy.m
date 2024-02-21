function epath = Hierholzer_Greedy(g,pos)
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
                % v = randsample(neighbors(g,u),1);
                %% Greedy algorithm for picking closer neighboring nodes while calcuting Euler path
                %% Intuition is to try and keep the path "compact"
                allneighbors = neighbors(g,u); % pick neighbor node with shortest distance to last node in cpath
                allneighborspos = pos(allneighbors,:);
                if length(cpath)==1
                    currentnode = startnode;
                else
                    currentnode = cpath(end-1);
                end
                previousnodepos = pos(currentnode,:);
                allneighborsdistances = zeros(size(allneighborspos,1),1);
                for i = 1:size(allneighbors,1)
                    allneighborsdistances(i,1) = norm(previousnodepos-allneighborspos(i,:));
                end
                allneighborsdistancessorted = [allneighbors,allneighborsdistances];
                allneighborsdistancessorted = round(allneighborsdistancessorted,3);
                allneighborsdistancessorted = sortrows(allneighborsdistancessorted,2);
                mindistanceneighborsnum = sum(allneighborsdistancessorted(:,2)==allneighborsdistancessorted(1,2)); % find all neighbors with minimum distance
                [~,indx] = mink(allneighborsdistancessorted(:,2),mindistanceneighborsnum);
                mindistanceneighbors = allneighborsdistancessorted(indx,1);
                if length(mindistanceneighbors)==1
                    v = mindistanceneighbors;
                else
                    v = randsample(mindistanceneighbors,1); % randomly pick neighbor with minimum distance
                end
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