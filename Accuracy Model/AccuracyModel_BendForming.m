clc
close all
clearvars
addpath("C:\Users\harsh\Documents\GitHub\Bend-Forming\Fabrication Algorithms")
addpath("C:\Users\harsh\Documents\GitHub\Bend-Forming\Accuracy Model")

%% STEP 1: Load truss geometry with bend path - Stanford bunny
load("C:\Users\harsh\Documents\GitHub\Bend-Forming\Exemplary Structures\StanfordBunny\20220316bunnyworkspace.mat")
bendpathfile = "C:\Users\harsh\Documents\GitHub\Bend-Forming\Exemplary Structures\StanfordBunny\AccuracyTest_BunnyPath.txt";
MachineInstructionsExact(pathbunny,posbunny,bendpathfile,0)

%% STEP 2: Generate imperfect geometry with fabrication defects
% "dcurve" is strut curvature, i.e. ratio of max transverse offset vs strut length
% "dfeed" is feed length error [mm] % positive means extra length
% "dbend" is bend angle error [o] % positive means more of a bend
% "drotate" is rotate angle error [o]
% Note here the bend and rotate angular errors are separated, but you can keep both the same to approxiamte a global angular error

% Systematic errors
dcurve = 0.03; % dcurve*100 is [%]
dfeed = 10; % [mm]
dbend = 0; % [o]
drotate = 0; % [o]
% Random errors
mucurve = 0;
mufeed = 0; % mean [mm]
mubend = 0; % mean [o]
murotate = 0; % mean [o]
sigcurve = 0;
sigfeed = 0; % standard deviation [mm]
sigbend = 0.25; % standard deviation [o]
sigrotate = 0.25; % standard deviation [o]
% Compute imperfect geometry with kinematic model
[perfnodes, impnodes, curvenodes, bendpathtxt, randomoffsets] = KinematicModel_HTM(bendpathfile,dcurve,dfeed,dbend,drotate,mucurve,mufeed,mubend,murotate,sigcurve,sigfeed,sigbend,sigrotate,15);
% Plot imperfect geometry superimposed with perfect geometry
plotimperfect_curved(perfnodes,impnodes,curvenodes,1,0)

%% STEP 3: Close fabrication defects in Abaqus with FIXED DISPLACEMENTS - OPTION 1 (used in AML paper)
addpath("C:\Users\harsh\Documents\GitHub\Bend-Forming\Accuracy Model\AbaqusFiles\Code\FixedDisplacements")
[EnergytoCloseDefects, MaxMisesStress] = AbaqusFixedDisplacements(perfnodes,impnodes,curvenodes); % [J], [MPa]

%% Close fabrication defects in Abaqus with SEQUENTIAL CONNECTORS - OPTION 2
% addpath("C:\Users\harsh\Documents\GitHub\Bend-Forming\Accuracy Model\AbaqusFiles\Code\SequentialConnectors")
% CLsequence = 1:numnodes(geulerbunny);
% [EnergytoCloseDefects, MaxMisesStress] = AbaqusSequentialConnectors(perfnodes,impnodes,curvenodes,CLsequence); % [J], [MPa]

%% Close fabrication defects in Abaqus with ALL SIMULTANEOUS CONNECTORS - OPTION 3
% addpath("C:\Users\harsh\Documents\GitHub\Bend-Forming\Accuracy Model\AbaqusFiles\Code\AllConnectors")
% [EnergytoCloseDefects, MaxMisesStress] = AbaqusAllConnectors(perfnodes,impnodes,curvenodes); % [J], [MPa]
