function tbl = HCP_statsAll(outfolder,filename)

subj=dir(outfolder);
tbl=table;
for i=1:length(subj)
    try
        if(~exist(fullfile(outfolder,subj(i).name,...
                'stats',filename),'file'))
            t = HCP_stats2table(fullfile(outfolder,subj(i).name,...
                'T1w',subj(i).name,'stats',filename));
        else
            t = HCP_stats2table(fullfile(outfolder,subj(i).name,...
                'stats',filename));
        end
        t=[table(repmat(cellstr(subj(i).name),height(t),1),'VariableNames',{'ID'}) t];
        tbl=[tbl; t];
    catch
        %1
    end
end

