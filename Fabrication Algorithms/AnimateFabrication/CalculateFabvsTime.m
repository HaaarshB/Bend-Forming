function [nodestructshort,nodestructfull] = CalculateFabvsTime(bendpathfile,feedrate,bendrate,dt)
%% Function for simulating fabrication by calculating nodal coordinates at each fabrication step
% Inputs: 
%   list of fabrication steps (bendpathfile)
%   feeding rate (feedrate) [mm/s]
%   bending rate (bendrate) [deg/s]
%   time step (dt) - essentially the resoultion of the output [s]
% Outputs:
%   struct of nodal coordinates vs time (nodestruct) - larger size than bendpathfile based on the specified time step

% Translates and rotates nodes from bend head; similar to Pensa Labs Wire Terminal software
% Assumes perfect fabrication (unlike the Bend-Forming accuracy model here: https://www.mathworks.com/matlabcentral/fileexchange/123360-bend-forming-algorithms)
% Assumes the same fabrication rate for bending and rotating

% Calculate fend length and bend angle in one time step
feedstep = dt*feedrate; % [mm]
bendstep = dt*bendrate; % [deg]
rotatestep = bendstep; % [deg] % assumes same speed for bending and rotating

% Load bend path
fileID = fopen(bendpathfile,'r');
bendpathtxt = textscan(fileID,'%s','delimiter','\n');
bendpathtxt = bendpathtxt{1};
fclose('all');

% Calculate total number of nodes in geometry, i.e indices of all feed lines
feedlineindx = [];
for i=1:length(bendpathtxt)
    linetxt = bendpathtxt{i};
    if contains(linetxt,'FEED')
        feedlineindx(end+1,1) = i;
    end
end

% Initialize nodestruct with each row corresponding to each time step of the bend path and each field corresponding to the nodal coordinates
nodestructfull = struct;
nodestructfull(1).time = 0;
nodestructfull(1).coords = zeros(length(feedlineindx),3);
nodestructshort = nodestructfull;

% Model perfect fabrication - in increments specified by the fabrication rates
% MORE EFFICIENT BY LOOPING THROUGH BENDPATH FILE ONLY ONCE
nodecounter = 0;
lastindx = 1;
for i=1:length(bendpathtxt)
    linetxt = bendpathtxt{i};
    if contains(linetxt,'FEED')
        nodecounter = nodecounter + 1; % increase node counter after feed line since feed line means new node
        feedlength = regexp(linetxt,'\d+\.?\d*','match');
        feedlength = str2double(feedlength{1});
        if mod(feedlength,feedstep)~=0
            numfeedsteps = floor(feedlength/feedstep);
        else
            numfeedsteps = int16(feedlength/feedstep);
        end
        % Feed along +y axis - in increments specified by the feeding rate and time step
        for node = 1:nodecounter
            for step=1:numfeedsteps
                % APPLY TRANSFORMATION TO ALL NODES NOT AT ORIGIN
                coordsfield = nodestructfull(lastindx+step-1).coords;
                currentnode = coordsfield(node,:);
                currentnode(2) = currentnode(2) + feedstep;
                if node==1
                    coordsfieldupdate = coordsfield;
                    coordsfieldupdate(node,:) = currentnode;
                    nodestructfull(lastindx+step).time = nodestructfull(lastindx+step-1).time + dt;
                else
                    coordsfieldupdate = nodestructfull(lastindx+step).coords;
                    coordsfieldupdate(node,:) = currentnode;
                end
                nodestructfull(lastindx+step).coords = coordsfieldupdate;
            end
            if mod(feedlength,feedstep)~=0
                % ADD ONE MORE FINAL STEP TO FINISH THE FABRICATION STEP                
                coordsfield = nodestructfull(lastindx+numfeedsteps).coords;
                currentnode = coordsfield(node,:);
                extrafeedlength = feedlength - numfeedsteps*feedstep;
                currentnode(2) = currentnode(2) + extrafeedlength;
                if node==1
                    coordsfieldupdate = coordsfield;
                    coordsfieldupdate(node,:) = currentnode;
                    nodestructfull(lastindx+numfeedsteps+1).time = nodestructfull(lastindx+numfeedsteps).time + extrafeedlength/feedstep*dt;
                    nodestructfull(lastindx+numfeedsteps+1).coords = coordsfieldupdate;
                else
                    coordsfieldupdate = nodestructfull(lastindx+numfeedsteps+1).coords;
                    coordsfieldupdate(node,:) = currentnode;
                    nodestructfull(lastindx+numfeedsteps+1).coords = coordsfieldupdate;
                end
            end
        end
    elseif contains(linetxt,'BEND')
        bendtheta = regexp(linetxt,'(+|-)?\d+\.?\d*','match');
        bendtheta = str2double(bendtheta{1});
        if mod(abs(bendtheta),bendstep)~=0
            numbendsteps = floor(abs(bendtheta)/bendstep);
        else
            numbendsteps = int16(abs(bendtheta)/bendstep);
        end
        if bendtheta < 0
            % Rotation about +z axis if thetabend is negative - in increments specified by the bending rate and time step
            for node = 1:nodecounter
                for step=1:numbendsteps            
                    % APPLY TRANSFORMATION TO ALL NODES NOT AT ORIGIN
                    coordsfield = nodestructfull(lastindx+step-1).coords;
                    currentnode = coordsfield(node,:);
                    rotplusz = [cos(deg2rad(abs(bendstep))),-sin(deg2rad(abs(bendstep))),0;sin(deg2rad(abs(bendstep))),cos(deg2rad(abs(bendstep))),0;0,0,1]; % bend by bendstep [o] each time
                    currentnode = rotplusz*currentnode';
                    if node==1
                        coordsfieldupdate = coordsfield;
                        coordsfieldupdate(node,:) = currentnode;
                        nodestructfull(lastindx+step).time = nodestructfull(lastindx+step-1).time + dt;
                    else
                        coordsfieldupdate = nodestructfull(lastindx+step).coords;
                        coordsfieldupdate(node,:) = currentnode;
                    end
                    nodestructfull(lastindx+step).coords = coordsfieldupdate;
                end
                if mod(bendtheta,bendstep)~=0
                    % ADD ONE MORE FINAL STEP TO FINISH THE FABRICATION STEP                
                    coordsfield = nodestructfull(lastindx+numbendsteps).coords;
                    currentnode = coordsfield(node,:);
                    extrabendtheta = abs(bendtheta) - numbendsteps*bendstep;
                    rotplusz = [cos(deg2rad(abs(extrabendtheta))),-sin(deg2rad(abs(extrabendtheta))),0;sin(deg2rad(abs(extrabendtheta))),cos(deg2rad(abs(extrabendtheta))),0;0,0,1];
                    currentnode = rotplusz*currentnode';
                    if node==1
                        coordsfieldupdate = coordsfield;
                        coordsfieldupdate(node,:) = currentnode;
                        nodestructfull(lastindx+numbendsteps+1).time = nodestructfull(lastindx+numbendsteps).time + extrabendtheta/bendstep*dt;
                        nodestructfull(lastindx+numbendsteps+1).coords = coordsfieldupdate;
                    else
                        coordsfieldupdate = nodestructfull(lastindx+numbendsteps+1).coords;
                        coordsfieldupdate(node,:) = currentnode;
                        nodestructfull(lastindx+numbendsteps+1).coords = coordsfieldupdate;
                    end
                end
            end
        elseif bendtheta > 0
            % Rotation about -z axis if thetabend is positive - in increments specified by the bending rate and time step
            for node = 1:nodecounter
                for step=1:numbendsteps            
                    % APPLY TRANSFORMATION TO ALL NODES NOT AT ORIGIN
                    coordsfield = nodestructfull(lastindx+step-1).coords;
                    currentnode = coordsfield(node,:);
                    rotnegz = [cos(deg2rad(-bendstep)),-sin(deg2rad(-bendstep)),0;sin(deg2rad(-bendstep)),cos(deg2rad(-bendstep)),0;0,0,1]; % bend by bendstep [o] each time
                    currentnode = rotnegz*currentnode';
                    if node==1
                        coordsfieldupdate = coordsfield;
                        coordsfieldupdate(node,:) = currentnode;
                        nodestructfull(lastindx+step).time = nodestructfull(lastindx+step-1).time + dt;
                    else
                        coordsfieldupdate = nodestructfull(lastindx+step).coords;
                        coordsfieldupdate(node,:) = currentnode;
                    end
                    nodestructfull(lastindx+step).coords = coordsfieldupdate;
                end
                if mod(bendtheta,bendstep)~=0
                    % ADD ONE MORE FINAL STEP TO FINISH THE FABRICATION STEP                
                    coordsfield = nodestructfull(lastindx+numbendsteps).coords;
                    currentnode = coordsfield(node,:);
                    extrabendtheta = abs(bendtheta) - numbendsteps*bendstep;
                    rotnegz = [cos(deg2rad(-extrabendtheta)),-sin(deg2rad(-extrabendtheta)),0;sin(deg2rad(-extrabendtheta)),cos(deg2rad(-extrabendtheta)),0;0,0,1];
                    currentnode = rotnegz*currentnode';
                    if node==1
                        coordsfieldupdate = coordsfield;
                        coordsfieldupdate(node,:) = currentnode;
                        nodestructfull(lastindx+numbendsteps+1).time = nodestructfull(lastindx+numbendsteps).time + extrabendtheta/bendstep*dt;
                        nodestructfull(lastindx+numbendsteps+1).coords = coordsfieldupdate;
                    else
                        coordsfieldupdate = nodestructfull(lastindx+numbendsteps+1).coords;
                        coordsfieldupdate(node,:) = currentnode;
                        nodestructfull(lastindx+numbendsteps+1).coords = coordsfieldupdate;
                    end
                end
            end    
        end
    elseif contains(linetxt,'Rotate') % Lower case "Rotate" line means the rotate sign isn't specified in the machine instructions (so the angle is defined positive away from the fabrication plane)
        rotatetheta = regexp(linetxt,'\d+\.?\d*','match');
        rotatetheta = str2double(rotatetheta{1});
        bendtheta = str2double(bendtheta{1});
        if mod(abs(rotatetheta),rotatestep)~=0
            numrotatesteps = floor(abs(rotatetheta)/rotatestep);
        else
            numrotatesteps = int16(abs(rotatetheta)/rotatestep);
        end
        if bendtheta < 0
            % Rotation about +y axis if previous bend angle is negative - in increments specified by the rotate rate and time step
            for node = 1:nodecounter                
                for step=1:numrotatesteps            
                    % APPLY TRANSFORMATION TO ALL NODES NOT AT ORIGIN
                    coordsfield = nodestructfull(lastindx+step-1).coords;
                    currentnode = coordsfield(node,:);
                    rotplusy = [cos(deg2rad(rotatestep)),0,sin(deg2rad(rotatestep));0,1,0;-sin(deg2rad(rotatestep)),0,cos(deg2rad(rotatestep))]; % rotate by rotatestep [o] each time
                    currentnode = rotplusy*currentnode';
                    if node==1
                        coordsfieldupdate = coordsfield;
                        coordsfieldupdate(node,:) = currentnode;
                        nodestructfull(lastindx+step).time = nodestructfull(lastindx+step-1).time + dt;
                    else
                        coordsfieldupdate = nodestructfull(lastindx+step).coords;
                        coordsfieldupdate(node,:) = currentnode;
                    end
                    nodestructfull(lastindx+step).coords = coordsfieldupdate;
                end
                if mod(rotatetheta,rotatestep)~=0
                    % ADD ONE MORE FINAL STEP TO FINISH THE FABRICATION STEP                
                    coordsfield = nodestructfull(lastindx+numrotatesteps).coords;
                    currentnode = coordsfield(node,:);
                    extrarotatetheta = abs(rotatetheta) - numrotatesteps*rotatestep;
                    rotplusy = [cos(deg2rad(extrarotatetheta)),0,sin(deg2rad(extrarotatetheta));0,1,0;-sin(deg2rad(extrarotatetheta)),0,cos(deg2rad(extrarotatetheta))];
                    currentnode = rotplusy*currentnode';
                    if node==1
                        coordsfieldupdate = coordsfield;
                        coordsfieldupdate(node,:) = currentnode;
                        nodestructfull(lastindx+numrotatesteps+1).time = nodestructfull(lastindx+numrotatesteps).time + extrarotatetheta/rotatestep*dt;
                        nodestructfull(lastindx+numrotatesteps+1).coords = coordsfieldupdate;
                    else
                        coordsfieldupdate = nodestructfull(lastindx+numrotatesteps+1).coords;
                        coordsfieldupdate(node,:) = currentnode;
                        nodestructfull(lastindx+numrotatesteps+1).coords = coordsfieldupdate;
                    end
                end
            end
        elseif bendtheta > 0
            % Rotation about -y axis if previous bend angle is positive - in increments specified by the rotate rate and time step
            for node = 1:nodecounter                
                for step=1:numrotatesteps            
                    % APPLY TRANSFORMATION TO ALL NODES NOT AT ORIGIN
                    coordsfield = nodestructfull(lastindx+step-1).coords;
                    currentnode = coordsfield(node,:);
                    rotnegy = [cos(deg2rad(-rotatestep)),0,sin(deg2rad(-rotatestep));0,1,0;-sin(deg2rad(-rotatestep)),0,cos(deg2rad(-rotatestep))]; % rotate by rotatestep [o] each time
                    currentnode = rotnegy*currentnode';
                    if node==1
                        coordsfieldupdate = coordsfield;
                        coordsfieldupdate(node,:) = currentnode;
                        nodestructfull(lastindx+step).time = nodestructfull(lastindx+step-1).time + dt;
                    else
                        coordsfieldupdate = nodestructfull(lastindx+step).coords;
                        coordsfieldupdate(node,:) = currentnode;
                    end
                    nodestructfull(lastindx+step).coords = coordsfieldupdate;
                end
                if mod(rotatetheta,rotatestep)~=0
                    % ADD ONE MORE FINAL STEP TO FINISH THE FABRICATION STEP                
                    coordsfield = nodestructfull(lastindx+numrotatesteps).coords;
                    currentnode = coordsfield(node,:);
                    extrarotatetheta = abs(rotatetheta) - numrotatesteps*rotatestep;
                    rotnegy = [cos(deg2rad(-extrarotatetheta)),0,sin(deg2rad(-extrarotatetheta));0,1,0;-sin(deg2rad(-extrarotatetheta)),0,cos(deg2rad(-extrarotatetheta))];
                    currentnode = rotnegy*currentnode';
                    if node==1
                        coordsfieldupdate = coordsfield;
                        coordsfieldupdate(node,:) = currentnode;
                        nodestructfull(lastindx+numrotatesteps+1).time = nodestructfull(lastindx+numrotatesteps).time + extrarotatetheta/rotatestep*dt;
                        nodestructfull(lastindx+numrotatesteps+1).coords = coordsfieldupdate;
                    else
                        coordsfieldupdate = nodestructfull(lastindx+numrotatesteps+1).coords;
                        coordsfieldupdate(node,:) = currentnode;
                        nodestructfull(lastindx+numrotatesteps+1).coords = coordsfieldupdate;
                    end
                end
            end  
        end
    elseif contains(linetxt,'ROTATE') % Upper case "ROTATE" line means the rotate sign IS specified in the machine instructions (positive = rotation about the +y feeding axis)
        rotatetheta = regexp(linetxt,'(+|-)?\d+\.?\d*','match');
        rotatetheta = str2double(rotatetheta{1});
        if mod(abs(rotatetheta),rotatestep)~=0
            numrotatesteps = floor(abs(rotatetheta)/rotatestep);
        else
            numrotatesteps = int16(abs(rotatetheta)/rotatestep);
        end
        % Rotation about +y axis - in increments specified by the rotate rate and time step
        for node = 1:nodecounter                
            for step=1:numrotatesteps            
                % APPLY TRANSFORMATION TO ALL NODES NOT AT ORIGIN
                coordsfield = nodestructfull(lastindx+step-1).coords;
                currentnode = coordsfield(node,:);
                rotplusy = [cos(deg2rad(sign(rotatetheta)*rotatestep)),0,sin(deg2rad(sign(rotatetheta)*rotatestep));0,1,0;-sin(deg2rad(sign(rotatetheta)*rotatestep)),0,cos(deg2rad(sign(rotatetheta)*rotatestep))]; % rotate by rotatestep [o] each time
                currentnode = rotplusy*currentnode';
                if node==1
                    coordsfieldupdate = coordsfield;
                    coordsfieldupdate(node,:) = currentnode;
                    nodestructfull(lastindx+step).time = nodestructfull(lastindx+step-1).time + dt;
                else
                    coordsfieldupdate = nodestructfull(lastindx+step).coords;
                    coordsfieldupdate(node,:) = currentnode;
                end
                nodestructfull(lastindx+step).coords = coordsfieldupdate;
            end
            if mod(rotatetheta,rotatestep)~=0
                % ADD ONE MORE FINAL STEP TO FINISH THE FABRICATION STEP                
                coordsfield = nodestructfull(lastindx+numrotatesteps).coords;
                currentnode = coordsfield(node,:);
                extrarotatetheta = abs(rotatetheta) - numrotatesteps*rotatestep;
                rotplusy = [cos(deg2rad(sign(rotatetheta)*extrarotatetheta)),0,sin(deg2rad(sign(rotatetheta)*extrarotatetheta));0,1,0;-sin(deg2rad(sign(rotatetheta)*extrarotatetheta)),0,cos(deg2rad(extrarotatetheta))];
                currentnode = rotplusy*currentnode';
                if node==1
                    coordsfieldupdate = coordsfield;
                    coordsfieldupdate(node,:) = currentnode;
                    nodestructfull(lastindx+numrotatesteps+1).time = nodestructfull(lastindx+numrotatesteps).time + extrarotatetheta/rotatestep*dt;
                    nodestructfull(lastindx+numrotatesteps+1).coords = coordsfieldupdate;
                else
                    coordsfieldupdate = nodestructfull(lastindx+numrotatesteps+1).coords;
                    coordsfieldupdate(node,:) = currentnode;
                    nodestructfull(lastindx+numrotatesteps+1).coords = coordsfieldupdate;
                end
            end
        end
    end
    nodestructshort(end+1).time = nodestructfull(end).time;
    nodestructshort(end).coords = nodestructfull(end).coords;
    lastindx = size(nodestructfull,2); % update last indx
end

% Remove zero rows from coordinates and flip order so nodes start at origin
for i=1:size(nodestructshort,2)
    coords = nodestructshort(i).coords;
    coords(~any(coords,2),:) = [];  % delete zero rows
    nodestructshort(i).coords = flipud([coords; 0,0,0]);
end
for i=1:size(nodestructfull,2)
    coords = nodestructfull(i).coords;
    coords(~any(coords,2),:) = [];  % delete zero rows
    nodestructfull(i).coords = flipud([coords; 0,0,0]);
end

end