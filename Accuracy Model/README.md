This folder contains algorithms for modeling the accuracy of Bend-Formed structures.
A brief description of important functions is provided below.
Run the "AccuracyModel_BendForming.m" file for an example calculation.

***Modeling imperfect fabrication:***
- KinematicModel_HTM - calculates an imperfect geometry based on systematic and random fabrication defects in feed length, bend/rotate angle, and strut curvature
- curvedstrut_fit - fits a circular arc to the start and endpoints of a strut using a specified transverse offset (using fsolve)

***Outputing imperfect geometry for closing defects in Abaqus:***
- AutocadOutputCurved - converts an imperfect geometry with curved struts into an Autocad script which generates and exports an IGES file (in same units as Matlab, so [mm])
- AutocadOutputCurvedExtraSave - same as AutocadOutputCurved but saves the IGES file at another specified location (useful if you want to store IGES files and not overwrite them during a loop)
- outputMESHseedsize - outputs seed size in [m] for Abaqus to create a mesh, calcualted by dividing the smallest strut into a specified number of elements (usually 20)

***Closing fabrication defects with FIXED DISPLACEMENTS (model described in AML paper):***
- Python script read by Abaqus: "AbaqusFixedDisplacements_Standard" (there are also other scripts called Riks, Standard Riks, and RiksRelax)
- AbaqusFixedDisplacements - uses fixed displacements to close fabricaiton defects in Abaqus with beam elements (B31)
- outputBCdisplacements - outputs a text file of fixed displacements which Abaqus script uses when applying BCs
- outputMPCconstraints - outputs a text file of kinematic coupling constraints which Abaqus script uses when applying constraints at nodes
- OUTPUT is an Abaqus model called "TrussAlignDispStandard" saved in the "AbaqusFiles" folder and two extracted results: 1) Energy required to close defects (i.e. dot product of reaction forces and fixed displacements at all nodes); 2) Maximum Mises stress after closing defects

***Closing fabrication defects with SEQUENTIAL CONNECTORS:***
- AbaqusSequentialConnectors - uses axial connectors (AXIAL in Abaqus) to close fabrication defects. Can specify the order in which to close defects, i.e a sequence of nodes to close sequentially.
- outputAXconnectors - outputs start and end nodes of axial connectors for Abaqus
- outputCLsequence - outputs closing sequence of axial connectors for Aabqus

***Closing fabrication defects with SIMULTANEOUS CONNECTORS:***
- AbaqusAllConnectors - also uses axial connectors to close fabricaiton defects but closes all connector simuntaneously
- outputCLsequenceALL - outputs simultaneous closing sequence of axial connectors for Abaqus

***Closing fabrication defects for TETRAHEDRAL TRUSS (simulations in AML paper):***
- AbaqusFixedDisplacement_Standard_TetraTruss - closes fabrication defects of an imperfect tetrahedral truss using fixed displacements and also outputs 1) deformed coordiantes of top/bottom truss faces, 2) beam forces (NFORSCO) for all beam elements in model
- AbaqusNaturalFrequency_TetraTruss - calcualtes free-free natural frequency of an imperfect tetrahedral truss with a modal analysis in Abaqus
- outputTOPBOTnodes_TetraTruss - outputs the coordinates of top/bottom nodes of the tetrahedral truss from only a list of perfect nodes (does this by rotating the truss until one face is flat on the xy plane)
- SurfacePrecision_TetraTruss - computs RMS surface precision by finding the RMS deviation from best-fit planes to the deformed coordiantes of the top/bottom nodes output by Abaqus

***Plotting functions:***
- plotimperfect_curved - plots imperfect geometry (red) superimposed on perfect geometry (black)
- plotimperfect_figures - same as plotimperfect_curved but removes axes and allows control over line thickness

***Misc functions:***
- feedvsbendlinecount - calculates the total number of feed lines and bend/rotate lines of a given bend path 
- totbendenergy - calculates an estimate of the energy required for bending all angles of a given bend path, assuming a plastic hinge model (i.e. energy of each bend = plastic moment * bend angle)
