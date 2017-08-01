
function RealisticDesign_D2D(arModel,ar)

% Create a realistic design with Observables, Time Points, Simulated Data and 10% Errors
% arModel = arStruct of model from biomodels database
% ar = arStruct of Transient function
% Both have to be created/compiled with Setup.m first

%1) Define a realistic sample of Observables out of given model states (direct, scaled, compound measurements possible)
%2) Fit a Transient Function to the observables dynamic (TransientFct.pdf)
%3) Calculate realistic Time Points with time parameters of Transient Function (SuggestedTimePoints.pdf)
%4) Simulate data with mean from model dyanmics and std deviation of 10% (DataPoints.xls)
%5) Save Realistic Design in ar Struct (workspace.mat)

global ar

%% Load model
if(nargin~=2)
    if exist('Results/Biomodel','dir')
        arLoad('Biomodel')
    else
        fprintf('First load biomodel')
        if exist('Results','dir')
        arLoad
        else
            error 'No Model found. Did you compile one?'
        end
    end
    arModel = arDeepCopy(ar);

    if exist('Results/Transient','dir')
        arLoad('Transient')
    else
        fprintf('Load Transient Function')
        arLoad
        if exist('Results','dir')
            arLoad
        else
            error 'No Model found. Did you compile one?'
        end
    end
end

% Assignments
t = arModel.model(1).data(1).tFine;
data = arModel.model(1).data(1).yFineSimu;

% create result folder and remove files from previous run
if ~exist('RealisticDesign','dir')
    mkdir RealisticDesign
end

if exist('RealisticDesign/TransientFit.pdf','file')
delete 'RealisticDesign/TransientFit.pdf'
end
if exist('RealisticDesign/Suggested_Realistic_Data.pdf','file')
delete 'RealisticDesign/Suggested_Realistic_Data.pdf'
end
if exist('RealisticDesign/Observables.xls','file')
delete 'RealisticDesign/Observables.xls'
end


%% State Observables
[y, yNames] = Observables(data, arModel.model.data.y);


%% Convert order of magnitude
[convertt, converty, y] = Magnitude_Conversion(t,y);


%% Fit Transient
Initialize_FitTransient 
ar.config.fiterrors=1;  % ignore errors in the biomodel data file
ar.config.ploterrors=2;
Parameter = zeros(size(y,2),7);
yExpStd = zeros(size(y,2),1);
ar.pExtern = [];
ar.model.data.tExp = t;

for i = 1:size(y,2)
    ar.model.data.yExp = y(:,i);
    if range(arModel.model.data.ystdFineSimu(:,i)) == 0 || isnan(range(arModel.model.data.ystdFineSimu(:,i)))
        ar.model.data.yExpStd = ar.model.data.yExp./10;
        yExpStd(i) = 0.1;
    else
        ar.model.data.yExpStd = arModel.model.data.ystdFineSimu(:,i);
        yExpStd(i) = mean(ar.model.data.yExpStd./ar.model.data.yExp);
    end
    ar.model.data.yNames = arModel.model.data.yNames(i);

    % Fit it!
    arLink(true); 
    arChi2(false);
    arSimu(false, true);
    arFitTransient(2);

    arPlot;
    xlim([min(t)-5 max(t)+5]);
    print -dpsc -append RealisticDesign/TransientFit.ps
    Parameter(i,:) = ar.p;
end
system('ps2pdf RealisticDesign/Transient_Fit.ps');
delete 'RealisticDesign/TransientFit.ps'


%% Get Time Points
Parameter = 10.^(Parameter);
tT = TimePoints(Parameter, convertt);


%% Plot Transient with suggested TimePoints
yExp = nan(size(tT,1),size(tT,2)); 
yStd = nan(size(tT,1),size(tT,2));    

for i = 1:size(tT,2) 
    ar.p = Parameter(i,:);
    ar.model.data.tExp = tT(:,i);
    ar.model.data.yExp = y(:,i)*converty(i);
    arSimuData  
    bounds = DefaultLbUbTransient;
    ar.lb = bounds.lb; ar.ub = bounds.ub;
    ar.p = Parameter(i,:);

    arPlot;
    xlim([min(ar.model.data.tExp) max(ar.model.data.tExp)]);
    print -dpsc -append RealisticDesign/Suggested_Realistic_Data.ps 
    yExp(:,i) = ar.model.data.yExp;
    yStd(:,i) = ones(size(tT,1),1).*yExpStd(i);
end 
system('ps2pdf RealisticDesign/Suggested_Realistic_Data.ps');
delete 'RealisticDesign/Suggested_Realistic_Data.ps'


%% Save it: Write arStruct for later use
ar.model.data.tExp = tT;
ar.model.data.yExp = yExp;
ar.model.data.yExpStd = yExp.*yStd;
ar.model.data.yNames = yNames;
arSave('RealisticDesign')
[~,ws]=fileparts(ar.config.savepath);
movefile(['Results/' ws],'Results\RealisticDesign');
save RealisticDesign/workspace.mat ar

% write nice data table  
WriteDataTable(tT, yNames, yExp);

