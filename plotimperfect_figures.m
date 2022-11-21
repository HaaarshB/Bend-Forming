function plotimperfect_figures(perfnodes,impnodes,curvenodestruct,perfgeombool,nodenumsbool,linewidth,viewangle)
%% Function to plot an imperfect Bend-Formed truss using coordinates of the perfect and imperfect nodes

    % Plot perfect and imperfect geometries
    figure()
    if isa(curvenodestruct,'struct')
        for i=1:(size(impnodes,1)-1)
            curvenodes = curvenodestruct(i).coords;
            p1 = plot3(curvenodes(:,1),curvenodes(:,2),curvenodes(:,3),'r','LineWidth',linewidth);
            hold on
        end
        scatter3(impnodes(:,1),impnodes(:,2),impnodes(:,3),30,'red','filled');
        startcurvenodes = curvenodestruct(1).coords;
        endcurvenodes = curvenodestruct(end).coords;
        scatter3([startcurvenodes(1,1), endcurvenodes(end,1)],[startcurvenodes(1,2), endcurvenodes(end,2)],[startcurvenodes(1,3), endcurvenodes(end,3)],60,'blue','filled');
    else
        p1 = plot3(impnodes(:,1),impnodes(:,2),impnodes(:,3),'-r','LineWidth',linewidth);
        hold on
        % scatter3([impnodes(1,1), impnodes(end,1)],[impnodes(1,2), impnodes(end,2)],[impnodes(1,3), impnodes(end,3)],75,'blue','filled');
    end
    if perfgeombool
        p2 = plot3(perfnodes(:,1),perfnodes(:,2),perfnodes(:,3),'-k','LineWidth',linewidth);
        legend([p1(1), p2(1)], 'Imperfect','Perfect','FontSize',14)
    end
    view(viewangle)
    xlabel('x','FontSize',14)
    ylabel('y','FontSize',14)
    zlabel('z','FontSize',14)
    axis equal
    axis off
    set(gcf,'color','w');
    if nodenumsbool
        for i=1:size(perfnodes,1)
            % text(perfnodes(i,1),perfnodes(i,2),perfnodes(i,3),num2str(i))
            text(impnodes(i,1),impnodes(i,2),impnodes(i,3),num2str(i),'FontSize',12)
        end
    end
    title('Accuracy Model','FontSize',14)

end