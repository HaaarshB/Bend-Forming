function pointmassstruct = CalculateStructureCMMOIvsTime(nodestruct,pointdensity,rhostrut,doutstrut,tstrut)
% Function for calculating the CM coordinates and MOI matrix of the structure during fabrication
% by discretizing each strut into N points of equally distributed mass
% Inputs:
%   struct of nodal coordinates at each time step (nodestruct)
%   point density (pointdensity) [# points/mm]
%   material density (rhostrut) [kg/m^3]
%   strut outer diameter (doutstrut) assuming a tube cross section [mm]
%   strut thickness (tstrut) [mm]
% Outputs (as a function of time):
%   struct (pointmassstruct) with discretized node coordinates (field: points),
%   equally distributed mass of each node (field: mass), 
%   center of mass coordinates (field: CM),
%   mass moment of inertia matrix calculated in CM frame (field: MOI_CM)

pointmassstruct = struct;
for i=1:size(nodestruct,2)
    pointmassstruct(i).time = nodestruct(i).time;
    pointcoordsarray = [];
    strutlengtharray = [];
    coords = nodestruct(i).coords;
    for j=1:(size(coords,1)-1)
        firstnode = coords(j,:);
        secondnode = coords(j+1,:);
        strutlength = norm(secondnode - firstnode);
        strutlengtharray(end+1,1) = strutlength;
        numpoints = ceil(strutlength*pointdensity); % number of point masses to split each strut
        xpoints = linspace(firstnode(1),secondnode(1),numpoints)';
        ypoints = linspace(firstnode(2),secondnode(2),numpoints)';
        zpoints = linspace(firstnode(3),secondnode(3),numpoints)';
        if j~=(size(coords,1)-1)
            pointcoordsarray((end+1):(end+numpoints-1),1:3) = [xpoints(1:(end-1)),ypoints(1:(end-1)),zpoints(1:(end-1))];    
        else
            pointcoordsarray((end+1):(end+numpoints),1:3) = [xpoints(1:end),ypoints(1:end),zpoints(1:end)];
        end
    end
    
    if i==1
        pointcoordsarray = [0,0,0];
    end

    % COORDINATES OF EACH POINT MASS AT EACH TIME STEP
    pointmassstruct(i).pointcoords = pointcoordsarray;

    % MASS OF EACH DISCRETIZED POINT ALONG THE STRUTS
    totalmass = rhostrut * pi/4*((doutstrut/1000)^2-((doutstrut-2*tstrut)/1000)^2) * sum(strutlengtharray)/1000; % [kg] % strutlengtharray, doutstrut, and tstrut are [mm]
    pointmass = totalmass/size(pointcoordsarray,1) * ones(size(pointcoordsarray,1),1); % equally distributed mass of each point [kg]
    pointmassstruct(i).pointmass = pointmass;
    pointmassstruct(i).totalmass = totalmass;

    % CENTER OF MASS OF DISCRETIZED POINTS AT EACH TIME STEP
    if ~isempty(pointcoordsarray)
        CM = [mean(pointcoordsarray(:,1)),mean(pointcoordsarray(:,2)),mean(pointcoordsarray(:,3))]; % just the average coordinate because all points have equal mass % [mm]
    else
        CM = zeros(1,3);
    end
    pointmassstruct(i).CM = CM; % https://en.wikipedia.org/wiki/Center_of_mass

    % MASS MOMENT OF INERTIA MATRIX AT EACH TIME STEP (ABOUT THE BODY CM CALCULATED ABOVE) [kg*mm^2]
    MOI_CM = zeros(3); % Calculated for a rigid system of particles as in: https://en.wikipedia.org/wiki/Parallel_axis_theorem
    for k=1:size(pointcoordsarray,1)
        MOI_CM = MOI_CM + pointmass(k,1)*skewmatrix((pointcoordsarray(k,1:3)-CM)')*skewmatrix((pointcoordsarray(k,1:3)-CM)'); % NOTE: unit is in [kg*mm^2] NOT [kg*m^2]
        % To switch to [kg*m^2] multiply 1/1000 to each skew matrix
        % ALSO NOTE THIS IS ABOUT THE CHANGING CM OF EACH INTERMEDIATE STRUCTURE
    end
    MOI_CM = -MOI_CM; % negative sign
    pointmassstruct(i).MOI_CM = MOI_CM;

end

end