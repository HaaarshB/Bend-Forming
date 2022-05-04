function plotgraph(g,pos,axisbool,nodecoordsbool,viewvec)
%% Plots a truss graph "g" with node coordinates "pos"
    if nargin < 3
        axisbool = 1;
        nodecoordsbool = 1;
        viewvec = 0;
    end
    figure()
    if ~nodecoordsbool
        plot(g, 'XData', pos(:,1), 'YData', pos(:,2), 'ZData', pos(:,3),'LineWidth',1.5,'NodeLabel',{});
    else
        plot(g, 'XData', pos(:,1), 'YData', pos(:,2), 'ZData', pos(:,3), 'NodeLabel', 1:numnodes(g),'LineWidth',1.5);
    end
    axis equal
    if ~axisbool
        set(gcf,'color','w');
        axis off
    else
        xlabel('x')
        ylabel('y')
        zlabel('z')
    end
    if sum(viewvec)~=0
        view(viewvec)
    end
end