%normalize to [0 1], each row is an instance
function [out, max_col, min_col]=norm_row(in)
% in=in';
if size(in,1)>1
max_col=max(in,[],2);
min_col=min(in,[],2);
for i = 1:size(in,2)
	in(:,i)=(in(:,i)-min_col)./(max_col-min_col+1e-6);
end
out = in;
else
    out=in;
end
% out=out';