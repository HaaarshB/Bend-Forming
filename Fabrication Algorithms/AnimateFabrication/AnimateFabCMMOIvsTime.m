function AnimateFabCMMOIvsTime(bendpathfile,nodestructshort,pointmassstructfull,filename,viewangle,colorconstrangebool,MOIplotbool,dataspeed,vidspeed)
%% Function to animate fabrication with varying center of mass (CM) and mass moment of inertia (MOI)
% Calculated with equally distributed point masses along each wire strut (as given by pointmassstruct)

% Plot point masses too? (so it's more clear what I'm doing)

if nargin < 5
    viewangle = [0 90];
    colorconstrangebool = 0;
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

% Find max axes limits
firstfabline = pointmassstructfull(1).pointcoords;
minx = min(firstfabline(:,1));
maxx = max(firstfabline(:,1));
miny = min(firstfabline(:,2));
maxy = max(firstfabline(:,2));
for i=2:size(pointmassstructfull,2)
    coords = pointmassstructfull(i).pointcoords;
    if min(coords(:,1)) < minx
        minx = min(coords(:,1));
    end
    if max(coords(:,1)) > maxx
        maxx = max(coords(:,1));
    end
    if min(coords(:,2)) < miny
        miny = min(coords(:,2));
    end
    if max(coords(:,2)) > maxy
        maxy = max(coords(:,2));
    end
end

% Calculate frame rate to plot fabrication in real time
frametimes = diff(timevecshort)/vidspeed;
framerate = 10^(abs(floor(log10(min(frametimes))))); % multiply frame times by a factor of 10 to make everything integers
frametimes = round(framerate*frametimes,0);

% Plot fabrication in real time with MOI matrix plotted as a color bar on the right
writerObj3D = VideoWriter(filename);
writerObj3D.FrameRate = framerate;
open(writerObj3D);
% f = figure('visible','off');
f= figure('units','normalized','outerposition',[0 0 1 1]);

for i=1:size(timevecshort,1)
    indx = timevecshort(i)==timevecfull;
    % Plot structure with CM highlighted in red
    if MOIplotbool
        axleft = subplot(1,2,1);
    end
    pointcoords = pointmassstructfull(indx).pointcoords;
    CM = pointmassstructfull(indx).CM;
    leftplot = plot3(pointcoords(:,1),pointcoords(:,2),pointcoords(:,3),'-k','LineWidth',4);
    hold on
    CMplot = scatter3(CM(1),CM(2),CM(3),50,'r','filled');
%     if i==fablines % highlight start and end points at the end
%         hold on
%         scatter3(0,0,0,50,'g','filled') % end node of bend path
%         scatter3(pointcoords(end,1),pointcoords(end,2),pointcoords(end,3),50,'g','filled') % start node of bend path
%     end
    axis equal
    xlabel('X [mm]')
    ylabel('Y [mm]')
    xlim(1.05*[minx maxx])
    ylim(1.05*[miny maxy])
    view(viewangle)

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
        title(fabsteptxt,'FontSize',16,'Fontweight','Bold') % show fabrication step as a subtitle
    end
    titletxt = append('t = ',num2str(round(timevecshort(i),2)),' s');
    subtitle(titletxt,'FontSize',16);
    set(gcf,'color','w');
    
    if MOIplotbool
        % Plot MOI_CM matrix on the right with a color bar
        axright = subplot(1,2,2);
        rightplot = imagesc(abs(pointmassstructfull(i).MOI_CM));
        cb = colorbar;
        if colorconstrangebool
            set(cb,'Limits',[min(min(abs(pointmassstructfull(end).MOI_CM))) max(max(abs(pointmassstructfull(end).MOI_CM)))]) % set limits on color bar so it's range stays constant during fabrication
        end
        % set(cb,'Position',[0.911, 0.2975, 0.02, 0.445]) % https://www.mathworks.com/matlabcentral/answers/157588-shrinking-the-height-of-the-colorbar
        % Adjust size of subplots
        set(axleft,'Units','normalized','position',[0.1,0.125,0.6,0.8]) % https://stackoverflow.com/questions/24125099/how-can-i-set-subplot-size-in-matlab-figure'
        set(axright,'Units','normalized','position',[0.75,0.35,0.175,0.35])
        axis off
        title('Inertia Matrix [kg*mm^2]','FontSize',14,'FontWeight','bold','Units','normalized','Position',[0.5, 1.025, 0])
    end
    
    frame = getframe(gcf);
    if i~=size(pointmassstructfull,2)
        for sec = 1:frametimes(i)
            writeVideo(writerObj3D,frame);
        end
        if MOIplotbool
            cla(axleft)
            cla(rightplot)
        else
            clf
        end
    else
        writeVideo(writerObj3D,frame);
        set(f,'visible','on')
    end
end
hold off
close(writerObj3D);

end