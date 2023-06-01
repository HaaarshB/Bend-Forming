function AnimateFabvsTime(bendpathfile,nodestructfull,nodestructshort,filename,viewangle,dataspeed,vidspeed)
%% Function to animate fabrication from struct of nodal coordinates at each fabrication step
if nargin < 5
    viewangle = [0 90];
    dataspeed = 2;
    vidspeed = 2;
end

% % Load bend path
fileID = fopen(bendpathfile,'r');
bendpathtxt = textscan(fileID,'%s','delimiter','\n');
bendpathtxt = bendpathtxt{1};
fclose('all');
timevecfab = extractfield(nodestructshort,'time')';

% % Shorten time vector based on speed of video
timevecfull = extractfield(nodestructfull,'time')';
arraysize = size(timevecfull,1);
extractdataindx = (1:dataspeed:arraysize)';
if extractdataindx(end) ~= arraysize
    extractdataindx(end+1) = arraysize;
end
timevecshort = timevecfull(extractdataindx);

% Find max axes limits
firstfabline = nodestructfull(1).coords;
minx = min(firstfabline(:,1));
maxx = max(firstfabline(:,1));
miny = min(firstfabline(:,2));
maxy = max(firstfabline(:,2));
for i=2:size(nodestructfull,2)
    coords = nodestructfull(i).coords;
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

% Plot fabrication in real time
writerObj3D = VideoWriter(filename);
writerObj3D.FrameRate = framerate;
open(writerObj3D);
f = figure();
% f = figure('visible','off');

for i=1:size(timevecshort,1)
    indx = timevecshort(i)==timevecfull;
    coords = nodestructfull(indx).coords;
    plot3(coords(:,1),coords(:,2),coords(:,3),'-k','LineWidth',4);
%         hold on % I think uncommenting this line shows you total volume spanned by structure during fabrication
    if i==size(nodestructfull,2) % highlight start and end points at the end
        hold on
        scatter3(0,0,0,50,'r','filled') % end node of bend path
        scatter3(coords(end,1),coords(end,2),coords(end,3),50,'r','filled') % start node of bend path
    end
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
    frame = getframe(gcf);
    if i~=size(nodestructfull,2)
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