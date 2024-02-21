function epath = Fluery_Greedy_Compact(g,pos)
%% Fluery algorithm for finding an Euler path; runs in O(E^2) where E is the number of edges
% Works only if the truss has no more than two nodes with odd degree
% Follows these website: https://slaystudy.com/fleurys-algorithm/, https://www.geeksforgeeks.org/fleurys-algorithm-for-printing-eulerian-path/

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
    
    galledges = g;
    stuckbool = 0;
    while length(epath)~=(numedges(galledges)+1)
        u = epath(end);
        if length(neighbors(g,u))==1
            v = neighbors(g,u);
        elseif ~stuckbool
            % v = randsample(neighbors(g,u),1); % pick neighbor node at random
            %% Greedy algorithm for picking closer neighboring nodes while calcuting Euler path
            %% Intuition is to try and keep the path "compact"
            allneighbors = neighbors(g,u); % pick neighbor node with SHORTEST distance to last node in Euler path
            allneighborspos = pos(allneighbors,:);
            if length(epath)==1
                currentnode = startnode;
            else
                currentnode = epath(end-1);
            end
            previousnodepos = pos(currentnode,:);
            allneighborsdistances = zeros(size(allneighborspos,1),1);
            for i = 1:size(allneighbors,1)
                allneighborsdistances(i,1) = norm(previousnodepos-allneighborspos(i,:));
            end
            allneighborsdistancessorted = [allneighbors,allneighborsdistances];
            allneighborsdistancessorted = round(allneighborsdistancessorted,3);
            allneighborsdistancessorted = sortrows(allneighborsdistancessorted,2,'ascend');
            mindistanceneighborsnum = sum(allneighborsdistancessorted(:,2)==allneighborsdistancessorted(1,2)); % find all neighbors with minimum distance
            [~,indx] = mink(allneighborsdistancessorted(:,2),mindistanceneighborsnum);
            mindistanceneighbors = allneighborsdistancessorted(indx,1);
            if length(mindistanceneighbors)==1
                v = mindistanceneighbors;
            else
                v = randsample(mindistanceneighbors,1); % randomly pick neighbor with minimum distance
            end
        elseif stuckbool % if edge to mininum distance neighbor is a bridge
            v = allneighborsdistancessorted(count,1);
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
        if length(count2)>=length(count1) || singularnode % check if edge is a bridge - if not add it to euler path and remove from graph
            stuckbool = 0;
            count = 1;
            epath = [epath;v];
            g = rmedge(g,u,v);
        elseif length(mindistanceneighbors)==1 % if while loop is stuck trying to remove an edge which is definitely a bridge
            stuckbool = 1;
            count = count + 1;
%             plot(g, 'XData', pos(:,1), 'YData', pos(:,2), 'ZData', pos(:,3))
%             axis equal
        end
    end    

end