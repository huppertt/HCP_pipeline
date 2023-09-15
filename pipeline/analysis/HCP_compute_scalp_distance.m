function HCP_compute_scalp_distance(subjid,rootdir)

HCProot='/disk/HCP';
if(nargin<2)
    rootdir=[HCProot '/analyzed'];
end
HCP_matlab_setenv;

FSfold=fullfile(rootdir,subjid,'T1w',subjid);
MNIfold=fullfile(rootdir,subjid,'MNINonLinear');

if(exist(fullfile(MNIfold,[subjid '.skinthickness.164k_fs_LR.dscalar.dscalar.nii'])))
    return
end

try
copyfile(fullfile(FSfold,'bem','watershed',[subjid '_outer_skin_surface']),fullfile(FSfold,'bem','outer_skin.surf'));
copyfile(fullfile(FSfold,'bem','watershed',[subjid '_outer_skull_surface']),fullfile(FSfold,'bem','outer_skull.surf'));
copyfile(fullfile(FSfold,'bem','watershed',[subjid '_inner_skull_surface']),fullfile(FSfold,'bem','inner_skull.surf'));
copyfile(fullfile(FSfold,'bem','watershed',[subjid '_brain_surface']),fullfile(FSfold,'bem','brain.surf'));
end

[v1,f1]=read_surf(fullfile(FSfold,'bem','outer_skin.surf'));
[v2,f2]=read_surf(fullfile(FSfold,'bem','outer_skull.surf'));
[v3,f3]=read_surf(fullfile(FSfold,'bem','inner_skull.surf'));
[v4,f4]=read_surf(fullfile(FSfold,'bem','brain.surf'));


curdir=pwd;
% 
% cd(fullfile(rootdir,subjid,'T1w','BrainExtraction_FNIRTbased'))
% system('invwarp -w NonlinearReg.nii.gz -o invwarp.nii.gz -r ../T1w_acpc_dc_restore_brain.nii.gz')
% 
% cd(fullfile(rootdir,subjid,'T1w',subjid,'bem'))
% copyfile(fullfile(rootdir,subjid,'T1w','BrainExtraction_FNIRTbased','invwarp.nii.gz'),'invwarp.nii.gz')
% 
% system(['${CARET7DIR}/wb_command -surface-apply-warpfield ' fullfile(rootdir,subjid,'MNINonLinear',subjid) '.R.pial.164k_fs_LR.surf.gii invwarp.nii.gz  R.pial.surf.gii']);
% system(['${CARET7DIR}/wb_command -surface-apply-warpfield ' fullfile(rootdir,subjid,'MNINonLinear',subjid) '.L.pial.164k_fs_LR.surf.gii invwarp.nii.gz  L.pial.surf.gii']);

cd(fullfile(FSfold,'bem'));

copyfile(fullfile(MNIfold,[subjid '.R.pial.164k_fs_LR.surf.gii']),'R.pial.surf.gii');
copyfile(fullfile(MNIfold,[subjid '.L.pial.164k_fs_LR.surf.gii']),'L.pial.surf.gii');

T=dlmread('../mri/c_ras.mat');
dlmwrite('inv_c_ras.mat',inv(T),'delimiter','\t');
system(['${CARET7DIR}/wb_command -surface-apply-warpfield R.pial.surf.gii ../../../MNINonLinear/xfms/acpc_dc2standard.nii.gz R.pial.surf.gii -fnirt '...
    '../../../MNINonLinear/xfms/standard2acpc_dc.nii.gz']);
system(['${CARET7DIR}/wb_command -surface-apply-affine R.pial.surf.gii inv_c_ras.mat R.pial.surf.gii']);
system(['${CARET7DIR}/wb_command -surface-apply-warpfield L.pial.surf.gii ../../../MNINonLinear/xfms/acpc_dc2standard.nii.gz L.pial.surf.gii -fnirt '...
    '../../../MNINonLinear/xfms/standard2acpc_dc.nii.gz']);
