function CCFtable = HCP_report_Dictionary_CCF(subjid)

warning('off','MATLAB:table:ModifiedVarnames');

curdir=pwd;
cd('/disk/HCP/pipeline/analysis/Xnat');

HCProot='/disk/HCP';

%tbl=readtable(fullfile(HCProot,'pipeline','templates','HCP_S1200_DataDictionary_Sept_18_2017_TJH.xls'));
load(fullfile(HCProot,'pipeline','templates','CCF_Dictionary_template.mat'));

MyTasks={'In-Scanner Task Performance','FreeSurfer','MR Sessions','MEG Sessions','Study Completion'};
tbl=tbl(ismember(tbl.category,MyTasks),:);

values=cell(height(tbl),1);


xnatdata=Xnat_get_SubjectInfo(subjid);

cd(curdir);

if(isempty(xnatdata))
   CCFtable =[];
   return;
end

WM_count=373*2;
LANG_count=295*2;
MOTOR_count=260*2;

tfMRI_count=WM_count+LANG_count+MOTOR_count;

%% Study Completion: 3T MR
lst=find(ismember(tbl.assessment,'Study Completion: 3T MR')); cnt=1; v=[];
i{cnt}='3T_Full_MR_Compl'; v(cnt)=1*(~isempty(find(ismember(xnatdata.label,[subjid '_MR1']))) & ...
    ~isempty(find(ismember(xnatdata.label,[subjid '_MR2'])))); cnt=cnt+1;
i{cnt}='T1_Count'; v(cnt)=sum(xnatdata.frames(ismember(xnatdata.type,'T1w_MPR'))); cnt=cnt+1;
i{cnt}='T2_Count';  v(cnt)=sum(xnatdata.frames(ismember(xnatdata.type,'T2w_SPC'))); cnt=cnt+1;
i{cnt}='3T_RS-fMRI_Count';  v(cnt)=sum(xnatdata.frames(ismember(xnatdata.type,{'rfMRI_REST1_AP', 'rfMRI_REST1_PA',...
    'rfMRI_REST2_AP', 'rfMRI_REST2_PA','rfMRI_REST3_AP', 'rfMRI_REST3_PA','rfMRI_REST4_AP', 'rfMRI_REST4_PA'}))); cnt=cnt+1; 
i{cnt}='3T_RS-fMRI_PctCompl'; v(cnt)=v(cnt-1)/(420*8); cnt=cnt+1;
i{cnt}='3T_Full_Task_fMRI'; v(cnt)=sum(xnatdata.frames(ismember(xnatdata.type,{'tfMRI_LANGUAGE1_AP', 'tfMRI_LANGUAGE2_PA'...
    'tfMRI_MOTOR1_AP','tfMRI_MOTOR2_PA','tfMRI_WM1_AP','tfMRI_WM2_PA'}))); cnt=cnt+1; 
