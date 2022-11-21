function outputCLsequenceALL(filename,AXfilename)
%% Function which outputs text file for closing all defects at once
% Used in Abaqus script to create axial connectors which close to calculate selfstress from closing defects

    % Parse through connector data file (constructed with "outputAXconnectors.m")
    AXconnectorfile = fopen(AXfilename);
    AXconnectordata = textscan(AXconnectorfile,'%s%s%s%s%s%s%s%s%s%s%s%s');
    fclose(AXconnectorfile);
    connectornames = AXconnectordata{1,7};
    connectordisps = str2double(AXconnectordata{1,9});

    % Construct text file with connectors to close based on provided closing sequence
    fileID = fopen(filename,'w');
    fprintf(fileID,'Initial Align1 ');
    for i = 1:length(connectornames)
        fprintf(fileID,'%s ',char(connectornames(i)));
        if i ~= length(connectornames)
            fprintf(fileID,'%f ',connectordisps(i));
        else
            fprintf(fileID,'%f',connectordisps(i));
        end
    end
    fclose('all');

end