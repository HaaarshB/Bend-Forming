function MultiMachineInstructionsExact(pathstruct,posstruct,filename,commentbool)
%% Function for converting multiple, patched Euler paths through a desired truss into EXACT machine instructions for a CNC wire bender with 3 DOFs (feed, bend, and rotate)
% Uses geometry of the bend path to create FEED/BEND/ROTATE instructions
% Uses distance between every two nodes in path (FEED),
% angles in between every three nodes in heuristic path (BEND),
% and angles between planes made by every three nodes in the path (ROTATE)

% NOTE: For this to work properly, the end point of each path must coincide with the start point of the next path.
% Otherwise the last bend angle at the end of each path will be wrong.

% EXACT machine instructions mean that each instruction has 5 digits after the decimal point 
% There are no additional features to help with fabrication and the feed lengths are exactly equal to the distance between nodes
% These EXACT machine instructions are used for the accuracy model of Bend-Fomring

if nargin < 4
    commentbool = 0; % Boolean for adding node number comments before each FEED line
end

fileID = fopen(filename,'w');
for pathnum=1:size(pathstruct,2)
    path = pathstruct(pathnum).path;
    pos = posstruct(pathnum).pos;

fprintf(fileID,'**STARTING BEND PATH %.0f**\n',pathnum);
% COLLINEAR NODES IN BEGINNING OF PATH (fed first before calculating plane ncurrent)
lastcollinearnode = 1;
while lastcollinearnode < (length(path)-1)
    firstnode = path(lastcollinearnode);
    secondnode = path(lastcollinearnode+1);
    thirdnode = path(lastcollinearnode+2);
    firstcoord = pos(firstnode,:); % current node
    secondcoord = pos(secondnode,:);
    thirdcoord = pos(thirdnode,:);
    if round(180-rad2deg(anglebtw(thirdcoord-secondcoord,firstcoord-secondcoord))) == 0 % check if there is a zero bend/rotate
        feed = norm(secondcoord-firstcoord);
        fprintf(fileID,'FEED %.5f\n',feed);
        lastcollinearnode = lastcollinearnode + 1;
    else
        break
    end
end
for i=lastcollinearnode:(length(path)-1)
    % FIRST NODE AFTER ALL COLLINEAR NODES
    if i==lastcollinearnode && length(path)~=2
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
        % Plane of first three nodes (after all collinear nodes have been fed)
        ncurrent = cross(thirdcoord-secondcoord,firstcoord-secondcoord)/norm(cross(thirdcoord-secondcoord,firstcoord-secondcoord));
        bendanglesign = 1; % starts with a postiive bend angle
    % SECOND TO LAST NODE OF FINAL PATH
    elseif i==(length(path)-1) && pathnum==size(pathstruct,2)
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
    % ALL NODES IN BETWEEN
    else
        firstnode = path(i);
        firstcoord = pos(firstnode,:); % current node
        if i==(length(path)-1) % PATHCING PATHS TOGETHER AT SECOND TO LAST NODE OF INTERMEDIATE PATHS (*)
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
        collinearnodes = 0; % boolean for a zero bend/rotate (i.e. all three nodes are collinear)
        doubledwire = 0; % boolean for a doubled wire (i.e. first node is same as third node)
        if round(180-rad2deg(anglebtw(thirdcoord-secondcoord,firstcoord-secondcoord))) == 0 % check if there is a zero bend/rotate
            collinearnodes = 1;
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
                    if round(rotate) == 180 % avoid rotation if it equals 180 deg
                        bendanglesign=-bendanglesign;
                        ncurrent = -nnext;
                        rotate = 0;
                    else
                        ncurrent = nnext;
                    end
                else % if rotation axis and rotation vector are in opposite directions
                    rotate = rad2deg(anglebtw(-ncurrent,nnext));
                    if round(rotate) == 180 % avoid rotation if it equals 180 deg
                        ncurrent = nnext;
                        rotate = 0;
                    else
                        bendanglesign=-bendanglesign;
                        ncurrent = -nnext;
                    end
                end
                if round(rotate)~=0
                    % Put "ROTATE __" into text file
                    % fprintf(fileID,'Rotate wire %.5f degrees\n',rotate*rotateanglesign);
                    fprintf(fileID,'ROTATE %.5f\n',rotate*rotateanglesign);
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
            fprintf(fileID,'BEND %.5f\n',180*bendanglesign);
        else
            if collinearnodes ~= 1
                bend = 180-rad2deg(anglebtw(thirdcoord-secondcoord,firstcoord-secondcoord));
                fprintf(fileID,'BEND %.5f\n',bend*bendanglesign);
            end
        end
    end
end

end
fclose(fileID);

end