i{cnt}='3T_tMRI_PctCompl'; v(cnt)=v(cnt-1)/tfMRI_count; cnt=cnt+1;
i{cnt}='fMRI_WM_Compl'; v(cnt)=sum(xnatdata.frames(ismember(xnatdata.type,{'tfMRI_WM1_AP','tfMRI_WM2_PA'}))); cnt=cnt+1;
i{cnt}='fMRI_Gamb_Compl'; v(cnt)=0;cnt=cnt+1;
i{cnt}='fMRI_Mot_Compl'; sum(xnatdata.frames(ismember(xnatdata.type,{'tfMRI_MOTOR1_AP','tfMRI_MOTOR2_PA'}))); cnt=cnt+1;
i{cnt}='fMRI_Lang_Compl'; v(cnt)=sum(xnatdata.frames(ismember(xnatdata.type,{'tfMRI_LANGUAGE1_AP', 'tfMRI_LANGUAGE2_PA'}))); cnt=cnt+1;
i{cnt}='fMRI_Soc_Compl'; v(cnt)=NaN; cnt=cnt+1;
i{cnt}='fMRI_Rel_Compl'; v(cnt)=NaN; cnt=cnt+1;
i{cnt}='fMRI_Emo_Compl'; v(cnt)=NaN;cnt=cnt+1;
i{cnt}='fMRI_WM_PctCompl'; v(cnt)=sum(xnatdata.frames(ismember(xnatdata.type,{'tfMRI_WM1_AP','tfMRI_WM2_PA'})))/WM_count; cnt=cnt+1;
i{cnt}='fMRI_Gamb_PctCompl'; v(cnt)=NaN;cnt=cnt+1;
i{cnt}='fMRI_Mot_PctCompl'; v(cnt)=sum(xnatdata.frames(ismember(xnatdata.type,{'tfMRI_MOTOR1_AP','tfMRI_MOTOR2_PA'})))/MOTOR_count; cnt=cnt+1;
i{cnt}='fMRI_Lang_PctCompl'; v(cnt)=sum(xnatdata.frames(ismember(xnatdata.type,{'tfMRI_LANGUAGE1_AP', 'tfMRI_LANGUAGE2_PA'})))/LANG_count; cnt=cnt+1;
i{cnt}='fMRI_Soc_PctCompl'; v(cnt)=NaN; cnt=cnt+1;
i{cnt}='fMRI_Rel_PctCompl'; v(cnt)=NaN;cnt=cnt+1;
i{cnt}='fMRI_Emo_PctCompl'; v(cnt)=NaN;cnt=cnt+1;
i{cnt}='3T_dMRI_Compl'; v(cnt)=sum(xnatdata.frames(ismember(xnatdata.type,{'DWI_dir98_PA', 'DWI_dir98_AP'...
    'DWI_dir99_PA','DWI_dir99_AP'}))); cnt=cnt+1;
i{cnt}='3T_dMRI_PctCompl'; v(cnt)=v(cnt-1)/(398); cnt=cnt+1;


for id=1:cnt-1
    values{lst(find(ismember(tbl.columnHeader(lst),i{id})))}=v(id);
end


%% Study Completion: MEG
lst=find(ismember(tbl.assessment,'Study Completion: MEG')); cnt=1; v=[]; i={};

i{cnt}='MEG_AnyData'; v(cnt)=1*(~isempty(find(ismember(xnatdata.label,[subjid '_MEG'])))); cnt=cnt+1;
i{cnt}='MEG_FullProt_Compl';  v(cnt)=v(1); cnt=cnt+1;
i{cnt}='MEG_HeadModel_Avail'; v(cnt)=v(1); cnt=cnt+1;
i{cnt}='MEG_CortRibn_Avail';  v(cnt)=v(1); cnt=cnt+1;
i{cnt}='MEG_Anatomy_Avail';   v(cnt)=v(1); cnt=cnt+1;
i{cnt}='MEG_Anatomy_Compl';   v(cnt)=v(1); cnt=cnt+1;
i{cnt}='MEG_Noise_Avail'; v(cnt)=length(find(ismember(xnatdata.type,'MEG_EMPTY'))); cnt=cnt+1;
i{cnt}='MEG_Noise_Compl'; v(cnt)=v(cnt-1)/1;cnt=cnt+1;
i{cnt}='MEG_RS_Avail'; v(cnt)=length(find(ismember(xnatdata.type,'rfMEG_REST'))); cnt=cnt+1;
i{cnt}='MEG_RS_Compl'; v(cnt)=v(cnt-1)/2;cnt=cnt+1;
i{cnt}='MEG_WM_Avail'; v(cnt)=length(find(ismember(xnatdata.type,{'tfMEG_WM1','tfMEG_WM2'}))); cnt=cnt+1;
i{cnt}='MEG_WM_Compl'; v(cnt)=v(cnt-1)/2;cnt=cnt+1;
i{cnt}='MEG_StoryMath_Avail'; v(cnt)=length(find(ismember(xnatdata.type,{'tfMEG_LANGUAGE1','tfMEG_LANGUAGE2'}))); cnt=cnt+1;
i{cnt}='MEG_StoryMath_Compl'; v(cnt)=v(cnt-1)/2;cnt=cnt+1;
i{cnt}='MEG_Motor_Avail'; v(cnt)=length(find(ismember(xnatdata.type,{'tfMEG_MOTOR1','tfMEG_MOTOR2'}))); cnt=cnt+1;
i{cnt}='MEG_Motor_Compl'; v(cnt)=v(cnt-1)/2;cnt=cnt+1;

