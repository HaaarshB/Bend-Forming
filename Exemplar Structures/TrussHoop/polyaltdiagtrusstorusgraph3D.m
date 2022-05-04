function [g,pos] = polyaltdiagtrusstorusgraph3D(rinner, router, ninner, nouter, sidenum)

%% Coordinates
sidenum=sidenum-1;
nbays=nouter*(sidenum+1);
numnodes = ninner*nbays; 
pos = zeros(numnodes,3);
rotangles = linspace(0,2*pi,nbays+1); % angular coordinates of bays
rotangles(end) = [];
rotnum = 1;
theta = linspace(0,2*pi,ninner+1); % anglular coordinates of longeron nodes
theta = theta + mod(ninner,2)*pi*(1-4/ninner); % rotate nodes if odd number of longerons
theta(end)=[];

outerpolysidelength = 2*router*sin(pi/nouter);
outerpolyhalfangle = pi*(nouter-2)/(2*nouter);
routervary1 = zeros(sidenum+1,1);
routervary1(1) = router;
for i=1:sidenum
    h = outerpolysidelength/(sidenum+1)*i;
    routervary1(i+1) = sqrt(h^2+router^2-2*h*router*cos(outerpolyhalfangle));
end
routervary2 = zeros(sidenum+1,1);
routervary2(1) = router-rinner;
for i=1:sidenum
    h = (2*(router-rinner)*sin(pi/nouter))/(sidenum+1)*i;
    routervary2(i+1) = sqrt(h^2+(router-rinner)^2-2*h*(router-rinner)*cos(outerpolyhalfangle));
end
rinnervary = routervary1-routervary2;

for side=1:nouter
    rindx = 1;
    for n=((sidenum+1)*(side-1)*ninner+1):ninner:((sidenum+1)*(side)*ninner+1) % make array of node coordinates for all bays
        if n~=((sidenum+1)*(side)*ninner+1)
            [xrot, yrot] = rotangle2D(rinnervary(rindx)*cos(theta')+routervary1(rindx), 0*ones(size(theta,2),1), rotangles(rotnum));
            pos(n:(n+ninner-1),:) = [xrot, yrot, rinnervary(rindx)*sin(theta')]; % [x,y,z]
            rotnum = rotnum + 1;
            rindx = rindx + 1;
        end
    end
end

% figure()
% scatter3(pos(:,1),pos(:,2),pos(:,3))
    
%% Connections

% Examples of edges
% s=[1 2 3 4 5  1 2 3 4 5   1 2 3 4 5      6 7 8 9 10  6 7 8 9 10      6 7 8 9 10         11 12 13 14 15  11 12 13 14 15  11 12 13 14 15]; % five longerons w three cirnum
% t=[2 3 4 5 1  6 7 8 9 10  7 8 9 10 6     7 8 9 10 6  11 12 13 14 15  12 13 14 15 11     12 13 14 15 11  1 2 3 4 5       2 3 4 5 1];

% s=[1 2 3  1 2 3  1 2 3    4 5 6  4 5 6  4 5 6    7 8 9  7 8 9     7 8 9      10 11 12  10 11 12  10 11 12]; % three longerons w four cirnum
% t=[2 3 1  4 5 6  5 6 4    5 6 4  7 8 9  8 9 7    8 9 7  10 11 12  11 12 10   11 12 10  1 2 3     2 3 1];

% Different s and t compared to trous without alternating diagonals
% 15 11 12 13 14
% 9 7 8
% 3 1 2

s=[];
t=[];
for b=1:nbays
    start = 1+ninner*(b-1);
    s(end+1:end+3*ninner,1) = repmat(start:(start+ninner-1),1,3)';
    if b==nbays
        t(end+1:end+ninner,1) = [((start+1):(start+ninner-1))';start];
        t(end+1:end+ninner,1) = (1:ninner)';
        t(end+1:end+ninner,1) = [ninner; 1; (2:ninner-1)'];
    elseif mod(b,2)==1
        t(end+1:end+ninner,1) = [((start+1):(start+ninner-1))'; start];
        t(end+1:end+ninner,1) = ((start+ninner):(start+2*ninner-1))';
        t(end+1:end+ninner,1) = [((start+ninner+1):(start+2*ninner-1))'; start+ninner];
    elseif mod(b,2)==0
        t(end+1:end+ninner,1) = [((start+1):(start+ninner-1))'; start];
        t(end+1:end+ninner,1) = ((start+ninner):(start+2*ninner-1))';
        t(end+1:end+ninner,1) = [(start+2*ninner-1); start+ninner; ((start+ninner+1):(start+2*ninner-2))'];
    end
end

g = graph(s,t);

end