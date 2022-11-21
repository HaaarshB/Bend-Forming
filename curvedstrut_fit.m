function F = curvedstrut_fit(x,startpoint,endpoint,curveoffset)
%% Function for fitting a circular arc to an imperfect Bend-Formed strut (with a perpendicular offset)
% Here fsovle is used to find the x values which satisfy F = 0. Note x(1) is radius and x(2) is phi.
strutlength = norm(endpoint-startpoint);
F = [strutlength/2 - x(1)*sin(x(2)/2), curveoffset - x(1)*(1-cos(x(2)/2))];
end