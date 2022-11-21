function [feedcount, bendrotatecount, totlinecount] = feedvsbendlinecount(bendpathfile)
%% Function to count the number of feed and bend/rotate lines in a bendpath
    % Set counters
    feedcount = 0;
    bendrotatecount = 0;
    % Load bend path
    fileID = fopen(bendpathfile,'r');
    bendpathtxt = textscan(fileID,'%s','delimiter','\n');
    bendpathtxt = bendpathtxt{1};
    fclose(fileID);
    % Calculate number of feed and bend/rotate lines in bendpath
    for i=1:length(bendpathtxt)
        linetxt = bendpathtxt{i};
        if contains(linetxt,'FEED')
            feedcount = feedcount + 1;
        elseif contains(linetxt,'BEND') || contains(linetxt,'Rotate') || contains(linetxt,'ROTATE')
            bendrotatecount = bendrotatecount + 1;
        end
    end
    totlinecount = length(bendpathtxt);
end