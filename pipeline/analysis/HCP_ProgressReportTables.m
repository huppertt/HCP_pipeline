function HCP_ProgressReportTables(outfolder)

if(nargin<1)
    outfolder='/disk/HCP/analyzed';
end

HCP_matlab_setenv;

curdir=pwd;
cd('/disk/HCP/pipeline/analysis/Xnat');

tbl= Xnat_get_all_data([],outfolder);

for i=1:height(tbl); 
    try; 
        try; 
            cat(i,1)=tbl.cat_id{i};
        catch; 
            cat(i,1)=str2num(tbl.cat_id{i}(1:strfind(tbl.cat_id{i},'-')-1)); 
        end; 
    catch
        cat(i,1)=NaN; 
    end; 
end;
cat(isnan(cat))=0;
tbl.cat_id=cat;

lst=ismember(tbl.Properties.VariableNames,{'cat_desc','label','cat_id'});

utbl=unique(tbl(:,lst));
subj=unique(tbl.subjid);

utbl(~ismember(utbl.label,{'DICOM','LINKED_DATA'}),:)=[];


tbl.uname=strcat(tbl.cat_desc,repmat(cellstr('_'),height(tbl),1),tbl.label);
lst=find(ismember(tbl.cat_desc,{'rfMRI_REST_AP_SBRef','rfMRI_REST_AP','rfMRI_REST_PA_SBRef','rfMRI_REST_PA'}));
for i=1:length(lst)
   if(tbl.cat_id(lst(i))>20)
             tbl.uname{lst(i)}=[tbl.cat_desc{lst(i)}  '_MR1' '_' tbl.label{lst(i)}];
        else
             tbl.uname{lst(i)}=[tbl.cat_desc{lst(i)}  '_MR2' '_' tbl.label{lst(i)}];
        end
    disp(i)
end

utbl.uname=strcat(utbl.cat_desc,repmat(cellstr('_'),height(utbl),1),utbl.label);
for i=1:height(utbl)
     if(ismember(utbl.cat_desc{i},{'rfMRI_REST_AP_SBRef','rfMRI_REST_AP','rfMRI_REST_PA_SBRef','rfMRI_REST_PA'}))
        if(utbl.cat_id(i)>20)
             utbl.uname{i}=[utbl.cat_desc{i}  '_MR1' '_' utbl.label{i}];
        else
             utbl.uname{i}=[utbl.cat_desc{i}  '_MR2' '_' utbl.label{i}];
        end
    end
end

utbl.cat_id=[];
utbl=unique(utbl);

