function AutocadOutput(path,pos,filename)
%% Function for outputing Euler path coordinates in a format recognized by AutoCAD
% Outputs coordinates of every coordinate in Euler path as "x1,y1,z1" in each line of a text file
% Then the "3DPOLY" command in AutoCAD creates a 3D sketch with line segments between all nodes, which is exported as an IGS file to be imported into Abaqus
    fileID = fopen(append(filename,".scr"),'w');    
    fprintf(fileID,'3DPOLY\n');
    edgesadded = [0,0];
    for i=1:(length(path)-1)
        node1 = path(i);
        node2 = path(i+1);
        if sum(ismember(edgesadded,[node1,node2],'rows'))==0 && sum(ismember(edgesadded,[node2,node1],'rows'))==0
            fprintf(fileID,'%.4f,',pos(node1,1));
            fprintf(fileID,'%.4f,',pos(node1,2));
            fprintf(fileID,'%.4f\n',pos(node1,3));
            edgesadded(i,:) = [node1, node2];
        else
            fprintf(fileID,'%.4f,',pos(node1,1));
            fprintf(fileID,'%.4f,',pos(node1,2));
            fprintf(fileID,'%.4f\n',pos(node1,3));
            fprintf(fileID,'\n3DPOLY\n');
        end
    end
    fprintf(fileID,'%.4f,',pos(node2,1));
    fprintf(fileID,'%.4f,',pos(node2,2));
    fprintf(fileID,'%.4f\n\n',pos(node2,3));
    fprintf(fileID,'EXPORT\n');
    fprintf(fileID,append(filename,".iges\n"));
    fprintf(fileID,'Y\n');
    fprintf(fileID,'ALL\n\n');
    fprintf(fileID,'ERASE\n');
    fprintf(fileID,'ALL\n\n');
    fclose('all');
end