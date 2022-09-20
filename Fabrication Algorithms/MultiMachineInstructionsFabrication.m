function MultiMachineInstructionsFabrication(pathstruct,posstruct,filename,commentbool,pinzbool,bendheaddiam,wirediam)
%% Function for converting multiple Euler path through a desired truss into FABRICATION machine instructions for a CNC wire bender with 3 DOFs (feed, bend, and rotate)
% Uses geometry of the bend path to create FEED/BEND/ROTATE instructions
% Uses distance between every two nodes in path (FEED),
% angles in between every three nodes in heuristic path (BEND),
% and angles between planes made by every three nodes in the path (ROTATE)

% FABRICATION machine instructions means that the code includes additional 
% features to help with fabrication, such as:
%   Avoid rotations < 10 deg or > 170 deg (see lines 115-133); 
%   Move bend head up and down with PINZ command to avoid collision while rotating (see lines 135-165);
%   Adjust feed for wire diameter and bend head radius (see lines 183-206);

if nargin < 4
    commentbool = 0; % Boolean for adding node number comments before each FEED line
    pinzbool = 0; % Boolean for adding PINZ movements before ROTATE wire lines >90 deg
    bendheaddiam = 1; % [mm]
    wirediam = 1; % [mm]
elseif nargin > 4 && nargin < 6
    bendheaddiam = 1; % [mm]
    wirediam = 1; % [mm]
end

fileID = fopen(filename,'w');
for pathnum=1:size(pathstruct,2)
    path = pathstruct(pathnum).path;
    pos = posstruct(pathnum).pos;

for i=1:length(path)
    % FIRST NODE OF FULL PATH
    if pathnum==1 && i==1
        fprintf(fileID,'**STARTING BEND PATH %.0f**\n',pathnum);
        firstnode = path(i);
        secondnode = path(i+1);
        thirdnode = path(i+2);
        firstcoord = pos(firstnode,:); % current node
        secondcoord = pos(secondnode,:);
        thirdcoord = pos(thirdnode,:);
        if commentbool
            % Put node numers into text file as a comment
            fprintf(fileID,'(Node %.0f to %.0f)\n',firstnode,secondnode);
        end
        % Put "FEED __" into text file
        feed = norm(secondcoord-firstcoord);
        fprintf(fileID,'FEED %.5f\n',feed);
        % Put "BEND __" into text file
        bend = 180-rad2deg(anglebtw(thirdcoord-secondcoord,firstcoord-secondcoord));
        if round(bend)~=0
            fprintf(fileID,'BEND %.5f\n',bend);
        end
        ncurrent = cross(thirdcoord-secondcoord,firstcoord-secondcoord)/norm(cross(thirdcoord-secondcoord,firstcoord-secondcoord)); % plane of first three nodes
        bendanglesign = 1; % starts with a postiive bend angle
        prevbendanglesign = bendanglesign;
        prevdoubledwire = 0;
        pindown = 0;
    % SECOND TO LAST NODE OF FULL PATH
    elseif pathnum==size(pathstruct,2) && i==(length(path)-1)
        firstnode = path(i);
        secondnode = path(i+1);
        firstcoord = pos(firstnode,:); % current node
        secondcoord = pos(secondnode,:);
        if commentbool
            % Put node numers into text file as a comment
            fprintf(fileID,'(Node %.0f to %.0f)\n',firstnode,secondnode);
        end
        % Put "FEED __" into text file
        feed = norm(secondcoord-firstcoord);
        fprintf(fileID,'FEED %.5f\n',feed);
    % LAST NODE OF INTERMEDIATE PATHS
    elseif  i==length(path)
        if pathnum~=size(pathstruct,2)
            fprintf(fileID,'\n**STARTING BEND PATH %.0f**\n',pathnum+1);
        end
    % ALL NODES IN BETWEEN
    else
        firstnode = path(i);
        firstcoord = pos(firstnode,:); % current node
        if i==(length(path)-1) % patching paths together
            nextpath = pathstruct(pathnum+1).path;
            nextpos = posstruct(pathnum+1).pos;
            secondnode = path(i+1);
            thirdnode = nextpath(2);
            secondcoord = pos(secondnode,:);
            thirdcoord = nextpos(thirdnode,:);
        else
            secondnode = path(i+1);
            thirdnode = path(i+2);
            secondcoord = pos(secondnode,:);
            thirdcoord = pos(thirdnode,:);
        end
        zerobendrotate = 0; % boolean for a zero bend/rotate (i.e. all three nodes are collinear)
        doubledwire = 0; % boolean for a doubled wire (i.e. first node is same as third node)
        if round(180-rad2deg(anglebtw(thirdcoord-secondcoord,firstcoord-secondcoord))) == 0 % check if there is a zero bend/rotate
            zerobendrotate = 1;
        elseif firstcoord == thirdcoord % check if there is a doubled wire (i.e. first node is same as third node)
            doubledwire = 1;             
            if bendanglesign == 1
                bendanglesign = -1;
            elseif bendanglesign == -1
                bendanglesign = 1;
            end
        % Figure out if I need to pause and rotate wire, i.e. change plane 
        else
            rotateanglesign = -bendanglesign; % rotate angle sign always opposite of previous bend angle sign (based on my CYS)
            % Compute plane of next three nodes
            nnext = cross(thirdcoord-secondcoord,firstcoord-secondcoord)/norm(cross(thirdcoord-secondcoord,firstcoord-secondcoord))*bendanglesign;
            if norm(cross(nnext,ncurrent))==0 % if plane of next three coordinates is same as machine plane
                if dot(nnext,ncurrent) ~= dot(abs(nnext),abs(ncurrent)) 
                    bendanglesign=-bendanglesign; % if plane of next three coordinates is opposite of machine plane
                end
            elseif any(abs(nnext-ncurrent) > 1e-3) % rotate wire if plane of next three coordinates is not same as machine plane (within a tolerance of 1e-3)
                rotaxis = (secondcoord-firstcoord)/norm(secondcoord-firstcoord) * bendanglesign;                    
                rotvector = cross(nnext,ncurrent)/norm(cross(nnext,ncurrent));
                rotvectorproj = vectorproj(rotvector,rotaxis); % direction you need to rotate to reach next plane
                if dot(rotvectorproj,rotaxis) == dot(abs(rotvectorproj),abs(rotaxis)) % if rotation axis and rotation vector are in the same direction
                    rotate = rad2deg(anglebtw(ncurrent,nnext));
                    if rotate >=170 % avoid rotations of >170 degrees
                        bendanglesign=-bendanglesign;
                        ncurrent = -nnext;
                        rotate = 0;
                    else
                        ncurrent = nnext;
                    end
                else % if rotation axis and rotation vector are in opposite directions
                    rotate = rad2deg(anglebtw(-ncurrent,nnext));
                    if rotate >=170 % avoid rotations of >170 degrees
                        ncurrent = nnext;
                        rotate = 0;
                    else
                        bendanglesign=-bendanglesign;
                        ncurrent = -nnext;
                    end
                end
                if ceil(rotate)~=0 && floor(rotate)~=0
                    if rotate >= 10 % avoid rotations of <10 degrees
                        if rotate > 90 && pinzbool
                            % Put "PINZ -5" into text file if rotation angle is more than 90 degrees to avoid collision with bend head when feeding next strut
                            fprintf(fileID,'PINZ -5\n');
                            pindown = 1;
                        elseif pinzbool
                            pindown = 0;
                        end
                        % Put "ROTATE __" into text file
                        fprintf(fileID,'Rotate wire %.5f degrees\n',rotate*rotateanglesign);
                    end
                end
            end
        end
        if commentbool
            % Put node numers into text file as a comment
            fprintf(fileID,'(Node %.0f to %.0f)\n',firstnode,secondnode);
        end
        % Put "FEED __" into text file
        feed = norm(secondcoord-firstcoord);
        fprintf(fileID,'FEED %.5f\n',feed);
        % Put "BEND __" into text file
        if doubledwire
            if pinzbool
                pindown = 0;
            end
            fprintf(fileID,'BEND %.5f\n',180*bendanglesign); % for doubled wire use 180 deg bend (can change depending on machine)
            prevdoubledwire = 1;
        else
            if pinzbool
                if pindown && ~prevdoubledwire % Move pin back up if pin is down and previous bend angle is same as current
                    if prevbendanglesign==bendanglesign
                        fprintf(fileID,'PINZ 0\n'); 
                    end
                    pindown = 0;
                end
            end
            if zerobendrotate ~= 1
                bend = 180-rad2deg(anglebtw(thirdcoord-secondcoord,firstcoord-secondcoord));
                fprintf(fileID,'BEND %.5f\n',bend*bendanglesign);
            end
            prevbendanglesign = bendanglesign;
            prevdoubledwire = 0;
        end
    end
