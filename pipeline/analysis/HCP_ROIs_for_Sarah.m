%Get list of subjid directories
outfolder = '/disk/HCP/analyzed';
subs = dir(outfolder);
subjids = {};
for i = 1:length(subs)
    if subs(i).isdir
        subjids = [subjids ; subs(i).name];
    end
end

% All ROIs
% ROI_list = {'ctx-lh-bankssts';'ctx-lh-caudalanteriorcingulate';'ctx-lh-caudalmiddlefrontal';'ctx-lh-corpuscallosum';'ctx-lh-cuneus';'ctx-lh-entorhinal';'ctx-lh-fusiform';'ctx-lh-inferiorparietal';'ctx-lh-inferiortemporal';'ctx-lh-isthmuscingulate';'ctx-lh-lateraloccipital';'ctx-lh-lateralorbitofrontal';'ctx-lh-lingual';'ctx-lh-medialorbitofrontal';'ctx-lh-middletemporal';'ctx-lh-parahippocampal';'ctx-lh-paracentral';'ctx-lh-parsopercularis';'ctx-lh-parsorbitalis';'ctx-lh-parstriangularis';'ctx-lh-pericalcarine';'ctx-lh-postcentral';'ctx-lh-posteriorcingulate';'ctx-lh-precentral';'ctx-lh-precuneus';'ctx-lh-rostralanteriorcingulate';'ctx-lh-rostralmiddlefrontal';'ctx-lh-superiorfrontal';'ctx-lh-superiorparietal';'ctx-lh-superiortemporal';'ctx-lh-supramarginal';'ctx-lh-frontalpole';'ctx-lh-temporalpole';'ctx-lh-transversetemporal';'ctx-lh-insula';'ctx-rh-bankssts';'ctx-rh-caudalanteriorcingulate';'ctx-rh-caudalmiddlefrontal';'ctx-rh-corpuscallosum';'ctx-rh-cuneus';'ctx-rh-entorhinal';'ctx-rh-fusiform';'ctx-rh-inferiorparietal';'ctx-rh-inferiortemporal';'ctx-rh-isthmuscingulate';'ctx-rh-lateraloccipital';'ctx-rh-lateralorbitofrontal';'ctx-rh-lingual';'ctx-rh-medialorbitofrontal';'ctx-rh-middletemporal';'ctx-rh-parahippocampal';'ctx-rh-paracentral';'ctx-rh-parsopercularis';'ctx-rh-parsorbitalis';'ctx-rh-parstriangularis';'ctx-rh-pericalcarine';'ctx-rh-postcentral';'ctx-rh-posteriorcingulate';'ctx-rh-precentral';'ctx-rh-precuneus';'ctx-rh-rostralanteriorcingulate';'ctx-rh-rostralmiddlefrontal';'ctx-rh-superiorfrontal';'ctx-rh-superiorparietal';'ctx-rh-superiortemporal';'ctx-rh-supramarginal';'ctx-rh-frontalpole';'ctx-rh-temporalpole';'ctx-rh-transversetemporal';'ctx-rh-insula'};
% ROI_list = {'ctx-lh-bankssts'	'ctx-lh-caudalanteriorcingulate'	'ctx-lh-caudalmiddlefrontal'	'ctx-lh-corpuscallosum'	'ctx-lh-cuneus'	'ctx-lh-entorhinal'	'ctx-lh-fusiform'	'ctx-lh-inferiorparietal'	'ctx-lh-inferiortemporal'	'ctx-lh-isthmuscingulate'	'ctx-lh-lateraloccipital'	'ctx-lh-lateralorbitofrontal'	'ctx-lh-lingual'	'ctx-lh-medialorbitofrontal'	'ctx-lh-middletemporal'	'ctx-lh-parahippocampal'	'ctx-lh-paracentral'	'ctx-lh-parsopercularis'	'ctx-lh-parsorbitalis'	'ctx-lh-parstriangularis'	'ctx-lh-pericalcarine'	'ctx-lh-postcentral'	'ctx-lh-posteriorcingulate'	'ctx-lh-precentral'	'ctx-lh-precuneus'	'ctx-lh-rostralanteriorcingulate'	'ctx-lh-rostralmiddlefrontal'	'ctx-lh-superiorfrontal'	'ctx-lh-superiorparietal'	'ctx-lh-superiortemporal'	'ctx-lh-supramarginal'	'ctx-lh-frontalpole'	'ctx-lh-temporalpole'	'ctx-lh-transversetemporal'	'ctx-lh-insula'	'ctx-rh-bankssts'	'ctx-rh-caudalanteriorcingulate'	'ctx-rh-caudalmiddlefrontal'	'ctx-rh-corpuscallosum'	'ctx-rh-cuneus'	'ctx-rh-entorhinal'	'ctx-rh-fusiform'	'ctx-rh-inferiorparietal'	'ctx-rh-inferiortemporal'	'ctx-rh-isthmuscingulate'	'ctx-rh-lateraloccipital'	'ctx-rh-lateralorbitofrontal'	'ctx-rh-lingual'	'ctx-rh-medialorbitofrontal'	'ctx-rh-middletemporal'	'ctx-rh-parahippocampal'	'ctx-rh-paracentral'	'ctx-rh-parsopercularis'	'ctx-rh-parsorbitalis'	'ctx-rh-parstriangularis'	'ctx-rh-pericalcarine'	'ctx-rh-postcentral'	'ctx-rh-posteriorcingulate'	'ctx-rh-precentral'	'ctx-rh-precuneus'	'ctx-rh-rostralanteriorcingulate'	'ctx-rh-rostralmiddlefrontal'	'ctx-rh-superiorfrontal'	'ctx-rh-superiorparietal'	'ctx-rh-superiortemporal'	'ctx-rh-supramarginal'	'ctx-rh-frontalpole'	'ctx-rh-temporalpole'	'ctx-rh-transversetemporal'	'ctx-rh-insula'	'AnteriorVentralStriatum_L'	'PreDorsalCaudate_L'	'PostDorsalCaudate_L'	'AnteriorPutamen_L'	'PosteriorPutamen_L'	'Thalamus_L'	'Amygdala_L'	'Hippocampus_L'	'AnteriorVentralStriatum_R'	'PreDorsalCaudate_R'	'PostDorsalCaudate_R'	'AnteriorPutamen_R'	'PosteriorPutamen_R'	'Thalamus_R'	'Amygdala_R'	'Hippocampus_R'}';
ROI_list = {'AnteriorVentralStriatum_L'	'PreDorsalCaudate_L'	'PostDorsalCaudate_L'	'AnteriorPutamen_L'	'PosteriorPutamen_L'	'Thalamus_L'	'Amygdala_L'	'Hippocampus_L'	'AnteriorVentralStriatum_R'	'PreDorsalCaudate_R'	'PostDorsalCaudate_R'	'AnteriorPutamen_R'	'PosteriorPutamen_R'	'Thalamus_R'	'Amygdala_R'	'Hippocampus_R' 'ctx-lh-bankssts'	'ctx-lh-caudalanteriorcingulate'	'ctx-lh-caudalmiddlefrontal'	'ctx-lh-cuneus'	'ctx-lh-entorhinal'	'ctx-lh-fusiform'	'ctx-lh-inferiorparietal'	'ctx-lh-inferiortemporal'	'ctx-lh-isthmuscingulate'	'ctx-lh-lateraloccipital'	'ctx-lh-lateralorbitofrontal'	'ctx-lh-lingual'	'ctx-lh-medialorbitofrontal'	'ctx-lh-middletemporal'	'ctx-lh-parahippocampal'	'ctx-lh-paracentral'	'ctx-lh-parsopercularis'	'ctx-lh-parsorbitalis'	'ctx-lh-parstriangularis'	'ctx-lh-pericalcarine'	'ctx-lh-postcentral'	'ctx-lh-posteriorcingulate'	'ctx-lh-precentral'	'ctx-lh-precuneus'	'ctx-lh-rostralanteriorcingulate'	'ctx-lh-rostralmiddlefrontal'	'ctx-lh-superiorfrontal'	'ctx-lh-superiorparietal'	'ctx-lh-superiortemporal'	'ctx-lh-supramarginal'	'ctx-lh-frontalpole'	'ctx-lh-temporalpole'	'ctx-lh-transversetemporal'	'ctx-lh-insula'	'ctx-rh-bankssts'	'ctx-rh-caudalanteriorcingulate'	'ctx-rh-caudalmiddlefrontal'	'ctx-rh-cuneus'	'ctx-rh-entorhinal'	'ctx-rh-fusiform'	'ctx-rh-inferiorparietal'	'ctx-rh-inferiortemporal'	'ctx-rh-isthmuscingulate'	'ctx-rh-lateraloccipital'	'ctx-rh-lateralorbitofrontal'	'ctx-rh-lingual'	'ctx-rh-medialorbitofrontal'	'ctx-rh-middletemporal'	'ctx-rh-parahippocampal'	'ctx-rh-paracentral'	'ctx-rh-parsopercularis'	'ctx-rh-parsorbitalis'	'ctx-rh-parstriangularis'	'ctx-rh-pericalcarine'	'ctx-rh-postcentral'	'ctx-rh-posteriorcingulate'	'ctx-rh-precentral'	'ctx-rh-precuneus'	'ctx-rh-rostralanteriorcingulate'	'ctx-rh-rostralmiddlefrontal'	'ctx-rh-superiorfrontal'	'ctx-rh-superiorparietal'	'ctx-rh-superiortemporal'	'ctx-rh-supramarginal'	'ctx-rh-frontalpole'	'ctx-rh-temporalpole'	'ctx-rh-transversetemporal'	'ctx-rh-insula'	}';

