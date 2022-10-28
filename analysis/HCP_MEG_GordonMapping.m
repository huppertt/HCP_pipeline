function HCP_MEG_GordonMapping(subjid)

outfolder='/disk/HCP/analyzed';

InL=fullfile(outfolder,subjid,'MNINonLinear','fsaverage_LR32k',[subjid '.L.sphere.MSMAll_2_d40_WRN.32k_fs_LR.surf.gii']);
InR=fullfile(outfolder,subjid,'MNINonLinear','fsaverage_LR32k',[subjid '.R.sphere.MSMAll_2_d40_WRN.32k_fs_LR.surf.gii']);

OutL=fullfile(outfolder,subjid,'MNINonLinear','waveletJ5',[subjid '.L.sphere.surf.gii']);
OutR=fullfile(outfolder,subjid,'MNINonLinear','waveletJ5',[subjid '.R.sphere.surf.gii']);

IL=gifti(InL);
OL=gifti(OutL);
kL=dsearchn(IL.vertices,OL.vertices);

IR=gifti(InR);
OR=gifti(OutR);
kR=dsearchn(IR.vertices,OR.vertices);

file='/disk/HCP/pipeline/templates/HCP_S900_GroupAvg_v1/Gordon333.32k_fs_LR.dlabel.nii';
c=ft_read_cifti(file);
lstL=find(c.brainstructure==1);
lstR=find(c.brainstructure==2);

labels = c.x333cort([lstL(kL); lstR(kR)]);

fL=rdir(fullfile(outfolder,subjid,'MEG*','*-prep.CORTEX_LEFT.surf.gii'));
fR=rdir(fullfile(outfolder,subjid,'MEG*','*-prep.CORTEX_RIGHT.surf.gii'));

L=gifti(fL(1).name);
R=gifti(fR(1).name);


ROI.LeftSurface.vertices=L.vertices;
ROI.LeftSurface.faces=L.faces;
ROI.LeftSurface.x333cort=c.x333cort(lstL(kL));
ROI.RightSurface.vertices=R.vertices;
ROI.RightSurface.faces=R.faces;
ROI.RightSurface.x333cort=c.x333cort(lstR(kR));
ROI.labels=readtable('/disk/HCP/pipeline/templates/HCP_S900_GroupAvg_v1/Gordon333_Key.txt','Delimiter','\t');

save(fullfile(outfolder,subjid,'scripts',[subjid '_MEG_Gordon333Mapping.mat']),'-STRUCT','ROI');