clearvars
close all
addpath("C:\Users\harsh\Documents\GitHub\Bend-Forming\Fabrication Algorithms")

%% Geometry and offsets
% Dish geometry
FDratio = 0.5;
D = 1000;
L = 120; % estimated triangle side length
Linner = 50; % inner hole diameter

% Offsets
delta1 = 0; % offset distance between ring points and outer ring covers % 0.005
delta2 = 0; % offset distance between ring points and constant beta edge % 0.005
delta3 = 0; % offset radius for center points % 0.01

% Angular defects for each ring
betarings = deg2rad([10,10,15,20,25]);

% Plots
p.oneslice = 0;
p.twoslice = 0;
p.pizza = 1;

%% Math for one slice
F = D*FDratio; % focal length
H = D^2/(16*F); % height of paraboloid
linearD = (D/2)*(sqrt((2*F)^2+(D/2)^2))/(2*F) + (2*F)*log(((D/2)+(sqrt((2*F)^2+(D/2)^2)))/(2*F)); % linear diameter of dish along its surface
ringnums = round((linearD/2-Linner)/(L)); % total number of rings (not including center hole)

ringangles = zeros(1,length(betarings)); % sweep angles for each ring
for i = 1:length(betarings)
    ringangles(i) = angle(betarings(1),betarings(i));
end

ring = struct;
ring1points = zeros(1,2);
zigzagpoints = zeros(1,2);
outerringpoints = zeros(1,2);
for ringnum=1:ringnums
   if ringnum==1 % points for inner hole and first ring
       thetaoffset1 = delta2/Linner;
       thetaoffset2 = delta2/(Linner+L);
       ring1points(1,:) = delta3*[cos(-ringangles(ringnum)/2), sin(-ringangles(ringnum)/2)];
       ring1points(2,:) = Linner*[cos(-ringangles(ringnum)/2), sin(-ringangles(ringnum)/2)];
       ring1points(3,:) = Linner*[cos(ringangles(ringnum)/2-thetaoffset1), sin(ringangles(ringnum)/2-thetaoffset1)];
       ring1points(4,:) = [Linner+L,0];
       ring1points(5,:) = (Linner+delta1)*[cos(-ringangles(ringnum)/2), sin(-ringangles(ringnum)/2)];
       ring1points(6,:) = (Linner+L+delta1)*[cos(-ringangles(ringnum)/2), sin(-ringangles(ringnum)/2)]; % outer ring 
       ring1points(7,:) = [Linner+L+delta1,0];
       ring1points(8,:) = (Linner+L+delta1)*[cos(ringangles(ringnum)/2-thetaoffset2), sin(ringangles(ringnum)/2-thetaoffset2)];
       ring(1).points = ring1points;
   elseif ringnum==ringnums
       thetaoffset = delta2/(Linner+ringnum*L);
       thetasplitbottom = (ringangles(ringnum)-thetaoffset)/ringnum;
       thetasplittop = (ringangles(ringnum)-thetaoffset)/(ringnum+1);
       ntop = 1;
       nbottom = 1;
       for i=1:(2*ringnum) % zig-zag points
           if mod(i,2)==1 % top points
               zigzagpoints(i,:) = (Linner+ringnum*L) * [cos(ringangles(1)/2-thetaoffset-ntop*thetasplittop), sin(ringangles(1)/2-thetaoffset-ntop*thetasplittop)];
               ntop = ntop+1;
           elseif mod(i,2)==0 % bottom points
               zigzagpoints(i,:) = (Linner+(ringnum-1)*L+2*delta1) * [cos(ringangles(1)/2-thetaoffset-nbottom*thetasplitbottom), sin(ringangles(1)/2-thetaoffset-nbottom*thetasplitbottom)];
               nbottom = nbottom+1;
           end
       end
       ntop = ntop-1;
       nbottom = nbottom-1;
       for i=1:(ringnum+2) % outer cover ring
           if i==1
               outerringpoints(i,:) = (Linner+ringnum*L+delta1) * [cos(ringangles(1)/2-thetaoffset-nbottom*thetasplitbottom), sin(ringangles(1)/2-thetaoffset-nbottom*thetasplitbottom)];
           elseif i==(ringnum+2)
               outerringpoints(i,:) = (Linner+ringnum*L+delta1) * [cos(ringangles(1)/2), sin(ringangles(1)/2)]; % end litter further out
               outerringpoints(i+1,:) = delta3*[cos(ringangles(ringnum)/2), sin(ringangles(ringnum)/2)]; % add final point near center
           else
               outerringpoints(i,:) = (Linner+ringnum*L+delta1) * [cos(ringangles(1)/2-thetaoffset-ntop*thetasplittop), sin(ringangles(1)/2-thetaoffset-ntop*thetasplittop)];
               ntop = ntop-1;
           end
       end
       ring(ringnum).points = [zigzagpoints; outerringpoints];
   else
       thetaoffset = delta2/(Linner+ringnum*L);
       thetasplitbottom = (ringangles(ringnum)-thetaoffset)/ringnum;
       thetasplittop = (ringangles(ringnum)-thetaoffset)/(ringnum+1);
       ntop = 1;
       nbottom = 1;
       for i=1:(2*ringnum) % zig-zag points
           if mod(i,2)==1 % top points
               zigzagpoints(i,:) = (Linner+ringnum*L) * [cos(ringangles(1)/2-thetaoffset-ntop*thetasplittop), sin(ringangles(1)/2-thetaoffset-ntop*thetasplittop)];
               ntop = ntop+1;
           elseif mod(i,2)==0 % bottom points
               zigzagpoints(i,:) = (Linner+(ringnum-1)*L+2*delta1) * [cos(ringangles(1)/2-thetaoffset-nbottom*thetasplitbottom), sin(ringangles(1)/2-thetaoffset-nbottom*thetasplitbottom)];
               nbottom = nbottom+1;
           end
       end
       ntop = ntop-1;
       nbottom = nbottom-1;
       for i=1:(ringnum+2) % outer cover ring
           if i==1
               outerringpoints(i,:) = (Linner+ringnum*L+delta1) * [cos(ringangles(1)/2-thetaoffset-nbottom*thetasplitbottom), sin(ringangles(1)/2-thetaoffset-nbottom*thetasplitbottom)];
           elseif i==(ringnum+2)
               outerringpoints(i,:) = (Linner+ringnum*L+delta1) * [cos(ringangles(1)/2-thetaoffset), sin(ringangles(1)/2-thetaoffset)];
           else
               outerringpoints(i,:) = (Linner+ringnum*L+delta1) * [cos(ringangles(1)/2-thetaoffset-ntop*thetasplittop), sin(ringangles(1)/2-thetaoffset-ntop*thetasplittop)];
               ntop = ntop-1;
           end
       end
       ring(ringnum).points = [zigzagpoints; outerringpoints];
   end
