clc
clearvars
addpath("C:\Users\harsh\Documents\GitHub\Bend-Forming\Fabrication Algorithms")
addpath("C:\Users\harsh\Documents\GitHub\Bend-Forming\Mesh Tools")
addpath("C:\Users\harsh\Documents\GitHub\Bend-Forming\Mesh Tools\jsonlab-master")
addpath("C:\Users\harsh\Documents\GitHub\Bend-Forming\Exemplar Structures\StanfordBunny\BunnyMeshes")

%% Load low-poly bunny from OBJ file
objfile = "C:\Users\harsh\Documents\GitHub\Bend-Forming\Exemplar Structures\StanfordBunny\BunnyMeshes\BunnyPolygonScaledHalf.obj";
[facesbunny,posbunnyog] = readObj(objfile);
[gbunny,posbunny] = facestograph(facesbunny,posbunnyog);
% plotgraph(gbunny,posbunny)
% plotbendpatharrows(geulerbunny,pathbunny,posbunny,4,15,[94.4 33.5])
% plotblacksvg(pathbunny,posbunny,4,[94.4 33.5])

% [geulerbunny,dupedgesbunny,edgesaddedbunny,lengthaddedbunny,pathbunny] = CPP_Algorithm(gbunny,posbunny);
[geuler,dupedges,edgesadded,lengthadded,eulerpath] = CPP_Algorithm_Fluery_Greedy(gbunny,posbunny);
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
% MachineInstructionsExact(pathbunny,posbunny,"C:\Users\harsh\Desktop\PathBunny.txt")

%% Output path for Solidworks
% SolidworksOutput(pathbunny,posbunny,"C:\Users\harsh\Desktop\bunnySWsketch.txt")

%% Plot bend path
%plotblacksvg(pathbunny,posbunny,4,[94.4,33.5])
plotfractionbendpath(pathbunny,posbunny,0.3,4,[94.4,33.5])
%plotbendpatharrows(geulerbunny,pathbunny,posbunny,4,15,'black',[94.4,33.5])