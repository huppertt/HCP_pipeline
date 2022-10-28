function HCP_WM_lobes(subjid,outfolder)

setenv('FREESURFER_HOME','/disk/HCP/pipeline/external/freesurfer-beta')

% Set Freesurfer SUBJECTS_DIR to subject T1w directory
setenv('SUBJECTS_DIR',fullfile(outfolder,subjid,'T1w'));

% Run Freesurfer lobar WM segmentation on both hemispheres

system(['mri_annotation2label '...
    ' --subject ' subjid ...
    ' --hemi lh --lobesStrict lobes'])

system(['mri_annotation2label '...
    ' --subject ' subjid ...
    ' --hemi rh --lobesStrict lobes'])

% Output as wmparc.lobes.mgz

system(['mri_aparc2aseg --s ' subjid ...
    ' --labelwm --hypo-as-wm --rip-unknown '... 
    ' --volmask --o wmparc.lobes.mgz --ctxseg aparc+aseg.mgz '... 
    '  --annot lobes ']) % --base-offset 200

% Convert to nifti format

system(['mri_convert '...
    ' ' fullfile(outfolder,subjid,'T1w',subjid,'mri','wmparc.lobes.mgz')...
    ' ' fullfile(outfolder,subjid,'T1w','wmparc.lobes.nii.gz')  ])

% Reset Freesurfer SUBJECTS_DIR
setenv('SUBJECTS_DIR','');