function V = Kdecomp(files)

Lall=[];

for i=1:length(files)
    l=load(files(i).name,'K');
    Lall=[Lall l.K];
end
[u,s,v]=svd(Lall,0);

s=diag(s);

nSV=max(find(abs(zscore(diff(s)))>-tinv(0.05,size(Lall,2))/2));

V = u(:,1:nSV)';