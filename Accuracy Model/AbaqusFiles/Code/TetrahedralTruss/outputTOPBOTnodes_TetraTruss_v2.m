function outputTOPBOTnodes_TetraTruss_v2(perfnodes,impnodes,filename)
%% Function which outputs top and bottom nodes in tetra truss geometry (to track their deformed coordinates and precision)

% Calculate either height of truss or sidelength of one triangle unit cell
referencelength = norm(perfnodes(2,:)-perfnodes(1,:));
planeztolerance = referencelength/4;

% Check whether a face of the tetrahedral truss is aligned with the xy-plane
sameplanenodecount = 0;
topplanenodesindx = [];
for k = 1:size(perfnodes,1)
    if abs(perfnodes(k,3)) < planeztolerance % if z-value is within ~5 mm off the origin (need this tolerance since I round perfnodes earlier)
        sameplanenodecount = sameplanenodecount + 1;
        topplanenodesindx(sameplanenodecount,1) = k;
    end
end
if sameplanenodecount >= round(size(perfnodes,1)/2,TieBreaker='tozero') % if more than half of the nodes are on the same plane (with some tolerance)
    bottomplanenodesindx = (1:size(perfnodes,1))';
    bottomplanenodesindx(topplanenodesindx) = [];
    topplanenodes = impnodes(topplanenodesindx,:); % find all imperfect nodes on top plane
    bottomplanenodes = impnodes(bottomplanenodesindx,:); % find all imperfect nodes on bottom plane
    % Plot top and bottom nodes to make sure comptutation is correct
    figure()
    plot3(perfnodes(:,1),perfnodes(:,2),perfnodes(:,3),'-k','LineWidth',2)
    hold on
    scatter3(topplanenodes(:,1),topplanenodes(:,2),topplanenodes(:,3),'filled','g')
    scatter3(bottomplanenodes(:,1),bottomplanenodes(:,2),bottomplanenodes(:,3),'filled','b')
    axis equal
    view([-60,0])
