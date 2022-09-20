function plotbendpatharrows(geuler,eulerpath,pos,linesize,arrowsize,arrowcolor,viewangle)
%% Function to visualize Euler path for a truss using arrows between the start and end nodes

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
        edgepath(i) = edgeindx(1);
    else
        edgepath(i) = edgeindx(2);
    end
end
digeulerinfo = zeros(length(edgepath),2);
geuleredges = geuler.Edges;
for i=1:length(edgepath)
    edgetoadd = table2array(geuleredges(edgepath(i),:));
    if edgetoadd(1)~=eulerpath(i)
        edgetoadd = flip(edgetoadd);
    end
    digeulerinfo(i,:) = edgetoadd;
end
digeuler = digraph(digeulerinfo(:,1),digeulerinfo(:,2));

% Find edge number labeling to match euler path
edgenums = zeros(length(edgepath),1);
digeuleredges = table2array(digeuler.Edges);
for i=1:length(edgepath)
    [~,edgenums(i)] = ismember(digeuleredges(i,:),digeulerinfo,'rows');
end

% Plot diagraph to represent continuous bend path
%figure()
trussplot = plot(digeuler, 'XData', pos(:,1), 'YData', pos(:,2), 'Zdata', pos(:,3), 'LineWidth',linesize, 'ArrowSize', arrowsize, 'NodeLabel', {}, 'NodeColor', [0 0 0]);
% trussplot = plot(digeuler, 'XData', pos(:,1), 'YData', pos(:,2), 'Zdata', pos(:,3), 'LineWidth',2, 'ArrowSize', 15, 'NodeLabel', {}, 'EdgeLabel',edgenums,'EdgeFontSize',10,'EdgeFontName','Cambria');
highlight(trussplot,[eulerpath(1),eulerpath(end)],'NodeColor','r','MarkerSize',8)
highlight(trussplot,'Edges',1:numedges(digeuler),'EdgeColor',arrowcolor)
set(gcf,'color','w');
axis equal
axis off
view(viewangle)
hold on

end