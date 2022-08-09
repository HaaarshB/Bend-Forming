function [geulerian,dupedges,edgesadded,lengthadded] = MakeEulerian(g,pos)
%% Adding minimum number of duplicate edges to a graph to make it semi-Eulerian, i.e. only with two nodes with odd degree
% Brute force method to find shortest paths between all but two nodes with odd degree
% Runs in O(N!) where N is the number of odd nodes in the graph
% Follows this website: https://freakonometrics.hypotheses.org/53694

geulerian = g;
oddvertices = find(mod(degree(g),2)==1); % find nodes with odd number of connections
numpathstoadd = length(oddvertices)/2-1;
dupedges = 0;
edgesadded = [0,0];
lengthadded = 0;

% Compare pairings of odd vertices to find ones with the least distance
allpairs = nchoosek(oddvertices,2);
for i = 1:size(allpairs,1) % Loop through each possible pair of odd vertices
    pair = allpairs(i,:);
    pairpath = shortestpath(g,pair(1),pair(2)); % shortest path btw each odd vertex pairing
    allpaths(i,1:length(pairpath)) = pairpath;
    pairpathdist = 0;
    for j = 1:(size(pairpath,2)-1)
        node1 = pairpath(j);
        node2 = pairpath(j+1);
        nodecoords = [pos(node1,:); pos(node2,:)];
        pairpathdist = pairpathdist + pdist(nodecoords); % calcualte weight (i.e. total distance) of each odd vertex pairing
    end
    allpairweights(i,1) = pairpathdist;
end
allpairs(:,end+1) = allpairweights;
allpaths(:,end+1) = allpairweights;
allpairssorted = sortrows(allpairs,size(allpairs,2)); % sort pairs by weight
allpathssorted = sortrows(allpaths,size(allpaths,2));

% Add shortest duplicate paths
for i = 1:numpathstoadd
    pairtoadd = allpairssorted(1,1:2);
    pathtoadd = nonzeros(allpathssorted(1,1:(end-1)));
    lengthadded = lengthadded + allpathssorted(1,end);
    for j = 1:(size(pathtoadd,1)-1)
        dupedges = dupedges + 1; % counts number of duplicate edges added
        node1add = pathtoadd(j);
        node2add = pathtoadd(j+1);
        edgesadded(dupedges,:) = [node1add,node2add];
        geulerian = addedge(geulerian,node1add,node2add); % add duplicate edges
    end
    [rmindxrow1,~] = find(allpairssorted(:,1:2)==pairtoadd);
    [rmindxrow2,~] = find(allpairssorted(:,1:2)==flip(pairtoadd));
    rmindxrow = unique([rmindxrow1;rmindxrow2],'rows');
    allpairssorted(rmindxrow,:) = []; % after adding one duplicate path delete all other paths which use the same nodes
    allpathssorted(rmindxrow,:) = [];
end

end