function HCP_FreeSurferRaw(subjid,outfolder)

if(nargin<2)
    outfolder='/disk/HCP/analyzed';
end

HCP_matlab_setenv;
system(['mkdir -p ' fullfile(outfolder,subjid,'T1w','FS_basic')]);

T1=fullfile(outfolder,subjid,'T1w','T1w.nii.gz');

cd(fullfile(outfolder,subjid,'T1w','FS_basic'));
setenv('SUBJECTS_DIR',fullfile(outfolder,subjid,'T1w','FS_basic'));
system(['mksubjdirs ' subjid]);

system(['mri_convert ' T1 ' ' fullfile(outfolder,subjid,'T1w','FS_basic',subjid,'mri','orig','001.mgz')])

system(['recon-all -subject ' subjid ' -all']); 