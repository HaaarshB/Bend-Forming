function [spacecraftstruct, feedstockspoolstruct] = SpacecraftBlocks(pointmassstruct,spacecraftparams,feedstocksspoolparams)
%% Function for including mass of spacecraft block and feedstock spool
% Input:
% pointmassstruct, spacecraftparams, feestockspoolparams
% Outputs:
% Structs for both spacecraft body and feedstock spool, with total mass [kg], coordinate of CM [mm], MOI_CM matrix [kg*mm^2], and plotting geometry [mm] for each fabrication frame.
% NOTE: size of the feedstock spool struct is one longer than pointmassstruct because it includes an intitial frame with no Bend-Formed structure.

% Spacecraft body modeled as a SOLID CUBE with specified sidelength [mm] and mass [kg]
% Feedstock spool modeled as a SOLID CYLINDER with specified diameter [mm], thickness [mm], and initial mass [kg]
% Note the mass of the feedstock spool decreases as wire is extruded to conserve mass.

%% SPACECRAFT BODY
bodyS = spacecraftparams.sidelength; % [mm]
bodyM = spacecraftparams.mass; % [kg]

% CENTER OF MASS OF SPACECRAFT BODY
bodyCM = [0,-bodyS/2,0]; % [mm]
bodyCM = bodyCM - [0,0,bodyS/2]; % move z-coordinate downward so fabrication plane is at top plane of the cube
% MOI SPACECRAFT BODY, MODELED AS A SOLID CUBE: https://en.wikipedia.org/wiki/List_of_moments_of_inertia
bodyMOI_CM = 1/6*bodyM*bodyS^2 * eye(3); % [kg*mm^2]

% Create solid cube as a 3D patch
bodyVERT = [bodyS/2,0,bodyS/2; -bodyS/2,0,bodyS/2; -bodyS/2,0,-bodyS/2; bodyS/2,0,-bodyS/2;...
    bodyS/2,-bodyS,bodyS/2; -bodyS/2,-bodyS,bodyS/2; -bodyS/2,-bodyS,-bodyS/2; bodyS/2,-bodyS,-bodyS/2];
bodyVERT(:,3) = bodyVERT(:,3) - bodyS/2 * ones(size(bodyVERT,1),1); % move z-coordinate downward so fabrication plane is at top plane of the cube
bodyFAC = [1,2,3,4; 1,2,6,5; 1,4,8,5; 2,3,7,6; 5,6,7,8; 3,4,8,7];

% Make spacecraft struct with CM, MOI_CM, total mass, plotting coords at each fabrication step
spacecraftstruct = struct;
spacecraftstruct(1).mass = bodyM;
spacecraftstruct(1).CM = bodyCM;
spacecraftstruct(1).MOI_CM = bodyMOI_CM;
spacecraftstruct(1).vert = bodyVERT;
spacecraftstruct(1).fac = bodyFAC;

% Plotting spacecraft body
% bodyPATCH = patch('Vertices',bodyVERT,'Faces',bodyFAC,'FaceVertexCData',hsv(6),'FaceColor','[0 0.4470 0.7410]');
% alpha(0.3)
% hold on
% scatter3(bodyCM(1),bodyCM(2),bodyCM(3),25,'r','filled')
% xlabel('x','FontSize',14)
% ylabel('y','FontSize',14)
% zlabel('z','FontSize',14)
% view([135 45])
% axis equal

%% FEEDSTOCK SPOOL

spoolM = feedstocksspoolparams.mass; % [kg]
spoolDIAM = feedstocksspoolparams.diameter; % [mm]
spoolTHICK = feedstocksspoolparams.thickness; % [mm]

