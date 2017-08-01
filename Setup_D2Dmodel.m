%% Create *.def
% arImportSBML('BIOMD0000000379','tend',100)

%% Load/compile model from database
arInit;
ar.config.checkForNegFluxes = false;
arLoadModel('BIOMD0000000009');
arLoadData('BIOMD0000000009_data');
arCompileAll;
arPlot
arSave('Biomodel')
[~,ws]=fileparts(ar.config.savepath);
movefile(['Results/' ws],'Results\Biomodel');
fprintf('Biomodel workspace saved to file ./Results/Biomodel/workspace.mat');
arModel = ar;


%% Load/compile Transient function
clear ar
arInit
arLoadModel('Transient');
arLoadData('Transient');
arCompileAll;
arSave('Transient')
[~,ws]=fileparts(ar.config.savepath);
movefile(['Results/' ws],'Results\Transient');
fprintf('transient workspace saved to file ./Results/Transient/workspace.mat');


%% Create Realistic Design
RealisticDesign_D2D(arModel,ar)
