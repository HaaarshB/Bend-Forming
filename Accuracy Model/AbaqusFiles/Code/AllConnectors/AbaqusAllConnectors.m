function [EnergytoCloseDefects, MaxMisesStress] = AbaqusAllConnectors(perfnodes,impnodes,curvenodes)
% Function which imports imperfect geometry into Abaqus and calculates self-sterss from closing defects
% Calculates self-stress by assigning axial connectors between truss nodes and SEQUENTIALLY prescribing zero displacements to them
% Outputs energy to close defects as total work of the connectors and maximum Von Mises stress after all alignment steps

    addpath("C:\Users\harsh\Documents\GitHub\Bend-Forming\Accuracy Model\AbaqusFiles\Code");
    addpath("C:\Users\harsh\Documents\GitHub\Bend-Forming\Accuracy Model\AbaqusFiles\Code\AllConnectors")

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
    
    %% Calculate self-stress from closing defects in Abaqus (with axial connectors)
    numelements = 20; % number of beam elements in shortest edge length of geometry
    outputMESHseedsize(numelements,perfnodes,"C:\Users\harsh\Documents\GitHub\Bend-Forming\Accuracy Model\AbaqusFiles\Code\MESHseedsize.txt"); % [m]
    % Output specs for all axial connector elements; 0.99 specifies how much to close the connectors
    outputAXconnectors(perfnodes,impnodes,0.99,"C:\Users\harsh\Documents\GitHub\Bend-Forming\Accuracy Model\AbaqusFiles\Code\AllConnectors\AXconnectors.txt")
    % Output sequence of closing nodes
    outputCLsequenceALL("C:\Users\harsh\Documents\GitHub\Bend-Forming\Accuracy Model\AbaqusFiles\Code\AllConnectors\CLsequence.txt","C:\Users\harsh\Documents\GitHub\Bend-Forming\Accuracy Model\AbaqusFiles\Code\AllConnectors\AXconnectors.txt")
    system('abaqus cae noGUI="C:\Users\harsh\Documents\GitHub\Bend-Forming\Accuracy Model\AbaqusFiles\Code\AllConnectors\AbaqusAllConnectors_Standard.py"');
    % system('abaqus cae noGUI="C:\Users\harsh\Documents\GitHub\Bend-Forming\Accuracy Model\AbaqusFiles\Code\AllConnectors\AbaqusAllConnectors_StandardRiks.py"');
    
    %% Calculate total energy for closing defects
    CONdisps = abs(load("C:\Users\harsh\Documents\GitHub\Bend-Forming\Accuracy Model\AbaqusFiles\Code\AllConnectors\CONdisps.txt")); % [m]
    CONforces = abs(load("C:\Users\harsh\Documents\GitHub\Bend-Forming\Accuracy Model\AbaqusFiles\Code\AllConnectors\CONforces.txt")); % [N]
    EnergytoCloseDefects = sum(CONforces.*CONdisps); % [J]

    %% Calculate maximum Mises stress from closing defects
    MaxMisesStress = abs(load("C:\Users\harsh\Documents\Wire Bending\Accuracy Model\AbaqusFiles\Code\AllConnectors\MaxMisesStress.txt"))\1e6; % [MPa]

end