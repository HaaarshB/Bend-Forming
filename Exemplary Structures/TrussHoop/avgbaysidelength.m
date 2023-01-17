function avgbaysidelength = avgbaysidelength(pos,ninner)
    baysidelength = 0;
    for i=1:ninner
        node1 = pos(i,:);
        node2 = pos(i+ninner,:);
        dist = norm(node2-node1);
        baysidelength = baysidelength + dist;
    end
    avgbaysidelength = baysidelength/ninner;
    avg = sprintf('Average bay side length: %.1f mm',avgbaysidelength);
    disp(avg);
end