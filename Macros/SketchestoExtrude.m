clc
clearvars
fileID = fopen("C:\Users\harsh\Desktop\SketchestoExtrude.txt",'w');

for i=1:173
    fprintf(fileID,'"3DSketch%.0f" ',i);
end

fclose('all');