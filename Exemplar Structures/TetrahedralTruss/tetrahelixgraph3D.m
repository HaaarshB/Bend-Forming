function [g,pos] = tetrahelixgraph3D(sidelength, nunits, duplicate)

%% Calculate truss node coordinates
numnodes = nunits+3;
pos = zeros(numnodes,3);
pos(1:3,:) = sidelength*[0 0 0; 0 1 0; cos(pi/6) sin(pi/6) 0];
for n=1:nunits
    x1node = pos(n,:);
    x2node = pos(n+1,:);
    x3node = pos(n+2,:);
    x4node = fsolve(@(x) fourthnode3D(x,x1node,x2node,x3node,sidelength),x3node,optimset('Display','off'));
    pos(n+3,:) = x4node;
end

% figure()
% scatter3(pos(:,1),pos(:,2),pos(:,3))

%% Create graph from edges

% Examples of edges
% s = [1 1 1 2 2 2 3 3 3]
% t = [2 3 4 3 4 5 4 5 6]

s=[];
t=[];
for n=1:(numnodes-1)
    if n==(numnodes-2) % connections for second to last node
        s((end+1):(end+2),1) = n*ones(2,1);
        t((end+1):(end+2),1) = [n+1, n+2];
    elseif n==(numnodes-1) % connections for last node
        s(end+1,1) = n;
        t(end+1,1) = n+1;
    else
        s((3*n-2):(3*n),1) = n*ones(3,1);
        t((3*n-2):(3*n),1) = [n+1, n+2, n+3];
    end
end

if duplicate
    s(end+1,1) = numnodes;
    t(end+1,1) = numnodes-2;
    g = graph(s,t);
else
    g = graph(s,t);
end

end