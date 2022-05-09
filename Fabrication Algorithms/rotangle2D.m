function [xrot,yrot] = rotangle2D(x,y,theta)
% rotates coordinates counterclockwise by an angle theta in radians

rot11 = repmat(cos(theta),length(x),1);
rot12 = repmat(-sin(theta),length(y),1);
rot21 = repmat(sin(theta),length(x),1);
rot22 = repmat(cos(theta),length(y),1);

xrot = rot11.*x + rot12.*y;
yrot = rot21.*x + rot22.*y;

end