function [y, yNames] = Observables( data, name, folder_name )
%OBSERVABLES Define Observables
%   Detailed explanation goes here

if(~exist('data', 'var') || isempty(data))
    error('No data in Observable function')
end
if(~exist('name', 'var') || isempty(name))
    error('No State Names in Observable function')
end
if(~exist('folder_name', 'var') || isempty(folder_name))
    folder_name = '';
end

Const = 0; Constants = ''; Sta = 0; States = '';
for i=2:size(data,2)
    if (range(data(:,i))/max(data(:,i)) < 1 || isnan(range(data(:,i))/max(data(:,i))))
        Const = [Const i];
        Constants = [Constants name(i)];
    else
        Sta = [Sta i];
        States = [States name(i)];
    end
end
Sta(1) = []; Const(1) = [];

% frequency of direct, relative, compound measurement of observables
ns = length(States); nabs=0; nr=0;nc=0;
while ceil(nabs+nr+nc) < 0.25*ns || floor(nabs+nr+nc) > 0.61*ns  % Number of observables should be in interval 25-61% of states (interval: 2 standard deviations)
nabs = max(0,round(ns*(0.18+randn*0.22)));
nr = max(0,round(ns*(0.23+randn*0.20)));
nc = max(0,round(ns*(0.06+randn*0.11)));
end

% Which states are Observables
Oabs = randperm(ns,nabs);
Or = randperm(ns,nr);
Oc = randperm(ns,nc);
Oc2 = randperm(ns,nc);

% Write obs in matrix/file
y = nan(size(data,1),length(Oabs)+length(Or)+length(Oc));
yNames = cell(length(Oabs)+length(Or)+length(Oc),1);
for i= 1:length(Oabs)
    y(:,i) = data(:,Sta(Oabs(i)));
    yNames(i) = States(Oabs(i));
end
for i = 1:length(Or)
    y(:,i+length(Oabs)) = data(:,Sta(Or(i)));
    yNames(i+length(Oabs)) = strcat(States(Or(i)),' scaled');
end
for i = 1:length(Oc)
    y(:,i+length(Oabs)+length(Or)) = data(:,Sta(Oc(i)))+data(:,Sta(Oc2(i)));
    yNames(i+length(Oabs)+length(Or)) = strcat(States(Oc(i)),' + ', States(Oc2(i)));
end
if isempty(yNames)
    [y, yNames] = Observables( data, name, folder_name );
end
xlswrite(['RealisticDesign' folder_name '/Observables.xls'],yNames);

end

