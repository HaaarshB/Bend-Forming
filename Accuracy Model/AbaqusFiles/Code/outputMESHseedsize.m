function outputMESHseedsize(numelements,perfnodes,filename)
%% Function which calculates the mesh seed size for Abaqus model of the truss hoop
% Mesh seed size is the shortest edge length of the geometry divided by the specified number of elements

% Find shortest length in truss
dist = zeros(length(perfnodes)-1,1);
for i=1:(length(perfnodes)-1)
    dist(i,1) = norm(perfnodes(i+1,:)-perfnodes(i,:));
end
mindist = min(dist);
MESHseedsize = mindist/numelements * 1/1000; % [m]

% Output coords as text file for Abaqus script to read
fileID = fopen(filename,'w');
fprintf(fileID,'%.6f',MESHseedsize);
fclose('all');

end