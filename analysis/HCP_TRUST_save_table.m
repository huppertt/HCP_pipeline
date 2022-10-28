function HCP_TRUST_save_table(outfolder)

subs = dir(outfolder);
subjids = {};
for i = 1:length(subs)
    if subs(i).isdir
        subjids = [subjids ; subs(i).name];
    end
end

Yvs = [];
R2s = [];
subs = {};

for i = 1:length(subjids)
    if exist(fullfile(outfolder,subjids{i},'TRUST', [subjids{i} '_TRUST_fit_noPCA.mat']))
        load(fullfile(outfolder,subjids{i},'TRUST', [subjids{i} '_TRUST_fit_noPCA.mat']))
        subs = [subs ; {subjids{i}}];
        Yvs = [Yvs ; Y_v];
        R2s = [R2s ; R2];
    end
end
tbl = table(subs,Yvs, R2s);
writetable(tbl,fullfile(outfolder, 'TRUST_Yv_values.csv'))