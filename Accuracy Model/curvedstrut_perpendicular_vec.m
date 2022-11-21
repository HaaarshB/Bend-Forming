function F = curvedstrut_perpendicular_vec(x,startpoint,endpoint,comptochange,xvecrand)
%% Function for finding a random perpendicular vector to strut tangent, to be used as the direction of the curve offset
% Used with fsolve
struttangent = ((endpoint-startpoint)/norm(endpoint-startpoint))';
xvecrand(comptochange) = x;
F = dot(xvecrand,struttangent); % dot product between two vectors will be zero if they are perpendicular
end