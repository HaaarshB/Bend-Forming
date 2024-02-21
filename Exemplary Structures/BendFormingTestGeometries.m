clc
clearvars
close all
addpath("C:\Users\harsh\OneDrive\Documents\GitHub\Bend-Forming\Fabrication Algorithms")
addpath("C:\Users\harsh\OneDrive\Documents\GitHub\Bend-Forming\Mesh Tools")
addpath("C:\Users\harsh\OneDrive\Documents\GitHub\Bend-Forming\Mesh Tools\distmesh")
addpath("C:\Users\harsh\OneDrive\Documents\GitHub\Bend-Forming\Mesh Tools\jsonlab-master")
addpath("C:\Users\harsh\OneDrive\Documents\GitHub\Bend-Forming\Exemplary Structures\FractalTriangle")
addpath("C:\Users\harsh\OneDrive\Documents\GitHub\Bend-Forming\Exemplary Structures\IsogridColumn")
addpath("C:\Users\harsh\OneDrive\Documents\GitHub\Bend-Forming\Exemplary Structures\CurvedGridshell\WithoutAngularDefects")
addpath("C:\Users\harsh\OneDrive\Documents\GitHub\Bend-Forming\Exemplary Structures\TetrahedralTruss")
addpath("C:\Users\harsh\OneDrive\Documents\GitHub\Bend-Forming\Exemplary Structures\TrussHoop")
addpath("C:\Users\harsh\OneDrive\Documents\GitHub\Bend-Forming\Exemplary Structures\StanfordBunny\BunnyMeshes")

