function HCP_Label_1020(subjid,outfolder,force)

HCProot='/disk/HCP';
if(nargin<2)
    outfolder=fullfile(HCProot,'analyzed');
end

if(nargin<3)
    force=false;
end

HCP_matlab_setenv;

if(exist(fullfile(outfolder,subjid,'T1w',subjid,'bem','10-20.labels'),'file') & ~force)
    return
end

ss=mne_read_bem_surfaces('/home/pkg/software/MNE/share/mne/mne_analyze/fsaverage/fsaverage-inner_skull-bem.fif');
[v,f]=read_surf(fullfile(outfolder,subjid,'T1w',subjid,'bem','inner_skull.surf'));

% These are the values in 
% /home/pkg/software/MNE/share/mne/mne_analyze/fsaverage/fsaverage-fiducials.fif
% It just doesn't make sense have to read each time so I hard coded it
fid =[  -80.6000  -29.1000  -41.3000    1.0000
    1.5000   85.1000  -34.8000    1.0000
   84.4000  -28.5000  -41.3000    1.0000];

% v2=ss.rr*1000;
% v(:,4)=1;
% v2(:,4)=1;
% T=v2\v;

T=importdata(fullfile(outfolder,subjid,'T1w',subjid,'mri','transforms','talairach.xfm'))
T.data(4,4)=1;
T=T.data;


fid2=fid*T;

ss2=mne_read_bem_surfaces(fullfile(outfolder,subjid,'T1w',subjid,'bem',[subjid '-head.fif']));
[k,d]=dsearchn(ss2.rr*1000,fid2(:,1:3));
fid2=ss2.rr(k,:);


tbl=nirs.util.list_1020pts('?');
dig =[tbl.X tbl.Y tbl.Z];

f=dig([2 1 3],:);
dig(:,4)=1;

com=(f(1,:)+f(3,:))/2;
vec = cross(f(2,:)-com,f(1,:)-com);
vec=vec/norm(vec);
lst=[0:.1:100]';
pts=ones(length(lst),1)*com+lst*vec;
[k,d]=dsearchn(dig(:,1:3),pts);
[~,i]=min(d);
f(4,:)=pts(i,:);


f2=fid2*1000;
com=(f2(1,:)+f2(3,:))/2;
vec = cross(f2(2,:)-com,f2(1,:)-com);
vec=vec/norm(vec);
lst=[0:.1:100]';
pts=ones(length(lst),1)*com+lst*vec;
[k,d]=dsearchn(ss2.rr*1000,pts);
[~,i]=min(d);
f2(4,:)=pts(i,:);


f(:,4)=1;
f2(:,4)=1;

 TT=f2\f;
%  fid2*TT = f

% Iterative closest point
for i=1:20;
    rr=ss2.rr*1000;
    rr(:,4)=1;
    rr=rr*TT;  
    
    k=dsearchn(rr(:,1:3),dig(:,1:3));
    TT=TT*(rr(k,:)\dig);
    TT(1:3,1:3)=TT(1:3,1:3)/norm(TT(1:3,1:3));
end
rr=ss2.rr*1000;
p=dig*inv(TT);
k=dsearchn(rr(:,1:3),p(:,1:3));

tbl.X=rr(k,1);
tbl.Y=rr(k,2);
tbl.Z=rr(k,3);


writetable(tbl,fullfile(outfolder,subjid,'T1w',subjid,'bem','10-20.labels'),'FileType','text');


