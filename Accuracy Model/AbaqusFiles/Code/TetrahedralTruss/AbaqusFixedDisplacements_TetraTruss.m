function [outputWRMS, outputPRMS, outputPMEAN, outputSMISES, outputNFORCSO] = AbaqusFixedDisplacements_TetraTruss(perfnodes,impnodes,curvenodes)
% Function which imports imperfect geometry into Abaqus and calculates self-sterss from closing defects
% Calculates self-stress by prescribing fixed displacements from imperfect nodes to the perfect geometry
% Outputs total work to close defects as sum of reaction forces * displacements
% Outputs maximum Von Mises stress from model after alignment and relax steps

    addpath("C:\Users\harsh\Documents\GitHub\Bend-Forming\Accuracy Model\AbaqusFiles\Code");
    addpath("C:\Users\harsh\Documents\GitHub\Bend-Forming\Accuracy Model\AbaqusFiles\Code\TetrahedralTruss")

    %% Check if there are curved struts in the geometry or not
    if nargin < 3
        curvenodes = 0;
    end

    %% Output IGES of perfect and imperfect geometries for AutoCAD
    if isa(curvenodes,'struct')
        AutocadOutputCurved(1:length(impnodes),impnodes,curvenodes,"C:\\Users\\harsh\\Documents\\GitHub\\Bend-Forming\\Accuracy Model\\AbaqusFiles\\Code\\impgeometry");
    else
        AutocadOutput(1:length(impnodes),impnodes,"C:\\Users\\harsh\\Documents\\GitHub\\Bend-Forming\\Accuracy Model\\AbaqusFiles\\Code\\impgeometry");
    end
    system('python "C:\Users\harsh\Documents\GitHub\Bend-Forming\Accuracy Model\AbaqusFiles\Code\CreateTrussIGES.py"');
    
    %% Calculate self-stress from closing defects in Abaqus (with prescribed displacements)
    numelements = 20; % number of beam elements in shortest edge length of geometry
    outputMESHseedsize(numelements,perfnodes,"C:\Users\harsh\Documents\GitHub\Bend-Forming\Accuracy Model\AbaqusFiles\Code\MESHseedsize.txt"); % [m]
    outputMPCconstraints(perfnodes,impnodes,"C:\Users\harsh\Documents\GitHub\Bend-Forming\Accuracy Model\AbaqusFiles\Code\FixedDisplacements\MPCconstraints.txt"); % [m]
    outputBCdisplacements(perfnodes,impnodes,"C:\Users\harsh\Documents\GitHub\Bend-Forming\Accuracy Model\AbaqusFiles\Code\FixedDisplacements\BCdisplacements.txt"); % [m]
    % Output undeformed coordinates of top and bottom faces of truss so Abaqus can output their deformed coordinates
    outputTOPBOTnodes_TetraTruss_v3(perfnodes,impnodes,"C:\Users\harsh\Documents\GitHub\Bend-Forming\Accuracy Model\AbaqusFiles\Code\TetrahedralTruss\TOPBOTnodes.txt"); % [m]
    system('abaqus cae noGUI="C:\Users\harsh\Documents\GitHub\Bend-Forming\Accuracy Model\AbaqusFiles\Code\TetrahedralTruss\AbaqusFixedDisplacements_Standard_TetraTruss.py"');
    
    %% Calculate surface precision from top and bottom nodes
    [RMStop, RMSbottom] = SurfacePrecision_TetraTruss("C:\Users\harsh\Documents\GitHub\Bend-Forming\Accuracy Model\AbaqusFiles\Code\TetrahedralTruss\DeformedCoordsTOP.txt","C:\Users\harsh\Documents\GitHub\Bend-Forming\Accuracy Model\AbaqusFiles\Code\TetrahedralTruss\DeformedCoordsBOTTOM.txt");
    outputWRMS = mean([RMStop,RMSbottom]); % RMS surface error [mm]

    %% Calculate average self-stress in all beam elements
    SMISES = importdata("C:\Users\harsh\Documents\GitHub\Bend-Forming\Accuracy Model\AbaqusFiles\Code\TetrahedralTruss\Smises.txt");
    outputSMISES = [min(abs(SMISES));rms(abs(SMISES));max(abs(SMISES))]; % Von Mises stress in members "" [Pa]

    %% Calculate average forces/bending moments in all beam elements
    NFORCSO = zeros(length(importdata("C:\Users\harsh\Documents\GitHub\Bend-Forming\Accuracy Model\AbaqusFiles\Code\TetrahedralTruss\NFORCSO1.txt")),6);
    outputNFORCSO = zeros(4,6);
    for i=1:6
        NFORCSO(:,i) = importdata("C:\Users\harsh\Documents\GitHub\Bend-Forming\Accuracy Model\AbaqusFiles\Code\TetrahedralTruss\NFORCSO"+num2str(i)+".txt");
        outputNFORCSO(1:4,i) = [min(abs(NFORCSO(:,i))),rms(abs(NFORCSO(:,i))),mean(abs(NFORCSO(:,i))),max(abs(NFORCSO(:,i)))]; % in either [N] or [N*m] % REDO WITH MEAN
    end
    outputPRMS = outputNFORCSO(2,1); % RMS axial force in members after closing defects [N]
    outputPMEAN = outputNFORCSO(3,1); % mean axial force in members after closing defects [N]
end