Rename={'tfMEG_LANGUAGE1_LINKED_DATA'
    'tfMEG_MOTOR1_LINKED_DATA'
    'tfMEG_MOTOR2_LINKED_DATA'
    'tfMEG_WM1_LINKED_DATA'
    'tfMEG_WM2_LINKED_DATA'
    'AAHScout_DICOM'
    'AAHScout_LINKED_DATA'
    'AAHScout_MPR_cor_DICOM'
    'AAHScout_MPR_sag_DICOM'
    'AAHScout_MPR_tra_DICOM'
    'AAHead_Scout_64ch-head-coil_DICOM'
    'AAHead_Scout_64ch-head-coil_MPR_cor_DICOM'
    'AAHead_Scout_64ch-head-coil_MPR_sag_DICOM'
    'AAHead_Scout_64ch-head-coil_MPR_sag_LINKED_DATA'
    'AAHead_Scout_64ch-head-coil_MPR_tra_DICOM'
    'ASL_DICOM'
    'ASL_LINKED_DATA'
    'ASL_M0_DICOM'
    'AXIAL RECONS_DICOM'
    'BIAS_64CH_DICOM'
    'BIAS_64CH_LINKED_DATA'
    'BIAS_BC_20channel_DICOM'
    'BIAS_BC_64CH_DICOM'
    'BIAS_BC_64CH_LINKED_DATA'
    'BIAS_BC_DICOM'
    'BOLD_LANGUAGE1_AP_DICOM'
    'BOLD_LANGUAGE1_AP_LINKED_DATA'
    'BOLD_LANGUAGE1_AP_PhysioLog_LINKED_DATA'
    'BOLD_LANGUAGE1_AP_SBRef_DICOM'
    'BOLD_MOTOR1_AP_DICOM'
    'BOLD_MOTOR1_AP_LINKED_DATA'
    'BOLD_MOTOR1_AP_PhysioLog_LINKED_DATA'
    'BOLD_MOTOR1_AP_SBRef_DICOM'
    'BOLD_MOTOR2_PA_DICOM'
    'BOLD_MOTOR2_PA_LINKED_DATA'
    'BOLD_MOTOR2_PA_PhysioLog_LINKED_DATA'
    'BOLD_MOTOR2_PA_SBRef_DICOM'
    'BOLD_MOTOR2_PA_SBRef_LINKED_DATA'
    'BOLD_MOTOR2_PA_SBRef_repeat_DICOM'
    'BOLD_REST1_AP_PhysioLog_LINKED_DATA'
    'BOLD_REST1_PA_PhysioLog_LINKED_DATA'
    'BOLD_REST2_AP_PhysioLog_LINKED_DATA'
    'BOLD_REST2_PA_PhysioLog_LINKED_DATA'
    'BOLD_REST3_AP_DICOM'
    'BOLD_REST3_AP_LINKED_DATA'
    'BOLD_REST3_AP_PhysioLog_LINKED_DATA'
    'BOLD_REST3_AP_SBRef_DICOM'
    'BOLD_REST3_PA_DICOM'
    'BOLD_REST3_PA_LINKED_DATA'
    'BOLD_REST3_PA_PhysioLog_LINKED_DATA'
    'BOLD_REST3_PA_SBRef_DICOM'
    'BOLD_REST4_AP_DICOM'
    'BOLD_REST4_AP_LINKED_DATA'
    'BOLD_REST4_AP_PhysioLog_LINKED_DATA'
    'BOLD_REST4_AP_SBRef_DICOM'
    'BOLD_REST4_PA_DICOM'
    'BOLD_REST4_PA_LINKED_DATA'
    'BOLD_REST4_PA_PhysioLog_LINKED_DATA'
    'BOLD_REST4_PA_SBRef_DICOM'
    'BOLD_WM1_AP_PhysioLog_LINKED_DATA'
    'BOLD_WM2_PA_PhysioLog_LINKED_DATA'
    'DWI_dir98_AP_DICOM'
    'DWI_dir98_AP_SBRef_DICOM'
    'DWI_dir98_PA_DICOM'
    'DWI_dir98_PA_SBRef_DICOM'
    'DWI_dir99_AP_DICOM'
    'DWI_dir99_AP_SBRef_DICOM'
    'DWI_dir99_PA_DICOM'
    'DWI_dir99_PA_LINKED_DATA'
    'DWI_dir99_PA_SBRef_DICOM'
    'FieldMap_DICOM'
    'FieldMap_Magnitude_DICOM'
    'FieldMap_Phase_DICOM'
    'FieldMap_Phase_LINKED_DATA'
    'HighSpeed_SB_DICOM'
    'Localizer_DICOM'
    'Localizer_aligned_DICOM'
    'Localizer_aligned_LINKED_DATA'
    'Perfusion_Weighted_DICOM'
    'PhoenixZIPReport_DICOM'
    'SWI_Images_DICOM'
    'SWI_Images_LINKED_DATA'
    'SpinEchoFieldMap_AP_DICOM'
    'SpinEchoFieldMap_AP_LINKED_DATA'
    'SpinEchoFieldMap_PA_DICOM'
    'SpinEchoFieldMap_PA_LINKED_DATA'
    'T1w_MPR_DICOM'
    'T1w_MPR_LINKED_DATA'
    'T2w_FLAIR_DICOM'
    'T2w_SPC_DICOM'
    'T2w_SPC_LINKED_DATA'
    'TOF_Limited_FOV_DICOM'
    'TOF_Limited_FOV_MIP_COR_DICOM'
    'TOF_Limited_FOV_MIP_SAG_DICOM'
    'TOF_Limited_FOV_MIP_TRA_DICOM'
    'ax recon_DICOM'
    'cor recon_DICOM'
    'dMRI_dir98_AP_DICOM'
    'dMRI_dir98_AP_SBRef_DICOM'
    'dMRI_dir98_PA_DICOM'
    'dMRI_dir98_PA_SBRef_DICOM'
    'dMRI_dir99_AP_DICOM'
    'dMRI_dir99_AP_SBRef_DICOM'
    'dMRI_dir99_AP_SBRef_LINKED_DATA'
    'dMRI_dir99_PA_DICOM'
    'dMRI_dir99_PA_LINKED_DATA'
    'dMRI_dir99_PA_SBRef_DICOM'
    'ep2d_mb_pasl_scout20_DICOM'
    'ep2d_mb_pasl_scout24_DICOM'
    'localizer  manually start physio_DICOM'
    'mIP_Images(SW)_DICOM'
    'rfMRI_REST1_AP_DICOM'
    'rfMRI_REST1_AP_LINKED_DATA'
    'rfMRI_REST1_AP_SBRef_DICOM'
    'rfMRI_REST1_PA_DICOM'
    'rfMRI_REST1_PA_LINKED_DATA'
    'rfMRI_REST1_PA_SBRef_DICOM'
    'rfMRI_REST1_PA_SBRef_LINKED_DATA'
    'rfMRI_REST2_AP_DICOM'
    'rfMRI_REST2_AP_LINKED_DATA'
    'rfMRI_REST2_AP_SBRef_DICOM'
    'rfMRI_REST2_PA_DICOM'
    'rfMRI_REST2_PA_LINKED_DATA'
    'rfMRI_REST2_PA_SBRef_DICOM'
    'rfMRI_REST3_AP_LINKED_DATA'
    'rfMRI_REST_AP_MR1_DICOM'
    'rfMRI_REST_AP_MR1_LINKED_DATA'
    'rfMRI_REST_AP_MR2_DICOM'
    'rfMRI_REST_AP_MR2_LINKED_DATA'
    'rfMRI_REST_AP_SBRef_MR1_DICOM'
    'rfMRI_REST_AP_SBRef_MR2_DICOM'
    'rfMRI_REST_PA_MR1_DICOM'
    'rfMRI_REST_PA_MR1_LINKED_DATA'
    'rfMRI_REST_PA_MR2_DICOM'
    'rfMRI_REST_PA_MR2_LINKED_DATA'
    'rfMRI_REST_PA_SBRef_MR1_DICOM'
    'rfMRI_REST_PA_SBRef_MR2_DICOM'
    'rfMRI_WM1_AP_SBRef_DICOM'
    't1_tse_fs_tra__DICOM'
    'tfMRI_LANGUAGE1_AP.txt_LINKED_DATA'
    'tfMRI_LANGUAGE1_AP_DICOM'
    'tfMRI_LANGUAGE1_AP_LINKED_DATA'
    'tfMRI_LANGUAGE1_AP_SBRef_DICOM'
    'tfMRI_LANGUAGE2_PA_DICOM'
    'tfMRI_LANGUAGE2_PA_LINKED_DATA'
    'tfMRI_LANGUAGE2_PA_SBRef_DICOM'
    'tfMRI_MOTOR1_AP.edat2_LINKED_DATA'
    'tfMRI_MOTOR1_AP_DICOM'
    'tfMRI_MOTOR1_AP_LINKED_DATA'
    'tfMRI_MOTOR1_AP_SBRef_DICOM'
    'tfMRI_MOTOR2_PA.edat2_LINKED_DATA'
    'tfMRI_MOTOR2_PA_DICOM'
    'tfMRI_MOTOR2_PA_LINKED_DATA'
    'tfMRI_MOTOR2_PA_SBRef_DICOM'
    'tfMRI_WM1_AP.edat2_LINKED_DATA'
    'tfMRI_WM1_AP_DICOM'
    'tfMRI_WM1_AP_LINKED_DATA'
    'tfMRI_WM1_AP_SBRef_DICOM'
    'tfMRI_WM2_PA.edat2_LINKED_DATA'
    'tfMRI_WM2_PA_DICOM'
    'tfMRI_WM2_PA_LINKED_DATA'
    'tfMRI_WM2_PA_SBRef_DICOM'
    'vessel_scout_head_MSUM_DICOM'
    'vessel_scout_head_MSUM_MIP_SAG_DICOM'
    'PET PiB Brain BP_All Pass 256_3.09Z_No match CT_DICOM'};


