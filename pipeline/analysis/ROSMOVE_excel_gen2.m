function [] = ROSMOVE_excel_gen2(subjid, outfolder,force)

% Check that freesurfer values are available
if ~exist( fullfile(outfolder,subjid,'T1w',subjid, 'mri','T1w_hires.nii.gz') )
    disp( [subjid ' missing T1w_hires.nii.gz'] )
    return;
end
if ~exist( fullfile(outfolder,subjid,'T1w',subjid, 'mri','aseg.hires.nii.gz') )
    disp( [subjid ' missing aseg.hires.nii.gz'] )
    return;
end
if ~exist(fullfile(outfolder,subjid,'stats','aseg.stats'),'file')
    disp( [subjid ' missing aseg.stats'] )
    return;
end
if ~exist(fullfile(outfolder,subjid,'stats','aseg.stats'),'file')
    disp( [subjid ' missing aseg.stats'] )
    return;
end

if(nargin<3)
    force=false;
end

% Name for excel file - will be written to outfolder directory
filename = 'ROSMOVE_volumes.xls';
% Create cell to export
volumes = {'SubjectID' subjid};

HCP_matlab_setenv


if exist(fullfile(outfolder, filename),'file')
   T = readtable(fullfile(outfolder, filename));
else
    T=[];
end

if (~force && ~isempty(T) && ~ismember(subjid,T.SubjectID))

dsiroot = '/home/jhengenius/dsi-studio/';  % Set this to your DSI Studio root!

% Make dir for volume calculations
mkdir( fullfile(outfolder,subjid,'T1w','Atlas_volumes') );

%% Atlas volume extraction
%Define regions from aseg.hires.nii.gz that are to be included in native
%brain mask (everything but ventricles)
mask_ROIs = {
    '1'  'Left Cerebral Exterior'
    '2'  'Left Cerebral White Matter'
    '3'  'Left Cerebral Cortex'
    '9'  'Left Thalamus'
    '10' 'Left Thalamus Proper'
    '11' 'Left Caudate'
    '12' 'Left Putamen'
    '13' 'Left Pallidum'
    '17' 'Left Hippocampus'
    '18' 'Left Amygdala'
    '26' 'Left Accumbens area'
    '28' 'Left VentralDC'
    '40' 'Right Cerebral Exterior'
    '41' 'Right Cerebral White Matter'
    '42' 'Right Cerebral Cortex'
    '48' 'Right Thalamus'
    '49' 'Right Thalamus Proper'
    '50' 'Right Caudate'
    '51' 'Right Putamen'
    '52' 'Right Pallidum'
    '53' 'Right Hippocampus'
    '54' 'Right Amygdala'
    '58' 'Right Accumbens area'
    '60' 'Right VentralDC'
    '7'  'Left Cerebellum White Matter'
    '8'  'Left Cerebellum Cortex'
    '46' 'Right Cerebellum White Matter'
    '47' 'Right Cerebellum Cortex'
    '16' 'Brain Stem'
    };


% Define ROIs for volume calculation (AAL2 cortical and CIC subcortical)
% Regions we want from AAL2 atlas:
AAL2ROI = {
    '1' 'Precentral_L'
    '2' 'Precentral_R'
    '15' 'Supp_Motor_Area_L'
    '16' 'Supp_Motor_Area_R'
    '61' 'Postcentral_L'
    '62' 'Postcentral_R'
    '5'  'Frontal_Mid_2_L'
    '6'  'Frontal_Mid_2_R'
    '25' 'OFCmed_L'
    '26' 'OFCmed_R'
    '27' 'OFCant_L'
    '28' 'OFCant_R'
    '29' 'OFCpost_L'
    '30' 'OFCpost_R'
    '31' 'OFClat_L'
    '32' 'OFClat_R'
    '35' 'Cingulate_Ant_L'
    '36' 'Cingulate_Ant_R'
    };
% Regions we want from CIC atlas
CIC_ROI = {
    '75'  'Amygdala_L'
    '175' 'Amygdala_R'
    '85'  'Hippocampus_L'
    '185' 'Hippocampus_R'
    '5'   'AnteriorVentralStriatum_L'
    '105' 'AnteriorVentralStriatum_R'
    '10'  'PreDorsalCaudate_L'
    '110' 'PreDorsalCaudate_R'
    '15'  'PostDorsalCaudate_L'
    '115' 'PostDorsalCaudate_R'
    '20'  'AnteriorPutamen_L'
    '120' 'AnteriorPutamen_R'
    '25'  'PosteriorPutamen_L'
    '125' 'PosteriorPutamen_R'
    '60'  'Thalamus_L'
    '160' 'Thalamus_R'
    };

% Warp AAL and CIC subcortical atlases to native space
disp('Warping atlases to native space.')
tic
system(['applywarp'...
    ' --ref=' fullfile(outfolder,subjid,'T1w',subjid, 'mri','T1w_hires.nii.gz')...
    ' --in='  fullfile(dsiroot,'atlas','AAL2.nii.gz')...
    ' --warp=' fullfile(outfolder,subjid,'MNINonLinear','xfms', 'standard2acpc_dc.nii.gz')...
    ' --out=' fullfile(outfolder,subjid,'T1w','Atlas_volumes','AAL2_native.nii.gz')...
    ' --interp=nn -v'
    ]);
system(['applywarp'...
    ' --ref=' fullfile(outfolder,subjid,'T1w',subjid, 'mri','T1w_hires.nii.gz')...
    ' --in='  fullfile(dsiroot,'atlas','CIC_LR_atlas.nii.gz')...
    ' --warp=' fullfile(outfolder,subjid,'MNINonLinear','xfms', 'standard2acpc_dc.nii.gz')...
    ' --out=' fullfile(outfolder,subjid,'T1w','Atlas_volumes','CIC_LR_atlas_native.nii.gz')...
    ' --interp=nn -v'
    ]);
