clearvars
close all
addpath("C:\Users\harsh\Documents\GitHub\Bend-Forming\Fabrication Algorithms")
addpath("C:\Users\harsh\Documents\GitHub\Bend-Forming\Exemplary Structures\IsogridColumn")

%% Input truss parameters
r = 100; % column radius in mm
nlongeron = 12; % 8
nbay = 10; % 16
boundary = 1; % boolean for including top boundary
pausetime = 0.1; % controls how fast path is plotted

[g3D,pos3D] = isogridcolumngraph3D(nlongeron, nbay, r, boundary);
[g2D,pos2D] = isogridcolumngraph2D(nlongeron, nbay, r, boundary);
pos2D(:,3) = zeros(size(pos2D,1),1);

plotgraph(g2D,pos2D,0,0,[180 -90])
% plotgraph(g3D,pos3D,0,0)

[geuler2D,~,~,~,eulerpath2D] = CPP_Algorithm(g2D,pos2D);
% [geuler3D,~,~,~,eulerpath3D] = CPP_Algorithm(g3D,pos3D);

lengthmasswire(eulerpath2D,pos2D,7800,0.9)
% lengthmasswire(eulerpath3D,pos3D,7800,0.9)

% MachineInstructions(eulerpath2D,pos2D,"C:\Users\harsh\Desktop\isogrid_prototype.txt")
plotbendpatharrows(g2D,eulerpath2D,pos2D,4,15,'green',[180,-90])

%% Old stuff

% Booleans for plotting
plot2Dgeom = 0;
plot2Dpath = 1;
plot2Dsvg = 0;
plot3Dgeom = 0;
plot3Dpath = 0;
% Boolean for video saving
savevideo = 0;
framerate = 5;
video3Dname = 'isogridtruss3D.avi';
video2Dname = 'isogridtruss2D.avi';

% Calculates and plots input truss both as a 3D and 2D unrolled graph
[g3D,pos3D] = isogridcolumngraph3D(nlongeron, nbay, r, boundary);
[g2D,pos2D] = isogridcolumngraph2D(nlongeron, nbay, r, boundary);
if plot2Dgeom
    figure()
    plot(g2D, 'XData', pos2D(:,1), 'YData', pos2D(:,2))
    axis equal
end
if plot3Dgeom
    figure()
    plot(g3D, 'XData', pos3D(:,1), 'YData', pos3D(:,2), 'ZData', pos3D(:,3))
    axis equal
end


%% Plot picked Euler path on 3D geometry

% Create Euler path starting at node 1
eulerpath3D = 1;
for n=nlongeron:-1:1
    if n==nlongeron
        for b=1:nbay
            eulerpath3D(end+1:end+2,1) = [b*n; b*n+1];
        end
        spiralline = (nbay+1)*n:-n:n;
        eulerpath3D(end+1:end+length(spiralline)) = spiralline;
    else
        for b=1:nbay
            eulerpath3D(end+1:end+2,1) = [n+(b-1)*nlongeron; n+b*nlongeron+1];
        end
        spiralline = (n+nbay*nlongeron):-nlongeron:n;
        eulerpath3D(end+1:end+length(spiralline)) = spiralline;
    end
end

% Plot one Euler path in red superimposed on original geometry
if plot3Dpath
    if savevideo
        writerObj3D = VideoWriter(video3Dname);
        writerObj3D.FrameRate = framerate;
        open(writerObj3D);
    end
    figure()
    pathplot = plot(g3D, 'XData', pos3D(:,1), 'YData', pos3D(:,2), 'Zdata', pos3D(:,3), 'NodeLabel', {});
    axis equal
    axis off
    set(gcf,'color','w');
    view(75.474,49.2981)
    if savevideo
        frame = getframe;
        writeVideo(writerObj3D,frame);
    end
    highlight(pathplot,eulerpath3D(1))
    highlight(pathplot,eulerpath3D(1),'NodeColor','r')
    if savevideo
        frame = getframe;
        writeVideo(writerObj3D,frame);
    end
    pause(pausetime)
    for i=1:(length(eulerpath3D)-1)
        highlight(pathplot,[eulerpath3D(i) eulerpath3D(i+1)],'LineWidth',2)
        highlight(pathplot,[eulerpath3D(i) eulerpath3D(i+1)],'EdgeColor','r')
        highlight(pathplot,eulerpath3D(i+1),'NodeColor','r')
        pause(pausetime)
        if savevideo
            frame = getframe;
            writeVideo(writerObj3D,frame);
        end
    end
    if savevideo
        close(writerObj3D);
    end
end

%% Plot picked Euler path on 2D unrolled geometry
% Example paths for (nlongeron, nbay)
% (3,1) = [1  2 5          6 2   3 6           7 3   4 7           8 4]
% (3,2) = [1  2 5  6 9  10 6 2   3 6  7 10  11 7 3   4 7  8 11  12 8 4]
% (4,1) = [1  2 6          7 2   3 7           8 3   4 8           9 4   5 9           10 5]
% (4,2) = [1  2 6  7 11 12 7 2   3 7  8 12  13 8 3   4 8  9 13  14 9 4   5 9 10 14  15 10 5]


% Create Euler path starting at node 1
eulerpath2D = 1;
for n=1:nlongeron
    for b=1:nbay
        if b==nbay
            eulerpath2D(end+1:end+2,1) = [n+1+(b-1)*(nlongeron+1); n+b*(nlongeron+1)];
            downline = (n+nbay*(nlongeron+1)+1):-(nlongeron+1):1;
            eulerpath2D(end+1:end+length(downline),1) = downline';
        else
            eulerpath2D(end+1:end+2,1) = [n+1+(b-1)*(nlongeron+1); n+b*(nlongeron+1)];
        end
    end
end

% Plot one Euler path in red superimposed on original geometry
if plot2Dpath
    if savevideo
        writerObj2D = VideoWriter(video2Dname);
        writerObj2D.FrameRate = 5;
        open(writerObj2D);
    end
    figure()
    pathplot = plot(g2D, 'XData', pos2D(:,1), 'YData', pos2D(:,2), 'NodeLabel', {});
    axis equal
    axis off
    set(gcf,'color','w');
    if savevideo
        frame = getframe;
        writeVideo(writerObj2D,frame);
    end
    highlight(pathplot,eulerpath2D(1))
    highlight(pathplot,eulerpath2D(1),'NodeColor','r')
    if savevideo
        frame = getframe;
        writeVideo(writerObj2D,frame);
    end
    pause(pausetime)
    for i=1:(length(eulerpath2D)-1)
        highlight(pathplot,[eulerpath2D(i) eulerpath2D(i+1)],'LineWidth',2)
        highlight(pathplot,[eulerpath2D(i) eulerpath2D(i+1)],'EdgeColor','r')
        highlight(pathplot,eulerpath2D(i+1),'NodeColor','r')
        pause(pausetime)
        if savevideo
            frame = getframe;
            writeVideo(writerObj2D,frame);
        end
    end
    if savevideo
        close(writerObj2D);
    end
end

%% Construct 2D SVG file for wire bender
svgpath = zeros(size(eulerpath2D,1),2);
for i=1:length(eulerpath2D)
    svgpath(i,:) = pos2D(eulerpath2D(i),:);
end
if plot2Dsvg
    figure()
    plot(svgpath(:,1),svgpath(:,2),'k')
    axis equal
    xlim([-ceil(max(-svgpath(:,1)))-5 5])
    set(gca,'XColor','none') % removes x and y axis numbering
    set(gca,'YColor','none')
    % set(gcf, 'Position',  [200, 200, 600, 500]) % sets size of figure
end