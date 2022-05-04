function [g,pos] = parabolictetrahedraltrussgraph3D(FDratio,diameter,depth)

% From tetrahedral truss geometry (see Lake 2002 paper)
sidelength = sqrt(3/2)*depth;
nrings = ceil((diameter-sidelength)/(2*sidelength));

syms k
numnodes = double(symsum(3*(2*k+1),k,0,nrings));
postop = zeros(numnodes, 3);

%% Coordinates (top layer)
% Inner triangle coordinates
h = sidelength*sqrt(3)/2; % height above xy-plane
rin = sidelength/sqrt(3);
thetain = [pi/2, pi/2+2*pi/3, pi/2+4*pi/3];
postop(1:3,:) = [rin*cos(thetain'),rin*sin(thetain'),h*ones(size(thetain,2),1)];
% Ring coordinates
for ring=1:nrings
    startindx = double(symsum(3*(2*k+1),k,0,ring-1)) + 1;
    rout = sidelength*sqrt((ring+1/2)^2 + 1/12);
    thetaoffset = atan2(sqrt(3)*(2*ring+1),1) - pi/3;
    thetaout = [thetain(1)-thetaoffset, thetain(1)+thetaoffset, thetain(2)-thetaoffset, thetain(2)+thetaoffset, thetain(3)-thetaoffset, thetain(3)+thetaoffset];
    circlepoints = [rout*cos(thetaout'),rout*sin(thetaout'),h*ones(size(thetaout,2),1)];
    currentnode = startindx;
    for side=1:6
        postop(currentnode,:) = circlepoints(side,:);
        currentnode = currentnode+1;
        if mod(side,2)==1 && ring~=1
            middlepos = middlepoints(circlepoints(side,:),circlepoints(side+1,:),ring-1);
            postop(currentnode:currentnode+size(middlepos,1)-1,:) = middlepos;
            currentnode = currentnode+size(middlepos,1);
        elseif mod(side,2)==0
            if side~=6
                middlepos = middlepoints(circlepoints(side,:),circlepoints(side+1,:),ring);
            else
                middlepos = middlepoints(circlepoints(side,:),circlepoints(1,:),ring);
            end
            postop(currentnode:currentnode+size(middlepos,1)-1,:) = middlepos;
            currentnode = currentnode+size(middlepos,1);
        end
    end
end

%% Coordinates (bottom layer)
% top layer rotated counterclockwise by 60 degrees
[posbottomx,posbottomy] = rotangle2D(postop(:,1),postop(:,2),pi/3);
posbottom = [posbottomx,posbottomy,0*ones(size(posbottomx,1),1)];

%% Make coordinates parabolic
% if nrings==0
%     rout = diameter/2;
% end

F = FDratio*diameter;

postopz = postop(:,1).^2/(4*F) + postop(:,2).^2/(4*F);
postop(:,3) = postop(:,3)+postopz;

posbottomz = posbottom(:,1).^2/(4*F) + posbottom(:,2).^2/(4*F);
posbottom(:,3) = posbottom(:,3)+posbottomz;

pos = [postop;posbottom];

%% Connections
connections = [0,0];
for i=1:size(pos,1) % connect all neighbors to form triangular grid
    neighbors = cell2mat(rangesearch(pos,pos(i,:),sidelength*1.1));
    neighbors(1) = [];
    for j=1:length(neighbors)
        neighbor = neighbors(j);
        if sum(ismember(connections,[i,neighbor],'rows'))==0 && sum(ismember(connections,[neighbor,i],'rows'))==0
            connections(end+1,:) = [i,neighbor];
        end
    end
end
connections(1,:)=[];
s = connections(:,1);
t = connections(:,2);
g = graph(s,t);
end