toc
% Create blank nii.gz file brain_mask_native with appropriate voxel res
disp('Generating brain mask.')
tic
system(['fslmaths '...
    fullfile(outfolder,subjid,'T1w',subjid, 'mri','T1w_hires.nii.gz')...
    ' -thr 0 -uthr 0 '...
    fullfile(outfolder,subjid,'T1w','Atlas_volumes','brain_mask_native.nii.gz')...
    ]);

% Populate mask file with regions from aseg.hires.nii.gz
for i = 1:length(mask_ROIs) % This loop generates native space brain_mask_native.nii.gz
    system(['fslmaths '...
        fullfile(outfolder,subjid,'T1w',subjid, 'mri','aseg.hires.nii.gz')...
        ' -thr ' mask_ROIs{i,1} ' -uthr '  mask_ROIs{i,1} ' -bin '...
        ' -add ' fullfile(outfolder,subjid,'T1w','Atlas_volumes','brain_mask_native.nii.gz')...
        ' -bin ' fullfile(outfolder,subjid,'T1w','Atlas_volumes','brain_mask_native.nii.gz')...
        ]);
end
toc

% Mask native space atlases
disp('Masking atlases.')
tic
system(['fslmaths '...
    fullfile(outfolder,subjid,'T1w','Atlas_volumes','AAL2_native.nii.gz')...
    ' -mul ' fullfile(outfolder,subjid,'T1w','Atlas_volumes','brain_mask_native.nii.gz')...
    ' ' fullfile(outfolder,subjid,'T1w','Atlas_volumes','AAL2_native.nii.gz')...
    ]);
system(['fslmaths '...
    fullfile(outfolder,subjid,'T1w','Atlas_volumes','CIC_LR_atlas_native.nii.gz')...
    ' -mul ' fullfile(outfolder,subjid,'T1w','Atlas_volumes','brain_mask_native.nii.gz')...
    ' ' fullfile(outfolder,subjid,'T1w','Atlas_volumes','CIC_LR_atlas_native.nii.gz')...
    ]);
toc

% Compute volumes for AAL2
disp('Computing atlas volumes.')
tic
for i = 1:length(AAL2ROI)
    [~,fsl_out] = system(['fslstats '...
        ' ' fullfile(outfolder,subjid,'T1w','Atlas_volumes','AAL2_native.nii.gz')...
        ' -l ' num2str( str2double(AAL2ROI{i,1}) - 0.25 )...
        ' -u ' num2str( str2double(AAL2ROI{i,1}) + 0.25 )...
        ' -V']);
    strs = strsplit(fsl_out, ' ');
    fsl_vol = strs{2};
    volumes = [volumes ; {AAL2ROI{i,2} str2double(fsl_vol) }];
end
% Compute volumes for CIC_LR
for i = 1:length(CIC_ROI)
    [~,fsl_out] = system(['fslstats '...
        ' ' fullfile(outfolder,subjid,'T1w','Atlas_volumes','CIC_LR_atlas_native.nii.gz')...
        ' -l ' num2str( str2double(CIC_ROI{i,1}) - 0.25 )...
        ' -u ' num2str( str2double(CIC_ROI{i,1}) + 0.25 )...
        ' -V']);
    strs = strsplit(fsl_out, ' ');
    fsl_vol = strs{2};
    volumes = [volumes ; {CIC_ROI{i,2} str2double(fsl_vol) }];
end
toc

%% Freesurfer stats extraction
disp('Retrieving aseg stats.')
tic
% Read in aseg stats
aseg = fileread(fullfile(outfolder,subjid,'stats','aseg.stats'));

% Get ICV from aseg
ICV_string = regexp(aseg,'Estimated Total Intracranial Volume, (\d*)\.(\d*), mm\^3', 'match');
strs = strsplit(ICV_string{:},',');
ICV = str2double(strs{2});
volumes = [volumes ; {'IntracranialVolume' ICV}];

% Get left/right cortical gray matter volume from aseg
LCV_string = regexp(aseg,'Left hemisphere cortical gray matter volume, (\d*)\.(\d*), mm\^3', 'match');
strs = strsplit(LCV_string{:},',');
LCV = str2double(strs{2});
volumes = [volumes ; {'L_CortGrayMatter' LCV} ];

RCV_string = regexp(aseg,'Right hemisphere cortical gray matter volume, (\d*)\.(\d*), mm\^3', 'match');
strs = strsplit(RCV_string{:},',');
RCV = str2double(strs{2});
volumes = [volumes ; {'R_CortGrayMatter' RCV}];
toc


%% Write to excel file
disp('Writing to Excel file.')
tic
% Check if excel file with filename exists in outfolder
if ~exist(fullfile(outfolder, filename),'file')
    % If not, write new file
    tbl=cell2table({volumes{:,2:end}},'VariableNames',{volumes{:,1}});
    nirs.util.write_xls(fullfile(outfolder, filename),tbl);
    %writetable(cell2table(volumes'),fullfile(outfolder, filename),'WriteVariableNames',0)
else
    % Else, read in existing file
    T = readtable(fullfile(outfolder, filename));
    % If subject isn't already present, append entry
    if ~ismember(subjid,T.SubjectID)
        T = [T ; cell2table({volumes{:,2:end}},'VariableNames',{volumes{:,1}})];
        % Write table with additional entry appended
       % writetable(T,fullfile(outfolder, filename)   )
        nirs.util.write_xls(fullfile(outfolder, filename),T);
    else
        disp(['Subject ' subjid ' already in table.'])
    end
end
toc;
else
    disp([subjid ' is already processed']);
end

