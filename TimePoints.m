function tT = TimePoints( p, convertt, folder_name )
%TIMEPOINTS Summary of this function goes here
%   p: Parameters on normal scale

if(~exist('p', 'var') || isempty(p))
    error('No parameters in TimePoint function')
end
if(~exist('convertt', 'var') || isempty(convertt))
    convertt = 1;
end
if(~exist('folder_name', 'var') || isempty(folder_name))
    folder_name = '';
end

p(~any(p,2),:) = [];
p(:,3:4) = log10(p(:,3:4)/convertt);

    T = 1.76 + 0.15*p(:,3) + 0.24*p(:,4) -0.03*p(:,3).*p(:,4);
    n = ceil(10.^(1.04 -0.07*p(:,3) + 0.06*p(:,4) -0.01*p(:,3).*p(:,4)));

tT=nan(max(n),length(T));
for k=1:length(T)
    tT(1:ceil(n(k)),k)=logspace(0,T(k),n(k))-1;
end

tT = round(tT*convertt,1);
tT(tT>1) = round(tT(tT>1)/5,1)*5;
tT(tT>10) = round(tT(tT>10)/50,1)*50;

xlswrite(['RealisticDesign' folder_name '/TimePoints.xls'],tT);
    
    
end

