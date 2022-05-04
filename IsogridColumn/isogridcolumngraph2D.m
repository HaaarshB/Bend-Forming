function [g,pos] = isogridcolumngraph2D(nlongeron, nbay, r, boundary)

%% Calculate truss node coordinates
numnodes = (nlongeron+1)*(nbay+1);
pos = zeros(numnodes,2);
axialunit = 2*pi*r / (nlongeron+1); % axial coordinates of longeron nodes
h = sqrt(3)*axialunit/2; % height of each bay using equilateral triangles
offset = axialunit/2;
for b=1:(nbay+1) % make array of node coordinates for all bays
    for n=1:(nlongeron+1)
        pos(n+(b-1)*(nlongeron+1),:) = [-1*((n-1)*axialunit+(b-1)*offset),(b-1)*h]; 
    end
end

%% Create graph from edges

% Examples of edges for (nlonberon, nbay)
% (3,1)
% s = [1  2 2 2  3 3 3  4 4    5 6 7]
% t = [2  3 5 6  4 6 7  7 8    6 7 8]
% (3,2)
% s = [1  2 2 2  3 3 3  4 4    5  6 6 6   7 7  7   8  8     9 10 11]
% t = [2  3 5 6  4 6 7  7 8    6  7 9 10  8 10 11  11 12    10 11 12]
% (4,1)
% s = [1  2 2 2  3 3 3  4 4 4  5 5     6 7 8 9]
% t = [2  3 6 7  4 7 8  5 8 9  9 10    7 8 9 10]

s=[];
t=[];
% creates edges for each bay
for b=1:nbay
    for l=1:nlongeron
        if l==1 % edges connected to first node in bay
            s(end+1,1) = 1+(nlongeron+1)*(b-1);
            t(end+1,1) = 2+(nlongeron+1)*(b-1);
            s(end+1:end+3,1) = 2+(nlongeron+1)*(b-1);
            t(end+1:end+3,1) = [3+(nlongeron+1)*(b-1), 3+(nlongeron+1)*(b-1)+(nlongeron-1),3+(nlongeron+1)*(b-1)+nlongeron];
        elseif l==nlongeron % edges connected to last node in bay
            s(end+1:end+2,1) = b*(nlongeron+1);
            t(end+1:end+2,1) = [b*(nlongeron+1)+nlongeron,b*(nlongeron+1)+nlongeron+1];
        else
            s(end+1:end+3,1) = 2+(nlongeron+1)*(b-1)+(l-1);
            t(end+1:end+3,1) = [3+(nlongeron+1)*(b-1), 3+(nlongeron+1)*(b-1)+(nlongeron-1),3+(nlongeron+1)*(b-1)+nlongeron]+(l-1)*ones(1,3);
        end
    end
end
% add patching edges at top
if boundary
    s(end+1:end+nlongeron) = (nbay*(nlongeron+1)+1):(nbay*(nlongeron+1)+nlongeron);
    t(end+1:end+nlongeron) = (nbay*(nlongeron+1)+2):(nbay*(nlongeron+1)+nlongeron+1);
end

g = graph(s,t);

end