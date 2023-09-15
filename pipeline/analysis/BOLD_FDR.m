
cd ~/Box/HCP/analyzed/

f=[rdir('HCP*/MNINonLinear/Results/BOLD_REST*/BOLD_REST*PA.nii.gz');...
    rdir('HCP*/MNINonLinear/Results/BOLD_REST*/BOLD_REST*AP.nii.gz')];
for i=1:length(f)
    disp(['loading (' num2str(i) ' of ' num2str(length(f)) ') ' f(i).name]);
    s{i,1}=f(i).name(1:min(strfind(f(i).name,'/')-1));
    p=fileparts(f(i).name);
    m=load_nii(fullfile(p,'brainmask_fs.2.0.nii.gz'));
    lst=find(m.img>0);
    n=load_nii(f(i).name);
    n2=reshape(n.img,prod(size(m.img)),size(n.img,4));
    BOLD{i,1}=n2(lst,:);
end

niter=1E4;
for iter=1:niter
    disp(iter)
    idx=randi(length(BOLD),2,1);
    ii=randi(size(BOLD{idx(1)},1),2,1);
    jj=randi(size(BOLD{idx(2)},1),2,1);
    a=BOLD{idx(1)}(ii,:);
    b=BOLD{idx(2)}(jj,:);
    a=a-mean(a,2)*ones(1,size(a,2));
    b=b-mean(b,2)*ones(1,size(b,2));
    n=min(size(b,2),size(a,2));
    a=a(:,1:n)';
    b=b(:,1:n)';
    [r,p]=corrcoef(a(:,1),b(:,1));
    TN(iter,1)=r(1,2); TN(iter,2)=p(1,2);
    [r,p]=corrcoef(a(:,1),a(:,2));
    TP(iter,1)=r(1,2); TP(iter,2)=p(1,2);
    a=nirs.math.innovations(a,16);
    b=nirs.math.innovations(b,16);
    [r,p]=corrcoef(a(:,1),b(:,1));
    TNi(iter,1)=r(1,2); TNi(iter,2)=p(1,2);
    [r,p]=corrcoef(a(:,1),a(:,2));
    TPi(iter,1)=r(1,2); TPi(iter,2)=p(1,2);
end


T=[zeros(niter,1);ones(niter,1)];
[tp,fp,th]=nirs.testing.roc(T,[TN(:,2); TP(:,2)]);
figure(1); hold on;
plot(fp, tp,'b');
figure(2); hold on;
plot(th,fp,'b');
[tp,fp,th]=nirs.testing.roc(T,[TNi(:,2); TPi(:,2)]);
figure(1); hold on;
plot(fp, tp,'r');
figure(2); hold on;
plot(th,fp,'r');