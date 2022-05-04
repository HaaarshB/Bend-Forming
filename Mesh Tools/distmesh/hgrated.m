function h=hgrated(p,g,varargin)

h=1+g*sqrt(p(:,1).^2+p(:,2).^2);
% h = min(4*sqrt(sum(p.^2,2))-1,2);
