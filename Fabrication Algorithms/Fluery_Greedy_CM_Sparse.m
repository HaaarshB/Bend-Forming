function epath = Fluery_Greedy_CM_Sparse(g,pos)
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
            currentpathnodes = pos(epath,:);
            previousnodepos = [mean(currentpathnodes(:,1)),mean(currentpathnodes(:,2)),mean(currentpathnodes(:,3))]; % geometric centroid of current Euler path (i.e. center of mass if all points have equal mass)
            allneighbors = neighbors(g,u); % pick neighbor node with FURTHEST distance to geometric centroid of points already in the path
            allneighborspos = pos(allneighbors,:);
            allneighborsdistances = zeros(size(allneighborspos,1),1);
            for i = 1:size(allneighbors,1)
                allneighborsdistances(i,1) = norm(previousnodepos-allneighborspos(i,:));
            end
            allneighborsdistancessorted = [allneighbors,allneighborsdistances];
            allneighborsdistancessorted = round(allneighborsdistancessorted,3);
            allneighborsdistancessorted = sortrows(allneighborsdistancessorted,2,'descend'); % THIS LINE IS DIFFERENT BETWEEN COMPACT AND SPARSE
            maxdistanceneighborsnum = sum(allneighborsdistancessorted(:,2)==allneighborsdistancessorted(1,2)); % find all neighbors with minimum distance
            [~,indx] = maxk(allneighborsdistancessorted(:,2),maxdistanceneighborsnum); % THIS LINE IS DIFFERENT BETWEEN COMPACT AND SPARSE
            maxdistanceneighbors = allneighborsdistancessorted(indx,1);
            if length(maxdistanceneighbors)==1
                v = maxdistanceneighbors;
            else
                v = randsample(maxdistanceneighbors,1); % randomly pick neighbor with furthest distance
            end
        elseif stuckbool % if edge to mininum distance neighbor is a bridge
            v = allneighborsdistancessorted(count,1);
        end
        % Count number of reachable vertices before and after removing neighboring edge
        count1 = dfsearch(g,u);
        % Remove only one edge between u-v (not all edges if there are doubled edges)
        gedges = table2array(g.Edges);
        edgeindxtorm = find(ismember(gedges,[u,v],'rows')); % find index of edge to remove
        if isempty(edgeindxtorm)
            edgeindxtorm = find(ismember(gedges,[v,u],'rows'));
        end
        g = rmedge(g,edgeindxtorm(1)); % remove only one edge between u-v (not all doubled edges)
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
            % Remove only one edge between u-v (not all edges if there are doubled edges)
            gedges = table2array(g.Edges);
            edgeindxtorm = find(ismember(gedges,[u,v],'rows')); % find index of edge to remove
            if isempty(edgeindxtorm)
                edgeindxtorm = find(ismember(gedges,[v,u],'rows'));
            end
            g = rmedge(g,edgeindxtorm(1)); % remove only one edge between u-v
%             plot(g, 'XData', pos(:,1), 'YData', pos(:,2), 'ZData', pos(:,3))
%             axis equal
        elseif length(maxdistanceneighbors)==1 % if while loop is stuck trying to remove an edge which is definitely a bridge
            stuckbool = 1;
            count = count + 1;
%             plot(g, 'XData', pos(:,1), 'YData', pos(:,2), 'ZData', pos(:,3))
%             axis equal
        end
    end    

end