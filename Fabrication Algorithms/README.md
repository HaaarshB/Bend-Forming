This folder contains fabrication algorithms of Bend-Forming.
A brief description of important functions is provided below.

***Fabrication functions:***
- CPP_Algorithm - calculates a continuous bend path for a given truss geometry by adding doubled edges and finding an Euler path
- Fluery - classic 1883 algorithm for finding an Euler path through a graph with <=two nodes w odd degree (works by picking random neighboring nodes)
- Hierholzer - classic 1873 algorithm for finding an Euler path through a graph with <=two nodes w odd degree (works by finding and appending small loops - still random but more efficient than Fluery)
- MakeEulerian - makes a truss graph Eulerian by adding doubled edges until <=two nodes have odd degree
- MachineInstructionsExact - converts a bend path into a list of exact machine instructions solely based on geometry of the nodes (i.e. assuming perfect fabrication and no springback compensation)
- MachineInstructionsFabrication - converts a bend path into a list of machine instructions considering the radius of each bend and avoiding rotations >170<sup>o</sup> and <10<sup>o</sup> (but no springback compensation)

***Plotting functions:***
- plotgraph - plots the truss geometry as a graph with nodes and edges
- plotbendpath - plots a bend path through the truss by highlighting edges in red
- plotbendpathCM - plots a bend path through the truss along with the center of mass (CM) of the fabricated portion
- plotmultibendpath - plots bend paths for multiple geometries back-to-back
- plotfractionbendpath - plots a fraction of the bend path with green edges
- plotbendpatharrows - displays a computed bend path with arrows on each edge
- plotblacksvg - plots the truss geometry with black edges

***Geometry output functions:***
- AutocadOutput - outputs the truss geometry as a script which can be run in Autocad to generate an IGES file (later used for 
- SolidworksOutput - outputs the truss geometry as a list of nodal coordinates which can be read with a Solidworks Macro to create a 3D sketch

***Misc functions:***
- lengthmasswire - ouputs the length a bend path (i.e. total length of required feedstock) and mass of the truss (default material is 1-mm steel wire)
- MachinePathCoordinatesCSV - outputs the bend path as a CSV file of nodal coordinates (X Y Z)
- MachinePathCoordinatesTXT - outputs the bend path as a TXT file of nodal coordinates (X Y Z)
