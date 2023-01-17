function [g,pos] = hoopcrosssection(rinner, ninner, crossbracing)

%% Coordinates
theta = linspace(0,2*pi,ninner+1); % anglular coordinates of longeron nodes
theta = theta + mod(ninner,2)*pi/2*(1-4/ninner); % rotate nodes if odd number of longerons
theta(end)=[];
pos(1:ninner,:) = [rinner*cos(theta'), 0*ones(size(theta,2),1), rinner*sin(theta')]; % [x,y,z]
if crossbracing
    pos(end+1,:) = [0,0,0];
end

%% Connections
s = (1:ninner)';
t = [2:ninner,1]';

if crossbracing
    s((end+1):(end+ninner)) = (1:ninner)';
    t(end+1:end+ninner) = (ninner+1)*ones(ninner,1);
end

g = graph(s,t);

end