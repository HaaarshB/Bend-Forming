This folder contains macros for converting a Matlab graph into a 3D sketch in Solidworks.
All the functions use the output of the "SolidworksOutput.m" function from the Fabrication Algorithms folder.

LineCoordsMarcoSW - Makes ONE 3D sketch in Solidworks from a list of coordinates
LineCoordsMarcoSWSeparateSketches - Makes SEPARATE 3D skteches in Solidworks from a list of coordinates, i.e. one sketch for each line (usually works better than "LineCoordsMarcoSW")
SketchestoExtrude - Outputs a list of sketch names to sweep extrude
ExtrudeSketchesSW - Sweep extrudes a list of 3D sketches using a specified circular cross section
