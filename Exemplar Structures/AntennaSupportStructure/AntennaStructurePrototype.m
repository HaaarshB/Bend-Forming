clc
clearvars
addpath("C:\Users\harsh\Documents\GitHub\Bend-Forming\Fabrication Algorithms")
addpath("C:\Users\harsh\Documents\GitHub\Bend-Forming\Exemplar Structures\TrussHoop")
addpath("C:\Users\harsh\Documents\GitHub\Bend-Forming\Mesh Tools\distmesh")
addpath("C:\Users\harsh\Desktop\Mesh Reflector\JulyPrototype")

%% Paraboloid dish
% % QUARTER SIZE
% D = 250;
% L = pi*D/15;

% FULL SIZE
D = 1040; % Diameter
L = pi*D/25.5; % Estimated side length

posstruct = struct;
gstruct = struct;
Nrings = 1;
ringoffset = 5; % radial offset between ring electrodes in [mm]

% 2D circular mesh transformed into a paraboloid
fd=@(p) dcircle(p,0,0,D/2);
[coords,faces]=distmesh2d(fd,@huniform,L,[-D/2,-D/2;D/2,D/2],[]);
close all
pos2d = coords;
pos2d(:,3) = 0;
poscommand = coords;

FDratio = 1; % FD ratio
F = D * FDratio; % Focal length
H = D^2/(16*F); % Height of paraboloid
% pos(:,3) = pos(:,1).^2/(4*F) + pos(:,2).^2/(4*F);
poscommand(:,3) = zeros(size(poscommand,1),1);

% Transform patched surface into a graph
stcommand = zeros(2,3*size(faces,1));
for i=1:(3*size(faces,1))
    row = ceil(i/3);
    if mod(i,3)==1
        stcommand(:,i) = [faces(row,1); faces(row,2)];
    elseif mod(i,3)==2
        stcommand(:,i) = [faces(row,2); faces(row,3)];
    elseif mod(i,3)==0
        stcommand(:,i) = [faces(row,3); faces(row,1)];
    end
end
stcommand = sort(stcommand)';
stcommand = unique(stcommand,'rows');
gcommand = graph(stcommand(:,1),stcommand(:,2));

%% Hoop
% % QUARTER SIZE
% Rinner = 70*2/3; % inner radius in mm (of column cross section)
% Router = D/2 + Rinner*sqrt(3)/2; % outer radius in mm (of torus) % first value is inner radius of hoop
% Nouter = 8; % number of polygonal sides in torus, set to 1 for normal hoop with SIDENUM = number of bays around circumference
% Ninner = 3; % number of polygonal sides in column cross setion
% Nbay = 1; % sidelengths along circumference

% FULL SIZE
Rinner = 70*2/3; % inner radius in mm (of column cross section)
Router = D/2 + Rinner*sqrt(3)/2; % outer radius in mm (of torus) % first value is inner radius of hoop
Nouter = 24; % number of polygonal sides in torus, set to 1 for normal hoop with SIDENUM = number of bays around circumference
Ninner = 3; % number of polygonal sides in column cross setion
Nbay = 1; % sidelengths along circumference

% [ghoop,poshoop,shoop,thoop] = polyaltdiagtrusstorusFLATgraph3D(Rinner,Router,Ninner,Nouter,Nbay);
[ghoop,poshoop,shoop,thoop] = newhoopcrosssection(Rinner,Router,Ninner,Nouter,Nbay);
avgbaysidelength(poshoop,Ninner);

% Move hoop up to match max z-coordinate of dish
zoffset = Rinner/2;
poshoop(:,3) = poshoop(:,3) + zoffset*ones(size(poshoop,1),1);

%% Delete edges on outer circumference of command surface
edgermnum = 0;
nodenorms = vecnorm(poscommand,2,2);
outeredgenodes = [];
for i=1:length(nodenorms)
    if abs(nodenorms(i)-D/2) < 1e-3
        outeredgenodes = [outeredgenodes; i];
    end
end
for i=1:length(outeredgenodes)
    outernode = outeredgenodes(i);
    outernodeneighbors = neighbors(gcommand,outernode);
    for j=1:length(outernodeneighbors)
        neighbornode = outernodeneighbors(j);
        if sum(ismember(outeredgenodes,neighbornode))==1
            gcommand = rmedge(gcommand,outernode,neighbornode);
            edgermnum = edgermnum + 1;
        end
    end
end
fprintf('%d outer edges removed\n',edgermnum);

%% Bend path for hoop and command surface
bendpathhoop = heuristicpathtrusshoop(Ninner,Nouter,Nbay);
[gcommandeuler,dupedges,edgesadded,lengthadded,bendpathcommand] = CPP_Algorithm(gcommand,poscommand);

