clc
clearvars
close all
addpath("C:\Users\harsh\Documents\GitHub\Bend-Forming\Fabrication Algorithms")
addpath("C:\Users\harsh\Documents\GitHub\Bend-Forming\Fabrication Algorithms\AnimateFabrication")
addpath("C:\Users\harsh\Documents\GitHub\Bend-Forming\Accuracy Model")

%% INPUT BENDPATH1
bendpathfile = "C:\Users\harsh\Desktop\Test.txt";

%% CALCULATE TIME-DEPENDENT FABRICATION
feedrate = 18000/60; % [mm/s] % using 10000 mm/min according to DI Wire Pro default (max is 10000 mm/min)
bendrate = 18000/60; % [deg/s] % using 10000 deg/min as given by DI Wire Pro default (max is 10000 o/min)
dt = 0.1; % [s] % fixed time step for ODEs 
feedstep = feedrate*dt; % [mm] % make sure amount fed during fixed time step (=fixeddt*feedrate) is very small compared to minimum strut length in the geometry
bendstep = bendrate*dt;

tic;
[nodestructshort, nodestructfull] = CalculateFabvsTime(bendpathfile,feedrate,bendrate,dt);
t1CalculateFabvsTime = toc;

%% ANIMATE FABRICATION VS TIME (without machine)
% tic;
% AnimateFabvsTime(bendpathfile,nodestructfull,nodestructshort,"C:\Users\harsh\Desktop\Test.avi",[20 40],3,3);
% t1AnimateFabvsTime = toc;

%% CALCULATE CM LOCATION AND MOI MATRIX VERSUS TIME BY DISCRETIZING STRUTS WITH POINT MASSES
pointdensity = 1/(feedstep-1); % [points/mm] % make sure I have at least one point per feedstep
rhostrut = 1600; % [kg/m^3] CFRP
doutstrut = 50; % [mm] 5-cm tube
thicknessstrut = 1; % [mm] 1-mm wall thickness
tic
pointmassstructshort = CalculateStructureCMMOIvsTime(nodestructshort,pointdensity,rhostrut,doutstrut,thicknessstrut); % contains CM location and MOI matrix versus time
pointmassstructfull = CalculateStructureCMMOIvsTime(nodestructfull,pointdensity,rhostrut,doutstrut,thicknessstrut);
t2DiscretizeStruts = toc;

%% ANIMATE FABRICATION WITH CM AND MOI
% tic;
% AnimateFabCMMOIvsTime(bendpathfile,nodestructshort,pointmassstructfull,"C:\Users\harsh\Desktop\Test.avi",[0 90],0,0,3,3);
% t3AnimateFab = toc;

%% ADD SPACECRAFT BODY AND FEEDSTOCK SPOOL
spacecraftparams = struct;
spacecraftparams.mass = 30; % [kg]
spacecraftparams.sidelength = 300; % [mm]

feedstockspoolparams = struct;
feedstockspoolparams.mass = pointmassstructfull(end).totalmass; % mass of feedstock spool equal to truss mass [kg]
feedstockspoolparams.diameter = 200; % [mm]
feedstockspoolparams.thickness = 50; % [mm]

tic;
[spacecraftstruct, feedstockspoolstruct] = SpacecraftBlocks(pointmassstructfull,spacecraftparams,feedstockspoolparams);
t4AddSpacecraftBodySpool = toc;

%% CALCULATE COMPOSITE CM WITH SPACECRAFT BODY AND FEEDSTOCK SPOOL
tic;
compCMMOIstruct = CalculateCompCMMOIvsTime(pointmassstructfull,spacecraftstruct,feedstockspoolstruct);
t5CalcCompCMMOI = toc;

%% ANIMATE FABRICATION WITH SPACECRAFT BODY AND FEEDSTOCK SPOOL
tic;
AnimateFabCompCMMOIvsTime(bendpathfile,nodestructshort,pointmassstructfull,spacecraftstruct,feedstockspoolstruct,compCMMOIstruct,"C:\Users\harsh\Desktop\Test.avi",[110,29],0,0,3,3);
t6AnimateFabComp = toc;