end

pointsone=[];
for i=1:size(ring,2)
    pointsone = [pointsone; ring(i).points];
end

if p.oneslice
    figure()
    plot(pointsone(:,1),pointsone(:,2),'k');
    xlim([-D/2*1.1 D/2*1.1])
    ylim([-D/2*1.1 D/2*1.1])
    set(gcf, 'Position',  [100, 100, 500, 475]) % Sets size of figure
%     set(gca,'XColor','none')
%     set(gca,'YColor','none')
    grid on
    hold off
end

%% Rotate and reflect slices to form full path
pointsonerot = rot(pointsone,-30);
pointsonerotref = [pointsonerot(:,1),-pointsonerot(:,2)];
pointstwo = [pointsonerotref(2:(end-1),:); [Linner,0]; flip(pointsonerot(2:(end-1),:))];

if p.twoslice
    figure()
    plot(pointstwo(:,1),pointstwo(:,2),'k');
    xlim([-D/2*1.1 D/2*1.1])
    ylim([-D/2*1.1 D/2*1.1])
    set(gcf, 'Position',  [100, 100, 500, 475]) % Sets size of figure
%     set(gca,'XColor','none')
%     set(gca,'YColor','none')
    grid on
    hold off
end

pointstworot1 = rot(pointstwo,120);
pointstworot2 = rot(pointstwo,240);
pointspizza = [pointstwo; pointstworot2; pointstworot1];

if p.pizza
    figure()
    plot(pointspizza(:,1),pointspizza(:,2),'k');
    xlim([-D/2*1.1 D/2*1.1])
    ylim([-D/2*1.1 D/2*1.1])
    set(gcf, 'Position',  [100, 100, 500, 475]) % Sets size of figure
    set(gca,'XColor','none')
    set(gca,'YColor','none')
%     grid on
    hold off
    axis equal
end

%% Make Matlab graph of the thing
pointspizza(:,3) = zeros(size(pointspizza,1),1);
st = [(1:(size(pointspizza,1)-1))',(2:size(pointspizza,1))'];
gpizza = graph(st(:,1),st(:,2));
pizzapath = 1:size(pointspizza,1);
% plotgraph(gpizza,pointspizza,1,0,[0 90])

plotbendpath(gpizza,pizzapath,pointspizza,0.1)
% plotbendpath(gpizza,pizzapath,pointspizza,0.1,1,10,'C:\Users\harsh\Desktop\angdefectdishtest.avi',[0 90])

lengthmasswire(pizzapath,pointspizza,7800,0.9)
plotbendpatharrows(gpizza,pizzapath,pointspizza,4,15,'black',[0,90])

% MachineInstructions(pizzapath,pointspizza,"C:\Users\harsh\Desktop\dish_prototype.txt")

%% Helper functions
function [anglering] = angle(beta1,beta2) % finds angle swept by each ring using angular defects
    anglering = pi/3 - beta1/2 - beta2/2;
end

function rotxy = rot(xy,theta) % counterclockwise rotation matrix
    rotmatrix = [cos(deg2rad(theta)) -sin(deg2rad(theta)); sin(deg2rad(theta)) cos(deg2rad(theta))];
    rotxy = rotmatrix*xy';
    rotxy = rotxy';
end