% CENTER OF MASS OF FEEDSTOCK SPOOL
spoolCM = [0, -bodyS-spoolDIAM/2, -spoolDIAM/2];
% MOI OF FEEDSTOCK SPOOL, MODELED AS A SOLID CYLINDER: https://en.wikipedia.org/wiki/List_of_moments_of_inertia
spoolMOI_CM = @(cylmass) [1/2*cylmass*(spoolDIAM/2)^2,0,0; 0,1/12*cylmass*(3*(spoolDIAM/2)^2+spoolTHICK^2),0; 0,0,1/12*cylmass*(3*(spoolDIAM/2)^2+spoolTHICK^2)]; % [kg*mm^2]
% NOTE: MOI changes at each fabrication step since mass of spool decreases.
% After rotation of the spool, Ixx is the largest value. These axes are same as Bend-Forming paper, with +y along feed axis and +z upwards from the fabrication plane.

% Create solid cylinder as two 3D patches and a surface
% https://www.mathworks.com/matlabcentral/answers/486172-how-can-i-plot-a-filled-cylinder-with-a-specific-height
% https://www.youtube.com/watch?v=_NAzGCYowkc
npoints = 100; % 100 points around circumference
circx=spoolDIAM/2*cos(linspace(0,2*pi,100))';
circy=spoolDIAM/2*sin(linspace(0,2*pi,100))';
spoolcircleTOP = [circx,circy+(-bodyS-spoolDIAM/2),spoolTHICK*ones(npoints,1)];
spoolcircleBOT = [circx,circy+(-bodyS-spoolDIAM/2),zeros(npoints,1)];
roty90 = [cos(deg2rad(90)),0,sin(deg2rad(90));0,1,0;-sin(deg2rad(90)),0,cos(deg2rad(90))]; % rotate points 90 deg around the +y-axis
spoolcircleTOP = (roty90*spoolcircleTOP')';
spoolcircleBOT = (roty90*spoolcircleBOT')';
spoolcircleTOP(:,1) = spoolcircleTOP(:,1) - spoolTHICK/2*ones(size(spoolcircleTOP,1),1);
spoolcircleTOP(:,3) = spoolcircleTOP(:,3) - spoolDIAM/2*ones(size(spoolcircleTOP,1),1);
spoolcircleBOT(:,1) = spoolcircleBOT(:,1) - spoolTHICK/2*ones(size(spoolcircleBOT,1),1);
spoolcircleBOT(:,3) = spoolcircleBOT(:,3) - spoolDIAM/2*ones(size(spoolcircleBOT,1),1);

% Make feedstock spool struct with CM, MOI_CM, total mass, plotting coords at each fabrication step
feedstockspoolstruct = struct;
feedstockspoolstruct(1).time = pointmassstruct(1).time;
feedstockspoolstruct(1).mass = spoolM; % initial mass of feedstock spool [kg]
feedstockspoolstruct(1).CM = spoolCM;
feedstockspoolstruct(1).MOI_CM = spoolMOI_CM(spoolM);
feedstockspoolstruct(1).spoolcircleTOP = spoolcircleTOP;
feedstockspoolstruct(1).spoolcircleBOT = spoolcircleBOT;
for i=2:size(pointmassstruct,2)
    feedstockspoolstruct(i).time = pointmassstruct(i).time;
    currentspoolM = spoolM - pointmassstruct(i).totalmass;
    feedstockspoolstruct(i).mass = currentspoolM; % changing mass of feedstock spool [kg]
    feedstockspoolstruct(i).MOI_CM = spoolMOI_CM(currentspoolM);
end

% Plotting feedstock spool
% figure()
% patch(spoolcircletop(:,1),spoolcircletop(:,2),spoolcircletop(:,3),[0 0.4470 0.7410]);
% patch(spoolcirclebottom(:,1),spoolcirclebottom(:,2),spoolcirclebottom(:,3),[0 0.4470 0.7410]);
% hold on
% surf([spoolcircletop(:,1),spoolcirclebottom(:,1)],[spoolcircletop(:,2),spoolcirclebottom(:,2)],[spoolcircletop(:,3),spoolcirclebottom(:,3)], 'FaceColor','[0 0.4470 0.7410]','EdgeColor','none')
% alpha(0.3)
% hold on
% scatter3(spoolCM(1),spoolCM(2),spoolCM(3),25,'r','filled')
% xlabel('x','FontSize',14)
% ylabel('y','FontSize',14)
% zlabel('z','FontSize',14)
% view([135 45])
% hold off
% axis('equal')

end