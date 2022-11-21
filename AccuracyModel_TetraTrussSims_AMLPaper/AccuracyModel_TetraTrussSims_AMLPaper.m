clc
close all
clearvars
addpath("C:\Users\harsh\Documents\GitHub\Bend-Forming\Fabrication Algorithms")
addpath("C:\Users\harsh\Documents\GitHub\Bend-Forming\Accuracy Model")
addpath("C:\Users\harsh\Documents\GitHub\Bend-Forming\Accuracy Model\AbaqusFiles\Code\TetrahedralTruss")

%% Fabrication defects
% "dcurve" is strut straightness given by nondimensional delta/strutlength
% "dfeed" is strut length tolerance in [mm] % positive means extra length
% "dbend" bend angle tolerance in [o] % positive means more of a bend
% "drotate" rotate angle tolerance in [o]

%% Accuracy of tetrahedral truss
addpath("C:\Users\harsh\Documents\GitHub\Bend-Forming\Exemplar Structures\TetrahedralTruss")
diameter = 1200; % zero ring: 60, one: 180, two: 305, three: 425, four: 550, five: 600, six: 700, seven: 800, eight: 950, nine: 1050, ten: 1200
% diameter as number of rings increases: 61.2372, 183.7117, 306.1862,
% 428.6607, 551.1352, 673.6097, 796.0842, 918.5587, 1041.03314, 1163.5076
depth = 50; % sidelength = 61.23724
sidelength = depth*sqrt(3/2);
FDratio = 0.8;
[gtetra, postetra] = tetrahedraltrussgraph3D(diameter,depth);
% [gtetra, postetra] = parabolictetrahedraltrussgraph3D(FDratio,diameter,depth);
[geulertetra,dupedges,edgesadded,lengthadded,pathtetra] = CPP_Algorithm(gtetra,postetra);
% plotgraph(gtetra,postetra,1,0,[0 90]);
% plotbendpath(geulertetra,pathtetra,postetra,0.2)
bendpathfile = "C:\Users\harsh\Documents\GitHub\Bend-Forming\Accuracy Model\AbaqusFiles\Code\TetrahedralTruss\BendpathFiles\TetraTrussTestPath.txt";
MachineInstructionsExact(pathtetra,postetra,bendpathfile,0)

[perfnodes, impnodes, curvenodes] = KinematicModel_HTM(bendpathfile,0,0,0,0,0,0,0,0,0,0,0,0,25);
plotimperfect_curved(perfnodes,impnodes,curvenodes,1,0)

%% Fabrication defects
% Systematic
dcurve = 0; % ratio of max transverse offset vs strut length 
dfeed = 0;
dbend = 0;
drotate = 0;
% Random
mucurve = 0;
mufeed = 0;
mubend = 0;
murotate = 0;
sigcurve = 0;
sigfeed = 0.2;
sigbend = 0;
sigrotate = 0;

bendpathfile = "C:\Users\harsh\Documents\GitHub\Bend-Forming\Accuracy Model\AbaqusFiles\Code\TetrahedralTruss\BendpathFiles\SevenRingPath2.txt";
[perfnodes, impnodes, curvenodes, bendpathtxt, randomoffsets] = KinematicModel_HTM(bendpathfile,dcurve,dfeed,dbend,drotate,mucurve,mufeed,mubend,murotate,sigcurve,sigfeed,sigbend,sigrotate,25);
plotimperfect_curved(perfnodes,impnodes,curvenodes,1,0)

%% Simulate closing defects by applying fixed displacements to imperfect nodes
tic
[outputWRMS, outputPRMS, outputSMISES, outputNFORCSO] = AbaqusFixedDisplacements_TetraTruss(perfnodes,impnodes,curvenodes);
comptime = toc;
comptime/60 % [min]

