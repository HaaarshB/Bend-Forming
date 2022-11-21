This folder contains fabrication algorithms of Bend-Forming.
A brief description of the important functions is provided below.

***Fabrication functions:***
- CPP_Algorithm - calculates a continuous bend path for a given truss geometry by adding doubled edges and finding an Euler path
- Hierholzer - finds an Euler path through a truss graph (but it needs to be Eulerian, i.e. with at most two nodes with odd degree)
- MakeEulerian - makes a truss graph Eulerian by adding doubled edges until at most two nodes have odd degree
- MachineInstructionsExact - converts a bend path into a list of exact machine instructions (i.e. solely based on geometry of the nodes)
- MachineInstructionsFabrication - converts a bend path into a list of machine instructions slightly optimized for fabrication with a CNC wire bender (i.e. considering radius of each bend and avoiding rotations >170<sup>o</sup> and <10<sup>o</sup>) 

***Plotting functions:***
- plotgraph - plots the truss geometry as a graph with nodes and edges
- plotbendpath - plots a computed bend path through the truss
- plotmultibendpath - plots bend paths for multiple geometries back-to-back
- plotfractionbendpath - plots a fraction of the bend path with green edges
- plotbendpatharrows - displays a computed bend path with arrows on each edge
- plotblacksvg - plots the truss geometry with black edges

***Geometry output functions:***
- AutocadOutput - outputs the truss geometry as a script which can be run in Autocad to generate an IGES file (later used for 
- SolidworksOutput - outputs the truss geometry as a list of nodal coordinates which can be read with a Solidworks Macro to create a 3D sketch

***Misc functions:***
- lengthmasswire - ouputs the length a bend path (i.e. total length of required feedstock) and mass of the truss (default material is 1-mm steel wire)
