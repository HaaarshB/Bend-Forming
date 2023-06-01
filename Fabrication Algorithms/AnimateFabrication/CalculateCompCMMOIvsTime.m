function compCMMOIstruct = CalculateCompCMMOIvsTime(pointmassstruct,spacecraftstruct,feedstockspoolstruct)
%% Function for calculating composite center of mass (CM) and inertia matrix (MOI) from geometry and CM/MOI of individual components
% Inputs:
% Structs for wire structure, spacecraft body, and feedstock spool at each fabrication step
% Outputs:
% One struct for total mass (constant), CM, MOI_CM, and plotting info for wire structure, spacecraft body, and feedstock spool
% (can then be input into AnimateFab_CompCM_MOI to plot fabrication)

compCMMOIstruct = struct; % initialize composite struct

%% COMPOSITE CENTER OF MASS OF ALL BODIES
compCMMOIstruct(1).time = feedstockspoolstruct(1).time;
compCMMOIstruct(1).totalmass = spacecraftstruct.mass + feedstockspoolstruct(1).mass; % mass of spacecraft body + mass of feedstock spool
compCMMOIstruct(1).compCM = (spacecraftstruct.mass*spacecraftstruct.CM + feedstockspoolstruct(1).mass*feedstockspoolstruct(1).CM) / compCMMOIstruct(1).totalmass; % center of mass equation

for i=2:size(pointmassstruct,2)
    % Spacecraft body mass and CM stays the same
    % Feedstock spool mass changes but CM stays the same
    % Wire mass changes and CM changes too
    compCMMOIstruct(i).time = feedstockspoolstruct(i).time;
    compCMMOIstruct(i).totalmass = spacecraftstruct.mass + feedstockspoolstruct(i).mass + pointmassstruct(i).totalmass; % mass of spacecraft body + mass of feedstock spool
    compCM = (spacecraftstruct.mass*spacecraftstruct.CM + feedstockspoolstruct(i).mass*feedstockspoolstruct(1).CM + sum(pointmassstruct(i).pointmass.*pointmassstruct(i).pointcoords)) / compCMMOIstruct(i).totalmass;
    compCMMOIstruct(i).compCM = compCM;
end

%% INERTIA MATRIX OF ALL BODIES - ABOUT THE COMPOSITE CM AND ABOUT BODY FRAME ORIGIN (I.E. BEND HEAD)
% Using parallel axes theorem with matrices: https://en.wikipedia.org/wiki/Parallel_axis_theorem
% compMOI about compCM = MOI about bodyCM - body's total mass * [vector from compCM to bodyCM]^2 
% Square brackets mean the skew symmetric matrix

MOI_compCM_spacecraftbody = spacecraftstruct.MOI_CM - spacecraftstruct.mass * skewmatrix(spacecraftstruct.CM - compCMMOIstruct(1).compCM) * skewmatrix(spacecraftstruct.CM - compCMMOIstruct(1).compCM);
MOI_compCM_feedstockspool = feedstockspoolstruct(1).MOI_CM - feedstockspoolstruct(1).mass * skewmatrix(feedstockspoolstruct(1).CM - compCMMOIstruct(1).compCM) * skewmatrix(feedstockspoolstruct(1).CM - compCMMOIstruct(1).compCM);
MOI_compCM = MOI_compCM_spacecraftbody + MOI_compCM_feedstockspool;
compCMMOIstruct(1).MOI_compCM = MOI_compCM;
compCMMOIstruct(1).MOI = MOI_compCM - compCMMOIstruct(1).totalmass*skewmatrix(compCMMOIstruct(1).compCM)*skewmatrix(compCMMOIstruct(1).compCM);

for i=2:size(pointmassstruct,2)
    % MOI about composite CM has three components: MOI of spacecraft body, feedstock spool, and wire structure
    % These components are calculated by translating their MOIs about their CMs to the composite CM using the parallel axis theorem (once for each component at each fabrication step)
    MOI_compCM_spacecraftbody = spacecraftstruct.MOI_CM - spacecraftstruct.mass * skewmatrix(spacecraftstruct.CM - compCMMOIstruct(i).compCM) * skewmatrix(spacecraftstruct.CM - compCMMOIstruct(i).compCM);
    MOI_compCM_feedstockspool = feedstockspoolstruct(i).MOI_CM - feedstockspoolstruct(i).mass * skewmatrix(feedstockspoolstruct(1).CM - compCMMOIstruct(i).compCM) * skewmatrix(feedstockspoolstruct(1).CM - compCMMOIstruct(i).compCM);
    MOI_compCM_wirestructure = pointmassstruct(i).MOI_CM - pointmassstruct(i).totalmass * skewmatrix(pointmassstruct(i).CM - compCMMOIstruct(i).compCM) * skewmatrix(pointmassstruct(i).CM - compCMMOIstruct(i).compCM);
    MOI_compCM = MOI_compCM_spacecraftbody + MOI_compCM_feedstockspool + MOI_compCM_wirestructure;
    compCMMOIstruct(i).MOI_compCM = MOI_compCM; % about composite CM
    compCMMOIstruct(i).MOI = MOI_compCM - compCMMOIstruct(i).totalmass*skewmatrix(compCMMOIstruct(i).compCM)*skewmatrix(compCMMOIstruct(i).compCM); % about body frame origin
end