%% CONSTANT SIGFEED
Nrings = 1:5; % test five ring sizes
trialnums = 1:5; % run five sims for each ring size
pathnames = ["OneRingPath2.txt","TwoRingPath2.txt","ThreeRingPath2.txt","FourRingPath2.txt","FiveRingPath2.txt","SixRingPath2.txt","SevenRingPath2.txt","EightRingPath2.txt"]; % picked paths with one plane aligned with the xy-plane
RMS_results_sigfeed = struct;
for i=1:length(Nrings)
    ring = Nrings(i);
    for j=1:length(trialnums)
    trialnum = trialnums(j);
    % Systematic errors
    dcurve = 0.03; % ratio of max transverse offset vs strut length 
    dfeed = 0;
    dbend = 0;
    drotate = 0;
    % Random errors
    mucurve = 0;
    mufeed = 0;
    mubend = 0;
    murotate = 0;
    sigcurve = 0;
    sigfeed = 0.2;
    sigbend = 0;
    sigrotate = 0;
    % Calcualte imperfect geometry
    bendpathfile = "C:\Users\harsh\Documents\GitHub\Bend-Forming\Accuracy Model\AbaqusFiles\Code\TetrahedralTruss\BendpathFiles\"+pathnames(ring);
    tic
    [perfnodes, impnodes, curvenodes, bendpathtxt, randomoffsets] = KinematicModel_HTM(bendpathfile,dcurve,dfeed,dbend,drotate,mucurve,mufeed,mubend,murotate,sigcurve,sigfeed,sigbend,sigrotate,25);
    % plotimperfect_curved(perfnodes,impnodes,curvenodes,1,0)
    % Close defects in Abaqus and calculate RMS surface error
    [outputWRMS, outputPRMS, outputPMEAN, outputSMISES, outputNFORCSO] = AbaqusFixedDisplacements_TetraTruss(perfnodes,impnodes,curvenodes);
    comptime = toc;
    RMS_results_sigfeed(length(trialnums)*(i-1)+trialnum).WRMS = outputWRMS; % RMS surface error of tetrahedral truss [mm]
    RMS_results_sigfeed(length(trialnums)*(i-1)+trialnum).PRMS = outputPRMS; % RMS axial force in members after closing defects [N]
    RMS_results_sigfeed(length(trialnums)*(i-1)+trialnum).PMEAN = outputPMEAN; % RMS axial force in members after closing defects [N]
    RMS_results_sigfeed(length(trialnums)*(i-1)+trialnum).SMISESavg = outputSMISES(2)/1e6; % Average Von Mises stress in members "" [MPa]
    RMS_results_sigfeed(length(trialnums)*(i-1)+trialnum).SMISES = outputSMISES; % Mises stress in members "" [Pa]
    RMS_results_sigfeed(length(trialnums)*(i-1)+trialnum).NFORCO = outputNFORCSO; % Forces and moments in members "" [N or N*m]
    RMS_results_sigfeed(length(trialnums)*(i-1)+trialnum).ringnum = ring; % Number of rings
    RMS_results_sigfeed(length(trialnums)*(i-1)+trialnum).comptime = comptime/60; % Time for computation [min]
    % Save workspace for each iteration
    save("C:\Users\harsh\Documents\GitHub\Bend-Forming\Accuracy Model\AccuracyModel_TetraTrussSims_AMLPaper\Diameter\Diameter_sigfeed\Ring"+num2str(ring)+"Run"+num2str(trialnum)+"_25curve.mat");
    end
end
% save("C:\Users\harsh\Documents\GitHub\Bend-Forming\Accuracy Model\AccuracyModel_TetraTrussSims_AMLPaper\Diameter\Diameter_sigfeed_Rings678Num45_RESULTS.mat"); % CHANGE THIS BETWEEN RINGS

%%
close all
clearvars
clc

