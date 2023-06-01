function AnimateFabCompCMMOIvsTime(bendpathfile,nodestructshort,pointmassstructfull,spacecraftstruct,feedstockspoolstruct,compCMMOIstruct,filename,viewangle,colorconstrangebool,MOIplotbool,dataspeed,vidspeed)
%% Function to animate fabrication with varying center of mass (CM) and mass moment of inertia (MOI) AND including spacecraft body and feedstock spool

if nargin < 8
    viewangle = [103,13];
    colorconstrangebool = 0;
    MOIplotbool = 0;
    dataspeed = 3;
    vidspeed = 3;
end

% % Load bend path
fileID = fopen(bendpathfile,'r');
bendpathtxt = textscan(fileID,'%s','delimiter','\n');
bendpathtxt = bendpathtxt{1};
fclose('all');
timevecfab = extractfield(nodestructshort,'time')';

% % Shorten time vector based on speed of video
timevecfull = extractfield(pointmassstructfull,'time')';
arraysize = size(timevecfull,1);
extractdataindx = (1:dataspeed:arraysize)';
if extractdataindx(end) ~= arraysize
    extractdataindx(end+1) = arraysize;
end
timevecshort = timevecfull(extractdataindx);

% Find max and min axes limits during fabrication
allcoordsinitial = [spacecraftstruct.vert; feedstockspoolstruct(1).spoolcircleTOP];
xlimloop = [min(allcoordsinitial(:,1)), max(allcoordsinitial(:,1))];
ylimloop = [min(allcoordsinitial(:,2)), max(allcoordsinitial(:,2))];
zlimloop = [min(allcoordsinitial(:,3)), max(allcoordsinitial(:,3))];
for i=1:size(pointmassstructfull,2)
    allcoordsinitial = [spacecraftstruct.vert; feedstockspoolstruct(1).spoolcircleTOP];
    allcoordsinitial = [allcoordsinitial;pointmassstructfull(i).pointcoords];
    % Adjust min and max x values based on coordinates after each fabrication step
    if min(allcoordsinitial(:,1)) < xlimloop(1)
        xlimloop = [min(allcoordsinitial(:,1)), xlimloop(2)];
    end
    if max(allcoordsinitial(:,1)) > xlimloop(2)
        xlimloop = [xlimloop(1),max(allcoordsinitial(:,1))];
    end
    % Same thing for y
    if min(allcoordsinitial(:,2)) < ylimloop(1)
        ylimloop = [min(allcoordsinitial(:,2)), ylimloop(2)];
    end
    if max(allcoordsinitial(:,2)) > ylimloop(2)
        ylimloop = [ylimloop(1),max(allcoordsinitial(:,2))];
    end
    % Same thing for z
    if min(allcoordsinitial(:,3)) < zlimloop(1)
        zlimloop = [min(allcoordsinitial(:,3)), zlimloop(2)];
    end
    if max(allcoordsinitial(:,3)) > zlimloop(2)
        zlimloop = [zlimloop(1),max(allcoordsinitial(:,3))];
    end
end
% Pad axes by 7%
xlimloop = 1.07*xlimloop;
ylimloop = 1.07*ylimloop;
zlimloop = 1.07*zlimloop;

% Calculate frame rate to plot fabrication in real time
frametimes = diff(timevecshort)/vidspeed;
framerate = 10^(abs(floor(log10(min(frametimes))))); % multiply frame times by a factor of 10 to make everything integers
frametimes = round(framerate*frametimes,0);

% Plot fabrication as a video with MOI matrix plotted as a color bar on the right
writerObj3D = VideoWriter(filename);
writerObj3D.FrameRate = framerate;
open(writerObj3D);
f = figure('units','normalized','outerposition',[0 0 1 1]);
hold on

if MOIplotbool
    % Initialize left subplot
    axleft = subplot(1,2,1);
end

% Plot spacecraft body
bodyCM = spacecraftstruct.CM;
bodyVERT = spacecraftstruct.vert;
bodyFAC = spacecraftstruct.fac;
patch('Vertices',bodyVERT,'Faces',bodyFAC,'FaceVertexCData',hsv(6),'FaceColor','[0 0.4470 0.7410]');
hold on

% Plot feedstock spool
spoolCM = feedstockspoolstruct.CM;
spoolcircleTOP = feedstockspoolstruct.spoolcircleTOP;
spoolcircleBOT = feedstockspoolstruct.spoolcircleBOT;
patch(spoolcircleTOP(:,1),spoolcircleTOP(:,2),spoolcircleTOP(:,3),[0 0.4470 0.7410]);
patch(spoolcircleBOT(:,1),spoolcircleBOT(:,2),spoolcircleBOT(:,3),[0 0.4470 0.7410]);
surf([spoolcircleTOP(:,1),spoolcircleBOT(:,1)],[spoolcircleTOP(:,2),spoolcircleBOT(:,2)],[spoolcircleTOP(:,3),spoolcircleBOT(:,3)], 'FaceColor','[0 0.4470 0.7410]','EdgeColor','none')
alpha(0.3)

