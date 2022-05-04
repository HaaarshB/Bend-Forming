function heuristicpath = heuristicpathtrusshoop(ninner,nouter,sidenum)
%% Function calcualtes heursitic bend path for truss hoop (with zero doubles)
% Heuristic path example for ninner=5 and sidenum=2;
% heuristicpath = [5,4,3,2,1,5, 6,1,7,2,8,3,9,4,...
%     10,6,7,8,9,10, 14,9,13,8,12,7,11,6,...
%     15,14,13,12,11,15,  16,11,17,12,18,13,19,14,...
%     20,16];  % for ninner=5 and two bays 
    heuristicpath = [];
    for bay=1:nouter*(sidenum)+1
        if bay==nouter*(sidenum)
            heuristicpath(end+1:end+ninner+1) = [ninner*bay; ((ninner*(bay-1)+1):ninner*bay)'];
            a = ninner-1:-1:1;
            b = ninner*bay-1:-1:(ninner*(bay-1)+1);
            c(1:2:2*numel(a))=a;
            c(2:2:end+1)=b;
            heuristicpath(end+1:end+2*(ninner-1)) = c';
        elseif bay==nouter*(sidenum)+1
            heuristicpath(end+1:end+nouter*(sidenum)+1) = ninner*[1; (nouter*(sidenum):-1:1)']; % last strut around circumference
        elseif mod(bay,2)==1 && bay~=nouter*(sidenum)+1
            heuristicpath(end+1:end+ninner+1) = [(ninner*bay:-1:(ninner*(bay-1)+1))'; ninner*bay];
            a = ninner*bay+1:ninner*(bay+1)-1;
            b = (ninner*(bay-1)+1):ninner*bay-1;
            c(1:2:2*numel(a))=a;
            c(2:2:end+1)=b;
            heuristicpath(end+1:end+2*(ninner-1)) = c';
        elseif mod(bay,2)==0 && bay~=nouter*(sidenum)
            heuristicpath(end+1:end+ninner+1) = [ninner*bay; ((ninner*(bay-1)+1):ninner*bay)'];
            a = ninner*(bay+1)-1:-1:ninner*bay+1;
            b = ninner*bay-1:-1:(ninner*(bay-1)+1);
            c(1:2:2*numel(a))=a;
            c(2:2:end+1)=b;
            heuristicpath(end+1:end+2*(ninner-1)) = c';
        end
        clearvars a b c
    end
    heuristicpath = heuristicpath';
end