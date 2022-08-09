clearvars
close all
addpath("C:\Users\harsh\Documents\GitHub\Bend-Forming\Fabrication Algorithms")
addpath("C:\Users\harsh\Documents\GitHub\Bend-Forming\Exemplar Structures\TetrahedralTruss")

%% Tetrahedral truss
diameter = 100; % mm % 200
depth = 50; % mm % 25
[g,pos] = tetrahedraltrussgraph3D(diameter,depth);

% Plot
plotgraph(g,pos)

% Unit cell bend path (heuristic)
% heuristicpath = [4,5,6,3,5,2,3,1,4,6,1,2,4]'; % for nrings=0
heuristicpath = [4,5,1,6,2,7,8,2,1,4,12,1,3,2,9,8,9,...
    3,12,11,3,10,9,20,10,21,11,10,11,22,12,23,4,24,5,16,6,...
    17,7,6,5,6,7,18,8,19,9,14,2,13,6,16,13,14,20,21,3,...
    15,1,24,15,21,22,23,24,16,17,18,19,20,21,14,15,22,...
    23,15,12,3,14,13,15,24,13,1,2,18,17,13,18,14,19]'; % for nrings=1

% plotblacksvg(heuristicpath,pos,4,[-60 60])
% plotgreenarrows(geuler,heuristicpath,pos,4,15,[-60 60])

%% Parabolic tetrahedral truss
FDratio = 0.8;
diameter = 250; % mm
depth = 40; % mm
[g,pos] = parabolictetrahedraltrussgraph3D(FDratio,diameter,depth);

% Plot
plotgraph(g,pos,1,0);

% heuristicpath = [4,5,1,6,2,7,8,2,1,4,12,1,3,2,9,8,9,...
%     3,12,11,3,10,9,20,10,21,11,10,11,22,12,23,4,24,5,16,6,...
%     17,7,6,5,6,7,18,8,19,9,14,2,13,6,16,13,14,20,21,3,...
%     15,1,24,15,21,22,23,24,16,17,18,19,20,21,14,15,22,...
%     23,15,12,3,14,13,15,24,13,1,2,18,17,13,18,14,19]'; % for nrings=0

%% Random Euler path from CPP algorithm
% Calculate and plot random Euler path
tic;
[geuler,dupedges,edgesadded,lengthadded,eulerpath] = CPP_Algorithm(g,pos);
time = toc;

%% Smarter Euler path from CPP algorithm with minimum wire rotations
% % Calculate and plot random Euler path
% tic;
% [geuler,dupedges,eulerpath] = CPP_Algorithm_minwirerotation(g,pos);
% time = toc;

%% Plot bend path
savevideo=0;
framerate=10;
filename='C:\Users\harsh\Desktop\curvedtruss_3ring.avi';
vidangle=[-37.5,30];
plotbendpath(geuler,heuristicpath,pos,0.1,savevideo,framerate,filename,vidangle);

%% Calculate mass of wire from bend path
densitywire = 7800; % kg/m3
diameterwire = 0.9; % mm
lengthmasswire(heuristicpath,pos,densitywire,diameterwire);

%% Output path for Solidworks
SolidworksOutput(eulerpath,pos,"C:\Users\harsh\Desktop\tetratrussSW.txt")

%% Output heuristic path for AutoCAD
AutocadOutput(eulerpath,pos,"C:\\Users\\harsh\\Desktop\\tetratrussAC")

%% Output path for DI Wire Pro
% MachineInstructions(heuristicpath,pos,"C:\Users\harsh\Desktop\tetratruss.txt")
