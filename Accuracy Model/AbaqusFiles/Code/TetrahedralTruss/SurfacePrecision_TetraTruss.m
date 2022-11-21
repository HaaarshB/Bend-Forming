function [RMStop, RMSbottom] = SurfacePrecision_TetraTruss(topnodesfile,bottomnodesfile)
% Calculate RMS surface error for two faces of tetrahedral truss after closing defects

topfileID = fopen(topnodesfile,'r');
bottomfileID = fopen(bottomnodesfile,'r');
topnodes = (fscanf(topfileID,'%f %f %f\n', [3 Inf]))'; % Top node deformed coordinates: (x,y,z)
bottomnodes = (fscanf(bottomfileID,'%f %f %f\n', [3 Inf]))'; % Bottom node ""
fclose('all');

% Calculate surface fits from deformed coordinates
topplanefit = fit([topnodes(:,1),topnodes(:,2)],topnodes(:,3),'poly11');
bottomplanefit = fit([bottomnodes(:,1),bottomnodes(:,2)],bottomnodes(:,3),'poly11');
% Best fit plane coefficients for Ax + By + Cz = D
topplaneA = topplanefit.p10;
topplaneB = topplanefit.p01;
topplaneC = -1;
topplaneD = -topplanefit.p00;
% Best fit plane coefficients for Ax + By + Cz = D
bottomplaneA = bottomplanefit.p10;
bottomplaneB = bottomplanefit.p01;
bottomplaneC = -1;
bottomplaneD = -bottomplanefit.p00;

% Plot plane fits for visual confirmation
% figure()
% plot(topplanefit,[topnodes(:,1),topnodes(:,2)],topnodes(:,3))
% axis equal
% figure()
% plot(bottomplanefit,[bottomnodes(:,1),bottomnodes(:,2)],bottomnodes(:,3))
% axis equal

% Initialize vectors for storing error between fit and data points
toperror = zeros(size(topnodes,1),1);
bottomerror = zeros(size(bottomnodes,1),1);

% Calculate errors between surface fit and data points on both faces
for i=1:size(topnodes,1)
    topnodex = topnodes(i,1);
    topnodey = topnodes(i,2);
    topnodez = topnodes(i,3);
    % Error calculated as shortest distance from topnode to plane given by coefficients A,B,C,D, i.e. along normal vector of the plane
    % Follows this Khan academy video: https://www.khanacademy.org/math/linear-algebra/vectors-and-spaces/dot-cross-products/v/point-distance-to-plane
    toperror(i,1) = abs((topplaneA*topnodex+topplaneB*topnodey+topplaneC*topnodez-topplaneD)/sqrt(topplaneA^2+topplaneB^2+topplaneC^2));
end
for i=1:size(bottomnodes,1)
    bottomnodex = bottomnodes(i,1);
    bottomnodey = bottomnodes(i,2);
    bottomnodez = bottomnodes(i,3);
    % Error calculated as shortest distance from bottomnode to plane given by coefficients A,B,C,D, i.e. along normal vector of the plane
    bottomerror(i,1) = abs((bottomplaneA*bottomnodex+bottomplaneB*bottomnodey+bottomplaneC*bottomnodez-bottomplaneD)/sqrt(bottomplaneA^2+bottomplaneB^2+bottomplaneC^2));
end

% Calculate rms surface error for both top and bottom faces
RMStop = rms(toperror)*1e3; % in [mm]
RMSbottom = rms(bottomerror)*1e3; % in [mm]
