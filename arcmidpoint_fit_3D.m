function F = arcmidpoint_fit_3D(x,startpoint,endpoint,curveoffset)
%% Function for finding midpoint of curved strut between two points with a specified perpendicular offset
% Here fsovle is used to find the x values which satisfy F = 0
% The variables to solve are the three coordinates of the arcmidpoint: (x(1), x(2), x(3))
solvepoint = [x(1),x(2),x(3)];
midpoint = (startpoint + endpoint)/2;
if norm(startpoint) == 0
    planeworigin = [0,0,1];
else
    planeworigin = cross(startpoint,endpoint);
    planeworigin = planeworigin/norm(planeworigin);
end
vecmidtosolvepoint = (solvepoint - midpoint)/norm(solvepoint - midpoint);
% Three equations to solve: 
% (1) Distance from solvepoint to midpoint is equal to dcurve offset
% (2) Solvepoint is equidistant from startpoint and endpoint
% (3) Vector from midpoint to solvepoint is either parallel or perpendicular to normal vector of plane made by startpoint, endpoint, and origin 
firsteq = norm(midpoint-solvepoint) - curveoffset;
secondeq = norm(startpoint-solvepoint)-norm(endpoint-solvepoint);
thirdeq = norm(cross(vecmidtosolvepoint,planeworigin));
% if randi([0,1])
%     thirdeq = dot(startpoint,endpoint);
% else
%     thirdeq = norm(cross(vecmidtosolvepoint,planeworigin));
% end
F = [firsteq, secondeq, thirdeq];

end