%% CONSTANT SIGTHETA
Nrings = 1:5; % test five ring sizes
trialnums = 1:5; % run three sims for each ring size
pathnames = ["OneRingPath2.txt","TwoRingPath2.txt","ThreeRingPath2.txt","FourRingPath2.txt","FiveRingPath2.txt","SixRingPath2.txt","SevenRingPath2.txt","EightRingPath2.txt"]; % picked paths with one plane aligned with the xy-plane
RMS_results_sigtheta = struct;
for i=1:length(Nrings)
    ring = Nrings(i);
    for j=1:length(trialnums)
    trialnum = trialnums(j);
    % Systematic errors
    dcurve = 0; % ratio of max transverse offset vs strut length 
    dfeed = 0;
    dbend = 0;
    drotate = 0;
    % Random errors
    mucurve = 0;
    mufeed = 0;
    mubend = 0;
    murotate = 0;
    sigcurve = 0;
    sigfeed = 0;
    sigbend = 0.2;
    sigrotate = 0.2;
    % Calcualte imperfect geometry
    bendpathfile = "C:\Users\harsh\Documents\GitHub\Bend-Forming\Accuracy Model\AbaqusFiles\Code\TetrahedralTruss\BendpathFiles\"+pathnames(ring);
    tic
    [perfnodes, impnodes, curvenodes, bendpathtxt, randomoffsets] = KinematicModel_HTM(bendpathfile,dcurve,dfeed,dbend,drotate,mucurve,mufeed,mubend,murotate,sigcurve,sigfeed,sigbend,sigrotate,10);
    % plotimperfect_curved(perfnodes,impnodes,curvenodes,1,0)
    % Close defects in Abaqus and calculate RMS surface error
    [outputWRMS, outputPRMS, outputPMEAN, outputSMISES, outputNFORCSO] = AbaqusFixedDisplacements_TetraTruss(perfnodes,impnodes,curvenodes);
    comptime = toc;
    RMS_results_sigtheta(length(trialnums)*(i-1)+trialnum).WRMS = outputWRMS; % RMS surface error of tetrahedral truss [mm]
    RMS_results_sigtheta(length(trialnums)*(i-1)+trialnum).PRMS = outputPRMS; % RMS axial force in members after closing defects [N]
    RMS_results_sigtheta(length(trialnums)*(i-1)+trialnum).PMEAN = outputPMEAN; % RMS axial force in members after closing defects [N]
    RMS_results_sigtheta(length(trialnums)*(i-1)+trialnum).SMISESavg = outputSMISES(2)/1e6; % Average Von Mises stress in members "" [MPa]
    RMS_results_sigtheta(length(trialnums)*(i-1)+trialnum).SMISES = outputSMISES; % Mises stress in members "" [Pa]
    RMS_results_sigtheta(length(trialnums)*(i-1)+trialnum).NFORCO = outputNFORCSO; % Forces and moments in members "" [N or N*m]
    RMS_results_sigtheta(length(trialnums)*(i-1)+trialnum).ringnum = ring; % Number of rings
    RMS_results_sigtheta(length(trialnums)*(i-1)+trialnum).comptime = comptime/60; % Time for computation [min]
    % Save workspace for each iteration
    save("C:\Users\harsh\Documents\GitHub\Bend-Forming\Accuracy Model\AccuracyModel_TetraTrussSims_AMLPaper\Diameter\Diameter_sigtheta\Ring"+num2str(ring)+"Run"+num2str(trialnum)+"_25curve.mat");
    end
end
% save("C:\Users\harsh\Documents\GitHub\Bend-Forming\Accuracy Model\AccuracyModel_TetraTrussSims_AMLPaper\Diameter\Diameter_sigtheta_Rings678Num45_RESULTS.mat"); % CHANGE THIS BETWEEN RINGS

%% 
% SMISESavg = zeros(40,1);
% for i=1:40
%     val = RMS_results_sigtheta(:,i).SMISES;
%     SMISESavg(i,1) = val(2);
% end
% SMISESavgMPA = SMISESavg/1e6;

%% FREQUENCY VS DCURVE
Nrings = [3,5,10]; % truss ring sizes for study
trialnums = 1:5; % number of sims for each dcurve value
pathnames = ["OneRingPath2.txt","TwoRingPath2.txt","ThreeRingPath2.txt","FourRingPath2.txt","FiveRingPath2.txt","SixRingPath2.txt","SevenRingPath2.txt","EightRingPath2.txt","NineRingPath1.txt","TenRingPath1.txt"]; % picked paths with one plane aligned with the xy-plane
dcurvevals = 0:0.01:0.05; % strut curvature from 1 to 5 %
FREQ_results = struct;

