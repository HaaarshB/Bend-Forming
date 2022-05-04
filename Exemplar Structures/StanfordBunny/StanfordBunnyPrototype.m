clc
clearvars
addpath("C:\Users\harsh\Documents\GitHub\Bend-Forming\Fabrication Algorithms")
addpath("C:\Users\harsh\Documents\GitHub\Bend-Forming\Exemplar Structures\MeshTools")
addpath("C:\Users\harsh\Documents\GitHub\Bend-Forming\Exemplar Structures\MeshTools\jsonlab-master")
addpath("C:\Users\harsh\Documents\GitHub\Bend-Forming\Exemplar Structures\StanfordBunny\BunnyMeshes")

%% Load low-poly bunny from OBJ file
objfile = "C:\Users\harsh\Documents\GitHub\Bend-Forming\Exemplar Structures\StanfordBunny\BunnyPolygonScaledHalf.obj";
[facesbunny,posbunnyog] = readObj(objfile);
[gbunny,posbunny] = facestograph(facesbunny,posbunnyog);
% plotgraph(gbunny,posbunny)
plotgreenarrows(geulerbunny,pathbunny,posbunny,4,15,[105 10])
plotblacksvg(pathbunny,posbunny,4,[105 10])

[geulerbunny,dupedgesbunny,edgesaddedbunny,lengthaddedbunny,pathbunny] = CPP_Algorithm(gbunny,posbunny);
% plotbendpath(geulerbunny,pathbunny,posbunny,0.2)
% plotbendpath(geulerbunny,pathbunny,posbunny,0.2,1,10,"C:\Users\harsh\Desktop\bunnybendpathvideo.avi",[-235,25])
% MachineInstructions(pathbunny,posbunny,"C:\Users\harsh\Desktop\pathbunnytest.txt")

%% Load high-poly bunny from JSON file
% jsonfile = "C:\Users\harsh\Documents\GitHub\Bend-Forming\Exemplar Structures\StanfordBunny\BunnyMeshes\bunny_full_tri_dense.json";
% [posbunny, T, S, m_p] = parse_frame_json(jsonfile);
% gbunny = graph(T(:,1),T(:,2));
% plotgraph(gbunny,posbunny)
% plotgreenarrows(geulerbunny,pathbunny,posbunny,4,15,[105 10])
% plotblacksvg(pathbunny,posbunny,4,[105 10])

% [geulerbunny,dupedgesbunny,edgesaddedbunny,lengthaddedbunny,pathbunny] = CPP_Algorithm(gbunny,posbunny);
% plotbendpath(geulerbunny,pathbunny,posbunny,0.2)
% plotbendpath(geulerbunny,pathbunny,posbunny,0.1,1,10,"C:\Users\harsh\Desktop\Yijiang Trusses\Bunny Truss\BunnyPath.avi",[73.5,21.4])
% MachineInstructions(pathbunny,posbunny,"C:\Users\harsh\Desktop\PathBunny.txt")

%% Output path for Solidworks
% SolidworksOutput(pathbunny,posbunny,"C:\Users\harsh\Desktop\bunnySWsketch.txt")