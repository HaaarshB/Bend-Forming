function MachinePathCoordinatesTXT(path,pos,filename)
%% Function which outputs a list of coordinates which represent a bend path for a truss
fileID = fopen(filename,'w');
for i=1:length(path)
    nodecoords = pos(path(i),:);
    if i~=length(path)
        fprintf(fileID,'%.5f ',nodecoords(1));
        fprintf(fileID,'%.5f ',nodecoords(2));
        fprintf(fileID,'%.5f\n',nodecoords(3));
    else
        fprintf(fileID,'%.5f ',nodecoords(1));
        fprintf(fileID,'%.5f ',nodecoords(2));
        fprintf(fileID,'%.5f',nodecoords(3));
    end
end
fclose('all');
end