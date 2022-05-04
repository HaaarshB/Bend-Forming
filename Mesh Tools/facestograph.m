function [g,possorted] = facestograph(faces,pos)
%% Function which transforms patched surface into a Matlab graph with connectivities
edgepairs = zeros(2,3*size(faces,1));
for i=1:(3*size(faces,1))
    row = ceil(i/3);
    if mod(i,3)==1
        edgepairs(:,i) = [faces(row,1); faces(row,2)];
    elseif mod(i,3)==2
        edgepairs(:,i) = [faces(row,2); faces(row,3)];
    elseif mod(i,3)==0
        edgepairs(:,i) = [faces(row,3); faces(row,1)];
    end
end
edgepairs = sort(edgepairs)';
edgepairs = unique(edgepairs,'rows')';
edgepairscols = edgepairs';

posnew = zeros(size(unique(pos,'rows'),1),3);
% Sort out nodal coordinates
for i=1:size(pos,1)
    [~,indx] = ismember(pos,pos(i,:),'rows');
    allindx = find(indx);
    minindx = min(allindx);
    allindx(1) = [];
    for k=1:length(allindx)
        indxtoreplace = allindx(k);
        edgepairscols(edgepairscols==indxtoreplace) = minindx;
    end
    posnew(minindx,:) = pos(minindx,:);
end

% Get rid of zero rows in position vector
possorted = posnew;
possorted(~any(possorted,2),:) = [];

% Sort edge pair numbers accordingly
edgepairssorted = edgepairscols;
[~,zeroindx] = ismember(posnew,[0,0,0],'rows');
zerorowindx=find(zeroindx);
consecnumstart = [0; find(diff(zerorowindx)>1); numel(zerorowindx)] + 1;
zerorowblocks = mat2cell(zerorowindx', 1, diff(consecnumstart)')'; % creates a list of consecutive indexes with zero rows

sumnumzeros = 0;
for i=1:size(zerorowblocks,1)
    if i~=size(zerorowblocks,1)
        currentblock = [zerorowblocks{i,:}]';
        nextblock = [zerorowblocks{i+1,:}]';
        sumnumzeros = sumnumzeros + length(currentblock);
        indxtochange = currentblock(end):nextblock(1);
        indxtochange(1) = [];
        indxtochange(end) = [];
        for k=1:length(indxtochange)
            workingindx = indxtochange(k);
            edgepairssorted(edgepairssorted==workingindx) = workingindx - sumnumzeros;
        end
    else
        lastblock = [zerorowblocks{i,:}]';
        sumnumzeros = sumnumzeros + length(lastblock);
        workingindx = size(posnew,1);
        edgepairssorted(edgepairssorted==workingindx) = workingindx - sumnumzeros;
    end
end

% Find unique edgepairs to get rid of doubled wires
addindx = 1;
edgepairsunique = zeros(1,2);
for i=1:size(edgepairssorted,1)
    edgetoadd = edgepairssorted(i,:);
    if sum(ismember(edgepairsunique,edgetoadd,'rows'))==0 && sum(ismember(edgepairsunique,flip(edgetoadd),'rows'))==0 % check if edge to add is unique
        edgepairsunique(addindx,:) = edgetoadd;
        addindx = addindx+1;
    end
end

% Make graph
s = edgepairsunique(:,1);
t = edgepairsunique(:,2);
g = graph(s,t);
end