for id=1:cnt-1
    values{lst(find(ismember(tbl.columnHeader(lst),i{id})))}=v(id);
end

%% 7 T not done
lst=find(ismember(tbl.assessment,'Study Completion: 7T MR')); 
for id=1:length(lst)
    values{lst(id)}=NaN;
end

%% Session Information
lst=find(ismember(tbl.assessment,'Session Information')); cnt=1; v={}; i={};

lst2=find(ismember(xnatdata.label,[subjid '_MR1']));

str=''; l='';
if(~isempty(lst2))
    for id=1:length(lst2); str=sprintf('%s,%s[%d]',str,xnatdata.type{lst2(id)},xnatdata.frames(lst2(id))); end; str(1)=[];
    for id=1:length(lst2); l=sprintf('%s,%s',l,xnatdata.URI{lst2(id)}); end; l(1)=[];
end

i{cnt}='MRsession_Scanner'; v{cnt}='MRRC Prisma [67078]'; cnt=cnt+1;
i{cnt}='MRsession_Scans'; v{cnt}=str; cnt=cnt+1;
i{cnt}='MRsession_Label'; v{cnt}=l; cnt=cnt+1;

lst2=find(ismember(xnatdata.label,[subjid '_MR2']));
if(~isempty(lst2))
    str=''; for id=1:length(lst2); str=sprintf('%s,%s[%d]',str,xnatdata.type{lst2(id)},xnatdata.frames(lst2(id))); end; str(1)=[];
    l='';for id=1:length(lst2); l=sprintf('%s,%s',l,xnatdata.URI{lst2(id)}); end; l(1)=[];
    i{cnt}='MRsession_Scanner_3T'; v{cnt}='MRRC Prisma [67078]'; cnt=cnt+1;
end

i{cnt}='MRsession_Scans_3T'; v{cnt}=str; cnt=cnt+1;
i{cnt}='MRsession_Label_3T'; v{cnt}=l; cnt=cnt+1;

i{cnt}='MRsession_Scanner_7T'; v{cnt}=''; cnt=cnt+1;
i{cnt}='MRsession_Scans_7T'; v{cnt}=''; cnt=cnt+1;
i{cnt}='MRsession_Label_7T'; v{cnt}=''; cnt=cnt+1;

lst2=find(ismember(xnatdata.label,[subjid '_MEG']));
if(length(lst2)>0)
    str=''; for id=1:length(lst2); str=sprintf('%s,%s[%d]',str,xnatdata.type{lst2(id)},1); end; str(1)=[];
    l='';for id=1:length(lst2); l=sprintf('%s,%s',l,xnatdata.URI{lst2(id)}); end; l(1)=[];
    
    i{cnt}='MEGsession_Scanner'; v{cnt}='UPMC CAMBSI Elekta-306 '; cnt=cnt+1;
    i{cnt}='MEGsession_Scans'; v{cnt}=str; cnt=cnt+1;
    i{cnt}='MEGsession_Label'; v{cnt}=l; cnt=cnt+1;
    for id=1:cnt-1
        values{lst(find(ismember(tbl.columnHeader(lst),i{id})))}=v{id};
    end
end

%% FreeSurfer Summary Statistics
lst=find(ismember(tbl.assessment,'FreeSurfer Summary Statistics')); cnt=1; v=[]; i={};
if(exist(['/disk/HCP/analyzed/' subjid '/T1w/' subjid '/stats/aseg.stats'],'file'))
    stats=HCP_aseg_stats(['/disk/HCP/analyzed/' subjid '/T1w/' subjid '/stats/aseg.stats']);
    stats=stats([end 1:end-1],:);
    for id=1:length(lst)
        values{lst(id)}=stats.Value(id);
    end
end


%% Volume (Subcortical) Segmentation
if(exist(['/disk/HCP/analyzed/' subjid '/T1w/' subjid '/stats/aseg.stats'],'file'))
    lst=find(ismember(tbl.assessment,'Volume (Subcortical) Segmentation')); cnt=1; v=[]; i={};
    stats=HCP_stats2table(['/disk/HCP/analyzed/' subjid '/T1w/' subjid '/stats/aseg.stats']);
    stats(ismember(stats.StructName,'non-WM-hypointensities'),:)=[];
    for id=1:length(lst)
        values{lst(id)}=stats.Volume_mm3(id);
    end