Rename2={'tfMEG_LANGUAGE1_LINKED_DATA'
    'tfMEG_MOTOR1_LINKED_DATA'
    'tfMEG_MOTOR2_LINKED_DATA'
    'tfMEG_WM1_LINKED_DATA'
    'tfMEG_WM2_LINKED_DATA'
    'AAHScout_DICOM'
    'REMOVE'
    'REMOVE'
    'REMOVE'
    'REMOVE'
    'REMOVE'
    'REMOVE'
    'REMOVE'
    'REMOVE'
    'REMOVE'
    'ASL_DICOM'
    'REMOVE'
    'REMOVE'
    'REMOVE'
    'BIAS_64CH_DICOM'
    'REMOVE'
    'REMOVE'
    'BIAS_BC_64CH_DICOM'
    'REMOVE'
    'REMOVE'
    'BOLD_LANGUAGE1_AP_DICOM'
    'BOLD_LANGUAGE1_AP_LINKED_DATA'
    'REMOVE'
    'BOLD_LANGUAGE1_AP_SBRef_DICOM'
    'BOLD_MOTOR1_AP_DICOM'
    'BOLD_MOTOR1_AP_LINKED_DATA'
    'REMOVE'
    'BOLD_MOTOR1_AP_SBRef_DICOM'
    'BOLD_MOTOR2_PA_DICOM'
    'BOLD_MOTOR2_PA_LINKED_DATA'
    'REMOVE'
    'BOLD_MOTOR2_PA_SBRef_DICOM'
    'REMOVE'
    'REMOVE'
    'REMOVE'
    'REMOVE'
    'REMOVE'
    'REMOVE'
    'BOLD_REST3_AP_DICOM'
    'BOLD_REST3_AP_LINKED_DATA'
    'REMOVE'
    'BOLD_REST3_AP_SBRef_DICOM'
    'BOLD_REST3_PA_DICOM'
    'BOLD_REST3_PA_LINKED_DATA'
    'REMOVE'
    'BOLD_REST3_PA_SBRef_DICOM'
    'BOLD_REST4_AP_DICOM'
    'BOLD_REST4_AP_LINKED_DATA'
    'REMOVE'
    'BOLD_REST4_AP_SBRef_DICOM'
    'BOLD_REST4_PA_DICOM'
    'BOLD_REST4_PA_LINKED_DATA'
    'REMOVE'
    'BOLD_REST4_PA_SBRef_DICOM'
    'REMOVE'
    'REMOVE'
    'DWI_dir98_AP_DICOM'
    'DWI_dir98_AP_SBRef_DICOM'
    'DWI_dir98_PA_DICOM'
    'DWI_dir98_PA_SBRef_DICOM'
    'DWI_dir99_AP_DICOM'
    'DWI_dir99_AP_SBRef_DICOM'
    'DWI_dir99_PA_DICOM'
    'REMOVE'
    'DWI_dir99_PA_SBRef_DICOM'
    'FieldMap_DICOM'
    'FieldMap_Magnitude_DICOM'
    'FieldMap_Phase_DICOM'
    'REMOVE'
    'REMOVE'
    'Localizer_DICOM'
    'Localizer_aligned_DICOM'
    'REMOVE'
    'Perfusion_Weighted_DICOM'
    'REMOVE'
    'SWI_Images_DICOM'
    'REMOVE'
    'SpinEchoFieldMap_AP_DICOM'
    'REMOVE'
    'SpinEchoFieldMap_PA_DICOM'
    'REMOVE'
    'T1w_MPR_DICOM'
    'REMOVE'
    'T2w_FLAIR_DICOM'
    'T2w_SPC_DICOM'
    'REMOVE'
    'REMOVE'
    'REMOVE'
    'REMOVE'
    'REMOVE'
    'REMOVE'
    'REMOVE'
    'DWI_dir98_AP_DICOM'
    'DWI_dir98_AP_SBRef_DICOM'
    'DWI_dir98_PA_DICOM'
    'DWI_dir98_PA_SBRef_DICOM'
    'DWI_dir99_AP_DICOM'
    'DWI_dir99_AP_SBRef_DICOM'
    'DWI_dir99_AP_SBRef_LINKED_DATA'
    'DWI_dir99_PA_DICOM'
    'DWI_dir99_PA_LINKED_DATA'
    'DWI_dir99_PA_SBRef_DICOM'
    'REMOVE'
    'REMOVE'
    'REMOVE'
    'REMOVE'
    'BOLD_REST1_AP_DICOM'
    'BOLD_REST1_AP_LINKED_DATA'
    'BOLD_REST1_AP_SBRef_DICOM'
    'BOLD_REST1_PA_DICOM'
    'BOLD_REST1_PA_LINKED_DATA'
    'BOLD_REST1_PA_SBRef_DICOM'
    'BOLD_REST1_PA_SBRef_LINKED_DATA'
    'BOLD_REST2_AP_DICOM'
    'BOLD_REST2_AP_LINKED_DATA'
    'BOLD_REST2_AP_SBRef_DICOM'
    'BOLD_REST2_PA_DICOM'
    'BOLD_REST2_PA_LINKED_DATA'
    'BOLD_REST2_PA_SBRef_DICOM'
    'BOLD_REST3_AP_LINKED_DATA'
    'BOLD_REST1_AP_DICOM'
    'BOLD_REST1_AP_LINKED_DATA'
    'BOLD_REST3_AP_DICOM'
    'BOLD_REST3_AP_LINKED_DATA'
    'BOLD_REST1_AP_SBRef_DICOM'
    'BOLD_REST3_AP_SBRef_DICOM'
    'BOLD_REST2_PA_DICOM'
    'BOLD_REST2_PA_LINKED_DATA'
    'BOLD_REST4_PA_DICOM'
    'BOLD_REST4_PA_LINKED_DATA'
    'BOLD_REST2_PA_SBRef_DICOM'
    'BOLD_REST3_PA_SBRef_DICOM'
    'BOLD_WM1_AP_SBRef_DICOM'
    'REMOVE'
    'BOLD_LANGUAGE1_AP_LINKED_DATA'
    'BOLD_LANGUAGE1_AP_DICOM'
    'BOLD_LANGUAGE1_AP_LINKED_DATA'
    'BOLD_LANGUAGE1_AP_SBRef_DICOM'
    'BOLD_LANGUAGE2_PA_DICOM'
    'BOLD_LANGUAGE2_PA_LINKED_DATA'
    'BOLD_LANGUAGE2_PA_SBRef_DICOM'
    'BOLD_MOTOR1_AP_LINKED_DATA'
    'BOLD_MOTOR1_AP_DICOM'
    'BOLD_MOTOR1_AP_LINKED_DATA'
    'BOLD_MOTOR1_AP_SBRef_DICOM'
    'BOLD_MOTOR2_PA_LINKED_DATA'
    'BOLD_MOTOR2_PA_DICOM'
    'BOLD_MOTOR2_PA_LINKED_DATA'
    'BOLD_MOTOR2_PA_SBRef_DICOM'
    'BOLD_WM1_AP_LINKED_DATA'
    'BOLD_WM1_AP_DICOM'
    'BOLD_WM1_AP_LINKED_DATA'
    'BOLD_WM1_AP_SBRef_DICOM'
    'BOLD_WM2_PA_LINKED_DATA'
    'BOLD_WM2_PA_DICOM'
    'BOLD_WM2_PA_LINKED_DATA'
    'BOLD_WM2_PA_SBRef_DICOM'
    'REMOVE'
    'REMOVE'
    'PET PiB Brain_DICOM'};


