function totbendenergy = totbendenergy(bendpathfile)
%% Function to calculate total energy required for all bending and rotating steps in the bendpathfile
% Uses plastic hinge model, i.e. energy = Mp * theta, for each bend and rotate step
% Does not consider energy for feeding nor any machine errors

    % Load bend path
    fileID = fopen(bendpathfile,'r');
    bendpathtxt = textscan(fileID,'%s','delimiter','\n');
    bendpathtxt = bendpathtxt{1};
    fclose(fileID);

    % Calculate energy for each bend and rotate line using plastic hinge model
    sigmay = 450*10^6; % [N/m2]
    wirediam = 0.0009;% [m]
    Zp = wirediam^3/6; % plastic section modulus
    Mp = Zp*sigmay; % plastic moment
    totbendenergy = 0; % [J]
    for i=1:length(bendpathtxt)
        linetxt = bendpathtxt{i};
        if contains(linetxt,'BEND')
            thetabend = regexp(linetxt,'(+|-)?\d+\.?\d*','match');
            thetabend = deg2rad(str2double(thetabend{1})); % [rad]
            bendenergy = Mp*abs(thetabend);
            totbendenergy = totbendenergy + bendenergy;
        elseif contains(linetxt,'Rotate')
            thetarotate = regexp(linetxt,'\d+\.?\d*','match');
            thetarotate = deg2rad(str2double(thetarotate{1})); % will always be positive
            rotateenergy = Mp*abs(thetarotate);
            totbendenergy = totbendenergy + rotateenergy;
        end
    end

    % Print output to command line
    fprintf(append('Total energy to bend: ', num2str(totbendenergy), ' J\n'));

end