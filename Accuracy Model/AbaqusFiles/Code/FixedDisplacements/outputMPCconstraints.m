function outputMPCconstraints(perfnodes,impnodes,filename)
%% Function which outputs coordinates of master and slave nodes for each MPC constraint between adjacent nodes in the imperfect truss
% Used in Abaqus script to create MPC constraints which become active 
% during the relax step, when self-stress is calculated in the truss

% Find adjacent nodes
adjacentnodes = cell(1,3);
counter = 1;
for i=1:(size(perfnodes,1)-1)
    currentnode = perfnodes(i,:);
    othernodes = perfnodes(i+1:end,:);
    for j=1:size(othernodes,1)
        nodedist = norm(othernodes(j,:)-currentnode);
        if nodedist < 0.5 % check for adjacency within 0.5 mm radius
            adjacentnodes{counter,1} = i;
            adjacentnodes{counter,2} = i+j;
            adjacentnodes{counter,3} = sprintf('Constraint-%d',counter);
            counter = counter + 1;
        end
    end
end

% Output coords as text file for Abaqus script to read
fileID = fopen(filename,'w');    
for i=1:size(adjacentnodes,1)
    masternode = impnodes(adjacentnodes{i,1},:) * 1e-3; % [m]
    slavenode = impnodes(adjacentnodes{i,2},:) * 1e-3; % [m]
    constraintname = adjacentnodes{i,3};
    % Print into text file
    fprintf(fileID,'%.6f ', masternode(1));
    fprintf(fileID,'%.6f ', masternode(2));
    fprintf(fileID,'%.6f ', masternode(3));
    fprintf(fileID,'%.6f ', slavenode(1));
    fprintf(fileID,'%.6f ', slavenode(2));
    fprintf(fileID,'%.6f ', slavenode(3));
    if i ~= size(adjacentnodes,1)
        fprintf(fileID,'%s\n', constraintname);
    else
        fprintf(fileID,'%s', constraintname);
    end
end
fclose('all');

end