for i=1:length(Rename)
    disp(i)
    lst=find(ismember(tbl.uname,Rename{i}));
    for j=1:length(lst)
        tbl.uname{lst(j)}=Rename2{i};
    end
end


for i=1:length(Rename)
    disp(i)
    lst=find(ismember(utbl.uname,Rename{i}));
    for j=1:length(lst)
        utbl.uname{lst(j)}=Rename2{i};
    end
end



D=cell(height(utbl),length(subj)+2);
for i=1:height(utbl)
    disp(i)
    for j=1:length(subj)
        lst=find(ismember(tbl.uname,utbl.uname{i}) & ismember(tbl.subjid,subj{j}));
        D{i,1}=utbl.uname{i};
        if(~isempty(strfind(utbl.uname{i},'MEG')))
            D{i,2}='MEG';
        elseif(~isempty(strfind(utbl.uname{i},'PET')))
            D{i,2}='PET';
        else
            D{i,2}='MRI';
        end
        
        D{i,2+j}=length(lst);
    end
end

tbl2=unique(cell2table(D,'VariableNames',{'FileName','Modality',subj{:}}));
tbl2=sortrows(tbl2,{'Modality','FileName'});

nirs.util.write_xls(fullfile(outfolder,'Summary','XnatUploadList.xls'),tbl2);


