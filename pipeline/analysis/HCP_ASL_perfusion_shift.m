function  HCP_ASL_perfusion_shift(subjid,outfolder,force)

if nargin < 3
    force = false;
end


if ~exist( fullfile(outfolder,subjid,'unprocessed','3T','ASL',[subjid '_3T_Perfusion.nii.gz']),'file' )
    disp([subjid ' missing perfusion data in unprocessed folder. Exiting.'])
    return
end
if ~exist( fullfile(outfolder,subjid,'T1w','T1w_acpc_dc_restore.nii.gz'),'file' )
    disp([subjid ' missing structural data in T1w folder. Exiting.'])
    return
end
if exist(fullfile(outfolder,subjid,'Perfusion'),'dir') &  ~force
    disp([subjid ' output directory already present and force is set to false. Exiting.'])
    return
end


% Load or create table to store values
if exist(fullfile(outfolder,'Perfusion_values_shift.csv'),'file')
    tbl = readtable(fullfile(outfolder,'Perfusion_values_shift.csv'));
else
    region_names = { 'AnteriorCingulate' 'AnteriorVentralStriatum' 'SuperiorFrontal' 'OrbitoFrontal' 'Insula' 'LateralTemporal' 'Parietal' 'PosteriorCingulate' 'Precuneus' 'Global' 'WhiteMatter'};
    varnames = ['SubjectID' strcat('Perf_' , region_names) strcat('WMNormPerf_' , region_names) strcat('ICVNormPerf_' , region_names) strcat('TBVNormPerf_' , region_names)];
    tbl = cell2table(cell(0,length(varnames)),'VariableNames',varnames);
end

if ~isempty(find(strcmp(tbl.SubjectID,subjid))) & ~force
    disp([subjid ' values are already stored in '  fullfile(outfolder,'Perfusion_values_shift.csv') ' and force is false. Exiting.']);
    return
end


% Create output directory subjid/Perfusion
mkdir( fullfile(outfolder,subjid,'Perfusion') );

if exist(fullfile(outfolder,subjid,'unprocessed','3T','ASL',[subjid '_3T_Perfusion.nii.gz']),'file')...
        & exist(fullfile(outfolder,subjid,'T1w','T1w_acpc_dc_restore.nii.gz'),'file')...
        & exist(fullfile(outfolder,subjid,'T1w','T1w_acpc_dc_restore_brain.nii.gz'),'file')...
        & exist(fullfile(outfolder,subjid,'T1w','aparc+aseg.nii.gz'),'file')

% Copy images to new dir
copyfile( fullfile(outfolder,subjid,'unprocessed','3T','ASL',[subjid '_3T_Perfusion.nii.gz']) ,     fullfile(outfolder,subjid,'Perfusion') );
copyfile( fullfile(outfolder,subjid,'T1w','T1w_acpc_dc_restore.nii.gz') ,                           fullfile(outfolder,subjid,'Perfusion') );
copyfile( fullfile(outfolder,subjid,'T1w','T1w_acpc_dc_restore_brain.nii.gz') ,                     fullfile(outfolder,subjid,'Perfusion') );
copyfile( fullfile(outfolder,subjid,'T1w','aparc+aseg.nii.gz') ,                                    fullfile(outfolder,subjid,'Perfusion') );

else
    disp([subjid ' is missing prerequisite T1w or aseg volumes. Returning.'])
    return
end

% Change dir to new dir
currdir = pwd;
cd(fullfile(outfolder,subjid,'Perfusion'))

