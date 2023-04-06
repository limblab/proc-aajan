function rsq = aajan_rsquared(y,yfit)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
yresid = y - yfit;
SSresid = sum(yresid.^2);
SStotal = (length(y)-1)*var(y);
rsq = 1-SSresid/SStotal;
end