system(['${CARET7DIR}/wb_command -surface-apply-affine L.pial.surf.gii inv_c_ras.mat L.pial.surf.gii']);


copyfile(fullfile(MNIfold,[subjid '.R.white.164k_fs_LR.surf.gii']),'R.white.surf.gii');
copyfile(fullfile(MNIfold,[subjid '.L.white.164k_fs_LR.surf.gii']),'L.white.surf.gii');

system(['${CARET7DIR}/wb_command -surface-apply-warpfield R.white.surf.gii ../../../MNINonLinear/xfms/acpc_dc2standard.nii.gz R.white.surf.gii -fnirt '...
    '../../../MNINonLinear/xfms/standard2acpc_dc.nii.gz']);
system(['${CARET7DIR}/wb_command -surface-apply-affine R.white.surf.gii inv_c_ras.mat R.white.surf.gii']);
system(['${CARET7DIR}/wb_command -surface-apply-warpfield L.white.surf.gii ../../../MNINonLinear/xfms/acpc_dc2standard.nii.gz L.white.surf.gii -fnirt '...
    '../../../MNINonLinear/xfms/standard2acpc_dc.nii.gz']);
system(['${CARET7DIR}/wb_command -surface-apply-affine L.white.surf.gii inv_c_ras.mat L.white.surf.gii']);



R=gifti('R.pial.surf.gii');
L=gifti('L.pial.surf.gii');

vr=double(R.vertices);
vl=double(L.vertices);

T1=delaunayn(v1);
T2=delaunayn(v2);
T3=delaunayn(v3);
T4=delaunayn(v4);

[~,skin2oskull]=dsearchn(v1,T1,v2);
[~,skin2iskull]=dsearchn(v1,T1,v3);
[~,skin2brain]=dsearchn(v1,T1,v4);
[~,skin2pialR]=dsearchn(v1,T1,vr);
[~,skin2pialL]=dsearchn(v1,T1,vl);



[~,oskull2iskull]=dsearchn(v2,T2,v3);
[~,oskull2brain]=dsearchn(v2,T2,v4);
[~,oskull2pialR]=dsearchn(v2,T2,vr);
[~,oskull2pialL]=dsearchn(v2,T2,vl);


[~,iskull2brain]=dsearchn(v3,T3,v4);
[~,iskull2pialR]=dsearchn(v3,T3,vr);
[~,iskull2pialL]=dsearchn(v3,T3,vl);

[~,brain2pialR]=dsearchn(v4,T4,vr);
[~,brain2pialL]=dsearchn(v4,T4,vl);



% save as cifti... copy template
a=ft_read_cifti(fullfile(MNIfold,[subjid '.thickness.164k_fs_LR.dscalar.nii']));

fileo=fullfile(MNIfold,[subjid '.braindepth.164k_fs_LR.dscalar.nii']);
a.depth=[skin2pialL; skin2pialR];
ft_write_cifti(fileo,a,'parameter','depth','writesurface',false);

fileo=fullfile(MNIfold,[subjid '.skinthickness.164k_fs_LR.dscalar.nii']);
kl=dsearchn(v2,T2,vl);
kr=dsearchn(v2,T2,vr);
a.depth=[skin2oskull(kl); skin2oskull(kr)];
ft_write_cifti(fileo,a,'parameter','depth','writesurface',false);

fileo=fullfile(MNIfold,[subjid '.skullthickness.164k_fs_LR.dscalar.nii']);
kl=dsearchn(v3,T3,vl);
kr=dsearchn(v3,T3,vr);
a.depth=[oskull2iskull(kl); oskull2iskull(kr)];
ft_write_cifti(fileo,a,'parameter','depth','writesurface',false);

fileo=fullfile(MNIfold,[subjid '.csfthickness.164k_fs_LR.dscalar.nii']);
a.depth=[iskull2pialL; iskull2pialR];
ft_write_cifti(fileo,a,'parameter','depth','writesurface',false);


cd(curdir);