clc
clearvars
addpath("C:\Users\harsh\Documents\GitHub\Bend-Forming\Fabrication Algorithms")
addpath("C:\Users\harsh\Documents\GitHub\Bend-Forming\Exemplar Structures\CurvedGridshell\WithoutAngularDefects")
addpath("C:\Users\harsh\Documents\GitHub\Bend-Forming\Mesh Tools\distmesh")

%% Paraboloid dish
D = 350; % Diameter
FDratio = 0.3; % FD ratio
F = D * FDratio; % Focal length
H = D^2/(16*F); % Height of paraboloid
L = D/8; % Estimated triangle edge length

% 2D circular mesh transformed into a paraboloid
% fd=@(p) sqrt(sum(p.^2,2))-D/2;
fd=@(p) dcircle(p,0,0,D/2);
[coords,faces]=distmesh2d(fd,@huniform,L,[-D/2,-D/2;D/2,D/2],[]);
close all
pos2d = coords;
pos2d(:,3) = 0;
pos = coords;
pos(:,3) = zeros(size(pos,1),1);
% pos(:,3) = pos(:,1).^2/(4*F) + pos(:,2).^2/(4*F); % comment this line for flat dish instead of curved dish

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

%% Plot graph
% plotgraph(g,pos,1,1,[0,90])

%% CPP algorithm on dish
tic;
[geuler,dupedges,edgesadded,lengthadded,eulerpath] = CPP_Algorithm(g,pos);
time = toc;

%% Plot bend path
% Plot solution to CPP algorithm
% plotbendpath(geuler,eulerpath,pos,0.2,1,10,"C:\Users\harsh\Desktop\FabTesting\Dish\dishcurvedbendpathvideo_top_fast.avi",[0,90])
% plotbendpath(geuler,eulerpath,pos,0.2,1,10,"C:\Users\harsh\Desktop\FabTesting\Dish\dishcurvedbendpathvideo_side_fast.avi",[-90,20])
% plotbendpath(geuler,eulerpath,pos,0.05)
plotbendpatharrows(geuler,eulerpath,pos,4,15,[0 90])
plotblacksvg(eulerpath,pos,4,[0 90])

%% Output to DI wire 
% MachineInstructions(eulerpath,pos,"C:\Users\harsh\Desktop\FabTesting\Dish\dishcurved.txt",1,1)

%% Output to SW
% SolidworksOutput(eulerpath,pos,"C:\Users\harsh\Desktop\FabTesting\Dish\dishSWsketch.txt")
