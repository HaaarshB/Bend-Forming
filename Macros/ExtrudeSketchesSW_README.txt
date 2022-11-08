The "ExtrudeSketchesSW" Macro extrudes the 3D line sketches created by "LineCoordsMarcoSW" to create a 3D wireframe structure in Solidworks.
For this to work properly, first run the "SketchestoExtrude.m" file to output the names of all 3D sketeches in the Solidwork sketch of the part.
This outputs a text file of the sketch names, which the "ExtrudeSketchesSW" then extrudes individually.