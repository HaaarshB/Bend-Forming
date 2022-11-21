clc
close all
clearvars
addpath("C:\Users\harsh\Documents\GitHub\Bend-Forming\Fabrication Algorithms")
addpath("C:\Users\harsh\Documents\GitHub\Bend-Forming\Accuracy Model")
addpath("C:\Users\harsh\Documents\GitHub\Bend-Forming\Accuracy Model\AbaqusFiles\Code\TetrahedralTruss")

%% STEP 1: Load truss geometry with bend path - tetrahedral truss
load("C:\Users\harsh\Documents\GitHub\Bend-Forming\Exemplar Structures\TetrahedralTruss\TetraTruss_Prototype.mat")
bendpathfile = "C:\Users\harsh\Documents\GitHub\Bend-Forming\Exemplar Structures\TetrahedralTruss\AccuracyTest_TetraTruss.txt";
MachineInstructionsExact(heuristicpath,pos,bendpathfile,0)

%% STEP 2: Generate imperfect geometry with fabrication defects
% "dcurve" is strut curvature, i.e. ratio of max transverse offset vs strut length
% "dfeed" is feed length error [mm] % positive means extra length
% "dbend" is bend angle error [o] % positive means more of a bend
% "drotate" is rotate angle error [o]
% Note here the bend and rotate angular errors are separated, but you can keep both the same to approxiamte a global angular error

%% RANDOM FEED LENGTH ERRORS
% Systematic errors
dcurve = 0.03; % dcurve*100 is [%]
dfeed = 0; % [mm]
dbend = 0; % [o]
drotate = 0; % [o]
% Random errors
mucurve = 0;
mufeed = 0; % mean [mm]
mubend = 0; % mean [o]
murotate = 0; % mean [o]
sigcurve = 0;
sigfeed = 0.2; % standard deviation [mm] % corresponds to sigmaL_unitless = 3e-3 in AML paper
sigbend = 0; % standard deviation [o]
sigrotate = 0; % standard deviation [o]

% Compute imperfect geometry with kinematic model
[perfnodes, impnodes, curvenodes, bendpathtxt, randomoffsets] = KinematicModel_HTM(bendpathfile,dcurve,dfeed,dbend,drotate,mucurve,mufeed,mubend,murotate,sigcurve,sigfeed,sigbend,sigrotate,15);
% Plot imperfect geometry superimposed with perfect geometry
plotimperfect_curved(perfnodes,impnodes,curvenodes,1,0)

%% Close fabrication defects in Abaqus with FIXED DISPLACEMENTS (used in AML paper)
% Output RMS surface erros and RMS residual axial load in all members
[outputWRMS, outputPRMS, outputPMEAN, outputSMISES, outputNFORCSO] = AbaqusFixedDisplacements_TetraTruss(perfnodes,impnodes,curvenodes);

%% RANDOM ANGULAR ERRORS
% Systematic errors
dcurve = 0; % dcurve*100 is [%]
dfeed = 0; % [mm]
dbend = 0; % [o]
drotate = 0; % [o]
% Random errors
mucurve = 0;
mufeed = 0; % mean [mm]
mubend = 0; % mean [o]
murotate = 0; % mean [o]
sigcurve = 0;
sigfeed = 0; % standard deviation [mm]
sigbend = 0.2; % standard deviation [o] % corresponds to sigmaL_unitless = 3e-3 in AML paper
sigrotate = 0.2; % standard deviation [o]

% Compute imperfect geometry with kinematic model
[perfnodes, impnodes, curvenodes, bendpathtxt, randomoffsets] = KinematicModel_HTM(bendpathfile,dcurve,dfeed,dbend,drotate,mucurve,mufeed,mubend,murotate,sigcurve,sigfeed,sigbend,sigrotate,15);
% Plot imperfect geometry superimposed with perfect geometry
plotimperfect_curved(perfnodes,impnodes,curvenodes,1,0)

%% Close fabrication defects in Abaqus with FIXED DISPLACEMENTS (used in AML paper)
% Output RMS surface erros and RMS residual axial load in all members
[outputWRMS, outputPRMS, outputPMEAN, outputSMISES, outputNFORCSO] = AbaqusFixedDisplacements_TetraTruss(perfnodes,impnodes,curvenodes);

%% RANDOM STRUT CURVATURE
% Systematic errors
dcurve = 0.03; % dcurve*100 is [%]
dfeed = 0; % [mm]
dbend = 0; % [o]
drotate = 0; % [o]
% Random errors
mucurve = 0;
mufeed = 0; % mean [mm]
mubend = 0; % mean [o]
murotate = 0; % mean [o]
sigcurve = 0;
sigfeed = 0; % standard deviation [mm]
sigbend = 0; % standard deviation [o]
sigrotate = 0; % standard deviation [o]

% Compute imperfect geometry with kinematic model
[perfnodes, impnodes, curvenodes, bendpathtxt, randomoffsets] = KinematicModel_HTM(bendpathfile,dcurve,dfeed,dbend,drotate,mucurve,mufeed,mubend,murotate,sigcurve,sigfeed,sigbend,sigrotate,15);
% Plot imperfect geometry superimposed with perfect geometry
plotimperfect_curved(perfnodes,impnodes,curvenodes,1,0)

%%  Compute natural frequency in Abaqus (used in AML paper)
NatFREQs = AbaqusNaturalFrequency_TetraTruss(perfnodes,impnodes,curvenodes);
