function plotbendpathwCM(geuler,eulerpath,pos,pausetime,savevideo,framerate,filename,vidangle)
%% Function which plots bend path on truss graph
    if nargin < 5
        savevideo = 0;
        filename = [];
    end
    if savevideo
        writerObj3D = VideoWriter(filename,'MPEG-4');
        writerObj3D.FrameRate = framerate;
        open(writerObj3D);
        nodelabel = {};
    else
        nodelabel = 1:numnodes(geuler);
    end
    pospath = pos(eulerpath,:);
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
    hold on
    CMplot = scatter3(pospath(1,1),pospath(1,2),pospath(1,3),50,'r','filled');
    if savevideo
        frame = getframe;
        writeVideo(writerObj3D,frame);
    end
    edgepath = zeros(length(eulerpath)-1,1);
    for i=1:(length(eulerpath)-1)
        delete(CMplot)
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
        else
            highlight(pathplot,'Edges',edgeindx(2),'LineWidth',2)
            highlight(pathplot,'Edges',edgeindx(2),'EdgeColor','r')
            highlight(pathplot,eulerpath(i+1),'NodeColor','r')
            edgepath(i) = edgeindx(2);
        end
        hold on
        % Plot center of mass of all nodes in path
        CMnode = [mean(pospath(1:(i+1),1)),mean(pospath(1:(i+1),2)),mean(pospath(1:(i+1),3))];
        CMplot = scatter3(CMnode(1),CMnode(2),CMnode(3),50,'r','filled');
        pause(pausetime)
        % Save in video
        if savevideo
            frame = getframe;
            writeVideo(writerObj3D,frame);
        end
    end
end