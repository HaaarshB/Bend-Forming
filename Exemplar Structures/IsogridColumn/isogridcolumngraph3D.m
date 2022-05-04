function [g,pos] = isogridcolumngraph3D(nlongeron, nbay, r, boundary)

%% Calculate truss node coordinates
numnodes = nlongeron*(nbay+1);
axialunit = 2*pi*r / (nlongeron+1); % axial coordinates of longeron nodes
h = sqrt(3)*axialunit/2; % height of each bay using equilateral triangles
pos = zeros(numnodes,3);
theta = linspace(0,2*pi,nlongeron+1); % anglular coordinates of longeron nodes
theta(end)=[];
b=1;
offsetodd=0;
offseteven=-2*pi/(2*nlongeron);
for n=1:nlongeron:numnodes % make array of node coordinates for all bays
    if mod(b,2)==1
        pos(n:(n+nlongeron-1),:) = [r*cos((theta+offsetodd)'), r*sin((theta+offsetodd)'), (ceil(n/nlongeron)-1)*h*ones(size(theta',1),1)]; % [x,y,z]
        offsetodd = offsetodd - 2*pi/(nlongeron);
    elseif mod(b,2)==0
        pos(n:(n+nlongeron-1),:) = [r*cos((theta+offseteven)'), r*sin((theta+offseteven)'), (ceil(n/nlongeron)-1)*h*ones(size(theta',1),1)]; % [x,y,z] 
        offseteven = offseteven - 2*pi/(nlongeron);
    end
    b=b+1;
end

%% Create graph from edges

% Examples of edges
% s = [1 1 1 1 2 2 2 3 3   4 4 4 4 5 5 5 6 6     7 8 9] % three longerons w two bays
% t = [2 3 4 5 3 5 6 4 6   5 6 7 8 6 8 9 7 9     8 9 7]
% 
% s = [1 1 1 1 2 2 2 3 3 3 4 4   5 5 5 5 6 6 6 7 7 7 8 8         9 10 11 12] % four longerons w two bays
% t = [2 4 5 6 3 6 7 4 7 8 5 8   6 8 9 10 7 10 11 8 11 12 9 12   10 11 12 9]

s=[];
t=[];
for b=1:nbay
    for l=1:nlongeron % creates edges for each bay
        if l==1 % edges connected to first node in bay
            s(end+1:end+4,1) = 1+nlongeron*(b-1);
            t(end+1:end+4,1) = [2+nlongeron*(b-1), b*nlongeron, b*nlongeron+1, b*nlongeron+2];
        elseif l==nlongeron % edges connected to last node in bay
            s(end+1:end+2,1) = b*nlongeron;
            t(end+1:end+2,1) = [b*nlongeron+1, (b+1)*nlongeron];
        else
            s(end+1:end+3,1) = l+nlongeron*(b-1);
            t(end+1:end+3,1) = [l+nlongeron*(b-1)+1, l+nlongeron*b, l+nlongeron*b+1];
        end
    end
end

% add edges to patch up final bay
if boundary
    s(end+1:end+nlongeron) = (nbay*nlongeron+1):((nbay+1)*nlongeron);
    t(end+1:end+nlongeron) = [(nbay*nlongeron+2):((nbay+1)*nlongeron), (nbay*nlongeron+1)];
end

g = graph(s,t);

end