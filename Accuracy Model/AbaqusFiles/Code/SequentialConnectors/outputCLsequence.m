function outputCLsequence(CLsequence,perfnodes,filename,AXfilename)
%% Function which outputs the sequence of closing nodes for closing defects
% Used in Abaqus script to create axial connectors which close to calculate selfstress from closing defects

    roundedperfnodes = round(perfnodes*1e-3,3); % [m]
    numnodes = size(unique(roundedperfnodes,'rows'),1);
    % Order rounded perfnodes in the order they appear in bend path
    orderedperfnodes = zeros(numnodes,3);
    count = 2;
    for i = 2:size(roundedperfnodes,1)
        node = roundedperfnodes(i,:);
        if ~ismember(orderedperfnodes,node,'rows')
            orderedperfnodes(count,:) = node;
            count = count + 1;
        end
    end

    % Parse through connector data file (constructed with "outputAXconnectors.m")
    AXconnectorfile = fopen(AXfilename);
    AXconnectordata = textscan(AXconnectorfile,'%s%s%s%s%s%s%s%s%s%s%s%s');
    fclose(AXconnectorfile);
    connectorperfnodes = str2double([AXconnectordata{1,10},AXconnectordata{1,11},AXconnectordata{1,12}]);
    connectorindx = zeros(size(connectorperfnodes,1),1);
    connectornames = AXconnectordata{1,7};
    connectordisps = str2double(AXconnectordata{1,9});

    for i=1:size(connectorperfnodes,1)
        [~,nodeindx] = ismember(connectorperfnodes(i,:),orderedperfnodes,'rows');
        connectorindx(i) = nodeindx;
    end

    % Construct text file with connectors to close based on provided closing sequence
    fileID = fopen(filename,'w');
    for i = 1:length(CLsequence)
        if i==1
            fprintf(fileID,'Initial Align1 ');
        else
            fprintf(fileID,'Align%d Align%d ',i-1,i);
        end
        nodetoclose = CLsequence(i);
        % Find connectors to close which correspond to the node in the closing sequence
        [allconnectorstoclose,~] = find(nodetoclose==connectorindx);
        for j = 1:length(allconnectorstoclose)
            connectortoclose = allconnectorstoclose(j);
            fprintf(fileID,'%s ',char(connectornames(connectortoclose)));
            if j ~= length(allconnectorstoclose)
                fprintf(fileID,'%f ',connectordisps(connectortoclose));
            elseif i ~= length(CLsequence)
                fprintf(fileID,'%f\n',connectordisps(connectortoclose));
            else
                fprintf(fileID,'%f\n',connectordisps(connectortoclose));
            end
        end
    end
    fclose('all');

end