%% Rotate command surface so that start node matches end node of hoop path
hoopendnode = bendpathhoop(end);
commandstartnode = bendpathcommand(1);
rotangle = anglebtw(poshoop(hoopendnode,:),poscommand(commandstartnode,:));
RzCCW = [cos(rotangle) -sin(rotangle) 0; sin(rotangle) cos(rotangle) 0; 0 0 1];
RzCW = [cos(rotangle) -sin(rotangle) 0; sin(rotangle) cos(rotangle) 0; 0 0 1]';
rotCCWnode = (RzCCW*poscommand(commandstartnode,:)')';
rotCWnode = (RzCW*poscommand(commandstartnode,:)')';
if abs(poshoop(hoopendnode,:)-rotCCWnode) < 1e-3
%     disp('CCW')
    rotmatrix = RzCCW; % rotation matrix to use
else
%     disp('CW')
    rotmatrix = RzCW; % rotation matrix to use
end

for i=1:size(poscommand,1)
    poscommand(i,:)=(rotmatrix*poscommand(i,:)')';
end

%% Match circumference nodes of command surface to closest hoop nodes in inner circumference

% commandnodestomatch = [];
% varyingouternodes = outeredgenodes;
% k = 1;
% for i=1:length(outeredgenodes)
%     outernode = outeredgenodes(i);
%     if ismember(outernode,edgesadded)
%         commandnodestomatch(k,1) = outernode;
%         varyingouternodes(i) = 0;
%         k=k+1;
%     end
% end
% commandnodestomatch = [commandnodestomatch; nonzeros(varyingouternodes)]; % reorder command nodes to match so that nodes with doubled edges get matched first
% matchednodes = [0,0];
% for i=1:length(commandnodestomatch)
%     outernode = commandnodestomatch(i);
%     [~,distvec] = dsearchn(poscommand(outernode,:),poshoopinner);
%     [~,nearestnode] = min(distvec);
%     nearestnodeinhoop = nearestnode*ninner;
%     if ismember(nearestnodeinhoop,matchednodes(:,2))
%         [~,commandnodeindx] = ismember(nearestnodeinhoop,matchednodes(:,2));
%         commandnodeadded = matchednodes(commandnodeindx,1);
%         if ismember(outernode,edgesadded) || ismember(commandnodeadded,edgesadded) % pick second closest neighbor if risk of making a tripled strut
%             distvec(nearestnode) = max(distvec);
%             [~,nearestnode] = min(distvec);
%             nearestnodeinhoop = nearestnode*ninner;
%             poscommand(outernode,:) = poshoop(nearestnodeinhoop,:);
%             matchednodes = [matchednodes; outernode,nearestnodeinhoop];
%         else
%             poscommand(outernode,:) = poshoop(nearestnodeinhoop,:);
%             matchednodes = [matchednodes; outernode,nearestnodeinhoop];
%         end
%     else
%         poscommand(outernode,:) = poshoop(nearestnodeinhoop,:);
%         matchednodes = [matchednodes; outernode,nearestnodeinhoop];
%     end
% end
% matchednodes(1,:) = [];

poshoopinner = poshoop((Ninner:Ninner:Ninner*Nouter*Nbay)',:); % only match to nodes in inner circumference of hoop
matchednodes = [0,0];
for i=1:length(outeredgenodes)
    outernode = outeredgenodes(i);
    [~,distvec] = dsearchn(poscommand(outernode,:),poshoopinner);
    [~,nearestnode] = min(distvec);
    nearestnodeinhoop = nearestnode*Ninner;
    poscommand(outernode,:) = poshoop(nearestnodeinhoop,:);
    matchednodes = [matchednodes; outernode,nearestnodeinhoop];
end
matchednodes(1,:) = [];

%% Plot
nodelabelhoop = {}; % 1:numnodes(ghoop)
nodelabelcommand = {}; % 1:numnodes(gcommandeuler)
figure()
plot(gcommandeuler,'XData',poscommand(:,1),'YData',poscommand(:,2),'ZData',poscommand(:,3),'LineWidth',1.5,'NodeLabel',nodelabelcommand,'MarkerSize',3);
hold on
plot(ghoop, 'XData',poshoop(:,1),'YData',poshoop(:,2),'ZData',poshoop(:,3),'LineWidth',1.5,'NodeLabel',nodelabelhoop,'MarkerSize',3);
axis equal
% axis off
set(gcf,'color','w');
xlabel('x')
ylabel('y')
zlabel('z')
view([0 90])
title('MIT Mesh Reflector Geometry')

%% Plot back-to-back bend paths
gstruct = struct;
pathstruct = struct;
posstruct = struct;
gstruct(1).g = ghoop;
gstruct(2).g = gcommandeuler;
pathstruct(1).path = bendpathhoop;
pathstruct(2).path = bendpathcommand;
posstruct(1).pos = poshoop;
posstruct(2).pos = poscommand;

savevideo=0;
framerate=10;
filename='C:\Users\harsh\Desktop\FinalGeometryPath.avi';
vidangle=[-45,45];
plotmultibendpath(gstruct,pathstruct,posstruct,[0.01,0.05],savevideo,framerate,filename,vidangle)

%% Plot green arrows
plotgreenarrows(ghoop,bendpathhoop,poshoop,3,15,[-58.8,40.6])
plotgreenarrows(gcommandeuler,bendpathcommand,poscommand,3,15,[-58.8,40.6])

%% Calculate mass of full structure
% lengthmasswire(pathstruct(1).path,posstruct(1).pos,7800,0.9)
% lengthmasswire(pathstruct(2).path,posstruct(2).pos,7800,0.9)

%% Output machine instructions for DI wire 
% MachineInstructions(pathstruct(1).path,posstruct(1).pos,"C:\Users\harsh\Desktop\hoopinstructionstest.txt",1,0)
% MachineInstructions(pathstruct(2).path,posstruct(2).pos,"C:\Users\harsh\Desktop\commandinstructionstest.txt",1,0)
% MultiMachineInstructions(pathstruct,posstruct,"C:\Users\harsh\Desktop\LargeAntennaInstructions.txt",1,0)

%% Output to SW
% SolidworksOutput(pathstruct(1).path,posstruct(1).pos,"C:\Users\harsh\Desktop\hoopSWsketch.txt")
% SolidworksOuput(pathstruct(2).path,posstruct(2).pos,"C:\Users\harsh\Desktop\commandSWsketch.txt")

%% Output command surface as IGES for Abaqus
% AutocadOutput(bendpathcommand,poscommand,"C:\\Users\\harsh\\Desktop\\trusscommandIGES");
% system('python "C:\Users\harsh\Desktop\Mesh Reflector\20220417_FinalGeometry\CommandFEM\Matlab_to_IGES\Matlab_to_IGES.py"');