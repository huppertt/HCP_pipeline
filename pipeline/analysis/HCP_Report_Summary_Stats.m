function HCP_Report_Summary_Stats(outfolder);
if(nargin<1)
    
outfolder='/disk/sulcus1/COBRA';

end

HCP_matlab_setenv;
system(['mkdir -p ' fullfile(outfolder,'/Summary/Stats')]);

try
tbl=HCP_check_analysis([],outfolder);
nirs.util.write_xls(fullfile(outfolder,'/Summary/ProgressReport.xlsx'),tbl);
end

f=dir(outfolder);

C={}; N={}; 
for i=1:length(f); 
    try; disp(f(i).name); 
        a=HCP_report_Dictioary_CCF(f(i).name); 
        if(~isempty(a)); 
            C{end+1}=a; 
            N{end+1}=f(i).name; 
        end;
    end; 
end;

for i=1:length(C); 
    nirs.util.write_xls(fullfile(outfolder,'/Summary/Stats/HCP_DictionaryStats.xlsx'),C{i},N{i}); 
end;

% volume stats
asegstats=HCP_statsAll(outfolder,'aseg.stats');
wmstats=HCP_statsAll(outfolder,'wmparc.stats');

if(isempty(asegstats))
    return
end

try
    % this sometimes fails if the table size exceeds Java heap memory
    nirs.util.write_xls(fullfile(outfolder,'Summary/Stats/AsegAll.xls'),asegstats);
    nirs.util.write_xls(fullfile(outfolder,'Summary/Stats/WMpacrAll.xls'),wmstats);
    
    
    %
    Tbl2=[asegstats; wmstats];
    clear C wmstats Tbl asegstats
    N=unique(Tbl2.ID);
    for i=1:length(N)
        lst=find(ismember(Tbl2.ID,N{i}));
        nirs.util.write_xls(fullfile(outfolder,'Summary/Stats/HCP_FreeSurferASEGStats.xlsx'),Tbl2(lst,:),N{i});
    end
    %clear Tbl2;
end

L{1}='aparc.stats';
L{2}='aparc.DKTatlas40.stats';
L{3}='aparc.a2009s.stats';
L{4}='BA.stats';
L{5}='entorhinal_exvivo.stats';

Tbl=[];
for i=1:length(L)
    t=HCP_statsAll(outfolder,['rh.' L{i}]);
    t=[t table(repmat(cellstr('rh'),height(t),1),'VariableNames',{'Hemisphere'})];
    t=[t table(repmat(cellstr(L{i}),height(t),1),'VariableNames',{'Method'})];
    Tbl=[Tbl; t];
end
for i=1:length(L)
    t=HCP_statsAll(outfolder,['lh.' L{i}]);
    t=[t table(repmat(cellstr('lh'),height(t),1),'VariableNames',{'Hemisphere'})];
    t=[t table(repmat(cellstr(L{i}),height(t),1),'VariableNames',{'Method'})];
    Tbl=[Tbl; t];
end


N=unique(Tbl.ID);
for i=1:length(N)
    lst=find(ismember(Tbl.ID,N{i}));  
    nirs.util.write_xls(fullfile(outfolder,'Summary/Stats/HCP_FreeSurferStats.xls'),Tbl(lst,:),N{i}); 
end

Labels=strcat(Tbl.StructName,repmat(cellstr('_'),height(Tbl),1),Tbl.Hemisphere,...
    repmat(cellstr('_'),height(Tbl),1),Tbl.Method);
for i=1:length(Labels)
    Labels{i}(strfind(Labels{i},'.'))='_';
    Labels{i}(strfind(Labels{i},'-'))='_';
    Labels{i}(strfind(Labels{i},'-'))='_';
    
end
S=unique(Labels);
Subj=unique(Tbl.ID);
Flds ={'NumVert'    'SurfArea'    'GrayVol'    'ThickAvg'    'ThickStd'    'MeanCurv'    'GausCurv'    'FoldInd'    'CurvInd'};

