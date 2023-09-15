function HCP_pvc(subjid)

if(exist(fullfile('/disk/HCP/analyzed',subjid,'T1w',subjid,'mri','gtmseg.mgz'))==2)
%    disp(['skipping ' subjid]);
    return
end

setenv('FREESURFER_HOME','/Applications/freesurfer');
system('source $FREESURFER_HOME/SetUpFreeSurfer.sh');
setenv('SUBJECTS_DIR',fullfile('/disk/HCP/analyzed',subjid,'T1w'));

system(['gtmseg --s ' subjid ' --xcerseg'])