if ~exist(fullfile(outfolder,subjid,'Perfusion',[subjid '_3T_Perfusion_acpc.nii.gz']),'file')
    % Call epi_reg on data (this script calls FAST to segment the T1w and takes
    % several minutes)
    system(['epi_reg ' ...
        ' --epi='       fullfile(outfolder,subjid,'Perfusion',[subjid '_3T_Perfusion.nii.gz'])...
        ' --t1='        fullfile(outfolder,subjid,'Perfusion','T1w_acpc_dc_restore.nii.gz')...
        ' --t1brain='   fullfile(outfolder,subjid,'Perfusion','T1w_acpc_dc_restore_brain.nii.gz')...
        ' --out='       fullfile(outfolder,subjid,'Perfusion',[subjid '_3T_Perfusion_acpc.nii.gz'])...
        ' -v']);
else 
    disp([subjid ' skipping alignment. ACPC aligned file found.'])
end


        

% Mask registered data with T1w brain mask
if ~exist(fullfile(outfolder,subjid,'Perfusion',[subjid '_3T_Perfusion_acpc_brain_shift.nii.gz']),'file')
    system(['fslmaths '...
        ' ' fullfile(outfolder,subjid,'Perfusion','T1w_acpc_dc_restore_brain.nii.gz')...
        ' -bin -mul '...
        ' ' fullfile(outfolder,subjid,'Perfusion',[subjid '_3T_Perfusion_acpc.nii.gz'])...
        ' ' fullfile(outfolder,subjid,'Perfusion',[subjid '_3T_Perfusion_acpc_brain_shift.nii.gz'])...
        ]);
    
    % Find robust minimum (2nd percentile) value in Perf image
    [~,ROIminmax] = system(['fslstats ' fullfile(outfolder,subjid,'Perfusion',[subjid '_3T_Perfusion_acpc_brain_shift.nii.gz']) ' -P 2']);
    ROIminmax = strsplit(ROIminmax,' ')
    
    % Subtract off min to shift most neg vals to near zero
    system(['fslmaths '...
        ' ' fullfile(outfolder,subjid,'Perfusion',[subjid '_3T_Perfusion_acpc_brain_shift.nii.gz'])...
        ' -sub ' ROIminmax{1}...
        ' ' fullfile(outfolder,subjid,'Perfusion',[subjid '_3T_Perfusion_acpc_brain_shift.nii.gz'])...
        ]);
end

% Define ROIs and super-regions based on Freesurfer parcellation
% Defines ROI super-regions
ROI(1).name='AnteriorCingulate';
ROI(1).list={'ctx-lh-rostralanteriorcingulate'
    'ctx-lh-caudalanteriorcingulate'
    'ctx-rh-rostralanteriorcingulate'
    'ctx-rh-caudalanteriorcingulate'};
ROI(2).name='AnteriorVentralStriatum';
ROI(2).list={'Left-Accumbens-area'
    'Left-Caudate'
    'Left-Putamen'
    'Right-Accumbens-area'
    'Right-Caudate'
    'Right-Putamen'};
ROI(3).name='SuperiorFrontal';
ROI(3).list={'ctx-lh-rostralmiddlefrontal'
    'ctx-lh-superiorfrontal'
    'ctx-lh-parstriangularis'
    'ctx-lh-frontalpole'
    'ctx-lh-parsopercularis'
    'ctx-lh-caudalmiddlefrontal'
    'ctx-lh-parsorbitalis'
    'ctx-rh-rostralmiddlefrontal'
    'ctx-rh-superiorfrontal'
    'ctx-rh-parstriangularis'
    'ctx-rh-frontalpole'
    'ctx-rh-parsopercularis'
    'ctx-rh-caudalmiddlefrontal'
    'ctx-rh-parsorbitalis'};
ROI(4).name='OrbitoFrontal';
ROI(4).list={'ctx-lh-lateralorbitofrontal'
    'ctx-lh-medialorbitofrontal'
    'ctx-rh-lateralorbitofrontal'
    'ctx-rh-medialorbitofrontal'};
ROI(5).name='Insula';
ROI(5).list={'ctx-lh-insula'
    'ctx-rh-insula'};
