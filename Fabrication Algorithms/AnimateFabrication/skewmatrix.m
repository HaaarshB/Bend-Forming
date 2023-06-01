function vskew = skewmatrix(x)
% Conerts a 3x1 vector into a 3x3 skew matrix 
vskew=[0 -x(3) x(2); x(3) 0 -x(1); -x(2) x(1) 0];
end