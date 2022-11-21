function [EnergytoCloseDefects, MaxMisesStress] = AbaqusFixedDisplacements(perfnodes,impnodes,curvenodes)
% Function which imports imperfect geometry into Abaqus and calculates self-sterss from closing defects
% Calculates self-stress by prescribing fixed displacements from imperfect nodes to the perfect geometry
% Outputs total work to close defects as sum of reaction forces * displacements
% Outputs maximum Von Mises stress from model after alignment and relax steps

    addpath("C:\Users\harsh\Documents\GitHub\Bend-Forming\Accuracy Model\AbaqusFiles\Code");
    addpath("C:\Users\harsh\Documents\GitHub\Bend-Forming\Accuracy Model\AbaqusFiles\Code\FixedDisplacements")

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
    
    %% Calculate self-stress from closing defects in Abaqus (with fixed displacements)
    numelements = 20; % number of beam elements in shortest edge length of geometry
    outputMESHseedsize(numelements,perfnodes,"C:\Users\harsh\Documents\GitHub\Bend-Forming\Accuracy Model\AbaqusFiles\Code\MESHseedsize.txt"); % [m]
    outputMPCconstraints(perfnodes,impnodes,"C:\Users\harsh\Documents\GitHub\Bend-Forming\Accuracy Model\AbaqusFiles\Code\FixedDisplacements\MPCconstraints.txt"); % [m]
    outputBCdisplacements(perfnodes,impnodes,"C:\Users\harsh\Documents\GitHub\Bend-Forming\Accuracy Model\AbaqusFiles\Code\FixedDisplacements\BCdisplacements.txt"); % [m]
    system('abaqus cae noGUI="C:\Users\harsh\Documents\GitHub\Bend-Forming\Accuracy Model\AbaqusFiles\Code\FixedDisplacements\AbaqusFixedDisplacements_Standard.py"');
    % system('abaqus cae noGUI="C:\Users\harsh\Documents\GitHub\Bend-Forming\Accuracy Model\AbaqusFiles\Code\FixedDisplacements\AbaqusFixedDisplacements_Riks.py"');
    % system('abaqus cae noGUI="C:\Users\harsh\Documents\GitHub\Bend-Forming\Accuracy Model\AbaqusFiles\Code\FixedDisplacements\AbaqusFixedDisplacements_StandardRiks.py"');
    
    %% Calculate total energy for closing defects
    disps = abs((perfnodes(2:end,:) - impnodes(2:end,:))) * 1e-3; % [m]
    RFs = abs(load("C:\Users\harsh\Documents\GitHub\Bend-Forming\Accuracy Model\AbaqusFiles\Code\FixedDisplacements\RFatNodes.txt")); % [N]
    EnergytoCloseDefects = sum(sum(disps.*RFs)); % [J]
    
    %% Calculate maximum Mises stress from closing defects
    MaxMisesStress = abs(load("C:\Users\harsh\Documents\Wire Bending\Accuracy Model\AbaqusFiles\Code\FixedDisplacements\MaxMisesStress.txt"))/1e6; % [MPa]

end