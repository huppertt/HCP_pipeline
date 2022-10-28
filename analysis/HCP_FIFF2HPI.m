function HCP_FIFF2HPI(subjid,outfolder,filename,force)

HCProot='/disk/HCP';
if(nargin<2)
    outfolder=fullfile(HCProot,'analyzed');
end

if(nargin<3)
   files=rdir(fullfile(outfolder,subjid,'MEG*','*-raw.fif'));
   filename={files.name};
end

if(nargin<4)
    force=false;
end

if(~iscellstr(filename))
    filename=cellstr(filename);
end

if(length(filename)>1)
    for i=1:length(filename)
         HCP_FIFF2HPI(subjid,outfolder,cellstr(filename{i}));
    end
    return
end


HCP_matlab_setenv;


[p,f]=fileparts(filename{1});
%f=f(1:strfind(f,'-raw')-1);
filen=fullfile(p,[f '-trans.fif']);
if(exist(filen,'file') & ~force)
    return
end


pts=eeg.io.readFIFFdigpts(filename{1});

t=readtable(fullfile(outfolder,subjid,'T1w',subjid,'bem','10-20.labels'),'FileType','text');
ss=mne_read_bem_surfaces(fullfile(outfolder,subjid,'T1w',subjid,'bem',[subjid '-head-dense.fif']));

[loca,locb]=ismember(t.Name,pts.kind);
lst=find(loca);
xyz=[t.X(loca(lst)) t.Y(loca) t.Z(loca(lst))]
xyz2=[pts.X(locb(lst)) pts.Y(locb(lst)) pts.Z(locb(lst))];


cp = mean(xyz,1);
vec1 = cross(xyz(2,:)-cp,xyz(3,:)-cp);
vec1=vec1/norm(vec1);
pp = ones(8001,1)*cp+[0:.05:400]'*vec1;

[k,d]=dsearchn(pp,ss.rr*1000);
[a,b]=min(d);
xyz(4,:)=ss.rr(b,:)*1000;


cp2 = mean(xyz2,1);
vec2 = cross(xyz2(2,:)-cp2,xyz2(3,:)-cp2);
vec2=vec2/norm(vec2);
pp2 = ones(8001,1)*cp2+[0:.05:400]'*vec2;

[k,d]=dsearchn(pp2,[pts.X pts.Y pts.Z]);
[a,b]=min(d);
xyz2(4,:)=[pts.X(b) pts.Y(b) pts.Z(b)];


xyz(:,4)=1;
xyz2(:,4)=1;
T=xyz2\xyz;
T(3,3)=1;

p = [pts.X pts.Y pts.Z ones(size(pts.X))]*T;

[r,t]=icp(ss.rr'*1000,p(:,[1:3])');

p2=(r * p(:,1:3)' + t*ones(1,size(p,1)))';

T2=[r t];
T2(4,4)=1;

TT=T*T2';
rr=ss.rr*1000;
rr(:,4)=1;
p2(:,4)=1;
for i=1:20;
    [k,dis]=dsearchn(rr(:,1:3),p2(:,1:3));
    TT=TT*(p2\rr(k,:));
    p2=[pts.X pts.Y pts.Z ones(size(pts.X))]*TT;
end



TT(4,1:3)=TT(4,1:3)/1000;


% 
% %ss=mne_read_bem_surfaces('/home/pkg/software/MNE/share/mne/mne_analyze/fsaverage/fsaverage-inner_skull-bem.fif');
% %[v,f]=read_surf(fullfile(outfolder,subjid,'T1w',subjid,'bem','inner_skull.surf'));
% 
% % These are the values in 
% % /home/pkg/software/MNE/share/mne/mne_analyze/fsaverage/fsaverage-fiducials.fif
% % It just doesn't make sense have to read each time so I hard coded it
% fid =[  -80.6000  -29.1000  -41.3000    1.0000
%     1.5000   85.1000  -34.8000    1.0000
%    84.4000  -28.5000  -41.3000    1.0000];
% % 
% % v2=ss.rr*1000;
% % v(:,4)=1;
% % v2(:,4)=1;
% % T=v2\v;v
% 
% T=importdata(fullfile(outfolder,subjid,'T1w',subjid,'mri','transforms','talairach.xfm'))
% T.data(4,4)=1;
% T=T.data;
% 
% fid2=fid*T;
% 
% ss2=mne_read_bem_surfaces(fullfile(outfolder,subjid,'T1w',subjid,'bem',[subjid '-head.fif']));
% [k,d]=dsearchn(ss2.rr*1000,fid2(:,1:3));
% fid2=ss2.rr(k,:);
% 
% % OK, now that I have the fiducials, let's figure out the MRI (coord=5) to HPI
% % (coord=4) registration
% 
% info=fiff_read_meas_info(filename{1});
% dig=horzcat(info.dig.r)'*1000;
% f=dig(1:3,:);
% dig(:,4)=1;
% 
% com=(f(1,:)+f(3,:))/2;
% vec = cross(f(2,:)-com,f(1,:)-com);
% vec=vec/norm(vec);
% lst=[0:.1:100]';
% pts=ones(length(lst),1)*com+lst*vec;
% [k,d]=dsearchn(dig(:,1:3),pts);
% [~,i]=min(d);
% f(4,:)=pts(i,:);
% 
% 
% f2=fid2*1000;
% com=(f2(1,:)+f2(3,:))/2;
% vec = cross(f2(2,:)-com,f2(1,:)-com);
% vec=vec/norm(vec);
% lst=[0:.1:100]';
% pts=ones(length(lst),1)*com+lst*vec;
% [k,d]=dsearchn(ss2.rr*1000,pts);
% [~,i]=min(d);
% f2(4,:)=pts(i,:);
% 
% 
% f(:,4)=1;
% f2(:,4)=1;
% 
%  TT=f2\f;
% %  fid2*TT = f
% 
% % Iterative closest point
% for i=1:20;
%     rr=ss2.rr*1000;
%     rr(:,4)=1;
%     rr=rr*TT;  
%     
%     [k,dis]=dsearchn(rr(:,1:3),dig(:,1:3));
%     TT=TT*(rr(k,:)\dig);
%     TT(1:3,1:3)=TT(1:3,1:3)/norm(TT(1:3,1:3));
% end


[p,f]=fileparts(filename{1});
%f=f(1:strfind(f,'-raw')-1);
filen=fullfile(p,[f '-trans.fif']);

copyfile('/home/pkg/software/MNE/share/mne/mne_analyze/fsaverage/fsaverage-trans.fif',filen);
fid=fiff_open(filen);

while(1)
    cnt=ftell(fid);
    i=fiff_read_tag_info(fid);
    if(i.kind==222);
        
        break;
    end
end
fclose(fid);
fid = fopen(filen,'rb+','ieee-be');
fseek(fid,cnt,-1);

%TT=inv(TT);
% 
% TT(4,1:3)=TT(4,1:3)/1000;
trans.from=4;
trans.to=5;
%trans.trans=inv(T)'*TT';
trans.trans=TT';

fiff_write_coord_trans(fid,trans);
fclose(fid);

return;