function HCP_make_MSMall_volume_mapping(subjid,outfolder,force)

if(nargin<2)
    outfolder='/disk/HCP/analyzed';
end

if(nargin<3)
    force = 0;
end

fileOut=fullfile(outfolder,subjid,'T1w',[subjid '_HCP-MMP_atlas.nii.gz']);
if(exist(fileOut)==2 & force == 0)
    disp(['skipping ' subjid]);
    return;
end


disp(['Running MSM-all to FS mapping: ' subjid]);
Hemi='L';
SphereIn =fullfile(outfolder,subjid,'MNINonLinear','fsaverage_LR32k',[subjid '.' Hemi '.sphere.MSMAll_1_d40_WRN.32k_fs_LR.surf.gii']);
SphereOut = fullfile(outfolder,subjid,'T1w',subjid,'surf',[lower(Hemi) 'h.sphere.reg']);
SIn=gifti(SphereIn);
[SOut1.vertices,SOut1.faces]=read_surf(SphereOut); 
T=delaunayn(double(SIn.vertices));
[k1,d]=dsearchn(double(SIn.vertices),T,SOut1.vertices);
nn=length(double(SIn.vertices));

Hemi='R';
SphereIn =fullfile(outfolder,subjid,'MNINonLinear','fsaverage_LR32k',[subjid '.' Hemi '.sphere.MSMAll_1_d40_WRN.32k_fs_LR.surf.gii']);
SphereOut = fullfile(outfolder,subjid,'T1w',subjid,'surf',[lower(Hemi) 'h.sphere.reg']);
SIn=gifti(SphereIn);
[SOut2.vertices,SOut2.faces]=read_surf(SphereOut); 
T=delaunayn(double(SIn.vertices));
[k2,d]=dsearchn(double(SIn.vertices),T,SOut2.vertices);




volumetemplate=load_nii(fullfile(outfolder,subjid,'T1w',subjid,'mri','ribbon.nii.gz'));
[pialL.vertices,pialL.faces]=read_surf(fullfile(outfolder,subjid,'T1w',subjid,'surf','lh.pial')); 
[pialR.vertices,pialR.faces]=read_surf(fullfile(outfolder,subjid,'T1w',subjid,'surf','rh.pial')); 
[whiteL.vertices,whiteL.faces]=read_surf(fullfile(outfolder,subjid,'T1w',subjid,'surf','lh.white')); 
[whiteR.vertices,whiteR.faces]=read_surf(fullfile(outfolder,subjid,'T1w',subjid,'surf','rh.white')); 

T=[volumetemplate.hdr.hist.srow_x;...
    volumetemplate.hdr.hist.srow_y;...
    volumetemplate.hdr.hist.srow_z;...
    [0 0 0 1]];

T2=dlmread(fullfile(outfolder,subjid,'T1w',subjid,'mri','c_ras.mat'));
T2=inv(T2);
nodes1=[whiteL.vertices; whiteR.vertices];
nodes2=[pialL.vertices; pialR.vertices];

lstCtx=find(volumetemplate.img==1);
[xyz(:,1),xyz(:,2),xyz(:,3)]=ind2sub(size(volumetemplate.img),lstCtx);
xyz=xyz-1;  % zero based instead of 1 based;
xyz(:,4)=1;
xyz=xyz*T'*T2';

% I don't know why I need to do this.
nodes1(:,1)=-nodes1(:,1);
nodes2(:,1)=-nodes2(:,1);


TT=delaunayn([nodes1; nodes2]);

[k,d]=dsearchn([nodes1; nodes2],TT,xyz(:,1:3));
k(find(k>length(nodes1)))=k(find(k>length(nodes1)))-length(nodes1);
aparc=zeros(size(volumetemplate.img));
labels=[k1; k2+nn];
aparc(lstCtx)=labels(k);

volumetemplate.img=aparc;

fileOut=fullfile(outfolder,subjid,'T1w',[subjid '_MSMall_mapping.nii.gz']);
disp(['saving ' fileOut]);
save_nii(volumetemplate,fileOut);


% make the Gordan Atlas too
f=fullfile(outfolder,subjid,'MNINonLinear','fsaverage_LR32k',[subjid '.L.CorticalAreas_dil_Final_Final_Areas_Group.32k_fs_LR.dlabel.nii']);
L_MMP=ft_read_cifti(f,'readsurface',false);
f=fullfile(outfolder,subjid,'MNINonLinear','fsaverage_LR32k',[subjid '.R.CorticalAreas_dil_Final_Final_Areas_Group.32k_fs_LR.dlabel.nii']);
R_MMP=ft_read_cifti(f,'readsurface',false);

Labels=[L_MMP.indexmax; R_MMP.indexmax+180];
volumetemplate.img(lstCtx)=Labels(aparc(lstCtx));

fileOut=fullfile(outfolder,subjid,'T1w',[subjid '_HCP-MMP_atlas.nii.gz']);
disp(['saving ' fileOut]);
save_nii(volumetemplate,fileOut);


% 
% % make the DKY Atlas too
% f=fullfile(outfolder,subjid,'MNINonLinear','fsaverage_LR32k',[ subjid '.aparc.32k_fs_LR.dlabel.nii']);
% atlas=ft_read_cifti(f,'readsurface',false);
% 
% volumetemplate.img(lstCtx)=atlas.([lower(subjid) '_aparc'])(aparc(lstCtx));
% fileOut=fullfile(outfolder,subjid,'T1w',[subjid '_aparc_atlas.nii.gz']);
% disp(['saving ' fileOut]);
% save_nii(volumetemplate,fileOut);
% 
% 
% f=fullfile(outfolder,subjid,'MNINonLinear','fsaverage_LR32k',[ subjid '.aparc.a2009s.32k_fs_LR.dlabel.nii']);
% atlas=ft_read_cifti(f,'readsurface',false);
% 
% volumetemplate.img(lstCtx)=atlas.([lower(subjid) '_aparc_a2009s'])(aparc(lstCtx));
% fileOut=fullfile(outfolder,subjid,'T1w',[subjid '_aparc_a2009s_atlas.nii.gz']);
% disp(['saving ' fileOut]);
% save_nii(volumetemplate,fileOut);
