function HCP_atlas_surface_to_volume_conversion(subjid,outfolder)
if(nargin<2)
    outfolder='/disk/HCP/analyzed';
end
HCP_matlab_setenv
cd(fullfile(outfolder, subjid, 'MNINonLinear','fsaverage_LR32k'))

fL=fullfile(outfolder,'HCP201','MNINonLinear','fsaverage_LR32k','HCP201.L.CorticalAreas_dil_Final_Final_Areas_Group.32k_fs_LR.dlabel.nii');
fR=fullfile(outfolder,'HCP201','MNINonLinear','fsaverage_LR32k','HCP201.R.CorticalAreas_dil_Final_Final_Areas_Group.32k_fs_LR.dlabel.nii');

c=ft_read_cifti(fL);
g=gifti;
g.cdata=int32(c.indexmax);
save(g,fullfile(outfolder, subjid, 'MNINonLinear','fsaverage_LR32k',[subjid '.L.CorticalAreas_dil_Final_Final_Areas_Group.32k_fs_LR.gii']));

c=ft_read_cifti(fR);
g=gifti;
g.cdata=int32(c.indexmax)+180;
save(g,fullfile(outfolder, subjid, 'MNINonLinear','fsaverage_LR32k',[subjid '.R.CorticalAreas_dil_Final_Final_Areas_Group.32k_fs_LR.gii']));


% Label a volume for the R hemisphere
system(['${CARET7DIR}/wb_command -label-to-volume-mapping '...
' ' fullfile(outfolder, subjid, 'MNINonLinear','fsaverage_LR32k',[subjid '.R.CorticalAreas_dil_Final_Final_Areas_Group.32k_fs_LR.gii'])... % Metric file (ROI labels)
' ' fullfile(outfolder, subjid, 'MNINonLinear','fsaverage_LR32k', [subjid '.R.midthickness_MSMAll_1_d40_WRN.32k_fs_LR.surf.gii'])...  % Surface to use coordinates from (midthickness)
' ' fullfile(outfolder, subjid, 'MNINonLinear','T1w_restore.nii.gz')...                             % Volume file in the desired output volume space (T1w_restore)
' ' fullfile('HCP-MMP_R_labels.nii.gz')...                                                             % Outfile name
' -ribbon-constrained '...
' ' fullfile(outfolder, subjid, 'MNINonLinear','fsaverage_LR32k',[subjid '.R.white_MSMAll_1_d40_WRN.32k_fs_LR.surf.gii'])...         % Inner surface
' ' fullfile(outfolder, subjid, 'MNINonLinear','fsaverage_LR32k',[subjid '.R.pial_MSMAll_1_d40_WRN.32k_fs_LR.surf.gii'])...           % Outer surface
])

% Label the volume for the L hemisphere
system(['${CARET7DIR}/wb_command -label-to-volume-mapping '...
' ' fullfile(outfolder, subjid, 'MNINonLinear','fsaverage_LR32k',[subjid '.L.CorticalAreas_dil_Final_Final_Areas_Group.32k_fs_LR.gii'])... % Metric file (ROI labels)
' ' fullfile(outfolder, subjid, 'MNINonLinear','fsaverage_LR32k', [subjid '.L.midthickness_MSMAll_1_d40_WRN.32k_fs_LR.surf.gii'])...  % Surface to use coordinates from (midthickness)
' ' fullfile(outfolder, subjid, 'MNINonLinear','T1w_restore.nii.gz')...                             % Volume file in the desired output volume space (T1w_restore)
' ' fullfile('HCP-MMP_L_labels.nii.gz')...                                                             % Outfile name
' -ribbon-constrained '...
' ' fullfile(outfolder, subjid, 'MNINonLinear','fsaverage_LR32k',[subjid '.L.white_MSMAll_1_d40_WRN.32k_fs_LR.surf.gii'])...         % Inner surface
' ' fullfile(outfolder, subjid, 'MNINonLinear','fsaverage_LR32k',[subjid '.L.pial_MSMAll_1_d40_WRN.32k_fs_LR.surf.gii'])...           % Outer surface
])


% Combine L and R volume labels (NOTE: What to do about overlap?)
system(['fslmaths '...
' ' fullfile(outfolder, subjid, 'MNINonLinear','fsaverage_LR32k','HCP-MMP_L_labels.nii.gz')...
' -max '...
' ' fullfile(outfolder, subjid, 'MNINonLinear','fsaverage_LR32k','HCP-MMP_R_labels.nii.gz')...
' ' fullfile(outfolder, subjid, 'MNINonLinear','fsaverage_LR32k','HCP-MMP_labels.nii.gz')...
])

% Warp to ACPC native space for use with 
system(['applywarp'...
' --ref=' fullfile(outfolder,subjid,'T1w','T1w_acpc_dc.nii.gz')...
' --in='  fullfile(outfolder, subjid, 'MNINonLinear','fsaverage_LR32k','HCP-MMP_labels.nii.gz')...
' --warp=' fullfile(outfolder,subjid,'MNINonLinear','xfms', 'standard2acpc_dc.nii.gz')...
' --out=' fullfile(outfolder, subjid, 'T1w','HCP-MMP_labels_acpc.nii.gz')...
' --interp=nn'
]);