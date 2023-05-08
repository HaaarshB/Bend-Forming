function MachinePathCoordinatesCSV(path,pos,filename)
%% Function which outputs a list of coordinates which represent a bend path for a truss
pathcoords = zeros(length(path),3);
for i=1:length(path)
    pathcoords(i,:) = pos(path(i),:);
end
% csvwrite(filename, [pathcoords(:,1), pathcoords(:,2), pathcoords(:,3)])
writematrix(pathcoords,filename)
end