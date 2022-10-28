function HCP_MSMall_volumemap(subjid,outfolder)

if(nargin<2)
    outfolder='/disk/HCP/analyzed';
end

volumetemplate=load_nii(fullfile(outfolder,subjid,'MNINonLinear','ribbon.nii.gz'));

pialL=gifti(fullfile(outfolder,subjid,'MNINonLinear','fsaverage_LR32k',...
    [subjid '.L.pial_MSMAll_2_d40_WRN.32k_fs_LR.surf.gii']));
pialR=gifti(fullfile(outfolder,subjid,'MNINonLinear','fsaverage_LR32k',...
    [subjid '.R.pial_MSMAll_2_d40_WRN.32k_fs_LR.surf.gii']));


wtL=gifti(fullfile(outfolder,subjid,'MNINonLinear','fsaverage_LR32k',...
    [subjid '.L.white_MSMAll_2_d40_WRN.32k_fs_LR.surf.gii']));
wtR=gifti(fullfile(outfolder,subjid,'MNINonLinear','fsaverage_LR32k',...
    [subjid '.R.white_MSMAll_2_d40_WRN.32k_fs_LR.surf.gii']));

T=[volumetemplate.hdr.hist.srow_x;...
    volumetemplate.hdr.hist.srow_y;...
    volumetemplate.hdr.hist.srow_z;...
    [0 0 0 1]];


nodes1=[wtL.vertices; wtR.vertices];
nodes2=[pialL.vertices; pialR.vertices];

lstCtx=find(volumetemplate.img==3 | volumetemplate.img==42);
[xyz(:,1),xyz(:,2),xyz(:,3)]=ind2sub(size(volumetemplate.img),lstCtx);
