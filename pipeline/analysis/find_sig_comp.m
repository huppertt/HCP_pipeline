function ncom = find_sig_comp(s,alpha)
% This function returns the number of statistically significant eigen
% values
% 
% North G, Bell T, Cahalan R, Moeng F. Sampling errors in the 
% estimation of empirical orthogonal functions. Mon Weather Rev. 1982;110:699–706. 

if(nargin<2)
    alpha=.05;
end

s=s/s(1);

N=length(s);

ds = s*(2/N)^.5;
t=(s(1:end-1)-s(2:end))./(ds(1:end-1).*2+ds(2:end).^2).^0.5;
t=max(t,eps);
p=2*tcdf(-abs(t),N);
ncom=max(find(p<alpha));