end

%% Surface Thickness
if exist(['/disk/HCP/analyzed/' subjid '/T1w/' subjid '/stats/lh.aparc.stats'],'file')
    lst=find(ismember(tbl.assessment,'Surface Thickness')); cnt=1; v=[]; i={};
    stats=[HCP_stats2table(['/disk/HCP/analyzed/' subjid '/T1w/' subjid '/stats/lh.aparc.stats']); ...
        HCP_stats2table(['/disk/HCP/analyzed/' subjid '/T1w/' subjid '/stats/rh.aparc.stats'])];
    for id=1:length(lst)
        values{lst(id)}=stats.ThickAvg(id);
    end
    
    lst=find(ismember(tbl.assessment,'Surface Area')); cnt=1; v=[]; i={};
    for id=1:length(lst)
        values{lst(id)}=stats.SurfArea(id);
    end
end

lst=find(ismember(tbl.assessment,{'Emotion','Gambling','Relational','Social'}));
for id=1:length(lst)
    values{lst(id)}=NaN;
end

lst=find(ismember(tbl.assessment,{'Language'}));
f=rdir(['/disk/HCP/analyzed/' subjid '/MNINonLinear/Results/BOLD_LANGUAGE*/EVs/*_BOLD_LANGUAGE*_TAB.txt']);
s=[];
for id=1:length(f)
    t=readtable(f(id).name,'Delimiter','tab');
    if(~isempty(t))
        s=table_vcat({s; t});
    end
end

if(~isempty(s))
    flds=s.Properties.VariableNames;
    for i=1:length(flds)
        n=s.(flds{i});
        try;
            if(strcmp(class(n),'cell'))
                lst2=find(ismember(n,{'','""""','NULL'}));
                for j=1:length(lst2)
                    n{lst2(j)}='NaN';
                end
                n=str2num(strvcat(n{:}));
                s.(flds{i})=n;
            end
        end;
    end
end

if(~isempty(s) && ismember('FilteredTrialStats_CRESP',s.Properties.VariableNames))
    try; s(isnan(s.FilteredTrialStats_CRESP),:)=[]; end;
    % FilteredTrialStats_RESP    FilteredTrialStats_CRESP    FilteredTrialStats_ACC    FilteredTrialStats_RTTIME
    values{lst(1)}=length(find(strcmp(s.FilteredTrialStats_RESP,s.FilteredTrialStats_CRESP)))/height(s);
    lstt=[]; %find(~ismember(s.FilteredTrialStats_RTTIME,'NULL'));
    if(length(lstt)>0)
        values{lst(2)}=nanmedian(s.FilteredTrialStats_RTTIME(lstt));
    else
        values{lst(2)}=NaN;
    end
    
    s1=s(~isnan(s.StoryLoop),:);
    values{lst(3)}=length(find(strcmp(s1.FilteredTrialStats_RESP,s1.FilteredTrialStats_CRESP)))/height(s1);
    lstt=[]; %find(~ismember(s1.FilteredTrialStats_RTTIME,'NULL'));
    if(length(lstt)>0)
        values{lst(4)}=nanmedian(s1.FilteredTrialStats_RTTIME(lstt));
    else
        values{lst(4)}=NaN;
    end
    values{lst(5)}=nanmedian(s1.StoryLevel);
    
    s1=s(~isnan(s.MathLoop),:);
    values{lst(6)}=length(find(strcmp(s1.FilteredTrialStats_RESP,s1.FilteredTrialStats_CRESP)))/height(s1);
    lstt=[]; %find(~ismember(s1.FilteredTrialStats_RTTIME,'NULL'));
    if(length(lstt)>0)
        values{lst(7)}=nanmedian(s1.FilteredTrialStats_RTTIME(lstt));
    else
        values{lst(7)}=NaN;
    end
    values{lst(8)}=nanmedian(s1.MathLevel);
else
    for ii=1:length(lst)
        values{lst(ii)}=NaN;
    end
end

