function tblStats=HCP_Collect_EPRIME_STATS(subjid);

warning('off','MATLAB:table:ModifiedVarnames');

f=rdir(fullfile(subjid,'unprocessed','3T','BOLD_WM*','LINKED_DATA','EPRIME','*_TAB.txt'));

tbl=[];
for i=1:length(f)
    a=readtable(f(i).name,'Delimiter','\t');
    lst=find(ismember(a.Properties.VariableNames,{'TargetType','StimType','BlockType','Stim_RT','Stim_ACC'}));
    tbl=[tbl; a(:,lst)];
end

lst=find(ismember(tbl.Properties.VariableNames,{'TargetType','StimType','BlockType'}));

ut=unique(tbl(:,lst));
ut(1,:)=[];

for i=1:height(ut)
    t=tbl(ismember(tbl(:,lst),ut(i,:)),:);
    S.Count(i,1)=height(t);
    S.ACC(i,1)=mean(t.Stim_ACC);
    S.RT(i,1)=mean(t.Stim_RT);
end

tblStats=[ut struct2table(S)];

disp(['Saving: ' fullfile(subjid,'Stats','WM_Eprime.stats')]);
writetable(tblStats,fullfile(subjid,'Stats','WM_Eprime.stats'),'FileType','txt');