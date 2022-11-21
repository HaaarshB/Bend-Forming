function outputAXconnectors(perfnodes,impnodes,dispratio,filename)
%% Function which outputs specs for axial connectors between adjacent nodes in the imperfect truss
% Used in Abaqus script to create axial connectors which close to calculate selfstress from closing defects

    % Find adjacent nodes
    adjacentnodes = cell(1,5);
    count = 1;
    for i=1:(size(perfnodes,1)-1)
        currentnode = perfnodes(i,:);
        othernodes = perfnodes(i+1:end,:);
        for j=1:size(othernodes,1)
            nodedist = norm(othernodes(j,:)-currentnode);
            node1 = i;
            node2 = i+j;
            if nodedist < 1e-2 && ~ismember(node2,cell2mat(adjacentnodes(:,2))) % check for adjacency
                connectorlength = norm(impnodes(node2,:)-impnodes(node1,:)) * 1e-3;
                adjacentnodes{count,1} = node1; % node 1 number
                adjacentnodes{count,2} = node2; % node 2 number
                adjacentnodes{count,3} = sprintf('NODE%d_NODE%d',node1,node2); % name of connector
                adjacentnodes{count,4} = connectorlength; % connector reference length [m]
                adjacentnodes{count,5} = -connectorlength * dispratio; % connector displacement [m]
                count = count + 1;
            end
        end
    end
    
    % Output coords as text file for Abaqus script to read
    fileID = fopen(filename,'w');    
    for i=1:size(adjacentnodes,1)
        perfectnode = round(perfnodes(adjacentnodes{i,1},:)*1e-3,3); % [m]
        connectnode1 = impnodes(adjacentnodes{i,1},:) * 1e-3; % [m]
        connectnode2 = impnodes(adjacentnodes{i,2},:) * 1e-3; % [m]
        constraintname = adjacentnodes{i,3};
        referencelength = adjacentnodes{i,4};
        connectordisp = adjacentnodes{i,5};
        % Print into text file
        fprintf(fileID,'%.6f ', connectnode1(1)); % Coordinates of the first node in the connector
        fprintf(fileID,'%.6f ', connectnode1(2));
        fprintf(fileID,'%.6f ', connectnode1(3));
        fprintf(fileID,'%.6f ', connectnode2(1)); % Coordinates of the second node in the connector
        fprintf(fileID,'%.6f ', connectnode2(2));
        fprintf(fileID,'%.6f ', connectnode2(3));
        fprintf(fileID,'%s ', constraintname); % Name of the connector
        fprintf(fileID,'%.6f ', referencelength); % Reference length of the connector
        fprintf(fileID,'%.6f ', connectordisp); % Displacement applied to connector, slightly less than reference length
        fprintf(fileID,'%.6f ', perfectnode(1)); % Coordinates of the perfect node the connector should close with
        fprintf(fileID,'%.6f ', perfectnode(2));
        if i ~= size(adjacentnodes,1)
            fprintf(fileID,'%.6f\n', perfectnode(3));
        else
            fprintf(fileID,'%.6f', perfectnode(3));
        end
    end
    fclose('all');

end