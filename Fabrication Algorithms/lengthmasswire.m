function lengthmasswire(path,pos,densitywire,diameterwire)
%% Function for calculating mass of wire structure (only wire, not joints)
% Calculates total mass of wire by summing up the length of each truss segment multiplied by cross-sectional area and density
% Units used: density in kg/m3, diameter in mm, mass in kg
% For welding wire prototypes, use density of 7800 kg/m3 and wire diameter of 0.9 mm
    lengthwire = 0; % m    
    for i=1:(length(path)-1)
        firstcoord = pos(path(i),:); % current node
        secondcoord = pos(path(i+1),:);
        lengthwire = lengthwire + norm(secondcoord-firstcoord)/1000;
    end
    areawire = pi/4*(diameterwire/1000)^2;
    masswire = densitywire*areawire*lengthwire;
    totallength = sprintf('Length of feedstock: %.3f m',lengthwire);
    totalmass = sprintf('Total mass of wire: %.3f kg',masswire);
    disp(totallength);
    disp(totalmass);
end