clc
clearvars
close all
addpath("C:\Users\harsh\Documents\GitHub\Bend-Forming\Fabrication Algorithms")
addpath("C:\Users\harsh\Documents\GitHub\Bend-Forming\Mesh Tools")
addpath("C:\Users\harsh\Documents\GitHub\Bend-Forming\Mesh Tools\jsonlab-master")
objfile = "C:\Users\harsh\Documents\GitHub\Bend-Forming\Exemplar Structures\EiffelTower\EiffelTower_400Faces_Scaled400mm.obj";
bendpathfile = "C:\Users\harsh\Desktop\EiffelTowerPath.txt";
[facestower,postowerog] = readObj(objfile);
[gtower,postower] = facestograph(facestower,postowerog);
plotgraph(gtower,postower,1,0,[45 45])
[geulertower,dupedgestower,edgesaddedtower,lengthaddedtower,pathtower] = CPP_Algorithm(gtower,postower);
plotbendpath(geulertower,pathtower,postower,0.01)
% plotbendpath(geulertower,pathtower,postower,0.01,1,20,"C:\Users\harsh\Desktop\EiffelTower\EiffelTower400mm_TestPathFast.avi",[90 0])
% MachineInstructionsExact(pathtower,postower,bendpathfile,1)
% MachineInstructionsFabrication(pathtower,postower,bendpathfile,1,0,1,1)