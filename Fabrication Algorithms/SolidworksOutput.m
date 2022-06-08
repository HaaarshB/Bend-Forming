function SolidworksOutput(path,pos,filename)
%% Function for outputing Euler path coordinates in a format recognized by Solidworks
% Outputs coordinates of every two coordinates in Euler path as "x1 y1 z1 x2 y2 z2" in each line of a text file
% Then a macro in Solidworks reads the file and creates a 3D sketch with line segments between each pair of two nodes
% Unit is mm when Solidworks opens it
% NOTE: For this to run properly, open the text file and copy paste everything into another blank text file
    fileID = fopen(filename,'w');    
    edgesadded = [0,0];
    pos = pos*1/1000;
    for i=1:(length(path)-1)
        node1 = path(i);
        node2 = path(i+1);
        if sum(ismember(edgesadded,[node1,node2],'rows'))==0 && sum(ismember(edgesadded,[node2,node1],'rows'))==0
            fprintf(fileID,'%.4f',pos(node1,1));
            fprintf(fileID,' ');
            fprintf(fileID,'%.4f',pos(node1,2));
            fprintf(fileID,' ');
            fprintf(fileID,'%.4f',pos(node1,3));
            fprintf(fileID,' ');
            fprintf(fileID,'%.4f',pos(node2,1));
            fprintf(fileID,' ');
            fprintf(fileID,'%.4f',pos(node2,2));
            fprintf(fileID,' ');
            if i~=(length(path)-1)
                fprintf(fileID,'%.4f\n',pos(node2,3));
            else
                fprintf(fileID,'%.4f',pos(node2,3));
            end
            edgesadded(i,:) = [node1, node2];
        end
    end
    fclose('all');
end