lst=find(ismember(tbl.assessment,{'Working Memory'}));
f=rdir(['/disk/HCP/analyzed/' subjid '/MNINonLinear/Results/BOLD_WM*/EVs/*_BOLD_WM*_TAB.txt']);
s=[];

keep={'StimType','TargetType','Stim_RTTime','Stim_ACC','Stim_RT','BlockType'};

for id=1:length(f)
    t=readtable(f(id).name,'Delimiter','tab');
    if(~isempty(t))
        s=table_vcat({s; t(:,ismember(t.Properties.VariableNames,keep))});
    end
end

if(~isempty(s))
    flds=s.Properties.VariableNames;
    for i=1:length(flds)
        n=s.(flds{i});
        try;
            if(strcmp(class(n),'cell'))
                lst2=find(ismember(n,{'','""""','NULL'}));
                for j=1:length(lst2)
                    n{lst2(j)}='NaN';
                end
                n=str2num(strvcat(n{:}));
                s.(flds{i})=n;
            end
        end;
    end
end
cnt=1; v=[]; i={};
if(~isempty(s))
    
    i{cnt}=    'WM_Task_Acc';       v(cnt)=nanmean(s.Stim_ACC); cnt=cnt+1;
    i{cnt}=    'WM_Task_Median_RT'; v(cnt)=nanmedian(s.Stim_RT); cnt=cnt+1;
    l=find(ismember(s.BlockType,'2-Back'));
    i{cnt}=    'WM_Task_2bk_Acc';   v(cnt)=nanmean(s.Stim_ACC(l)); cnt=cnt+1;
    i{cnt}=    'WM_Task_2bk_Median_RT'; v(cnt)=nanmedian(s.Stim_RT(l)); cnt=cnt+1;
    l=find(ismember(s.BlockType,'0-Back'));
    i{cnt}=    'WM_Task_0bk_Acc';   v(cnt)=nanmean(s.Stim_ACC(l)); cnt=cnt+1;
    i{cnt}=    'WM_Task_0bk_Median_RT'; v(cnt)=nanmedian(s.Stim_RT(l)); cnt=cnt+1;
    
    l=find(ismember(s.BlockType,'0-Back') & ismember(s.StimType,'Body'));
    i{cnt}=    'WM_Task_0bk_Body_Acc';v(cnt)=nanmean(s.Stim_ACC(l)); cnt=cnt+1;
    l=find(ismember(s.BlockType,'0-Back') & ismember(s.StimType,'Body') & ismember(s.TargetType,'target'));
    i{cnt}=    'WM_Task_0bk_Body_Acc_Target';v(cnt)=nanmean(s.Stim_ACC(l)); cnt=cnt+1;
    l=find(ismember(s.BlockType,'0-Back') & ismember(s.StimType,'Body') & ~ismember(s.TargetType,'target'));
    i{cnt}=    'WM_Task_0bk_Body_Acc_Nontarget';v(cnt)=nanmean(s.Stim_ACC(l)); cnt=cnt+1;
    
    l=find(ismember(s.BlockType,'0-Back') & ismember(s.StimType,'Face'));
    i{cnt}=    'WM_Task_0bk_Face_Acc';v(cnt)=nanmean(s.Stim_ACC(l)); cnt=cnt+1;
    l=find(ismember(s.BlockType,'0-Back') & ismember(s.StimType,'Face') & ismember(s.TargetType,'target'));
    i{cnt}=    'WM_Task_0bk_Face_Acc_Target';v(cnt)=nanmean(s.Stim_ACC(l)); cnt=cnt+1;
    l=find(ismember(s.BlockType,'0-Back') & ismember(s.StimType,'Face') & ~ismember(s.TargetType,'target'));
    i{cnt}=    'WM_Task_0bk_Face_ACC_Nontarget';v(cnt)=nanmean(s.Stim_ACC(l)); cnt=cnt+1;
    
    l=find(ismember(s.BlockType,'0-Back') & ismember(s.StimType,'Place'));
    i{cnt}=    'WM_Task_0bk_Place_Acc';v(cnt)=nanmean(s.Stim_ACC(l)); cnt=cnt+1;
    l=find(ismember(s.BlockType,'0-Back') & ismember(s.StimType,'Place') & ismember(s.TargetType,'target'));
    i{cnt}=    'WM_Task_0bk_Place_Acc_Target';v(cnt)=nanmean(s.Stim_ACC(l)); cnt=cnt+1;
    l=find(ismember(s.BlockType,'0-Back') & ismember(s.StimType,'Place') & ~ismember(s.TargetType,'target'));
    i{cnt}=    'WM_Task_0bk_Place_Acc_Nontarget';v(cnt)=nanmean(s.Stim_ACC(l)); cnt=cnt+1;
    
    l=find(ismember(s.BlockType,'0-Back') & ismember(s.StimType,'Tools'));
    i{cnt}=    'WM_Task_0bk_Tool_Acc';v(cnt)=nanmean(s.Stim_ACC(l)); cnt=cnt+1;
    l=find(ismember(s.BlockType,'0-Back') & ismember(s.StimType,'Tools') & ismember(s.TargetType,'target'));
    i{cnt}=    'WM_Task_0bk_Tool_Acc_Target';v(cnt)=nanmean(s.Stim_ACC(l)); cnt=cnt+1;
    l=find(ismember(s.BlockType,'0-Back') & ismember(s.StimType,'Tools') & ~ismember(s.TargetType,'target'));
    i{cnt}=    'WM_Task_0bk_Tool_Acc_Nontarget';v(cnt)=nanmean(s.Stim_ACC(l)); cnt=cnt+1;
    
    l=find(ismember(s.BlockType,'2-Back') & ismember(s.StimType,'Body'));
    i{cnt}=    'WM_Task_2bk_Body_Acc';v(cnt)=nanmean(s.Stim_ACC(l)); cnt=cnt+1;
    l=find(ismember(s.BlockType,'2-Back') & ismember(s.StimType,'Body') & ismember(s.TargetType,'target'));
    i{cnt}=    'WM_Task_2bk_Body_Acc_Target';v(cnt)=nanmean(s.Stim_ACC(l)); cnt=cnt+1;
    l=find(ismember(s.BlockType,'2-Back') & ismember(s.StimType,'Body') & ~ismember(s.TargetType,'target'));
    i{cnt}=    'WM_Task_2bk_Body_Acc_Nontarget';v(cnt)=nanmean(s.Stim_ACC(l)); cnt=cnt+1;
    
    
    l=find(ismember(s.BlockType,'2-Back') & ismember(s.StimType,'Face'));
    i{cnt}=    'WM_Task_2bk_Face_Acc';v(cnt)=nanmean(s.Stim_ACC(l)); cnt=cnt+1;
    l=find(ismember(s.BlockType,'2-Back') & ismember(s.StimType,'Face') & ismember(s.TargetType,'target'));
    i{cnt}=    'WM_Task_2bk_Face_Acc_Target';v(cnt)=nanmean(s.Stim_ACC(l)); cnt=cnt+1;
    l=find(ismember(s.BlockType,'2-Back') & ismember(s.StimType,'Face') & ~ismember(s.TargetType,'target'));
    i{cnt}=    'WM_Task_2bk_Face_Acc_Nontarget';v(cnt)=nanmean(s.Stim_ACC(l)); cnt=cnt+1;
    
    
    l=find(ismember(s.BlockType,'2-Back') & ismember(s.StimType,'Body'));
    i{cnt}=   'WM_Task_2bk_Place_Acc';v(cnt)=nanmean(s.Stim_ACC(l)); cnt=cnt+1;
    l=find(ismember(s.BlockType,'2-Back') & ismember(s.StimType,'Body') & ismember(s.TargetType,'target'));
    i{cnt}=   'WM_Task_2bk_Place_Acc_Target';v(cnt)=nanmean(s.Stim_ACC(l)); cnt=cnt+1;
    l=find(ismember(s.BlockType,'2-Back') & ismember(s.StimType,'Body') & ~ismember(s.TargetType,'target'));
    i{cnt}=    'WM_Task_2bk_Place_Acc_Nontarget';v(cnt)=nanmean(s.Stim_ACC(l)); cnt=cnt+1;
    
    
    l=find(ismember(s.BlockType,'2-Back') & ismember(s.StimType,'Tools'));
    i{cnt}=    'WM_Task_2bk_Tool_Acc';v(cnt)=nanmean(s.Stim_ACC(l)); cnt=cnt+1;
    l=find(ismember(s.BlockType,'2-Back') & ismember(s.StimType,'Tools') & ismember(s.TargetType,'target'));
    i{cnt}=    'WM_Task_2bk_Tool_Acc_Target';v(cnt)=nanmean(s.Stim_ACC(l)); cnt=cnt+1;
    l=find(ismember(s.BlockType,'2-Back') & ismember(s.StimType,'Tools') & ~ismember(s.TargetType,'target'));
    i{cnt}=    'WM_Task_2bk_Tool_Acc_Nontarget';v(cnt)=nanmean(s.Stim_ACC(l)); cnt=cnt+1;
    
    l=find(ismember(s.BlockType,'0-Back') & ismember(s.StimType,'Body'));
    i{cnt}=    'WM_Task_0bk_Body_Median_RT';v(cnt)=nanmedian(s.Stim_RT(l)); cnt=cnt+1;
    l=find(ismember(s.BlockType,'0-Back') & ismember(s.StimType,'Body') & ismember(s.TargetType,'target'));
    i{cnt}=    'WM_Task_0bk_Body_Median_RT_Target';v(cnt)=nanmedian(s.Stim_RT(l)); cnt=cnt+1;
    l=find(ismember(s.BlockType,'0-Back') & ismember(s.StimType,'Body') & ~ismember(s.TargetType,'target'));
    i{cnt}=    'WM_Task_0bk_Body_Median_RT_Nontarget';v(cnt)=nanmedian(s.Stim_RT(l)); cnt=cnt+1;
    
    l=find(ismember(s.BlockType,'0-Back') & ismember(s.StimType,'Face'));
    i{cnt}=    'WM_Task_0bk_Face_Median_RT';v(cnt)=nanmedian(s.Stim_RT(l)); cnt=cnt+1;
    l=find(ismember(s.BlockType,'0-Back') & ismember(s.StimType,'Face') & ismember(s.TargetType,'target'));
    i{cnt}=    'WM_Task_0bk_Face_Median_RT_Target';v(cnt)=nanmedian(s.Stim_RT(l)); cnt=cnt+1;
    l=find(ismember(s.BlockType,'0-Back') & ismember(s.StimType,'Face') & ~ismember(s.TargetType,'target'));
    i{cnt}=    'WM_Task_0bk_Face_Median_RT_Nontarget';v(cnt)=nanmedian(s.Stim_RT(l)); cnt=cnt+1;
    
    l=find(ismember(s.BlockType,'0-Back') & ismember(s.StimType,'Place'));
    i{cnt}=    'WM_Task_0bk_Place_Median_RT';v(cnt)=nanmedian(s.Stim_RT(l)); cnt=cnt+1;
    l=find(ismember(s.BlockType,'0-Back') & ismember(s.StimType,'Place') & ismember(s.TargetType,'target'));
    i{cnt}=    'WM_Task_0bk_Place_Median_RT_Target';v(cnt)=nanmedian(s.Stim_RT(l)); cnt=cnt+1;
    l=find(ismember(s.BlockType,'0-Back') & ismember(s.StimType,'Place') & ~ismember(s.TargetType,'target'));
    i{cnt}=    'WM_Task_0bk_Place_Median_RT_Nontarget';v(cnt)=nanmedian(s.Stim_RT(l)); cnt=cnt+1;
    
    l=find(ismember(s.BlockType,'0-Back') & ismember(s.StimType,'Tools'));
    i{cnt}=    'WM_Task_0bk_Tool_Median_RT';v(cnt)=nanmedian(s.Stim_RT(l)); cnt=cnt+1;
    l=find(ismember(s.BlockType,'0-Back') & ismember(s.StimType,'Tools') & ismember(s.TargetType,'target'));
    i{cnt}=    'WM_Task_0bk_Tool_Median_RT_Target';v(cnt)=nanmedian(s.Stim_RT(l)); cnt=cnt+1;
    l=find(ismember(s.BlockType,'0-Back') & ismember(s.StimType,'Tools') & ~ismember(s.TargetType,'target'));
    i{cnt}=    'WM_Task_0bk_Tool_Median_RT_Nontarget';v(cnt)=nanmedian(s.Stim_RT(l)); cnt=cnt+1;
    
    l=find(ismember(s.BlockType,'2-Back') & ismember(s.StimType,'Body'));
    i{cnt}=    'WM_Task_2bk_Body_Median_RT';v(cnt)=nanmedian(s.Stim_RT(l)); cnt=cnt+1;
    l=find(ismember(s.BlockType,'2-Back') & ismember(s.StimType,'Body') & ismember(s.TargetType,'target'));
    i{cnt}=    'WM_Task_2bk_Body_Median_RT_Target';v(cnt)=nanmedian(s.Stim_RT(l)); cnt=cnt+1;
    l=find(ismember(s.BlockType,'2-Back') & ismember(s.StimType,'Body') & ~ismember(s.TargetType,'target'));
    i{cnt}=    'WM_Task_2bk_Body_Median_RT_Nontarget';v(cnt)=nanmedian(s.Stim_RT(l)); cnt=cnt+1;
    
    
    l=find(ismember(s.BlockType,'2-Back') & ismember(s.StimType,'Face'));
    i{cnt}=    'WM_Task_2bk_Face_Median_RT';v(cnt)=nanmedian(s.Stim_RT(l)); cnt=cnt+1;
    l=find(ismember(s.BlockType,'2-Back') & ismember(s.StimType,'Face') & ismember(s.TargetType,'target'));
    i{cnt}=    'WM_Task_2bk_Face_Median_RT_Target';v(cnt)=nanmedian(s.Stim_RT(l)); cnt=cnt+1;
    l=find(ismember(s.BlockType,'2-Back') & ismember(s.StimType,'Face') & ~ismember(s.TargetType,'target'));
    i{cnt}=    'WM_Task_2bk_Face_Median_RT_Nontarget';v(cnt)=nanmedian(s.Stim_RT(l)); cnt=cnt+1;
    
    
    l=find(ismember(s.BlockType,'2-Back') & ismember(s.StimType,'Body'));
    i{cnt}=   'WM_Task_2bk_Place_Median_RT';v(cnt)=nanmedian(s.Stim_RT(l)); cnt=cnt+1;
    l=find(ismember(s.BlockType,'2-Back') & ismember(s.StimType,'Body') & ismember(s.TargetType,'target'));
    i{cnt}=   'WM_Task_2bk_Place_Median_RT_Target';v(cnt)=nanmedian(s.Stim_RT(l)); cnt=cnt+1;
    l=find(ismember(s.BlockType,'2-Back') & ismember(s.StimType,'Body') & ~ismember(s.TargetType,'target'));
    i{cnt}=    'WM_Task_2bk_Place_Median_RT_Nontarget';v(cnt)=nanmedian(s.Stim_RT(l)); cnt=cnt+1;
    
    
    l=find(ismember(s.BlockType,'2-Back') & ismember(s.StimType,'Tools'));
    i{cnt}=    'WM_Task_2bk_Tool_Median_RT';v(cnt)=nanmedian(s.Stim_RT(l)); cnt=cnt+1;
    l=find(ismember(s.BlockType,'2-Back') & ismember(s.StimType,'Tools') & ismember(s.TargetType,'target'));
    i{cnt}=    'WM_Task_2bk_Tool_Median_RT_Target';v(cnt)=nanmedian(s.Stim_RT(l)); cnt=cnt+1;
    l=find(ismember(s.BlockType,'2-Back') & ismember(s.StimType,'Tools') & ~ismember(s.TargetType,'target'));
    i{cnt}=    'WM_Task_2bk_Tool_Median_RT_Nontarget';v(cnt)=nanmedian(s.Stim_RT(l)); cnt=cnt+1;
end
for id=1:cnt-1
    values{lst(find(ismember(tbl.columnHeader(lst),i{id})))}=v(id);
end


%% TODO
% Image Reconstruction Info: 3T MR

 CCFtable=[table(values) tbl];

writetable(CCFtable,fullfile(HCProot,'analyzed',subjid,'scripts','CCF_DictionaryReport.txt'));





