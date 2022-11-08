clc
clearvars
close all
addpath("C:\Users\harsh\Documents\GitHub\Bend-Forming\Fabrication Algorithms")
addpath("C:\Users\harsh\Documents\GitHub\Bend-Forming\Mesh Tools")
addpath("C:\Users\harsh\Documents\GitHub\Bend-Forming\Mesh Tools\jsonlab-master")
% objfile = "C:\Users\harsh\Documents\GitHub\Bend-Forming\Exemplar Structures\Teapot\PotLid\Teapot_124Faces_Scaled1.25.obj";
objfile = "C:\Users\harsh\Documents\GitHub\Bend-Forming\Exemplar Structures\Teapot\OneSolid\Teapot_123Faces_Final.obj";
bendpathfile = "C:\Users\harsh\Desktop\TeapotFab.txt";
[facesteapot,posteapotog] = readObj(objfile);
[gteapot,posteapot] = facestograph(facesteapot,posteapotog);
plotgraph(gteapot,posteapot,1,0,[45 45])
[geulerteapot,dupedgesteapot,edgesaddedteapot,lengthaddedteapot,pathteapot] = CPP_Algorithm(gteapot,posteapot);
% plotbendpath(geulerteapot,pathteapot,posteapot,0.1)
% plotbendpath(geulertower,pathteapot,posteapot,0.01,1,20,"C:\Users\harsh\Desktop\Teapot\Teapot_TestPathFast.avi",[90 0])
MachineInstructionsExact(pathteapot,posteapot,bendpathfile,0)
% MachineInstructionsFabrication(pathteapot,posteapot,bendpathfile,1,1,2,0.9)

%% Plot bend path
plotbendpath(geulerteapot,pathteapot,posteapot,0.1)
% plotblacksvg(pathteapot,posteapot,4,[180,-76.6])
% plotbendpatharrows(geulerteapot,pathteapot,posteapot,4,15,'black',[180,-76.6])

%% Test of bend path giving the perfect geometry
[perfnodes, impnodes, curvenodes] = HTM_truss_systematic_random_curved_v2(bendpathfile,0,0,0.5,0,0,0,0,0,0,0,0,0);
plotimperfect_curved(perfnodes,impnodes,curvenodes,1,0)