function plotfractionbendpath(eulerpath,pos,frac,linesize,viewangle)
%% Function to plot truss with black edges

pathpoints = pos(eulerpath,:);
pathtoplot = round(size(eulerpath,1)*frac);

figure()
if pathtoplot == size(eulerpath,1)
    plot3(pathpoints(:,1),pathpoints(:,2),pathpoints(:,3),'-k','LineWidth',linesize);
else
    plot3(pathpoints(1:pathtoplot,1),pathpoints(1:pathtoplot,2),pathpoints(1:pathtoplot,3),'Color','#00B417','LineWidth',linesize);
    hold on
    plot3(pathpoints((pathtoplot+1):size(eulerpath,1),1),pathpoints((pathtoplot+1):size(eulerpath,1),2),pathpoints((pathtoplot+1):size(eulerpath,1),3),'Color','#000000','LineWidth',linesize*0.5);
end
%     set(gcf, 'Position',  [100, 100, 500, 475]) % Sets size of figure
set(gca,'XColor','none')
set(gca,'YColor','none')
axis off
axis equal
view(viewangle)

end