% ROIs of interest for study
selected_ROIs = {'AnteriorVentralStriatum_L';'PreDorsalCaudate_L';'PostDorsalCaudate_L';'AnteriorPutamen_L';'PosteriorPutamen_L';'Thalamus_L';'Amygdala_L';'Hippocampus_L';'AnteriorVentralStriatum_R';'PreDorsalCaudate_R';'PostDorsalCaudate_R';'AnteriorPutamen_R';'PosteriorPutamen_R';'Thalamus_R';'Amygdala_R';'Hippocampus_R';'ctx-lh-bankssts';'ctx-lh-caudalanteriorcingulate';'ctx-lh-caudalmiddlefrontal';'ctx-lh-entorhinal';'ctx-lh-fusiform';'ctx-lh-inferiorparietal';'ctx-lh-inferiortemporal';'ctx-lh-isthmuscingulate';'ctx-lh-lateralorbitofrontal';'ctx-lh-medialorbitofrontal';'ctx-lh-middletemporal';'ctx-lh-parahippocampal';'ctx-lh-parsopercularis';'ctx-lh-parsorbitalis';'ctx-lh-parstriangularis';'ctx-lh-posteriorcingulate';'ctx-lh-precuneus';'ctx-lh-rostralanteriorcingulate';'ctx-lh-rostralmiddlefrontal';'ctx-lh-superiorfrontal';'ctx-lh-superiorparietal';'ctx-lh-superiortemporal';'ctx-lh-supramarginal';'ctx-lh-frontalpole';'ctx-lh-insula';'ctx-rh-bankssts';'ctx-rh-caudalanteriorcingulate';'ctx-rh-caudalmiddlefrontal';'ctx-rh-entorhinal';'ctx-rh-fusiform';'ctx-rh-inferiorparietal';'ctx-rh-inferiortemporal';'ctx-rh-isthmuscingulate';'ctx-rh-lateralorbitofrontal';'ctx-rh-medialorbitofrontal';'ctx-rh-middletemporal';'ctx-rh-parahippocampal';'ctx-rh-parsopercularis';'ctx-rh-parsorbitalis';'ctx-rh-parstriangularis';'ctx-rh-posteriorcingulate';'ctx-rh-precuneus';'ctx-rh-rostralanteriorcingulate';'ctx-rh-rostralmiddlefrontal';'ctx-rh-superiorfrontal';'ctx-rh-superiorparietal';'ctx-rh-superiortemporal';'ctx-rh-supramarginal';'ctx-rh-frontalpole';'ctx-rh-insula'};
% Selected ROI indices
idx_ROI = find(ismember(ROI_list,selected_ROIs));

