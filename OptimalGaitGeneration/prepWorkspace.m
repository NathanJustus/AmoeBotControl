folder = fileparts(which(mfilename));
ks = strfind(folder,'\');
folder = folder(1:ks(end)-1);

addpath([folder,'\DataExtraction']);
addpath([folder,'\DataExtraction\DataFiles']);
addpath([folder,'\OptimalGaitGeneration']);
addpath([folder,'\OptimalGaitGeneration\DataFiles']);
addpath([folder,'\OptimalGaitGeneration\Animations']);

clear folder ks