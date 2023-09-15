function HCP_makeIso2Mesh(subjid,outfolder)


HCProot='/disk/HCP';
if(nargin<2)
    outfolder=fullfile(HCProot,'analyzed');
end

HCP_matlab_setenv;  % Sets the FSL, Freesurfer, etc folders 

folder=fullfile(outfolder,subjid,'T1w',subjid,'bem');

if(exist(fullfile(folder,[subjid '-mmc-cfg.mat'])))
    disp([fullfile(folder,[subjid '-mmc-cfg.mat']) ' exists: SKIPPING']);
    return
end

% Head surface
bem=mne_read_bem_surfaces(fullfile(folder,[subjid '-bem.fif']));

for i=1:length(bem)
    bem(i).rr=bem(i).rr*1000;
end
% 
% [v,f]=read_surf('../surf/lh.pial');
% frac=length(bem(1).rr)/length(v);
% [v,f]=meshresample(v,f+1,frac);
% 
% bem(end).rr=v;
% bem(end).tris=f;
% 
% 
% [v,f]=read_surf('../surf/rh.pial');
% frac=length(bem(1).rr)/length(v);
% [v,f]=meshresample(v,f+1,frac);
% 
% bem(end+1).rr=v;
% bem(end).tris=f;

node=bem(1).rr;
elem=bem(1).tris;

regions=[];
for i=2:length(bem)
    [node,elem]=mergemesh(node,elem,bem(i).rr,bem(i).tris);
end
for i=2:length(bem)-1
    regions=[regions; [.5*(bem(i-1).rr+bem(i).rr) (i-1)*ones(size(bem(1).rr,1),1)]];
end
regions=[regions; [.95*bem(end).rr length(bem)*ones(size(bem(end).rr,1),1)]];

% v1=bem(end-1).rr;
% cm=mean(v1);
% v1=(v1-ones(size(v1,1),1)*cm)*.98+ones(size(v1,1),1)*cm;
% 
% v2=bem(end).rr;
% cm=mean(v2);
% v2=(v2-ones(size(v2,1),1)*cm)*.98+ones(size(v2,1),1)*cm;
% 
% regions=[regions; [ v1 length(bem)-1*ones(size(v1,1),1)]];
% regions=[regions; [ v2 length(bem)-1*ones(size(v2,1),1)]];

range=max(node)-min(node);
p0= min(node)-.1*range;
p1= max(node)+.1*range;
keepratio=1;
maxvol=1;
forcebox=0;
holes=[];

% read the fiff source space
src=mne_read_source_spaces(fullfile(outfolder,subjid,'MNINonLinear','waveletJ5',[subjid '-ico5-src.fif']));

node=[node; src(1).rr*1000; src(2).rr*1000];

[node,elem,face]=surf2mesh(node,elem,p0,p1,keepratio,maxvol,regions,holes,forcebox);
[k,d]=dsearchn(node,[src(1).rr*1000; src(2).rr*1000]);

reglab=unique(elem(:,5));

cfg.node=node;
cfg.elem=elem(:,1:4);
cfg.nphoton=1e5;
cfg.elemprop=elem(:,5);
cfg.srcpos=[30 30 0];
cfg.srcdir=[0 0 1];
cfg.srcspace = k;

for i=1:length(reglab)
    cfg.elemprop(find(elem(:,5)==reglab(i)))=i;
end

lambda=690;

cfg.media{1}=nirs.media.tissues.bone(lambda);
cfg.media{2}=nirs.media.tissues.water(lambda);
cfg.media{3}=nirs.media.tissues.brain(lambda,.7,60);

%an N by 4 array, each row specifies [mua, mus, g, n]
cfg.prop(1,:)=[0 0 1 1];
for i=1:length(cfg.media)
    cfg.prop(i+1,:)=[cfg.media{i}.mua cfg.media{i}.mus cfg.media{i}.g(1) cfg.media{i}.ri];
end

cfg.tstart=0;
cfg.tend=5e-9;
cfg.tstep=5e-10;
cfg.debuglevel='TP';

% populate the missing fields to save computation
cfg=mmclab(cfg,'prep');

save(fullfile(folder,[subjid '-mmc-cfg.mat']),'cfg');