ROI(6).name='LateralTemporal';
ROI(6).list={'ctx-lh-superiortemporal'
    'ctx-lh-middletemporal'
    'ctx-lh-inferiortemporal'
    'ctx-lh-bankssts'
    'ctx-rh-superiortemporal'
    'ctx-rh-middletemporal'
    'ctx-rh-inferiortemporal'
    'ctx-rh-bankssts'};
ROI(7).name='Parietal';
ROI(7).list={'ctx-lh-inferiorparietal'
    'ctx-lh-superiorparietal'
    'ctx-lh-supramarginal'
    'ctx-rh-inferiorparietal'
    'ctx-rh-superiorparietal'
    'ctx-rh-supramarginal'};
ROI(8).name='PosteriorCingulate';
ROI(8).list={'ctx-lh-posteriorcingulate'
    'ctx-lh-isthmuscingulate'
    'ctx-rh-posteriorcingulate'
    'ctx-rh-isthmuscingulate'};
ROI(9).name='Precuneus';
ROI(9).list={'ctx-lh-precuneus'
    'ctx-rh-precuneus'};
ROI(10).name='Global';
ROI(10).list={'ctx-lh-rostralanteriorcingulate'
    'ctx-lh-caudalanteriorcingulate'
    'ctx-rh-rostralanteriorcingulate'
    'ctx-rh-caudalanteriorcingulate'
    'Left-Accumbens-area'
    'Left-Caudate'
    'Left-Putamen'
    'Right-Accumbens-area'
    'Right-Caudate'
    'Right-Putamen'
    'ctx-lh-rostralmiddlefrontal'
    'ctx-lh-superiorfrontal'
    'ctx-lh-parstriangularis'
    'ctx-lh-frontalpole'
    'ctx-lh-parsopercularis'
    'ctx-lh-caudalmiddlefrontal'
    'ctx-lh-parsorbitalis'
    'ctx-rh-rostralmiddlefrontal'
    'ctx-rh-superiorfrontal'
    'ctx-rh-parstriangularis'
    'ctx-rh-frontalpole'
    'ctx-rh-parsopercularis'
    'ctx-rh-caudalmiddlefrontal'
    'ctx-rh-parsorbitalis'
    'ctx-lh-lateralorbitofrontal'
    'ctx-lh-medialorbitofrontal'
    'ctx-rh-lateralorbitofrontal'
    'ctx-rh-medialorbitofrontal'
    'ctx-lh-insula'
    'ctx-rh-insula'
    'ctx-lh-superiortemporal'
    'ctx-lh-middletemporal'
    'ctx-lh-inferiortemporal'
    'ctx-lh-bankssts'
    'ctx-rh-superiortemporal'
    'ctx-rh-middletemporal'
    'ctx-rh-inferiortemporal'
    'ctx-rh-bankssts'
    'ctx-lh-inferiorparietal'
    'ctx-lh-superiorparietal'
    'ctx-lh-supramarginal'
    'ctx-rh-inferiorparietal'
    'ctx-rh-superiorparietal'
    'ctx-rh-supramarginal'
    'ctx-lh-posteriorcingulate'
    'ctx-lh-isthmuscingulate'
    'ctx-rh-posteriorcingulate'
    'ctx-rh-isthmuscingulate'
    'ctx-lh-precuneus'
    'ctx-rh-precuneus'};
ROI(11).name = 'WhiteMatter'
ROI(11).list = {'Left-Cerebral-White-Matter'
    'Right-Cerebral-White-Matter'};

% Read in LUT so that we can find image labels of the above ROIs
load(fullfile(outfolder, 'LUT.mat'))
for i = 1:length(ROI)
   for j = 1:length(ROI(i).list)
      [idx ~] = find(strcmp(ROI(i).list{j}, LUT)); % Get row of LUT
      ROI(i).label(j) = LUT{idx,1}; % Save 
   end
end