end

end
fclose(fileID);

%% Post process to adjust each feed length using the bend angle which follows it, the bend head diameter, and the wire feedstock diameter (i.e. curvature of bend)
fileID = fopen(filename,'r');
txtcontent = textscan(fileID,'%s','delimiter','\n');
txtcontent = txtcontent{1};
fclose(fileID);
feedlines = find(contains(txtcontent,'FEED'));
bendlines = find(contains(txtcontent,'BEND'));
rotatelines = find(contains(txtcontent,'Rotate'));
doubledwirelines = union(find(contains(txtcontent,'BEND 180')),find(contains(txtcontent,'BEND -180')));
for i=1:size(feedlines,1)
    feedlineindx = feedlines(i);
    feedlinecontents = regexp(txtcontent(feedlineindx),'[\d*\.]*\d*','match');
    feedlengthcell = [feedlinecontents{:}];
    feedlinelength = str2double(strcat(feedlengthcell{:}));
    if ismember(feedlineindx+1,bendlines) && feedlinelength > 1 % only change feed lines which have bend lines directly after them
        bendlineindx = feedlineindx + 1;
        bendlinecontents = regexp(txtcontent(bendlineindx),'[\d*\.]*\d*','match');
        bendanglecell = [bendlinecontents{:}];
        bendlineangle = str2double(strcat(bendanglecell{:}));
        feedadjust = (bendheaddiam/2+wirediam/2)*sin(abs(deg2rad(bendlineangle))/2);
        feedlengthnew = feedlinelength - feedadjust;
        txtcontent(feedlineindx) = {sprintf('FEED %.5f',feedlengthnew)};
    end
end

%% Save machine instructions in a text file
fileID = fopen(filename,'wt') ;
fprintf(fileID,'%s\n',txtcontent{:});
fclose('all');

end