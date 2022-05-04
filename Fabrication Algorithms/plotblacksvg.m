function plotblacksvg(eulerpath,pos,linesize,viewangle)
%% Function to plot truss with black edges

pathpoints = pos(eulerpath,:);
figure()
plot3(pathpoints(:,1),pathpoints(:,2),pathpoints(:,3),'-k','LineWidth',linesize);
%     set(gcf, 'Position',  [100, 100, 500, 475]) % Sets size of figure
set(gca,'XColor','none')
set(gca,'YColor','none')
axis off
axis equal
view(viewangle)

end