function plotbendpath(geuler,eulerpath,pos,pausetime,savevideo,framerate,filename,vidangle)
%% Function which plots bend path on truss graph
    if nargin < 5
        savevideo = 0;
        filename = [];
    end
    if savevideo
        writerObj3D = VideoWriter(filename);
        writerObj3D.FrameRate = framerate;
        open(writerObj3D);
        nodelabel = {};
    else
        nodelabel = 1:numnodes(geuler);
    end
    figure()
    pathplot = plot(geuler, 'XData', pos(:,1), 'YData', pos(:,2), 'Zdata', pos(:,3), 'NodeLabel', nodelabel);
    axis equal
    if savevideo
        set(gcf,'color','w');
        view(vidangle)
        axis off
        frame = getframe;
        writeVideo(writerObj3D,frame);
    else
        title('Bend path')
    end
    highlight(pathplot,eulerpath(1))
    highlight(pathplot,eulerpath(1),'NodeColor','r')
    if savevideo
        frame = getframe;
        writeVideo(writerObj3D,frame);
    end
    edgepath = zeros(length(eulerpath)-1,1);
    for i=1:(length(eulerpath)-1)
        nodein = eulerpath(i);
        nodeout = eulerpath(i+1);
        gedges = table2array(geuler.Edges);
        edgeindx = find(ismember(gedges,[nodein,nodeout],'rows')); % find index of edge to highlight
        if isempty(edgeindx)
            edgeindx = find(ismember(gedges,[nodeout,nodein],'rows'));
        end
        if ~ismember(edgepath,edgeindx(1))
            highlight(pathplot,'Edges',edgeindx(1),'LineWidth',2)
            highlight(pathplot,'Edges',edgeindx(1),'EdgeColor','r')
            highlight(pathplot,eulerpath(i+1),'NodeColor','r')
            edgepath(i) = edgeindx(1);
            pause(pausetime)
            if savevideo
                frame = getframe;
                writeVideo(writerObj3D,frame);
            end
        else
            highlight(pathplot,'Edges',edgeindx(2),'LineWidth',2)
            highlight(pathplot,'Edges',edgeindx(2),'EdgeColor','r')
            highlight(pathplot,eulerpath(i+1),'NodeColor','r')
            edgepath(i) = edgeindx(2);
            pause(pausetime)
            if savevideo
                frame = getframe;
                writeVideo(writerObj3D,frame);
            end
        end
    end
end