function redoPET(subjid)
c=pwd;
HCP_matlab_setenv;

% setenv('FREESURFER_HOME','/disk/HCP/pipeline/external/freesurfer-beta');
% system(['source ' getenv('FREESURFER_HOME') filesep 'SetUpFreeSurfer.sh']);
% setenv('PATH',[getenv('PATH') ':' getenv('FREESURFER_HOME') filesep 'bin']);
% setenv('PATH',[getenv('PATH') ':' getenv('FREESURFER_HOME') filesep 'fsfast' filesep 'bin']);
% setenv('PATH',[getenv('PATH') ':' getenv('FREESURFER_HOME') filesep 'mni' filesep 'bin']);


cd(fullfile('/disk','HCP','analyzed',subjid,'PET'));
setenv('SUBJECTS_DIR',fullfile('/disk','HCP','analyzed',subjid,'T1w'));

%system(['mri_coreg --s ' subjid ' --mov PiB-AVG.nii --reg ./new.lta']);

system([' mri_gtmpvc --i PiB-AVG.nii --reg new.lta --psf 6 --seg gtmseg.mgz --default-seg-merge --auto-mask PSF 0.01 --o gtm.output']);
system([' mri_gtmpvc --i PiB-AVG.nii --reg new.lta --psf 0 --seg gtmseg.mgz --default-seg-merge --auto-mask PSF 0.01 --o gtm_noPSF.output']);

cd(c);


setenv('FREESURFER_HOME','/disk/HCP/pipeline/external/freesurfer-beta');
system(['source ' getenv('FREESURFER_HOME') filesep 'SetUpFreeSurfer.sh']);
setenv('PATH',[getenv('PATH') ':' getenv('FREESURFER_HOME') filesep 'bin']);
setenv('PATH',[getenv('PATH') ':' getenv('FREESURFER_HOME') filesep 'fsfast' filesep 'bin']);
setenv('PATH',[getenv('PATH') ':' getenv('FREESURFER_HOME') filesep 'mni' filesep 'bin']);

cd(fullfile('/disk','HCP','analyzed',subjid,'PET'));


system(['flirt -v -cost mutualinfo -searchrx -180 180 -searchry -180 180 -searchrz -180 180 ' ...
'-in PiB-AVG.nii -ref ' fullfile(outfolder,subjid,'T1w','T2w_acpc_dc.nii.gz') ' '...
'-omat initial_xfm.mat -out PiB-native.nii']);

setenv('FREESURFER_HOME','/disk/HCP/pipeline/external/freesurfer-beta');
system(['source ' getenv('FREESURFER_HOME') filesep 'SetUpFreeSurfer.sh']);
setenv('PATH',[getenv('PATH') ':' getenv('FREESURFER_HOME') filesep 'bin']);
setenv('PATH',[getenv('PATH') ':' getenv('FREESURFER_HOME') filesep 'fsfast' filesep 'bin']);
setenv('PATH',[getenv('PATH') ':' getenv('FREESURFER_HOME') filesep 'mni' filesep 'bin']);


system(['mri_coreg --s ' subjid ' --mov PiB-native.nii.gz --ref ' fullfile(outfolder,subjid,'T1w',subjid,'mri/T1.mgz')...
' --reg PiB-AVG.reg.lta']);

system(['mri_gtmpvc --i PiB-native.nii.gz --reg PiB-AVG.reg.lta --psf 6 --seg gtmseg.mgz' ...
' --default-seg-merge --auto-mask PSF .01 --mgx .01 --o gtmpvc.output --rescale 8 47 --no-reduce-fov --max-threads'])

system(['mri_gtmpvc --i PiB-native.nii.gz --reg PiB-AVG.reg.lta --psf 0 --seg gtmseg.mgz' ...
' --default-seg-merge --auto-mask PSF .01 --mgx .01 --o gtmpvc_noPSF.output --rescale 8 47 --no-reduce-fov --max-threads'])

system('mkdir -p gtm_noPVC.output')
system(['mri_convert PiB-native.nii.gz --apply_transform PiB-AVG.reg.lta'...
' --like ${SUBJECTS_DIR}/mri/gtmseg.mgz PiB-native-gtm.nii.gz']);
system('mri_segstats --i PiB-native-gtm.nii.gz --seg ${SUBJECTS_DIR}/mri/gtmseg.mgz --excludeid 0 --ctab ${SUBJECTS_DIR}/mri/gtmseg.ctab --sum gtm_noPVC.output/stats.dat')

system('mkdir -p nongtm.output')
system(['mri_convert PiB-native.nii.gz --apply_transform PiB-AVG.reg.lta'...
' --like ${SUBJECTS_DIR}/mri/aparc+aseg.mgz PiB-aseg.nii.gz']);
system('mri_segstats --i PiB-aseg.nii.gz --seg ${SUBJECTS_DIR}/mri/aparc+aseg.mgz --excludeid 0 --ctab $FREESURFER_HOME/FreeSurferColorLUT.txt --sum nongtm.output/stats.dat')

