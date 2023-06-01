function [g,pos] = FractalTriangle2Dgraph(nunits,sidelength)
%% Creates a graph of a 2D N x N triangular grid
L = sidelength;
H = L*sqrt(3)/2;
% Coordinates of nodes
numnodes = (nunits+1)*(nunits+2)/2;
pos = zeros(numnodes,3);

firstnodex = flipud((0:L/2:(nunits*L/2))');
firstnodey = flipud((0:H:(nunits*H))');
for i=0:nunits
    firstnodenum = i*(i+1)/2+1; % lazy caterer's number
    lastnodenum = (i+1)*(i+2)/2;
    rowxcoords = (firstnodex(i+1,1):L:(firstnodex(i+1,1)+i*L))';
    rowycoords = firstnodey(i+1,1)*ones(size(rowxcoords,1),1);
    pos(firstnodenum:lastnodenum,:) = [rowxcoords,rowycoords,zeros(size(rowxcoords,1),1)];
end

% Connectivity of nodes
connections = [0,0];
for i=1:size(pos,1) % connect all neighbors to form triangular grid
    neighbors = cell2mat(rangesearch(pos,pos(i,:),sidelength*1.1));
    neighbors(1) = [];
    for j=1:length(neighbors)
        neighbor = neighbors(j);
        if sum(ismember(connections,[i,neighbor],'rows'))==0 && sum(ismember(connections,[neighbor,i],'rows'))==0
            connections(end+1,:) = [i,neighbor];
        end
    end
end
connections(1,:)=[];
s = connections(:,1);
t = connections(:,2);
g = graph(s,t);

end