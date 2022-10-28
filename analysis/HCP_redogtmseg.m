function HCP_redogtmseg(s)

setenv('FREESURFER_HOME','/disk/HCP/pipeline/external/freesurfer-beta');

setenv('FSLDIR','/disk/HCP/pipeline/external/fsl/');
setenv('PATH',[getenv('FREESURFER_HOME') '/bin/:' getenv('PATH')]);

%setenv('FSLDIR','/home/pkg/software/fsl/fsl');
setenv('FSLDIR','/disk/HCP/pipeline/external/fslnew/');

system(['source ' getenv('FREESURFER_HOME') filesep 'SetUpFreeSurfer.sh']);

setenv('PATH',[getenv('PATH') ':/disk/HCP/pipeline/external/fslnew/bin/'])
setenv('PATH',[getenv('PATH') ':/disk/HCP/pipeline/external/fslnew/'])
setenv('PATH',[getenv('PATH') ':' getenv('FREESURFER_HOME') filesep 'bin']);
setenv('PATH',[getenv('PATH') ':' getenv('FREESURFER_HOME') filesep 'fsfast' filesep 'bin']);
setenv('PATH',[getenv('PATH') ':' getenv('FREESURFER_HOME') filesep 'mni' filesep 'bin']);
outfolder='/disk/HCP/analyzed';

setenv('SUBJECTS_DIR',fullfile(outfolder,s,'T1w'))
setenv('SUBJECT',s);
system(['gtmseg --s ' s ' --xcerseg']);

end