clearvars
close all
addpath("C:\Users\harsh\Documents\GitHub\Bend-Forming\Fabrication Algorithms")
addpath("C:\Users\harsh\Documents\GitHub\Bend-Forming\Exemplary Structures\TrussHoop")

%% Isogrid hoop
router = 500; % 185 % outer radius in mm (of torus)
rinner = 50; % 35 % inner radius in mm (of column cross section)
nouter = 12; % number of polygonal sides in torus, set to 1 for normal hoop with SIDENUM = number of bays around circumference
ninner = 5; % number of polygonal sides in column cross setion
sidenum = 1; % sidelengths along circumference
[g,pos] = polyisogridtorusgraph3D(rinner,router,ninner,nouter,sidenum);
avgbaysidelength(pos,ninner);
plotgraph(g,pos);

%% Truss hoop (alternating diagonals)
% % Lab scale 30 cm diameter hoop
% rinner = 35; % inner radius in mm (of column cross section)
% router = 150+rinner; % outer radius in mm (of torus)
% nouter = 6; % number of polygonal sides in torus, set to 1 for normal hoop with SIDENUM = number of bays around circumference
% ninner = 6; % number of polygonal sides in column cross setion
% sidenum = 2; % sidelengths along circumference

% % 1.05 m diameter hoop
rinner = 35; % inner radius in mm (of column cross section)
router = 525+rinner; % outer radius in mm (of torus) % first value is distance from inner vertex-to-vertex
nouter = 24; % number of polygonal sides in torus, set to 1 for normal hoop with SIDENUM = number of bays around circumference
ninner = 3; % number of polygonal sides in column cross setion
sidenum = 2; % sidelengths along circumference

[g,pos] = polyaltdiagtrusstorusgraph3D(rinner,router,ninner,nouter,sidenum);
avgbaysidelength(pos,ninner);
plotgraph(g,pos);

%% Heuristic path
heuristicpath = heuristicpathtrusshoop(ninner,nouter,sidenum);

% Calculate mass of wire from bend path
densitywire = 7800; % kg/m3
diameterwire = 0.9; % mm
lengthmasswire(heuristicpath,pos,densitywire,diameterwire);

%% Random Euler path from CPP algorithm
% Calculate and plot random Euler path
tic;
[geuler,dupedges,edgesadded,lengthadded,eulerpath] = CPP_Algorithm(g,pos);
time = toc;

if dupedges > 0
    figure()
    plot(g, 'XData', pos(:,1), 'YData', pos(:,2), 'ZData', pos(:,3))
    axis equal
    title('Truss graph')
    figure()
    plot(geuler, 'XData', pos(:,1), 'YData', pos(:,2), 'ZData', pos(:,3))
    axis equal
    title("Truss graph with " + dupedges + " duplicate edges")
end

%% Plot bend path
savevideo=0;
framerate=10;
filename='C:\Users\harsh\Desktop\test.avi';
vidangle=[30,0];
plotbendpath(geuler,eulerpath,pos,0.25,savevideo,framerate,filename,vidangle);
% plotbendpath(g,heuristicpath,pos,0.5)

% plotgreenarrows(g,heuristicpath,pos,4,10,[0,90])
% plotblacksvg(heuristicpath,pos,4,[0 15])

%% Output heuristic path for Solidworks
% SolidworksOutput(heuristicpath,pos,"C:\Users\harsh\Desktop\demohoopSW.txt")

%% Output heuristic path for AutoCAD
% AutocadOutput(heuristicpath,pos,"C:\Users\harsh\Desktop\Mesh Reflector\Simulations\HoopParametricStudyFeb2022\GeometryCoords\Nbayfreq5")

%% Output heuristic path for DI Wire Pro
% MachineInstructions(heuristicpath,pos,"C:\Users\harsh\Desktop\trusshooptest.txt")