% Plot CMs of spacecraft body, feedstock spool, and composite CM
compCM = compCMMOIstruct(1).compCM;
bodyCMplot = scatter3(bodyCM(1),bodyCM(2),bodyCM(3),15,'r','filled');
spoolCMplot = scatter3(spoolCM(1),spoolCM(2),spoolCM(3),15,'r','filled');
compCMplot = scatter3(compCM(1),compCM(2),compCM(3),100,'r','filled');
xlabel('X [mm]','FontSize',14)
ylabel('Y [mm]','FontSize',14)
zlabel('Z [mm]','FontSize',14)
axis('equal')
xlim(xlimloop)
ylim(ylimloop)
zlim(zlimloop)
view(viewangle)
% Add time step as a title
titletxt = append('t = ',num2str(round(pointmassstructfull(1).time,2)),' s');
subtitle(titletxt,'FontSize',16);
set(gcf,'color','w');
hold on

% Plot coordinate axes
coordaxesplot = quiver3(zeros(3,1),zeros(3,1),zeros(3,1),[1;0;0],[0;1;0],[0;0;1],30,'Color','k','LineWidth',3);

if MOIplotbool
    % Initialize right subplot
    axright = subplot(1,2,2);
    rightplot = imagesc(abs(compCMMOIstruct(1).MOI_compCM));
    cb = colorbar;
    if colorconstrangebool
        set(cb,'Limits',[min(min(abs(compCMMOIstruct(end).MOI_compCM))) max(max(abs(compCMMOIstruct(end).MOI_compCM)))]) % set limits on color bar so it's range stays constant during fabrication
    end
    % Adjust size of subplots
    set(axleft,'Units','normalized','position',[0.1,0.125,0.6,0.8]) % https://stackoverflow.com/questions/24125099/how-can-i-set-subplot-size-in-matlab-figure'
    set(axright,'Units','normalized','position',[0.75,0.35,0.175,0.35])
    % axis equal
    axis off
    title('Inertia Matrix [kg*mm^2]','FontSize',15,'FontWeight','bold','Units','normalized','Position',[0.5, 1.025, 0])
end

% First frame with just spacecraft body and feedstock spool
frame = getframe(gcf);
writeVideo(writerObj3D,frame);

for i=1:size(timevecshort,1)
    % REPLACE LEFT SUBPLOT WITH NEW FABRICATION FRAME
    if MOIplotbool
        axes(axleft)
    end
    if i==1
        delete(compCMplot)
        delete(coordaxesplot)
    else % delte wire structure and CM dots for next frame
        delete(compCMplot)
        delete(wireplot)
        delete(wireCMplot)
    end
    hold on
    % Highlight individual and composite CMs in red
    indx = timevecshort(i)==timevecfull;
    pointcoords = pointmassstructfull(indx).pointcoords;
    wirestructureCM = pointmassstructfull(indx).CM;
    compCM = compCMMOIstruct(indx).compCM;
    wireplot = plot3(pointcoords(:,1),pointcoords(:,2),pointcoords(:,3),'-k','LineWidth',3);
    wireCMplot = scatter3(wirestructureCM(1),wirestructureCM(2),wirestructureCM(3),15,'r','filled');
    compCMplot = scatter3(compCM(1),compCM(2),compCM(3),100,'r','filled');
    % Add fab step and time step as a title
    [~,fabindx]=min(abs(timevecfab-timevecshort(i)));
    if fabindx~=1
        fablinetxt = bendpathtxt{fabindx-1};
        if contains(fablinetxt,'FEED')
            feedlength = regexp(fablinetxt,'\d+\.?\d*','match');
            fabsteptxt = sprintf('FEED %d',round(str2double(feedlength),0));
        elseif contains(fablinetxt,'BEND')
            bendtheta = regexp(fablinetxt,'(+|-)?\d+\.?\d*','match');
            fabsteptxt = sprintf('BEND %d',round(str2double(bendtheta),0));
        elseif contains(fablinetxt,'ROTATE')
            rotatetheta = regexp(fablinetxt,'(+|-)?\d+\.?\d*','match');
            fabsteptxt = sprintf('ROTATE %d',round(str2double(rotatetheta),0));
        end
        titletxt = append('t = ',num2str(round(timevecshort(i),2)),' s');
        title(fabsteptxt,'FontSize',16,'Fontweight','Bold') % show fabrication step as a subtitle
    end
    subtitle(titletxt,'FontSize',16);
    set(gcf,'color','w');
    
    if MOIplotbool
        % REPLACE RIGHT SUBPLOT WITH NEW INERTIA MATRIX (with absolute value numbers)
        axes(axright);
        delete(rightplot) % delete inertia matrix for next frame
        rightplot = imagesc(abs(compCMMOIstruct(indx).MOI_compCM));
        cb = colorbar;
        if colorconstrangebool
            set(cb,'Limits',[min(min(abs(compCMMOIstruct(end).MOI_compCM))) max(max(abs(compCMMOIstruct(end).MOI_compCM)))]) % set limits on color bar so it's range stays constant during fabrication
        end
        axis off
        title('Inertia Matrix [kg*mm^2]','FontSize',14,'FontWeight','bold','Units','normalized','Position',[0.5,1.025,0])
    end

    frame = getframe(gcf);
    if i~=size(timevecshort,1)
        for sec = 1:frametimes(i)
            writeVideo(writerObj3D,frame);
        end
    else
        writeVideo(writerObj3D,frame);
        set(f,'visible','on')
    end
end

hold off
close(writerObj3D);

end