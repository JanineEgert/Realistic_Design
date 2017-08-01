function WriteDataTable( tT, yNames, ysimu, folder_name )
%WRITEDATATABLE Summary of this function goes here
%   Detailed explanation goes here

if(~exist('tT', 'var') || isempty(tT))
    error('No TimePoints in WriteDataTable function')
end
if(~exist('yNames', 'var') || isempty(yNames))
    error('No Observable Names in WriteDataTable function')
end
if(~exist('ysimu', 'var') || isempty(ysimu))
    error('No simulated ObsData in WriteDataTable function')
end
if(~exist('folder_name', 'var') || isempty(folder_name))
    folder_name = '';
end

Data = nan(size(tT,1),size(tT,2)*3);
Text = cell(1,length(yNames)*3);
z=0;

for i = 1:size(tT,2)
    Text{1,i+z} = 't';
    Text{1,i+z+1} = yNames{i};
    Text{1,i+z+2} = [yNames{i} '_std'];
Data(:,i+z) = tT(:,i);
Data(:,i+z+1) = ysimu(:,i);
Data(:,i+z+2) = abs(ysimu(:,i)./10);
z=z+2;
end

Raw = [Text; num2cell(Data)];
% if exist('RealisticDesign/Realistic_Data.xls')
%     delete 'RealisticDesign/Realistic_Data.xls'
% end
xlswrite(['RealisticDesign' folder_name '/DataPoints.xls'],Raw);

end