% Create extracted ASL image of each ROI and find volume and mean perf
% values
for i = 1:length(ROI)
    disp([subjid ' Region: ' ROI(i).name])
    for j = 1:length(ROI(i).label)
        system(['fslmaths '...
            ' ' fullfile(outfolder,subjid,'Perfusion','aparc+aseg.nii.gz')...
            ' -thr ' num2str(ROI(i).label(j)-0.5) ' -uthr ' num2str(ROI(i).label(j)+0.5) ' -bin'...
            ' -mul ' fullfile(outfolder,subjid,'Perfusion',[subjid '_3T_Perfusion_acpc_brain_shift.nii.gz'])...
            ' ' fullfile(outfolder,subjid,'Perfusion','ROI.nii.gz')]);
        
        if strcmp(ROI(i).name,'WhiteMatter')
            system(['fslmaths '...
                ' ' fullfile(outfolder,subjid,'Perfusion','ROI.nii.gz')...
                ' -ero -ero '...
                ' ' fullfile(outfolder,subjid,'Perfusion','ROI.nii.gz')]);
        end
        
        [returnval,ROI_stats] = system(['fslstats ROI.nii.gz -M -V']); % Extract mean perfusion (-M) and volume (-V) for each ROI 
        ROI_stats = strsplit(ROI_stats,' ');
        ROI(i).flow(j) =        str2num(ROI_stats{1});
        ROI(i).vol(j) =         str2num(ROI_stats{3});
        disp([subjid ' ROI: ' ROI(i).list{j} ' Flow: ' ROI_stats{1} ' Volume: ' ROI_stats{3}]);
    end
end

% Compute volume-weighted mean flow values for super regions
for i = 1:length(ROI)
    ROI(i).volweightedflow = sum(ROI(i).flow.*ROI(i).vol) / sum(ROI(i).vol);
end
  
% Normalize volume-weighted mean flow to cerebral WM flow values
for i = 1:length(ROI)
    ROI(i).wmnormflow = ROI(i).volweightedflow/ROI(end).volweightedflow;
end
    

% Load aseg stats file with ICV, TBV, etc
fid = fopen(fullfile(outfolder,subjid,'stats','aseg.stats'),'r');
stats = textscan(fid,'%s','delimiter', '\n')
fclose(fid);
stats = stats{1};
for i = 1:length(stats)
    if regexp(stats{i},'Estimated Total Intracranial Volume, \d+.\d+')
        match = regexp(stats{i},'Estimated Total Intracranial Volume, \d+.\d+','match','noemptymatch');
        ICV = strsplit(match{1},',');
        ICV = str2num(ICV{2});
    elseif regexp(stats{i},'Brain Segmentation Volume Without Ventricles, \d+.\d+')
        match = regexp(stats{i},'Brain Segmentation Volume Without Ventricles, \d+.\d+','match','noemptymatch');
        TBV = strsplit(match{1},',');
        TBV = str2num(TBV{2});
    end
end

%Normalize volume-weighted mean perf to ICV and BV
for i = 1:length(ROI)
    ROI(i).ICVnorm = ROI(i).volweightedflow/ICV;
    ROI(i).BVnorm = ROI(i).volweightedflow/TBV;
end

% Write regional flow to tbl - either replace existing subject row or
% append row to bottom of sheet
tbl_vals = [{['''' subjid '''']} ROI.volweightedflow ROI.wmnormflow ROI.ICVnorm ROI.BVnorm];
if ~isempty(find(strcmp(tbl.SubjectID,subjid)))
    tbl_idx = find(strcmp(tbl.SubjectID,['''' subjid '''']));
    tbl(tbl_idx,:)=[tbl_vals];
else
    tbl=[tbl ; tbl_vals];
end

% Sort rows by subjid
sortrows(tbl, 'SubjectID');

% Write table to outfolder
writetable(tbl, fullfile(outfolder,'Perfusion_values_shift.csv'));

% Return to original dir
cd(currdir)

end