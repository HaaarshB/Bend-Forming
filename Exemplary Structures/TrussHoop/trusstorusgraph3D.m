function [g,pos] = trusstorusgraph3D(rinner, router, ninner, cirnum)

%% Coordinates
numnodes = ninner*cirnum;
pos = zeros(numnodes,3);
rotangles = linspace(0,2*pi,cirnum+1); % angular coordinates of bays
rotangles(end) = [];
rotnum = 1;
theta = linspace(0,2*pi,ninner+1); % anglular coordinates of longeron nodes
theta = theta + mod(ninner,2)*pi/2*(1-4/ninner); % rotate nodes if odd number of longerons
theta(end)=[];
for n=1:ninner:numnodes % make array of node coordinates for all bays
    [xrot, yrot] = rotangle2D(rinner*cos(theta')+router, 0*ones(size(theta,2),1), rotangles(rotnum));
    pos(n:(n+ninner-1),:) = [xrot, yrot, rinner*sin(theta')]; % [x,y,z]
    rotnum = rotnum + 1;
end

%% Connections

% Examples of edges
% s=[1 2 3 4 5  1 2 3 4 5   1 2 3 4 5      6 7 8 9 10  6 7 8 9 10      6 7 8 9 10         11 12 13 14 15  11 12 13 14 15  11 12 13 14 15]; % five longerons w three cirnum
% t=[2 3 4 5 1  6 7 8 9 10  7 8 9 10 6     7 8 9 10 6  11 12 13 14 15  12 13 14 15 11     12 13 14 15 11  1 2 3 4 5       2 3 4 5 1];

% s=[1 2 3  1 2 3  1 2 3    4 5 6  4 5 6  4 5 6    7 8 9  7 8 9     7 8 9      10 11 12  10 11 12  10 11 12]; % three longerons w four cirnum
% t=[2 3 1  4 5 6  5 6 4    5 6 4  7 8 9  8 9 7    8 9 7  10 11 12  11 12 10   11 12 10  1 2 3     2 3 1];

s=[];
t=[];
for b=1:cirnum
    start = 1+ninner*(b-1);
    s(end+1:end+3*ninner,1) = repmat(start:(start+ninner-1),1,3)';
    if b==cirnum
        t(end+1:end+ninner,1) = [((start+1):(start+ninner-1))';start];
        t(end+1:end+ninner,1) = (1:ninner)';
        t(end+1:end+ninner,1) = [(2:ninner)'; 1];
    else
        t(end+1:end+ninner,1) = [((start+1):(start+ninner-1))'; start];
        t(end+1:end+ninner,1) = ((start+ninner):(start+2*ninner-1))';
        t(end+1:end+ninner,1) = [((start+ninner+1):(start+2*ninner-1))'; start+ninner];
    end
end

g = graph(s,t);

end