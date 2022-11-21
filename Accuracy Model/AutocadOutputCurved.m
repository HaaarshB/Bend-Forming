function AutocadOutputCurved(path,pos,curvenodes,filename)
%% Function for outputing truss geometry with curved struts in a format recognized by AutoCaD
% Creates a script for AutoCad to run to output the geometry as an IGES file
    fileID = fopen(append(filename,".scr"),'w');    
    fprintf(fileID,'3DPOLY\n');
    for i=1:(length(path)-1)
        node1 = path(i);
        node2 = path(i+1);
        fprintf(fileID,'%.4f,',pos(node1,1));
        fprintf(fileID,'%.4f,',pos(node1,2));
        fprintf(fileID,'%.4f\n',pos(node1,3));
        curvecoords = curvenodes(i).coords;
        for j=2:(size(curvecoords,1)-1)
            fprintf(fileID,'%.4f,',curvecoords(j,1));
            fprintf(fileID,'%.4f,',curvecoords(j,2));
            fprintf(fileID,'%.4f\n',curvecoords(j,3));
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