for ring=1:length(Nrings)
    ringnum = Nrings(ring);
    for i=1:length(dcurvevals)
        for j=1:length(trialnums)
        trialnum = trialnums(j);
        % Systematic errors
        dcurve = dcurvevals(i); % ratio of max transverse offset vs strut length 
        dfeed = 0;
        dbend = 0;
        drotate = 0;
        % Random errors
        mucurve = 0;
        mufeed = 0;
        mubend = 0;
        murotate = 0;
        sigcurve = 0;
        sigfeed = 0.008;
        sigbend = 0;
        sigrotate = 0;
        % Calculate imperfect geometry with given number of nodes along each curved strut
        bendpathfile = "C:\Users\harsh\Documents\GitHub\Bend-Forming\Accuracy Model\AbaqusFiles\Code\TetrahedralTruss\BendpathFiles\"+pathnames(ring);
        tic
        [perfnodes, impnodes, curvenodes] = HTM_truss_systematic_random_curved_v2(bendpathfile,dcurve,dfeed,dbend,drotate,mucurve,mufeed,mubend,murotate,sigcurve,sigfeed,sigbend,sigrotate,10);
        % plotimperfect_curved(perfnodes,impnodes,curvenodes,1,0)
        % Calculate natural frequencies of truss
        NatFREQs = AbaqusNaturalFrequency_TetraTruss(perfnodes,impnodes,curvenodes);
        comptime = toc;
        FREQ_results(length(trialnums)*(i-1)+trialnum).allfreqs = NatFREQs; % [Hz]
        FREQ_results(length(trialnums)*(i-1)+trialnum).freq = NatFREQs(7); % [Hz]
        FREQ_results(length(trialnums)*(i-1)+trialnum).comptime = comptime/60; % [min]
        FREQ_results(length(trialnums)*(i-1)+trialnum).dcurve = dcurve;
        FREQ_results(length(trialnums)*(i-1)+trialnum).Nrings = ringnum;
        % Save workspace for each iteration
        save("C:\Users\harsh\Documents\GitHub\Bend-Forming\Accuracy Model\AccuracyModel_TetraTrussSims_AMLPaper\Frequency_vs_Curve\Ring"+num2str(ringnum)+"\Ring"+num2str(ringnum)+"_Dcurve"+num2str(dcurve)+"Run"+num2str(trialnum)+".mat");
        end
    end
    % save("C:\Users\harsh\Documents\GitHub\Bend-Forming\Accuracy Model\AccuracyModel_TetraTrussSims_AMLPaper\Frequency_vs_Curve\Ring"+num2str(ringnum)+"_RESULTS.mat");
end

%% RE-RUN SPECIFIC SIMULATION - FEED ERROR (for verification or plotting)
ring= 5;
trialnum = 2;
RMS_results_sigfeed = struct;
load("C:\\Users\\harsh\\Documents\\GitHub\\Bend-Forming\\Accuracy Model\\AccuracyModel_TetraTrussSims_AMLPaper\\Diameter\\Diameter_sigfeed\\Ring"+num2str(ring)+"Run"+num2str(trialnum)+"_25curve.mat")
tic
[outputWRMS, outputPRMS, outputPMEAN, outputSMISES, outputNFORCSO] = AbaqusFixedDisplacements_TetraTruss(perfnodes,impnodes,curvenodes);
comptime = toc;
RMS_results_sigfeed(length(trialnums)*(i-1)+trialnum).WRMS = outputWRMS; % RMS surface error of tetrahedral truss [mm]
RMS_results_sigfeed(length(trialnums)*(i-1)+trialnum).PRMS = outputPRMS; % RMS axial force in members after closing defects [N]
RMS_results_sigfeed(length(trialnums)*(i-1)+trialnum).PMEAN = outputPMEAN; % RMS axial force in members after closing defects [N]
RMS_results_sigfeed(length(trialnums)*(i-1)+trialnum).SMISESavg = outputSMISES(2)/1e6; % Average Von Mises stress in members "" [MPa]
RMS_results_sigfeed(length(trialnums)*(i-1)+trialnum).SMISES = outputSMISES; % Mises stress in members "" [Pa]
RMS_results_sigfeed(length(trialnums)*(i-1)+trialnum).NFORCO = outputNFORCSO; % Forces and moments in members "" [N or N*m]
RMS_results_sigfeed(length(trialnums)*(i-1)+trialnum).ringnum = ring; % Number of rings
RMS_results_sigfeed(length(trialnums)*(i-1)+trialnum).comptime = comptime/60; % Time for computation [min]
% Save workspace for each iteration
% save("C:\Users\harsh\Documents\GitHub\Bend-Forming\Accuracy Model\AccuracyModel_TetraTrussSims_AMLPaper\Diameter\Diameter_sigfeed\Ring"+num2str(ring)+"Run"+num2str(trialnum)+"_25curve.mat");

