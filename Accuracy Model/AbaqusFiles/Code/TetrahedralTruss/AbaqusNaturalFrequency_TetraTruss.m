function NatFREQs = AbaqusNaturalFrequency_TetraTruss(perfnodes,impnodes,curvenodes)
% Function which imports imperfect geometry into Abaqus and calculates its free-free natural frequencies
% Tailored for tetrahedral truss geometries with depth H and diameter D

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
    system('abaqus cae noGUI="C:\Users\harsh\Documents\GitHub\Bend-Forming\Accuracy Model\AbaqusFiles\Code\TetrahedralTruss\AbaqusNaturalFrequency_TetraTruss.py"');
    
    %% FINAL STEP: Calculate surface precision from top and bottom nodes
    freqfileID = fopen("C:\Users\harsh\Documents\GitHub\Bend-Forming\Accuracy Model\AbaqusFiles\Code\TetrahedralTruss\NatFREQ.txt",'r');
    freqdata = (fscanf(freqfileID,'%f %f \n', [2 Inf]))'; % Top node deformed coordinates: (x,y,z)
    fclose('all');
    NatFREQs = freqdata(:,2);

end