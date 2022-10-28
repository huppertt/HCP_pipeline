function ROSMOVE_rfMRI_superregion_table(outfolder)

subs = dir(outfolder);
subjids = {};
for i = 1:length(subs)
    if subs(i).isdir
        subjids = [subjids ; subs(i).name];
    end
end

stack = [];
has_corr= {};
for i = 1:length(subjids)
    if exist(fullfile(outfolder,subjids{i},'MNINonLinear','Results',[subjids{i} '_rfMRI_conn_matrix_superregions.mat']))
        load(fullfile(outfolder,subjids{i},'MNINonLinear','Results',[subjids{i} '_rfMRI_conn_matrix_superregions.mat']))
        stack = cat(3,stack, r_pearson_res);
        has_corr = [has_corr ; subjids{i}];
    end
end

corr_vals = [];
for i = 1:6
    corr_vals = [corr_vals permute(stack(i,i+6,:),[3,2,1])];
end

tbl = [has_corr num2cell(atanh(corr_vals))];

tbl = cell2table(tbl,'VariableNames',{'Subjid' 'SM_L' 'SM_R' 'EX_L' 'EX_R' 'LM_L' 'LM_R'});

writetable(tbl,fullfile(outfolder,'Resting_state_superregion_connectivity.csv'))