else
    % Begin shenanigans to find top and bottom nodes of tetrahedral truss
    % Rotate truss various ways using boundary nodes until I find the right normal vector which results in half of the nodes having roughly the samez-value. These nodes are then the top nodes.
    perfnodesvaried = perfnodes;
    bruteforcenodes = nchoosek(2:size(perfnodes,1),2); % FINDS ALL PERMUTATIONS OF THREE NODES IN PERFECT GEOMETRY
    bruteforcenodes = bruteforcenodes(randperm(size(bruteforcenodes, 1)),:);
    count = 1;
    breakbool = 0;
    while breakbool ~= 1 % want to find normal vector such that half of the furthest nodes have the same z-value, i.e. are on the same plane
        point1 = perfnodes(1,:);
        point2 = perfnodes(bruteforcenodes(count,1),:);
        point3 = perfnodes(bruteforcenodes(count,2),:);
        if norm(point2-point1) > referencelength && norm(point3-point1) > referencelength && norm(point3-point2) > referencelength % ensure all three nodes are far away from each other
            planevec = cross(point2-point1,point3-point1);
            planevecunit = planevec/norm(planevec);
            rotaxis = cross(planevecunit,[0,0,1]);
            rotangle = anglebtw(planevecunit,[0,0,1])*1.1; % rotate slightly more than calculated
            Kmatrix = [0,-rotaxis(3),rotaxis(2);rotaxis(3),0,-rotaxis(1);-rotaxis(2),rotaxis(1),0];
            Rmatrix = eye(3)+sin(rotangle)*Kmatrix+(1-cos(rotangle))*mpower(Kmatrix,2);
            for j=1:size(perfnodes,1)
                perfnodesvaried(j,:) = Rmatrix*perfnodes(j,:)';
            end
            figure()
            plot3(perfnodes(:,1),perfnodes(:,2),perfnodes(:,3),'-k','LineWidth',2)
            axis equal
            view([0 90])
            hold on
            scatter3(point1(:,1),point1(:,2),point1(:,3),'filled','g')
            scatter3(point2(:,1),point2(:,2),point2(:,3),'filled','g')
            scatter3(point3(:,1),point3(:,2),point3(:,3),'filled','g')
            quiver3(0,0,0,30*planevecunit(1),30*planevecunit(2),30*planevecunit(3), 'c','LineWidth',5);
            quiver3(0,0,0,30*rotaxis(1),30*rotaxis(2),30*rotaxis(3), 'b','LineWidth',5);
            plot3(perfnodesvaried(:,1),perfnodesvaried(:,2),perfnodesvaried(:,3),'-k','LineWidth',2)
            hold off
            sameplanenodecount = 0;
            topplanenodesindx = [];
            for k = 1:size(perfnodesvaried,1)
                if abs(perfnodesvaried(k,3)) < planeztolerance % if z-value is within some tolerance off the xy-plane (need this tolerance since I round perfnodes earlier)
                    sameplanenodecount = sameplanenodecount + 1;
                    topplanenodesindx(sameplanenodecount,1) = k;
                end
            end
            if sameplanenodecount >= round(size(perfnodes,1)/2,TieBreaker='tozero')-1 % if half of the nodes are on the same plane (with some tolerance)
                bottomplanenodesindx = (1:size(perfnodes,1))';
                bottomplanenodesindx(topplanenodesindx) = [];
                topplanenodes = impnodes(topplanenodesindx,:); % find all imperfect nodes on top plane
                bottomplanenodes = impnodes(bottomplanenodesindx,:); % find all imperfect nodes on bottom plane
                % Plot top and bottom nodes to make sure comptutation is correct
                figure()
                plot3(perfnodes(:,1),perfnodes(:,2),perfnodes(:,3),'-k','LineWidth',2)
                hold on
                % plot3(perfnodesvaried(:,1),perfnodesvaried(:,2),perfnodesvaried(:,3),'-k','LineWidth',2)
                % quiver3(0,0,0,30*planevecunit(1),30*planevecunit(2),30*planevecunit(3), 'c','LineWidth',5);
                % quiver3(0,0,0,30*rotaxis(1),30*rotaxis(2),30*rotaxis(3), 'b','LineWidth',5);
                scatter3(topplanenodes(:,1),topplanenodes(:,2),topplanenodes(:,3),'filled','g')
                scatter3(bottomplanenodes(:,1),bottomplanenodes(:,2),bottomplanenodes(:,3),'filled','b')
                axis equal
                view([-60,0])
                breakbool = 1; % break out of while loop
            else
                count = count + 1;
            end
        
        else
            count = count + 1;
        end
    end
end

% Write top and bottom nodes in a text file for Abaqus to extract deformed coordinates after anaylsis is finished (to calculate surface precision)
fileID = fopen(filename,'w');
for i=1:size(topplanenodes,1) % first line is all imperfect nodes on first face, not including curved nodes
    if i~=size(topplanenodes,1)
        fprintf(fileID,'%.6f ', topplanenodes(i,1)*1e-3);
        fprintf(fileID,'%.6f ', topplanenodes(i,2)*1e-3);
        fprintf(fileID,'%.6f ', topplanenodes(i,3)*1e-3);
    else
        fprintf(fileID,'%.6f ', topplanenodes(i,1)*1e-3);
        fprintf(fileID,'%.6f ', topplanenodes(i,2)*1e-3);
        fprintf(fileID,'%.6f\n', topplanenodes(i,3)*1e-3);
    end
end
for i=1:size(bottomplanenodes,1) % second line is all imperfect nodes on second face, not including curved nodes
    if i~=size(bottomplanenodes,1)
        fprintf(fileID,'%.6f ', bottomplanenodes(i,1)*1e-3);
        fprintf(fileID,'%.6f ', bottomplanenodes(i,2)*1e-3);
        fprintf(fileID,'%.6f ', bottomplanenodes(i,3)*1e-3);
    else
        fprintf(fileID,'%.6f ', bottomplanenodes(i,1)*1e-3);
        fprintf(fileID,'%.6f ', bottomplanenodes(i,2)*1e-3);
        fprintf(fileID,'%.6f', bottomplanenodes(i,3)*1e-3);
    end
end
fclose('all');

end