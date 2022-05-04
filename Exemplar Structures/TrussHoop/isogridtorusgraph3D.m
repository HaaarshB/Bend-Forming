function [g,pos] = isogridtorusgraph3D(rinner, router, ninner, cirnum)

%% Coordinates
numnodes = ninner*cirnum;
pos = zeros(numnodes,3);
rotangles = linspace(0,2*pi,cirnum+1); % angular coordinates of bays
rotangles(end) = [];
rotnum = 1;
theta1 = linspace(0,2*pi,ninner+1); % anglular coordinates of longeron nodes
theta1 = theta1 + mod(ninner,2)*pi/2*(1-4/ninner); % rotate nodes if odd number of longerons
theta1(end)=[];
for n=1:ninner:numnodes % make array of node coordinates for all bays
    if mod(rotnum,2)==1
        [xrot, yrot] = rotangle2D(rinner*cos(theta1')+router, 0*ones(size(theta1,2),1), rotangles(rotnum));
        pos(n:(n+ninner-1),:) = [xrot, yrot, rinner*sin(theta1')]; % [x,y,z]
    else
        theta2 = theta1 - pi/ninner; % rotate nodes
        [xrot, yrot] = rotangle2D(rinner*cos(theta2')+router, 0*ones(size(theta2,2),1), rotangles(rotnum));
        pos(n:(n+ninner-1),:) = [xrot, yrot, rinner*sin(theta2')]; % [x,y,z]
    end
    rotnum = rotnum + 1;
end

%% Connections

% Examples of edges
% s=[1 2 3 4 5  1 2 3 4 5   1 2 3 4 5      6 7 8 9 10  6 7 8 9 10      6 7 8 9 10         11 12 13 14 15  11 12 13 14 15  11 12 13 14 15]; % five longerons w three cirnum
% t=[2 3 4 5 1  6 7 8 9 10  7 8 9 10 6     7 8 9 10 6  11 12 13 14 15  15 11 12 13 14     12 13 14 15 11  1 2 3 4 5       5 1 2 3 4];

% s=[1 2 3  1 2 3  1 2 3    4 5 6  4 5 6  4 5 6    7 8 9  7 8 9     7 8 9      10 11 12  10 11 12  10 11 12]; % three longerons w four cirnum
% t=[2 3 1  4 5 6  5 6 4    5 6 4  7 8 9  9 7 8    8 9 7  10 11 12  11 12 10   11 12 10  1 2 3     3 1 2];

% s=[1,2,3,4,5, 1,2,3,4,5,  1,2,3,4,5,   6,7,8,9,10,  6,7,8,9,10,      6,7,8,9,10,      11,12,13,14,15,  11,12,13,14,15,  11,12,13,14,15,  16,17,18,19,20,  16,17,18,19,20,   16,17,18,19,20]; % five longerons w four cirnum
% t=[2,3,4,5,1, 6,7,8,9,10, 7,8,9,10,6,  7,8,9,10,6,  11,12,13,14,15,  15,11,12,13,14,  12,13,14,15,11,  16,17,18,19,20,  17,18,19,20,16,  17,18,19,20,16,  1,2,3,4,5,        5,1,2,3,4];

s=[];
t=[];
for b=1:cirnum
    start = 1+ninner*(b-1);
    s(end+1:end+3*ninner,1) = repmat(start:(start+ninner-1),1,3)';
    if b==cirnum
        t(end+1:end+ninner,1) = [((start+1):(start+ninner-1))';start];
        t(end+1:end+ninner,1) = (1:ninner)';
        t(end+1:end+ninner,1) = [ninner;1;(2:(ninner-1))'];
    elseif mod(b,2)==1
        t(end+1:end+ninner,1) = [((start+1):(start+ninner-1))'; start];
        t(end+1:end+ninner,1) = ((start+ninner):(start+2*ninner-1))';
        t(end+1:end+ninner,1) = [((start+ninner+1):(start+2*ninner-1))'; start+ninner];
    else
        t(end+1:end+ninner,1) = [((start+1):(start+ninner-1))'; start];
        t(end+1:end+ninner,1) = ((start+ninner):(start+2*ninner-1))';
        t(end+1:end+ninner,1) = [(start+2*ninner-1); start+ninner; ((start+ninner+1):(start+2*ninner-2))'];
    end
end

g = graph(s,t);

end