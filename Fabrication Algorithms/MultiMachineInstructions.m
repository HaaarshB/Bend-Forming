function MultiMachineInstructions(pathstruct,posstruct,filename,commentbool,pinzbool)
%% Function for converting an Euler path into machine instructions for DI Wire Pro, i.e. G code (general)
% Uses geometry of the bend path to create FEED/BEND/ROTATE instructions
% Uses distance between every two nodes in path (FEED),
% angles in between every three nodes in heuristic path (BEND),
% and angles between planes made by every three nodes in the path (ROTATE wire)

if nargin < 4
    commentbool = 0; % Boolean for adding node number comments before each FEED line
    pinzbool = 0; % Boolean for adding PINZ movements before ROTATE wire lines >90 deg
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
            fprintf(fileID,'(Node %.0f ',firstnode);
            fprintf(fileID,'to %.0f)\n',secondnode);
        end
        % Put "FEED __" into text file
        feed = norm(secondcoord-firstcoord) - 1.5;
        fprintf(fileID,'FEED ');
        fprintf(fileID,'%.1f\n',feed);
        % Put "BEND __" into text file
        bend = 180-rad2deg(anglebtw(thirdcoord-secondcoord,firstcoord-secondcoord));
        fprintf(fileID,'BEND ');
        fprintf(fileID,'%.1f\n',bend);
        ncurrent = cross(thirdcoord-secondcoord,firstcoord-secondcoord)/norm(cross(thirdcoord-secondcoord,firstcoord-secondcoord));
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
            fprintf(fileID,'(Node %.0f ',firstnode);
            fprintf(fileID,'to %.0f)\n',secondnode);
        end
        % Put "FEED __" into text file
        feed = norm(secondcoord-firstcoord) - 1.5;
        fprintf(fileID,'FEED ');
        fprintf(fileID,'%.1f\n',feed);
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
        doubledwire = 0;
        if firstcoord == thirdcoord % if there is a doubled wire
            doubledwire = 1;             
            if bendanglesign == 1
                bendanglesign = -1;
            elseif bendanglesign == -1
                bendanglesign = 1;
            end
        % Figure out if I need to pause and rotate wire, i.e. change plane 
        else
            % Compute plane of next three nodes
            nnext = cross(thirdcoord-secondcoord,firstcoord-secondcoord)/norm(cross(thirdcoord-secondcoord,firstcoord-secondcoord))*bendanglesign;
            if norm(cross(nnext,ncurrent))==0 % if plane of next three coordinates is same as DI plane
                if dot(nnext,ncurrent) ~= dot(abs(nnext),abs(ncurrent)) 
                    bendanglesign=-bendanglesign; % if plane of next three coordinates is opposite of DIplane
                end
            elseif any(abs(nnext-ncurrent) > 1e-3) % rotate wire if plane of next three coordinates is not same as DIplane (within a tolerance of 1e-3)
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
                        fprintf(fileID,'Rotate wire ');
                        fprintf(fileID,'%.0f',rotate);
                        fprintf(fileID,' degrees\n');
                    end
                end
            end
        end
        if commentbool
            % Put node numers into text file as a comment
            fprintf(fileID,'(Node %.0f ',firstnode);
            fprintf(fileID,'to %.0f)\n',secondnode);
        end
        % Put "FEED __" into text file
        feed = norm(secondcoord-firstcoord) - 1.5;
        fprintf(fileID,'FEED ');
        fprintf(fileID,'%.1f\n',feed);
        % Put "BEND __" into text file
        if doubledwire
            if pinzbool
                pindown = 0;
            end
            fprintf(fileID,'BEND ');
            fprintf(fileID,'%.1f\n',180*bendanglesign);
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
            bend = 180-rad2deg(anglebtw(thirdcoord-secondcoord,firstcoord-secondcoord));
            if ceil(bend)~=0 && floor(bend)~=0
                fprintf(fileID,'BEND ');
                fprintf(fileID,'%.1f\n',bend*bendanglesign);
            end
            prevbendanglesign = bendanglesign;
            prevdoubledwire = 0;
        end
    end
end

end

fclose(fileID);

%% Post process to move wire rotation before bending a doubled wire (since it's easier to rotate before a +-180 bend)
fileID = fopen(filename,'r');
txtcontent = textscan(fileID,'%s','delimiter','\n');
txtcontent = txtcontent{1};
fclose(fileID);
fileID = fopen(filename,'r');
txtcontentnew = textscan(fileID,'%s','delimiter','\n');
txtcontentnew = txtcontentnew{1};
fclose(fileID);
doubledwirelines = union(find(contains(txtcontent,'BEND 180')),find(contains(txtcontent,'BEND -180')));
rotatelines = find(contains(txtcontent,'Rotate'));
bendlines = find(contains(txtcontent,'BEND')); 
for i=1:size(doubledwirelines,1)
    bendlineindx = doubledwirelines(i);
    nextrotatelineindx = rotatelines(rotatelines > bendlineindx); % Finds rotate line after BEND +-180 line
    if ~isempty(nextrotatelineindx)
        nextrotatelineindx = nextrotatelineindx(1);
        rotateline = txtcontent{nextrotatelineindx};
        prevbendlineindx = bendlines(bendlines < bendlineindx); % Finds previous bend line before BEND +-180 line
        prevbendlineindx = prevbendlineindx(end);
        % Reorders text file so that rotate line is directly after previous bend line and before +-180 bend
        if nextrotatelineindx-bendlineindx == 2 % but only if rotate line is close to doubled wire
            txtcontentnew{prevbendlineindx+1} = txtcontent{nextrotatelineindx-1}; % Put PINZ down line first
            txtcontentnew{prevbendlineindx+2} = rotateline; % Put rotate line
            for j=3:(nextrotatelineindx-prevbendlineindx)
                txtcontentnew{prevbendlineindx+j} = txtcontent{prevbendlineindx+j-2};
            end
        elseif nextrotatelineindx-bendlineindx == 1
            txtcontentnew{prevbendlineindx+1} = rotateline; % Put rotate line first
            for j=2:(nextrotatelineindx-prevbendlineindx)
                txtcontentnew{prevbendlineindx+j} = txtcontent{prevbendlineindx+j-1};
            end
        end
    end
end
fileID = fopen(filename,'wt') ;
fprintf(fileID,'%s\n',txtcontentnew{:});
fclose('all');

end