% now do the motion table
s=struct;
f=rdir([outfolder '/*/BOLD*/Movement_Regressors.txt']);
for i=1:length(f)
    d=dlmread(f(i).name);
    lst=strfind(f(i).name,filesep);
    s(i).File=f(i).name;
    s(i).Subject=f(i).name(1:lst(1)-1);
    s(i).Task=f(i).name(lst(1)+1:lst(2)-1);
    s(i).rmsX=sqrt(mean(d(:,1).^2));
    s(i).rmsY=sqrt(mean(d(:,2).^2));
    s(i).rmsZ=sqrt(mean(d(:,3).^2));
    s(i).rmsA1=sqrt(mean(d(:,4).^2));
    s(i).rmsA2=sqrt(mean(d(:,5).^2));
    s(i).rmsA3=sqrt(mean(d(:,6).^2));
    s(i).maxX=max(abs(d(:,1)));
    s(i).maxY=max(abs(d(:,2)));
    s(i).maxZ=max(abs(d(:,3)));
    s(i).maxA1=max(abs(d(:,4)));
    s(i).maxA2=max(abs(d(:,5)));
    s(i).maxA3=max(abs(d(:,6)));
    
end

tbl3=struct2table(s);

utasks=unique(tbl3.Task);

lst=[];
for i=1:length(utasks)
    if(isempty(strfind(utasks{i},'_3')) & ...
           isempty(strfind(utasks{i},'_4')))
        lst=[lst i];
    end
end
utasks={utasks{lst}};

usubj=unique(tbl3.Subject);
flds=tbl3.Properties.VariableNames(4:end);

D=cell(length(utasks)*length(flds),length(usubj)+2);
for i=1:length(flds)
    for j=1:length(usubj)
        for k=1:length(utasks)
            lst=find(ismember(tbl3.Subject,usubj{j}) & ...
                ismember(tbl3.Task,utasks{k}));
            if(~isempty(lst))
                D{(i-1)*length(utasks)+k,1}=utasks{k};
                D{(i-1)*length(utasks)+k,2}=flds{i};
                D{(i-1)*length(utasks)+k,2+j}=tbl3.(flds{i})(lst);
            else
                D{(i-1)*length(utasks)+k,1}=utasks{k};
                D{(i-1)*length(utasks)+k,2}=flds{i};
                D{(i-1)*length(utasks)+k,2+j}=NaN;
            end
            
        end
    end
end

tbl3=cell2table(D,'VariableNames',{'Task','Parameter',usubj{:}});


nirs.util.write_xls(fullfile(outfolder,'Summary','MotionStats.xls'),tbl3);





