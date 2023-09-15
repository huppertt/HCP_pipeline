function HCP_WMH_analysis(subjid,outfolder)

if(nargin<2)
    outfolder='/disk/HCP/analyzed';
end

HCP_matlab_setenv;

FLAIR=fullfile(outfolder,subjid,'T2FLAIR',[subjid '_3T_T2FLAIR_acpc.nii.gz']);
HiRES=fullfile(outfolder,subjid,'T1w','T1w_acpc.nii.gz');

% STEP 1 
% #1. creates WMHv3 folder which will contain processed data for each scan
% #2. copies required files into "destination": to_copy_subj (subject-specific)
% #3. registers mask_ICV_auto to FLAIR space (for N4 correction)
% #4. creates required masks from Freesurfer segmentation & registers them to FLAIR space:
% #WM mask for whole brain (step03_extract_wmh.m will look for WMH only within this mask)
% #(WM mask excludes CER & Brainstem, and includes subcortical regions to help capture WMH around ventricles)
% #cerebellar WM mask (used to normalize intensity of WM in rest of brain, as CER is known to have few WMH)

setenv('SUBJECTS_DIR',fullfile(outfolder,subjid,'T1w'));
setenv('PATH',[getenv('PATH') ':' getenv('FREESURFER_HOME') filesep 'fsfast' filesep 'bin']);
setenv('PATH',[getenv('PATH') ':' getenv('FREESURFER_HOME') filesep 'mni' filesep 'bin']);


%  #get WM+Vents mask from FS seg --> into fs_dir
%     get_fs_mask(wm_vents_mask_withcer, subjID, scanID)
fs_seg= fullfile(getenv('SUBJECTS_DIR'),subjid,'mri','aseg.mgz');
mask= fullfile(outfolder,subjid,'T2FLAIR','WM+Vents+Subcort_mask_withcer+brainstem');
system(['mri_binarize --i ' fs_seg ' --ctx-wm --ventricles --subcort-gm --o ' mask '.mgz']);
system(['mri_convert -i ' mask '.mgz -rl ' FLAIR ' -rt nearest -o ' mask '.nii']);

%     get_fs_mask(cer_and_brainstem_mask, subjID, scanID)  #get_fs_mask(whole_cerebellum_mask, subjID, scanID)
mask= fullfile(outfolder,subjid,'T2FLAIR','Cerebellum_mask');
system(['mri_binarize --i ' fs_seg ' --match 6 7 8 45 46 47 --o ' mask '.mgz']);
system(['mri_convert -i ' mask '.mgz -rl ' FLAIR ' -rt nearest -o ' mask '.nii']);

%     remove_cer_and_brainstem_from_mask(wm_vents_mask_withcer, wm_vents_mask, subjID, scanID)     #remove_cer_from_wm_vents_mask(subjID, scanID)
mask1= fullfile(outfolder,subjid,'T2FLAIR','WM+Vents+Subcort_mask_withcer+brainstem.nii');
mask2= fullfile(outfolder,subjid,'T2FLAIR','Cerebellum_mask.nii');
mask3= fullfile(outfolder,subjid,'T2FLAIR','WM+Vents+Subcort_mask_nocer_nobrainstem.nii');
system(['fslmaths ' mask1 ' -sub ' mask2 ' -thr 1 -bin ' mask3]);


%     get_fs_mask(cerebellar_wm_mask, subjID, scanID)
mask4= fullfile(outfolder,subjid,'T2FLAIR','CerebellarWM_mask');
system(['mri_binarize --i ' fs_seg ' --match 7 46 --o ' mask4 '.mgz']);
system(['mri_convert -i ' mask4 '.mgz -rl ' FLAIR ' -rt nearest -o ' mask4 '.nii']);


%     #register mask from FS space to FLAIR space --> into wmh_dir

mask1=[mask1 '.nii'];
mask2=[mask2 '.nii'];
mask3=[mask3 '.gz'];
mask4=[mask4 '.nii'];


for thr=1:.5:4
    GPN_SeedSelector_singlesub(FLAIR,mask4,mask4,mask3,thr);
end



