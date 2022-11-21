function outputBCdisplacements(perfnodes,impnodes,filename)
%% Function which outputs displacemnts of imperfect nodes to arrive at perfect geometry
% Used in Abaqus script to calculate self-stress in the truss from these displacements, during the alignment step.

% Calculate displacements to go from impnodes to perfnodes
displacements = perfnodes - impnodes;

% Output coords as text file for Abaqus script to read
fileID = fopen(filename,'w');    
for i=2:size(displacements,1)
    nodetomove = impnodes(i,:) * 1e-3; % [m];
    BCdisplacement = displacements(i,:) * 1e-3; % [m];
    % Print into text file
    fprintf(fileID,'%.6f ', nodetomove(1));
    fprintf(fileID,'%.6f ', nodetomove(2));
    fprintf(fileID,'%.6f ', nodetomove(3));
    fprintf(fileID,'%.6f ', BCdisplacement(1));
    fprintf(fileID,'%.6f ', BCdisplacement(2));
    fprintf(fileID,'%.6f ', BCdisplacement(3));
    fprintf(fileID,'BC-%d ', i);
    if i ~= size(displacements,1)
        fprintf(fileID,'NODE%d\n', i);
    else
        fprintf(fileID,'NODE%d\n', i);
    end
end
fclose('all');

end