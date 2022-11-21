function [perfnodes, impnodes, curvenodes, bendpathtxt, randomoffsetsflip] = KinematicModel_HTM(bendpathfile,dcurve,dfeed,dbend,drotate,mucurve,mufeed,mubend,murotate,sigcurve,sigfeed,sigbend,sigrotate,thetapoints)
%% Function to calculate an imperfect Bend-Formed truss using the tolerances of individual fabrication steps (i.e. feeding, bending, rotating)
% Recreates a series of machine instructions for a 2-DOF CNC wire bender BUT with tolerances of individual steps to model an imperfect structure.
% The tolerances are constants which represent the magnitude of an imperfection during feeding (dfeed and dcurve), bending (dbend), and rotating (drotate) the wire feedstock.
% NOTE: tolerances are not stocahstic or random. They are the same value for each type of machine instruction.

% CONSIDERS BOTH SYSTEMATIC AND RANDOM MACHINE ERRORS
% SYSTEMATIC ERRORS:
% "dcurve" is strut straightness given by nondimensional delta/strutlength
% "dfeed" is strut length tolerance in [mm] % positive means extra length
% "dbend" bend angle tolerance in [o] % positive means more of a bend
% "drotate" rotate angle tolerance in [o]
% RANDOM ERRORS:
% "mu__" and "sig__" define a normal distribution for the same errors as above

    % Number of nodes along strut if it is curved
    if nargin < 14
        thetapoints = 25;
    end

    % Load bend path
    fileID = fopen(bendpathfile,'r');
    bendpathtxt = textscan(fileID,'%s','delimiter','\n');
    bendpathtxt = bendpathtxt{1};
    fclose('all');

   % Find total number of imperfect nodes in bend path (i.e. how many times the instruction file has "FEED")
    totnodes = 1;
    feedlineindx = [];
    for i=1:length(bendpathtxt)
        linetxt = bendpathtxt{i};
        if contains(linetxt,'FEED')
            totnodes = totnodes + 1;
            feedlineindx(end+1,1) = i;
        end
    end

    % Find total number of bend/rotate lines and make a list of random offsets to them (using random mean and standard deviation)
    % These same random offsets are used for each calculation of HTM matrices
    randomoffsets = zeros(length(bendpathtxt),1);
    for i=1:length(bendpathtxt)
        linetxt = bendpathtxt{i};
        if contains(linetxt,'FEED')
            randomoffsets(i,1) = random('Normal',mufeed,sigfeed);
        elseif contains(linetxt,'BEND')
            randomoffsets(i,1) = random('Normal',mubend,sigbend);
        elseif contains(linetxt,'Rotate')
            randomoffsets(i,1) = random('Normal',murotate,sigrotate);
        end
    end

    % Initialize perfect and imperfect nodes at the origin
    perfnodes = zeros(totnodes,3);
    impnodes = zeros(totnodes,3);
    curvenodes = struct;

    % Calculate perfect and imperfect homogenous transformation matrices (HTMs) for each node in bend path
    allHTMs = struct;
    for i=1:length(feedlineindx)
        feedline = feedlineindx(i);
        lastline = length(bendpathtxt);
        % Make HTM matrix for all lines from current feed line to last line of instructions by multiplying HTMs from each line in between
        perfHTM = eye(4); % initialize with identity matrices
        impHTM = eye(4);
        for line = feedline:lastline % Multiply HTMs from each line in between
            linetxt = bendpathtxt{line};
            if contains(linetxt,'FEED') % HTM for feeding
                feedlength = regexp(linetxt,'\d+\.?\d*','match');
                feedlength = str2num(feedlength{1});
                impfeedlength = feedlength;
                if dfeed ~= 0 || mufeed ~= 0 || sigfeed ~= 0 % add feed tolerance to feedlength
                    impfeedlength = feedlength + dfeed + randomoffsets(line,1); % both systematic and random error
                end
                perffeedHTM = [1,0,0,0;0,1,0,feedlength;0,0,1,0;0,0,0,1];
                impfeedHTM = [1,0,0,0;0,1,0,impfeedlength;0,0,1,0;0,0,0,1];
                perfHTM = perffeedHTM * perfHTM ; % update perfect and imperfect HTMs
                impHTM = impfeedHTM * impHTM;
            elseif contains(linetxt,'BEND')
                thetabend = regexp(linetxt,'(+|-)?\d+\.?\d*','match');
                thetabend = str2double(thetabend{1});
                thetaoffsetrand = randomoffsets(line,1);
                if thetabend < 0
                    dbendneg = -dbend; % switch sign of dbend if thetabend is negative so that +dbend still matches with "overbend" convention and -dbend with "underbend"
                    thetaoffsetrandneg = -thetaoffsetrand;
                    impthetabend = thetabend + dbendneg + thetaoffsetrandneg; % both systematic and random error
                    % Rotation about +z axis if thetabend is negative
                    perfbendHTM = [cos(deg2rad(abs(thetabend))),-sin(deg2rad(abs(thetabend))),0,0;sin(deg2rad(abs(thetabend))),cos(deg2rad(abs(thetabend))),0,0;0,0,1,0;0,0,0,1];
                    impbendHTM = [cos(deg2rad(abs(impthetabend))),-sin(deg2rad(abs(impthetabend))),0,0;sin(deg2rad(abs(impthetabend))),cos(deg2rad(abs(impthetabend))),0,0;0,0,1,0;0,0,0,1];
                    perfHTM = perfbendHTM * perfHTM;
                    impHTM = impbendHTM * impHTM;
                elseif thetabend > 0
                    impthetabend = thetabend + dbend + thetaoffsetrand;
                    % Rotation about -z axis if thetabend is positive
                    perfbendHTM = [cos(deg2rad(-thetabend)),-sin(deg2rad(-thetabend)),0,0;sin(deg2rad(-thetabend)),cos(deg2rad(-thetabend)),0,0;0,0,1,0;0,0,0,1];
                    impbendHTM = [cos(deg2rad(-impthetabend)),-sin(deg2rad(-impthetabend)),0,0;sin(deg2rad(-impthetabend)),cos(deg2rad(-impthetabend)),0,0;0,0,1,0;0,0,0,1];
                    perfHTM = perfbendHTM * perfHTM;
                    impHTM = impbendHTM * impHTM;
                end
            elseif contains(linetxt,'Rotate')
                thetarotate = regexp(linetxt,'\d+\.?\d*','match');
                thetarotate = str2double(thetarotate{1}); % if machine instructions have only positive rotations defined away from the fabrication plane
                impthetarotate = thetarotate + drotate + randomoffsets(line,1);
                if thetabend < 0
                    % Rotation about +y axis if previous bend angle is negative
                    perfrotateHTM = [cos(deg2rad(thetarotate)),0,sin(deg2rad(thetarotate)),0;0,1,0,0;-sin(deg2rad(thetarotate)),0,cos(deg2rad(thetarotate)),0;0,0,0,1];
                    improtateHTM = [cos(deg2rad(impthetarotate)),0,sin(deg2rad(impthetarotate)),0;0,1,0,0;-sin(deg2rad(impthetarotate)),0,cos(deg2rad(impthetarotate)),0;0,0,0,1];
                    perfHTM = perfrotateHTM * perfHTM;
                    impHTM = improtateHTM * impHTM;
                elseif thetabend > 0
                    % Rotation about -y axis if previous bend angle is positive
                    perfrotateHTM = [cos(deg2rad(-thetarotate)),0,sin(deg2rad(-thetarotate)),0;0,1,0,0;-sin(deg2rad(-thetarotate)),0,cos(deg2rad(-thetarotate)),0;0,0,0,1];
                    improtateHTM = [cos(deg2rad(-impthetarotate)),0,sin(deg2rad(-impthetarotate)),0;0,1,0,0;-sin(deg2rad(-impthetarotate)),0,cos(deg2rad(-impthetarotate)),0;0,0,0,1];
                    perfHTM = perfrotateHTM * perfHTM;
                    impHTM = improtateHTM * impHTM;
                end
            elseif contains(linetxt,'ROTATE')
                thetarotate = regexp(linetxt,'(+|-)?\d+\.?\d*','match');
                thetarotate = str2double(thetarotate{1}); % if machine instructions have positive or negative rotations about feedstock axis (+y axis)
                impthetarotate = thetarotate + drotate + randomoffsets(line,1);
                perfrotateHTM = [cos(deg2rad(thetarotate)),0,sin(deg2rad(thetarotate)),0;0,1,0,0;-sin(deg2rad(thetarotate)),0,cos(deg2rad(thetarotate)),0;0,0,0,1];
                improtateHTM = [cos(deg2rad(impthetarotate)),0,sin(deg2rad(impthetarotate)),0;0,1,0,0;-sin(deg2rad(impthetarotate)),0,cos(deg2rad(impthetarotate)),0;0,0,0,1];
                perfHTM = perfrotateHTM * perfHTM;
                impHTM = improtateHTM * impHTM;
            end
        end
        allHTMs(i).perfHTMs = perfHTM;
        allHTMs(i).impHTMs = impHTM;
    end

    % Apply HTMs to all nodes to arrive at the perfect and imperfect geometries from all nodes at the origin
    for i=1:size(allHTMs,2)
        perfHTM = allHTMs(i).perfHTMs;
        impHTM = allHTMs(i).impHTMs;
        coordspostperfHTM = perfHTM * [perfnodes(i,:)';1];
        coordspostimpHTM = impHTM * [impnodes(i,:)';1];
        perfnodes(i,:) = coordspostperfHTM(1:3)';
        impnodes(i,:) = coordspostimpHTM(1:3)';
    end

    % Flip order of truss nodes so larger index means further away from bend head
    perfnodes = flip(perfnodes);
    impnodes = flip(impnodes);

    % Apply curvature between every two imperfect nodes using dcurve, mucurve, and sigcurve (to simulate curved struts)
    % NOTE: This applies an offset given by (dcurve * strut length) in a random perpendicular direction to the strut.
    % The strut length is given by the distance between every two nodes of the imperfect geometry, so it may vary for each strut if there is a nonzero feed length error.
    if dcurve ~= 0 || mucurve ~= 0 || sigcurve ~= 0
        curvemidpoints = zeros(size(impnodes,1)-1,3);
        curvenodes = struct;
        changebasismatrices = struct;
        % thetapoints = 100;
        curvecoords3D = zeros(thetapoints,3);
        syms x
        for i=1:(size(impnodes,1)-1)
            startpoint = impnodes(i,:);
            endpoint = impnodes(i+1,:);
            midpoint = (startpoint+endpoint)/2;
            tanvec = ((endpoint-startpoint)/norm(endpoint-startpoint))';
            strutlength = norm(endpoint - startpoint);
            curveoffset = (dcurve+random('Normal',mucurve,sigcurve))*strutlength;
            % Fit circular arc to straight strut using dcurve
            fun1 = @(x)curvedstrut_fit(x,startpoint,endpoint,curveoffset);
            radphiguess = [feedlength,deg2rad(45)]; % inital guess
            options = optimset('Display','off'); % turn off display of "<stopping criteria details>"
            radphi = fsolve(fun1,radphiguess,options);
            radfit = radphi(1);
            phifit = radphi(2);
            theta = linspace(-phifit/2,phifit/2,thetapoints)';
            curvecoords2D = [radfit*(cos(theta)-cos(phifit/2)),radfit*sin(theta),zeros(thetapoints,1)];
            curvemidpoint2D = [radfit*(1-cos(phifit/2)),0,0];
            % Transform 2D curved strut into basis of the 3D strut using a transformation matrix
            % The direction of the curved offset is random
            xvecrand = randn(1,3)';
            [nonzerocomp,~] = find(tanvec);
            if size(nonzerocomp,1)==1
                comptochange = nonzerocomp;
            else
                comptochange = randi([min(nonzerocomp) max(nonzerocomp)]);
            end
            if comptochange == 1
                newcomp = vpasolve(x*tanvec(1)+xvecrand(2)*tanvec(2)+xvecrand(3)*tanvec(3)==0,x);
            elseif comptochange == 2
                newcomp = vpasolve(xvecrand(1)*tanvec(1)+x*tanvec(2)+xvecrand(3)*tanvec(3)==0,x);
            else
                newcomp = vpasolve(xvecrand(1)*tanvec(1)+xvecrand(2)*tanvec(2)+x*tanvec(3)==0,x);
            end
            xvecrand(comptochange) = newcomp;
            xvecnew = xvecrand/norm(xvecrand); % picks a random unit vector perpendicular to strut tangent vector as the x-axis of a new basis for the curved strut
            yvecnew = tanvec; % y-axis is the strut tangent vector
            zvecnew = cross(xvecnew,yvecnew)/norm(cross(xvecnew,yvecnew)); % z-axis
            changebasismatrix = [xvecnew,yvecnew,zvecnew];
            changebasismatrices(i).matrix = changebasismatrix;
            curvemidpoint3D = (changebasismatrix*curvemidpoint2D')' + midpoint;
            curvemidpoints(i,:) = curvemidpoint3D;
            for j=1:thetapoints
                curvecoords3D(j,:) = (changebasismatrix*(curvecoords2D(j,:))')' + midpoint;
            end
            curvenodes(i).coords = curvecoords3D;
        end
    else
        curvenodes = 0;
        curvemidpoints = 0;
    end
    randomoffsetsflip = flip(randomoffsets);

end