function pos=middlepoints(p1,p2,npoints)
    % Function which returns the coordinates of npoints which lie on a line
    % between points p1 and p2. The list is ordered going from p1 to p2.
    pos = zeros(npoints,3);
    for point=1:npoints
        pos(point,:) = 1/(npoints+1) * ((npoints-(point-1))*p1 + point*p2);
    end
end