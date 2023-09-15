function HCP_make_dconn_DSI(subjid,J,outfolder)


HCProot='/disk/HCP';
if(nargin<3)
    outfolder=fullfile(HCProot,'analyzed');
end

if(nargin<2 || isempty(J))
    J=5;
end


HCP_matlab_setenv;


p=fullfile(outfolder,subjid,'MNINonLinear',['waveletJ' num2str(J)]);
if(exist(p)~=7)
    disp(['Wavelet folder does not exist: CREATING']);
    disp(p);
    HCP_makeMNIsourcespace(subjid,J,outfolder);
end


dsi=fullfile(outfolder,subjid,'T1w','Diffusion',[subjid '_dsistudio.trk']);	

Rsurf=gifti(fullfile(p,[subjid '.R.midthickness_MSMSulc.surf.gii']));
Lsurf=gifti(fullfile(p,[subjid '.L.midthickness_MSMSulc.surf.gii']));


Rsurf=gifti(fullfile(p,[subjid '.R.white_MSMSulc.surf.gii']));
Lsurf=gifti(fullfile(p,[subjid '.L.white_MSMSulc.surf.gii']));



fid    = fopen(dsi, 'r');


header.id_string                 = fread(fid, 6, '*char')';
header.dim                       = fread(fid, 3, 'short')';
header.voxel_size                = fread(fid, 3, 'float')';
header.origin                    = fread(fid, 3, 'float')';
header.n_scalars                 = fread(fid, 1, 'short')';
header.scalar_name               = fread(fid, [20,10], '*char')';
header.n_properties              = fread(fid, 1, 'short')';
header.property_name             = fread(fid, [20,10], '*char')';
header.vox_to_ras                = fread(fid, [4,4], 'float')';
header.reserved                  = fread(fid, 444, '*char');
header.voxel_order               = fread(fid, 4, '*char')';
header.pad2                      = fread(fid, 4, '*char')';
header.image_orientation_patient = fread(fid, 6, 'float')';
header.pad1                      = fread(fid, 2, '*char')';
header.invert_x                  = fread(fid, 1, 'uchar');
header.invert_y                  = fread(fid, 1, 'uchar');
header.invert_z                  = fread(fid, 1, 'uchar');
header.swap_xy                   = fread(fid, 1, 'uchar');
header.swap_yz                   = fread(fid, 1, 'uchar');
header.swap_zx                   = fread(fid, 1, 'uchar');
header.n_count                   = fread(fid, 1, 'int')';
header.version                   = fread(fid, 1, 'int')';
header.hdr_size                  = fread(fid, 1, 'int')';

iTrk = 1;
for iTrk=1:header.n_count
    pts = fread(fid, 1, 'int');
    tracks(iTrk).nPoints = pts;
    tracks(iTrk).matrix  = fread(fid, [3+header.n_scalars, tracks(iTrk).nPoints], '*float')';
    disp(iTrk);
end

fclose(fid)


starts=zeros(length(tracks),3); 
ends=starts; 
lengths=zeros(length(tracks),1); 

for i=1:length(tracks); 
    starts(i,:)=tracks(i).matrix(1,:); 
    ends(i,:)=tracks(i).matrix(end,:);
    lengths(i)=sum((sum((diff(tracks(i).matrix,[],1)).^2,2)).^0.5);
    disp(i);
end;


starts(:,4)=1;
ends(:,4)=1;
for i=1:3; 
    starts(:,i)=starts(:,i)-header.dim(i)/2; 
    ends(:,i)=ends(:,i)-header.dim(i)/2; 
end;
starts=starts*header.vox_to_ras;
ends=ends*header.vox_to_ras;

v=double([Lsurf.vertices; Rsurf.vertices]);
T=delaunayn(v);
[ks,ds]=dsearchn(v,T,starts(:,1:3));
[ke,de]=dsearchn(v,T,ends(:,1:3));

lst=find(ds>10 | de>10 & lengths>20);
ks(lst)=[];
ke(lst)=[];

Dconn.adj=zeros(length(v),length(v));
lst=sub2ind(size(Dconn.adj),ks,ke);
lst2=sub2ind(size(Dconn.adj),ke,ks);
for i=1:length(lst)
    Dconn.adj(lst(i))=Dconn.adj(lst(i))+1;
    Dconn.adj(lst2(i))=Dconn.adj(lst2(i))+1;
end

