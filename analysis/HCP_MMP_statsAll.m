function HCP_MMP_statsAll(outfolder)

if(nargin<1)
    outfolder='/disk/HCP/analyzed';
end

tbl=HCP_check_analysis([],outfolder);
tblStats={};
for i=1:height(tbl)
    disp(tbl.Subjid{i});
    tblStats{i,1}=HCPMMPstats(tbl.Subjid{i},outfolder);
end


f={'thickness','area','volume','myelin'};
delete(fullfile(outfolder,'Summary','Stats','HCP_MMP_Stats.xlsx'));
for fI=1:length(f)
    s=struct;
    cnt=1;
    flds=tblStats{1}.Label;
    for j=1:length(flds)
        flds{j}=genvarname(flds{j});
        s=setfield(s,flds{j},[]);
        for i=1:length(tblStats)
            if(~isempty(tblStats{i}))
                s.(flds{j})(i,1)=tblStats{i}.(f{fI})(j);
            else
                s.(flds{j})(i,1)=NaN;
            end
        end
    end
    nirs.util.write_xls(fullfile(outfolder,'Summary','Stats','HCP_MMP_Stats.xlsx'),struct2table(s),f{fI});
end
