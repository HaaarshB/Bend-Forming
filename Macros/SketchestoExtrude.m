clc
clearvars
fileID = fopen("C:\Users\harsh\Documents\GitHub\Bend-Forming\Macros\SketchestoExtrude.txt",'w');

for i=1:108
    fprintf(fileID,'"3DSketch%.0f" ',i);
end

fclose('all');