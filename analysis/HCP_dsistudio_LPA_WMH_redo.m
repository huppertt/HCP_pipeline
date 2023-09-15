function HCP_dsistudio_LPA_WMH_redo(subjid,outfolder, force)

if nargin < 3
    force = 0;
end

dsiroot = '/home/jhengenius/dsi-studio/';

if ~exist(fullfile(outfolder, subjid,'T1w',subjid,'dmri',[subjid '_dsistudio.fib.gz']),'file') | ~exist(fullfile(outfolder, subjid,'T1w',subjid,'dmri',[subjid '_dsistudio.trk.gz']),'file')
   disp([subjid ' is missing full-brain tractography. Run HCP_dsistudio_wmh.m first.' ])
   return
end
if ~exist(fullfile(outfolder,subjid,'T2FLAIR','WMH_LPA_thres_mni.nii.gz'),'file')
   disp([subjid ' is missing MNI-aligned LPA WMH map.' ])
   return
end


curdr=pwd;
cd(fullfile(outfolder,subjid,'T1w',subjid,'dmri'));


% Filter all tracts by WMH ROI; save new smaller trk file containing
% tracts that pass through WMH only
if ~exist(['./' subjid '_WMH_LPA_dsistudio.trk.gz'] ,'file') || force
    disp('Generating LPA WMH trk file.')
    system([dsiroot filesep 'dsi_studio --action=ana --source=' subjid '_dsistudio.fib.gz '...
        ' --tract=' subjid '_dsistudio.trk.gz '...
        ' --roi=' fullfile(outfolder,subjid,'T2FLAIR','WMH_LPA_thres_mni.nii.gz')...
        ' --output=' subjid '_WMH_LPA_dsistudio.trk.gz']);


% This analysis computes connectivity for the tracts passing through
% WMH areas only
disp('Computing custom MMP atlas WMH connectivity.')
system([dsiroot filesep 'dsi_studio --action=ana --source=' subjid '_dsistudio.fib.gz '...
    ' --tract=' subjid '_WMH_LPA_dsistudio.trk.gz '... % Use new smaller trk containing only WMH associated tracts
    ' --connectivity_threshold=0 '...
    ' --connectivity=HCP-MMP_subcort_atlas.nii.gz '...
    ' --connectivity_value=qa,count,ncount,lesion '... %
    ' --connectivity_type=end'...
    ' --output=' subjid '_WMH_LPA_conn']);
end 
cd(curdr)