function trusshoopperimeter = trusshoopperimeterFLAT(Router,Nouter)
%% Function which calculates perimeter of truss hoop using geometry
% Uses equation here: http://mathcentral.uregina.ca/qq/database/qq.09.07/h/lindsay2.html 
% Note this calcualtes the perimeter [m] of the inner polygon if looking at a top view of the hoop
trusshoopperimeter = Router*sqrt(2-2*cos(2*pi/Nouter)) * Nouter*1/1000;
end