% Sort selected_ROIs according to ROI_list
% [~,idx_sort] = sort(ROI_list(idx_ROI));
% unsorted = 1:length(selected_ROIs);
% newInd(idx_sort) = unsorted;
% selected_ROIs = selected_ROIs(newInd);

% Define indices for upper triangle
idx_ut = logical(triu(ones(length(selected_ROIs)),1));
%idx_lt = logical(tril(ones(length(selected_ROIs)),-1));

% Generate linear indices for upper triangle (used later)
linIdx = reshape(1:size(selected_ROIs,1)^2,size(selected_ROIs,1),size(selected_ROIs,1));

linIdx = linIdx(idx_ut);

%Generate names of columns in cell array

data_types = {'SlTOT','SlWMH','FVolWMH'};

data_cell = {};

for i = 1:length(data_types)
    for j = 1:length(linIdx)
        [r,c] = ind2sub(length(selected_ROIs),linIdx(j));
        data_cell{(i-1)*length(linIdx)+j} = [data_types{i} '-' strrep(selected_ROIs{r},'ctx-','') '-' strrep(selected_ROIs{c},'ctx-','')];
    end
end
data_cell = ['SubjectID' data_cell];

% For each subject, if all data exists, load data
stack = [];
for s = 1:length(subjids)
    
    EXIST_STOT = exist(fullfile(outfolder,subjids{s},'T1w',subjids{s},'dmri',[subjids{s} '_dsistudio.trk.gz.desikan_CIC_atlas.count.end.connectivity.mat']) , 'file');
    EXIST_SWMH = exist(fullfile(outfolder,subjids{s},'T1w',subjids{s},'dmri',[subjids{s} '_WMH_conn.desikan_CIC_atlas.count.end.connectivity.mat']) , 'file');
    EXIST_MWMH = exist(fullfile(outfolder,subjids{s},'T1w',subjids{s},'dmri',[subjids{s} '_dsistudio.trk.gz.desikan_CIC_atlas.lesion.end.connectivity.mat']) , 'file');
    
    if ~EXIST_MWMH | ~EXIST_STOT | ~EXIST_SWMH
        continue
    end
    
    % Load and extract upper tri elements from data
    load(fullfile(outfolder,subjids{s},'T1w',subjids{s},'dmri',[subjids{s} '_dsistudio.trk.gz.desikan_CIC_atlas.count.end.connectivity.mat']));
    StrTOT = connectivity;
    StrTOT = StrTOT(idx_ROI,idx_ROI);
    StrTOT = StrTOT(idx_ut);
    stack = cat(3,stack,connectivity);
    load(fullfile(outfolder,subjids{s},'T1w',subjids{s},'dmri',[subjids{s} '_WMH_conn.desikan_CIC_atlas.count.end.connectivity.mat']))
    StrWMH = connectivity;
    StrWMH = StrWMH(idx_ROI,idx_ROI);
    StrWMH = StrWMH(idx_ut);
    load(fullfile(outfolder,subjids{s},'T1w',subjids{s},'dmri',[subjids{s} '_dsistudio.trk.gz.desikan_CIC_atlas.lesion.end.connectivity.mat']) )
    VolWMH = connectivity;
    VolWMH = VolWMH(idx_ROI,idx_ROI);
    VolWMH = VolWMH(idx_ut);
    
    dat = [StrTOT ; StrWMH ; VolWMH];
    
    % Create row of values
    newRow = num2cell(dat');
    newRow = [subjids{s} newRow];
    
    % Append to data_cell
    data_cell = [data_cell ; newRow];
end