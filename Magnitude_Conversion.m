function [ convertt, converty, y ] = Magnitude_Conversion( t, y)
%MAGNITUDE_CONVERSION 
%   Switch order of magnitude of time in range 0-1000 
%   (if range condition allows, set dtmin > 1)

%   Switch order of magnitude of data in Range >10^-3 
%   or <-10^-3 (if negative sign)


% Magnitude t
convertt = 1;
dtmin = min(diff(t));
if dtmin < 1
    convertt = dtmin;
end
tRange = range(t);
if tRange > 1000
    convertt = tRange/1000;
end

% Magnitude data
converty = ones(size(y,2),1);
for i=1:size(y,2)
        if (max(y(:,i)) < 10^(-3) && min(y(:,i)) > -10^(-3))
            converty(i) = 10.^(floor(log10(range(y(:,i)))));
            y(:,i) = y(:,i)./converty(i); 
        end
end

end
