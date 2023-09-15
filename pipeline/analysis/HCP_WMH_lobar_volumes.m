function HCP_WMH_lobar_volumes(subjid,outfolder,force)

if nargin > 3
    force = 0;
end

% Check if output already exists; if force is FALSE, return
if exist(fullfile(outfolder,subjid,'T2FLAIR',[subjid '_WMH_lobar_volumes.mat']),'file') & ~force
    disp([subjid ' already has output and force=FALSE. Skipping'])
    return
end
    % Check if WMH fuzzy cluster output exists
if ~exist(fullfile(outfolder,subjid,'T2FLAIR', [subjid '_3T_WMH_fuzzy_acpc.nii.gz']),'file')
   disp([subjid ' missing fuzzy WMH map. Exiting.'])
   return
end
% Check if WM segmentation from Freesurfer exists
if ~exist(fullfile(outfolder,subjid,'T1w','wmparc.nii.gz' ),'file')
    disp([subjid ' missing WM parcellation. Exiting.'])
    return
end
% Check if TIV stats from Freesurfer exists
if ~exist(fullfile(outfolder,subjid,'T1w',subjid,'stats','aseg.stats' ),'file')
    disp([subjid ' missing aseg.stats. Exiting.'])
    return
end


currdir = pwd;
cd(fullfile(outfolder,subjid,'T2FLAIR'))

setenv('FREESURFER_HOME','/disk/HCP/pipeline/external/freesurfer-beta');

% Copy necessary files to T2FLAIR dir
system(['cp -v /disk/HCP/pipeline/analysis/atlases/ICBM152_2009c_AtlasWhite.nii.gz ./' ]);
system(['cp -v /disk/HCP/pipeline/analysis/atlases/ICBM152_2009c_AtlasWhite.txt ./' ]);
system(['cp -v ' fullfile(outfolder,subjid,'T1w','wmparc.nii.gz') ' ./']);

% Resample MNI lobar atlas to MNI T1w resolution so HCP pipeline xfms work 
% system(['mri_convert  '...
%     ' --like ' fullfile(outfolder,subjid,'MNINonLinear','T1w_restore_brain.nii.gz')...
%     ' --resample_type nearest '...
%     ' ICBM152_2009c_AtlasWhite.nii.gz '...
%     ' AtlasWhite_resampled.nii.gz '])
if ~exist(fullfile(outfolder,subjid,'T2FLAIR','AtlasWhite_resampled.nii.gz')) | force
    setenv('SUBJECTS_DIR', fullfile(outfolder,subjid,'MNINonLinear'))
    system(['mri_vol2vol '...
        ' --targ ' fullfile(outfolder,subjid,'MNINonLinear','T1w_restore_brain.nii.gz')...
        ' --interp nearest --regheader '...
        ' --mov ICBM152_2009c_AtlasWhite.nii.gz '...
        ' --o AtlasWhite_resampled.nii.gz ']);
end

% Warp and resample MNI lobar atlas to subject native space (NN interp)
if ~exist(fullfile(outfolder,subjid,'T2FLAIR','AtlasWhite_native.nii.gz'),'file') | force
    system(['applywarp --interp=nn '...
        ' --ref='    fullfile(outfolder,subjid,'T2FLAIR', [subjid '_3T_WMH_fuzzy_acpc.nii.gz'])...
        ' --in='     fullfile(outfolder,subjid,'T2FLAIR','AtlasWhite_resampled.nii.gz')...
        ' --warp='   fullfile(outfolder,subjid,'MNINonLinear','xfms','standard2acpc_dc.nii.gz')...
        ' --out='    fullfile(outfolder,subjid,'T2FLAIR','AtlasWhite_native.nii.gz')...
        ' -v']);
end

% Find intersection of native space lobar atlas with WMH seg from
% Freesurfer
system(['fslmaths '...
    ' wmparc.nii.gz -thr 2999.5 -bin '...
    ' -mul AtlasWhite_native.nii.gz '...
    ' AtlasWhite_native.nii.gz']);


% Threshold and binarize WMH probability map using 0.05
system(['fslmaths '...
    ' ' [subjid '_3T_WMH_fuzzy_acpc.nii.gz']...
    ' -thr 0.95 -bin '...
    ' WMH_thres.nii.gz' ]);

% Calculate WMH volume in lobe
LobeLabels = ...
{'Frontal_L'	30
'Frontal_R'     17
'Parietal_L'	57
'Parietal_R'	105
'Occipital_L'	73
'Occipital_R'	45
'Temporal_L'	83
'Temporal_R'	59};

LobeWMHVols = [];

for i = 1:length(LobeLabels)
    % Create lobe mask and multiple WMH by lobe mask
    system(['fslmaths '...
        ' AtlasWhite_native.nii.gz '...
        ' -thr '  num2str(LobeLabels{i,2}-0.5)...
        ' -uthr ' num2str(LobeLabels{i,2}+0.5)...
        ' -bin -mul WMH_thres.nii.gz '...
         ' temp.nii.gz']);
    % Compute volume
    [~,VoxVol] = system(['fslstats temp.nii.gz -V']);
    VoxVol = strsplit(VoxVol);
    LobeWMHVols(i) = str2double(VoxVol{2});
end

% Get deep unsegmented WMH volume
system(['fslmaths '...
    ' wmparc.nii.gz -thr 2999.5 -bin '...
    ' -mul WMH_thres.nii.gz -bin '...
    ' temp.nii.gz']);
[~,VoxVol] = system(['fslstats temp.nii.gz -V']);
VoxVol = strsplit(VoxVol);
LobeWMHVols = [LobeWMHVols  str2double(VoxVol{2})-sum(LobeWMHVols)];
    
delete('temp.nii.gz')

% Get ICV from aseg.stats
stats = fileread(fullfile(outfolder,subjid,'T1w',subjid,'stats','aseg.stats' ));
ICV_string = regexp(stats,'Estimated Total Intracranial Volume, (\d*)\.(\d*), mm\^3', 'match');
strs = strsplit(ICV_string{:},',');
ICV = str2double(strs{2});

BVol_string = regexp(stats,'Measure BrainSegNotVentSurf, BrainSegVolNotVentSurf, Brain Segmentation Volume Without Ventricles from Surf, (\d*)\.(\d*), mm\^3','match');
strs = strsplit(BVol_string{:},',');
BVol = str2double(strs{4});

CGVol_string = regexp(stats,'Measure Cortex, CortexVol, Total cortical gray matter volume, (\d*)\.(\d*), mm\^3','match');
strs = strsplit(CGVol_string{:},',');
CGVol = str2double(strs{4});


fracdeep = LobeWMHVols(end)/sum(LobeWMHVols);
disp([subjid ' fraction of WMH in deep/unsegmented white matter: ' num2str(fracdeep)]);

% Save as table
WMH_table = cell2table([subjid num2cell(LobeWMHVols) ICV BVol CGVol],'VariableNames',['SubjectID' LobeLabels(:,1)' 'UnsegmentedDeep' 'ICV' 'TBVnoVents' 'CortGMVol'])

save([subjid '_WMH_lobar_volumes.mat'],'WMH_table')

setenv('FREESURFER_HOME','/disk/HCP/pipeline/external/freesurfer-beta')
cd(currdir)