%% 2D FRACTAL TRIANGLE
% similar to Sierpinksi triangle (https://en.wikipedia.org/wiki/Sierpi%C5%84ski_triangle) with middle triangle removed
nunits = 2; % 5 for small, 20 for large
sidelength = 2000; % [mm]
[g,pos] = FractalTriangle2Dgraph(nunits,sidelength);
plotgraph(g,pos)

%% CURVED GRIDSHELL
D = 1000; % Diameter
FDratio = 0.3; % FD ratio
F = D * FDratio; % Focal length
H = D^2/(16*F); % Height of paraboloid
L = D/5; % Estimated triangle edge length

% 2D circular mesh transformed into a paraboloid
% fd=@(p) sqrt(sum(p.^2,2))-D/2;
fd=@(p) dcircle(p,0,0,D/2);
[coords,faces]=distmesh2d(fd,@huniform,L,[-D/2,-D/2;D/2,D/2],[]);
close all
pos2d = coords;
pos2d(:,3) = 0;
pos = coords;
pos(:,3) = zeros(size(pos,1),1);
pos(:,3) = pos(:,1).^2/(4*F) + pos(:,2).^2/(4*F); % comment this line for flat dish instead of curved dish

% Transform patched surface into a graph
edgepairs = zeros(2,3*size(faces,1));
for i=1:(3*size(faces,1))
    row = ceil(i/3);
    if mod(i,3)==1
        edgepairs(:,i) = [faces(row,1); faces(row,2)];
    elseif mod(i,3)==2
        edgepairs(:,i) = [faces(row,2); faces(row,3)];
    elseif mod(i,3)==0
        edgepairs(:,i) = [faces(row,3); faces(row,1)];
    end
end
edgepairs = sort(edgepairs)';
edgepairs = unique(edgepairs,'rows')';
s = edgepairs(1,:);
t = edgepairs(2,:);
g = graph(s,t);
plotgraph(g,pos)

%% ISOGRID COLUMN (2D or 3D)
r = 100; % column radius in mm
nlongeron = 12; % 8
nbay = 10; % 16
boundary = 1; % boolean for including top boundary

% 2D column
[g,pos] = isogridcolumngraph2D(nlongeron, nbay, r, boundary);
pos(:,3) = zeros(size(pos,1),1);
plotgraph(g,pos,1,0,[180 -90])

% Zig-zag fabrication path
heuristicpath = 1;
for n=1:nlongeron
    for b=1:nbay
        if b==nbay
            heuristicpath(end+1:end+2,1) = [n+1+(b-1)*(nlongeron+1); n+b*(nlongeron+1)];
            downline = (n+nbay*(nlongeron+1)+1):-(nlongeron+1):1;
            heuristicpath(end+1:end+length(downline),1) = downline';
        else
            heuristicpath(end+1:end+2,1) = [n+1+(b-1)*(nlongeron+1); n+b*(nlongeron+1)];
        end
    end
end


% % 3D column
% [g,pos] = isogridcolumngraph3D(nlongeron, nbay, r, boundary);
% plotgraph(g,pos,0,1,[30,0])
%     for b=1:nbay
%         if b==nbay
%             heuristicpath2D(end+1:end+2,1) = [n+1+(b-1)*(nlongeron+1); n+b*(nlongeron+1)];
%             downline = (n+nbay*(nlongeron+1)+1):-(nlongeron+1):1;
%             heuristicpath2D(end+1:end+length(downline),1) = downline';
%         else
%             heuristicpath2D(end+1:end+2,1) = [n+1+(b-1)*(nlongeron+1); n+b*(nlongeron+1)];
%         end
%     end
% end
% 
% % Zig-zag fabrication path
% heuristicpath = 1;
% for n=nlongeron:-1:1
%     if n==nlongeron
%         for b=1:nbay
%             heuristicpath(end+1:end+2,1) = [b*n; b*n+1];
%         end
%         spiralline = (nbay+1)*n:-n:n;
%         heuristicpath(end+1:end+length(spiralline)) = spiralline;
%     else
%         for b=1:nbay
%             heuristicpath(end+1:end+2,1) = [n+(b-1)*nlongeron; n+b*nlongeron+1];
%         end
%         spiralline = (n+nbay*nlongeron):-nlongeron:n;
%         heuristicpath(end+1:end+length(spiralline)) = spiralline;
%     end
% end

plotbendpathwCM(g,heuristicpath,pos,0.01,1,50,"C:\Users\harsh\Desktop\Test.mp4",[0 90])

%% TRUSS HOOP
rinner = 25; % inner radius in mm (of column cross section)
router = 70+rinner; % outer radius in mm (of torus)
nouter = 5; % number of polygonal sides in torus, set to 1 for normal hoop with SIDENUM = number of bays around circumference
ninner = 4; % number of polygonal sides in column cross setion
sidenum = 1; % sidelengths along circumference

[g,pos] = polyaltdiagtrusstorusgraph3D(rinner,router,ninner,nouter,sidenum);
avgbaysidelength(pos,ninner);
plotgraph(g,pos)
heuristicpath = heuristicpathtrusshoop(ninner,nouter,sidenum);
plotbendpathwCM(g,heuristicpath,pos,0.01,1,50,"C:\Users\harsh\Desktop\Test.mp4",[0 90])

%% TETRAHEDRAL TRUSS
diameter = 30; % mm % 100
depth = 30; % mm % 25
[g,pos] = tetrahedraltrussgraph3D(diameter,depth);
plotgraph(g,pos)

%% STANFORD BUNNY
% Load low-poly bunny from OBJ file
objfile = "C:\Users\harsh\Documents\GitHub\Bend-Forming\Exemplary Structures\StanfordBunny\BunnyMeshes\BunnyPolygonScaledHalf.obj";
[facesbunny,posbunnyog] = readObj(objfile);
[g,pos] = facestograph(facesbunny,posbunnyog);
plotgraph(g,pos)

%% Compute bend path through geometry
tic;
[geuler,dupedges,edgesadded,lengthadded,eulerpath] = CPP_Algorithm(g,pos); % random Hierholzer algorithm - classic method of finding Euler path
% [geuler,dupedges,edgesadded,lengthadded,eulerpath] = CPP_Algorithm_Hierholzer_Greedy(g,pos);
% [geuler,dupedges,edgesadded,lengthadded,eulerpath] = CPP_Algorithm_Fluery_Greedy_Compact(g,pos); % picks next node in the Euler path to be closest to previous node in the path
% [geuler,dupedges,edgesadded,lengthadded,eulerpath] = CPP_Algorithm_Fluery_Greedy_Sparse(g,pos); % picks next node in the Euler path to be furthest away from previous node in the path
% [geuler,dupedges,edgesadded,lengthadded,eulerpath] = CPP_Algorithm_Fluery_Greedy_CM_Compact(g,pos); % picks next node in the Euler path to be closest to centroid of all previous nodes in the path
% [geuler,dupedges,edgesadded,lengthadded,eulerpath] = CPP_Algorithm_Fluery_Greedy_CM_Sparse(g,pos); % picks next node in the Euler path to be furthest away from centroid of all previous nodes in the path
CPPtime = toc;
% plotbendpath(geuler,eulerpath,pos,0.1)
% plotbendpath(geuler,eulerpath,pos,0.01,1,50,"C:\Users\harsh\OneDrive\Desktop\Test.mp4",[0 90])
plotbendpathwCM(geuler,eulerpath,pos,0.01,1,50,"C:\Users\harsh\OneDrive\Desktop\Test.mp4",[0 90])

% Calculate mass of wire from bend path
densitywire = 7800; % kg/m3
diameterwire = 0.9; % mm
diameterbendhead = 1; % mm
lengthmasswire(eulerpath,pos,densitywire,diameterwire);

%% Write machine instructions to test bend path physically
pathtomake = eulerpath;
MachineInstructionsExact(pathtomake,pos,"C:\Users\harsh\OneDrive\Desktop\Test.txt",0)
% MachineInstructionsFabrication(eulerpath,pos,"C:\Users\harsh\Desktop\Test.txt",0,0,diameterbendhead,diameterwire)
% MachinePathCoordinatesCSV(pathtomake,pos,"C:\Users\harsh\OneDrive\Desktop\Test.csv")
% save("C:\Users\harsh\Desktop\Test.mat")