%% RE-RUN SPECIFIC SIMULATION - ANGULAR ERROR (for verification or plotting)
ring= 8;
trialnum = 1;
RMS_results_sigtheta = struct;
load("C:\\Users\\harsh\\Documents\\GitHub\\Bend-Forming\\Accuracy Model\\AccuracyModel_TetraTrussSims_AMLPaper\\Diameter\\Diameter_sigtheta\\Ring"+num2str(ring)+"Run"+num2str(trialnum)+"_25curve.mat")
tic
[outputWRMS, outputPRMS, outputPMEAN, outputSMISES, outputNFORCSO] = AbaqusFixedDisplacements_TetraTruss(perfnodes,impnodes,curvenodes);
comptime = toc;
RMS_results_sigtheta(length(trialnums)*(i-1)+trialnum).WRMS = outputWRMS; % RMS surface error of tetrahedral truss [mm]
RMS_results_sigtheta(length(trialnums)*(i-1)+trialnum).PRMS = outputPRMS; % RMS axial force in members after closing defects [N]
RMS_results_sigtheta(length(trialnums)*(i-1)+trialnum).PMEAN = outputPMEAN; % RMS axial force in members after closing defects [N]
RMS_results_sigtheta(length(trialnums)*(i-1)+trialnum).SMISESavg = outputSMISES(2)/1e6; % Average Von Mises stress in members "" [MPa]
RMS_results_sigtheta(length(trialnums)*(i-1)+trialnum).SMISES = outputSMISES; % Mises stress in members "" [Pa]
RMS_results_sigtheta(length(trialnums)*(i-1)+trialnum).NFORCO = outputNFORCSO; % Forces and moments in members "" [N or N*m]
RMS_results_sigtheta(length(trialnums)*(i-1)+trialnum).ringnum = ring; % Number of rings
RMS_results_sigtheta(length(trialnums)*(i-1)+trialnum).comptime = comptime/60; % Time for computation [min]
% Save workspace for each iteration
% save("C:\Users\harsh\Documents\GitHub\Bend-Forming\Accuracy Model\AccuracyModel_TetraTrussSims_AMLPaper\Diameter\Diameter_sigtheta\Ring"+num2str(ring)+"Run"+num2str(trialnum)+"_25curve.mat");


%% RE-RUN SPECIFIC SIMULATION - NATURAL FREQUENCY (for verification or plotting)
ringnum = 3;
dcurve = 0;
trialnum = 3;
FREQ_results = struct;
load("C:\\Users\\harsh\\Documents\\GitHub\\Bend-Forming\\Accuracy Model\\AccuracyModel_TetraTrussSims_AMLPaper\\Frequency_vs_Curve\\Ring"+num2str(ringnum)+"\\Ring"+num2str(ringnum)+"_Dcurve"+num2str(dcurve)+"Run"+num2str(trialnum)+".mat")
NatFREQs = AbaqusNaturalFrequency_TetraTruss(perfnodes,impnodes,curvenodes);
comptime = toc;
FREQ_results(length(trialnums)*(i-1)+trialnum).allfreqs = NatFREQs; % [mm]
FREQ_results(length(trialnums)*(i-1)+trialnum).freq = NatFREQs(7); % [mm]
FREQ_results(length(trialnums)*(i-1)+trialnum).comptime = comptime/60; % [min]
FREQ_results(length(trialnums)*(i-1)+trialnum).dcurve = dcurve;
FREQ_results(length(trialnums)*(i-1)+trialnum).Nrings = ringnum;
% Save workspace for each iteration
% save("C:\Users\harsh\Documents\GitHub\Bend-Forming\Accuracy Model\AccuracyModel_TetraTrussSims_AMLPaper\Frequency_vs_Curve\Ring"+num2str(ringnum)+"\Ring"+num2str(ringnum)+"_Dcurve"+num2str(dcurve)+"Run"+num2str(trialnum)+".mat");