tt={};
for i=1:length(Flds)
    D=cell(length(S)+1,length(Subj));
    for i2=1:length(Subj)
        D{1,i2}=Subj{i2};
        lst2=find(ismember(Tbl.ID,Subj{i2}));
        for i3=1:length(S)
            lst3=lst2(find(ismember({Labels{lst2}},S{i3})));
            if(isempty(lst3))
                D{i3+1,i2}=NaN;
            else
                D{i3+1,i2}=Tbl.(Flds{i})(lst3);
            end
        end
        %disp(i2);
    end
    tt{i}=cell2table(D','VariableNames',{'ID' S{:}});
    disp([Flds{i} ' done'])
    
    %     if(size(D,1)>255)
    %         cnt=1;
    %         for tIdx=1:254:size(D,1)
    %             % the code can't handle more then 255 columns on a single sheet
    %             % so hack around it
    %             tt2=tt{i}(:,[1 tIdx:min(tIdx+254,size(D,1))]);
    %
    %             nirs.util.write_xls(fullfile(outfolder,'Summary/Stats/HCP_FreeSurferStats_V2.xls'),tt2,[Flds{i} '_' num2str(cnt)]);
    %             cnt=cnt+1;
    %         end
    try
        %     else
        nirs.util.write_xls(fullfile(outfolder,'Summary/Stats/HCP_FreeSurferStats_V2.xlsx'),tt{i},Flds{i});
    catch
        disp('XLS write failed');
    end
    
    %    end
    
end


for i=1:9;  writetable(tt{i},fullfile(outfolder,'/Summary/Stats',['STATS_' Flds{i} '.txt'])); end;




%% Tbl2
clear tt;

Labels=Tbl2.StructName;
for i=1:length(Labels)
    %disp(i)
    Labels{i}(strfind(Labels{i},'.'))='_';
    Labels{i}(strfind(Labels{i},'-'))='_';
    Labels{i}(strfind(Labels{i},'-'))='_';
    if(~isempty(str2num(Labels{i}(1))))
        Labels{i}=['n' Labels{i}];
    end
end
S=unique(Labels);
Subj=unique(Tbl.ID);
Flds ={'Volume_mm3','normMean','normStdDev'};
tt={};
for i=1:length(Flds)
    D=cell(length(S)+1,length(Subj));
    for i2=1:length(Subj)
        D{1,i2}=Subj{i2};
        lst2=find(ismember(Tbl2.ID,Subj{i2}));
        for i3=1:length(S)
            lst3=lst2(find(ismember({Labels{lst2}},S{i3})));
            if(isempty(lst3))
                D{i3+1,i2}=NaN;
            else
                D{i3+1,i2}=Tbl2.(Flds{i})(lst3);
            end
        end
        %disp(i2);
    end
    tt{i}=cell2table(D','VariableNames',{'ID' S{:}});
    disp([Flds{i} ' done'])
    
    %     if(size(D,1)>255)
    %         cnt=1;
    %         for tIdx=1:254:size(D,1)
    %             % the code can't handle more then 255 columns on a single sheet
    %             % so hack around it
    %             tt2=tt{i}(:,[1 tIdx:min(tIdx+254,size(D,1))]);
    %
    %             nirs.util.write_xls(fullfile(outfolder,'Summary/Stats/HCP_FreeSurferASEGStats_V2.xls'),tt2,[Flds{i} '_' num2str(cnt)]);
    %             cnt=cnt+1;
    %         end
    %     else
    try
        nirs.util.write_xls(fullfile(outfolder,'Summary/Stats/HCP_FreeSurferASEGStats_V2.xlsx'),tt{i},Flds{i});
    catch
        disp('XLS write failed');
    end
    
    %    end
    
end

for i=1:length(Flds);  writetable(tt{i},fullfile(outfolder,'/Summary/Stats',['STATS_' Flds{i} '.txt'])); end;

PET_stats(outfolder);

curdir=pwd;
CCF_Dictionary_All(outfolder);
cd(curdir);

f=rdir(fullfile(outfolder,'**/stats/aseg.stats'));
tbl=table;
for i=1:length(f); tbl=[tbl; getasegstats(f(i).name)]; end;

try;
nirs.util.write_xls(fullfile(outfolder,'Summary/Stats/HCP_FreeSurferASEGStats_V2.xlsx'),tbl,'TotalBrainStats');
end
 writetable(tbl,fullfile(outfolder,'/Summary/Stats','TotalBrainStats.txt')); 


