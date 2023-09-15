function remap = HCP_sort_Xnat_Nifti(scans,day)

remap=struct('outfolder',[],'files',[]);
remap(:)=[];

% find the field maps etc
BiasBC=[];
Bias=[];
FMphase=[];
FMmag=[];
SEFM_AP=[];
SEFM_PA=[];



for i=1:length(scans)
    if(~isempty(strfind(scans(i).name,'BIAS_BC')))
        BiasBC(end+1)=i;
    end
    if(~isempty(strfind(scans(i).name,'BIAS_64CH')))
        Bias(end+1)=i;
    end
    if(~isempty(strfind(scans(i).name,'FieldMap_Magnitude')))
        FMmag(end+1)=i;
    end
    if(~isempty(strfind(scans(i).name,'FieldMap_Phase')))
        FMphase(end+1)=i;
    end

    if(~isempty(strfind(scans(i).name,'SpinEchoFieldMap_AP')))
        SEFM_AP(end+1)=i;
    end
    if(~isempty(strfind(scans(i).name,'SpinEchoFieldMap_PA')))
        SEFM_PA(end+1)=i;
    end   
end


for i=1:99
    found=nan(2,1);
    for j=1:length(scans)
        p=fileparts(scans(j).name);
         if(strcmp(scans(j).name,[p filesep num2str(i) '-gre_field_mapping']))
            found(1)=j;
            for j2=1:length(scans)
                 if(strcmp(scans(j2).name,[p filesep num2str(i+1) '-gre_field_mapping']))
                    found(2)=j2;
                 end
            end
            
         end
    end
    if(all(~isnan(found)))
        FMmag(end+1)=found(1);
        FMphase(end+1)=found(2);
    end
    
end



remapt.outfolder=[];
remapt.files={};
cnt=1;
for i=1:length(BiasBC)
    remapt.files{cnt,1}=scans(BiasBC(i)).name;
    if(i>1)
        remapt.files{cnt,2}=['_BIAS_BC' num2str(i) '.nii.gz'];
    else
        remapt.files{cnt,2}='_BIAS_BC.nii.gz';
    end
    cnt=cnt+1;
end
for i=1:length(Bias)
    remapt.files{cnt,1}=scans(Bias(i)).name;
    if(i>1)
        remapt.files{cnt,2}=['_BIAS_BC_64channel' num2str(i) '.nii.gz'];
    else
        remapt.files{cnt,2}='_BIAS_BC_64channel.nii.gz';
    end
    cnt=cnt+1;
end

for i=1:length(FMmag)
    remapt.files{cnt,1}=scans(FMmag(i)).name;
    if(i>1)
        remapt.files{cnt,2}=['_FieldMapMagnitude' num2str(i) '.nii.gz'];
    else
        remapt.files{cnt,2}='_FieldMapMagnitude.nii.gz';
    end
    cnt=cnt+1;
end
for i=1:length(FMphase)
    remapt.files{cnt,1}=scans(FMphase(i)).name;
    if(i>1)
        remapt.files{cnt,2}=['_FieldMapPhase' num2str(i) '.nii.gz'];
    else
        remapt.files{cnt,2}='_FieldMapPhase.nii.gz';
    end
    cnt=cnt+1;
end
for i=1:length(SEFM_AP)
    remapt.files{cnt,1}=scans(SEFM_AP(i)).name;
    if(i>1)
        remapt.files{cnt,2}=['_SpinEchoFieldMap_AP' num2str(i) '.nii.gz'];
    else
        remapt.files{cnt,2}='_SpinEchoFieldMap_AP.nii.gz';
    end
    cnt=cnt+1;
end
for i=1:length(SEFM_PA)
    remapt.files{cnt,1}=scans(SEFM_PA(i)).name;
    if(i>1)
        remapt.files{cnt,2}=['_SpinEchoFieldMap_PA' num2str(i) '.nii.gz'];
    else
        remapt.files{cnt,2}='_SpinEchoFieldMap_PA.nii.gz';
    end
    cnt=cnt+1;
end

for i=1:size(remapt.files,1)
    f=rdir(fullfile(remapt.files{i,1},'resources','NIFTI','files','*.nii.gz'));
    remapt.files{i,1}=f(1).name;
end

if(day==1)
keywords={'ASL' 'ASL' 'Perfusion_Weighted' [];
    'ASL' 'ASL' 'ASL' [];
     'ASL' 'ASL' 'est_asl_nog_1200ms' [];
    'BOLD_REST1_AP' 'BOLD_REST1_AP' 'rfMRI_REST_AP' 'rfMRI_REST_AP_SBRef';
    'BOLD_REST1_PA' 'BOLD_REST1_PA' 'rfMRI_REST_PA' 'rfMRI_REST_PA_SBRef';
    'BOLD_REST2_AP' 'BOLD_REST2_AP' 'rfMRI_REST_AP' 'rfMRI_REST_AP_SBRef';
    'BOLD_REST2_PA' 'BOLD_REST2_PA' 'rfMRI_REST_PA' 'rfMRI_REST_PA_SBRef';
    'BOLD_REST'     'BOLD_REST'     'Resting_state_BOLD___TURN_ON_PHYSIO' 'Resting_state_BOLD___TURN_ON_PHYSIO__SBRef';
    'BOLD_REST'     'BOLD_REST'     'ep2d_bold_128_rest' [];
    'BOLD_REST1_PA'     'BOLD_REST1_PA'     'rfMRI_REST_PA' 'rfMRI_REST_PA_SBRef';
    'BOLD_REST1_AP'     'BOLD_REST1_AP'     'rfMRI_REST_AP' 'rfMRI_REST_AP_SBRef';
    'BOLD_WM1_AP'   'BOLD_WM1_AP'   'tfMRI_WM1_AP'  'tfMRI_WM1_AP_SBRef';
    'BOLD_WM2_PA'   'BOLD_WM2_PA'   'tfMRI_WM2_PA'  'tfMRI_WM2_PA_SBRef';
    'T2w_SPC1'      'T2w_SPC1'      'T2w_SPC'       [];
    'T1w_MPR1'      'T1w_MPR1'      'T1w_MPR'       [];
    'T1w_MPR1'      'T1w_MPR1'      'MPRAGE'       [];
    'Diffusion'     'DWI_dir98_AP'  'DWI_dir98_AP'  'DWI_dir98_AP_SBRef';
    'Diffusion'     'DWI_dir99_AP'  'DWI_dir99_AP'  'DWI_dir99_AP_SBRef';
    'Diffusion'     'DWI_dir98_PA'  'DWI_dir98_PA'   'DWI_dir98_PA_SBRef';
    'Diffusion'     'DWI_dir99_PA'  'DWI_dir99_PA' 'DWI_dir99_PA_SBRef';
    'Diffusion'     'DWI_dir113_AP' 'diff_113_AP' 'diff_113_AP_SBRef';
    'Diffusion'     'DWI_AP'        'dti'   [];
    'T2FLAIR'       'T2FLAIR'      'T2w_FLAIR'      [];
     'T2FLAIR'       'T2FLAIR'      'axial_flair_tse'      [];
    'BOLD_LANGUAGE1_AP'  'BOLD_LANGUAGE1_AP' 'tfMRI_LANGUAGE1_AP' 'tfMRI_LANGUAGE1_AP_SBRef';
    'BOLD_LANGUAGE2_PA' 'BOLD_LANGUAGE2_PA' 'tfMRI_LANGUAGE2_PA' 'tfMRI_LANGUAGE2_PA_SBRef';
    'BOLD_MOTOR1_AP' 'BOLD_MOTOR1_AP'   'tfMRI_MOTOR1_AP' 'tfMRI_MOTOR1_AP_SBRef';
    'BOLD_MOTOR2_PA' 'BOLD_MOTOR2_PA'   'tfMRI_MOTOR2_PA' 'tfMRI_MOTOR2_PA_SBRef';
    'SWI'           'SWI'           'SWI_Images'    []};
else
    keywords={'ASL' 'ASL' 'ASL' [];
    'BOLD_REST3_AP' 'BOLD_REST3_AP' 'rfMRI_REST_AP' 'rfMRI_REST_AP_SBRef';
    'BOLD_REST3_PA' 'BOLD_REST3_PA' 'rfMRI_REST_PA' 'rfMRI_REST_PA_SBRef';
    'BOLD_REST4_AP' 'BOLD_REST4_AP' 'rfMRI_REST_AP' 'rfMRI_REST_AP_SBRef';
    'BOLD_REST4_PA' 'BOLD_REST4_PA' 'rfMRI_REST_PA' 'rfMRI_REST_PA_SBRef';
    'BOLD_REST'     'BOLD_REST'     'Resting_state_BOLD___TURN_ON_PHYSIO' 'Resting_state_BOLD___TURN_ON_PHYSIO__SBRef';
    'BOLD_WM1_AP'   'BOLD_WM1_AP'   'tfMRI_WM1_AP'  'tfMRI_WM1_AP_SBRef';
    'BOLD_WM2_PA'   'BOLD_WM2_PA'   'tfMRI_WM2_PA'  'tfMRI_WM2_PA_SBRef';
        'BOLD_REST1_PA'     'BOLD_REST1_PA'     'rfMRI_REST_PA' 'rfMRI_REST_PA_SBRef';
    'BOLD_REST1_AP'     'BOLD_REST1_AP'     'rfMRI_REST_AP' 'rfMRI_REST_AP_SBRef';
    'T2w_SPC1'      'T2w_SPC1'      'T2w_SPC'       [];
    'T1w_MPR1'      'T1w_MPR1'      'T1w_MPR'       [];
    'T1w_MPR1'      'T1w_MPR1'      'MPRAGE'       [];
    'Diffusion'     'DWI_dir98_AP'  'DWI_dir98_AP'  'DWI_dir98_AP_SBRef';
    'Diffusion'     'DWI_dir99_AP'  'DWI_dir99_AP'  'DWI_dir99_AP_SBRef';
    'Diffusion'     'DWI_dir98_PA'  'DWI_dir98_PA'   'DWI_dir98_PA_SBRef';
    'Diffusion'     'DWI_dir99_PA'  'DWI_dir99_PA' 'DWI_dir99_PA_SBRef';
    'T2FLAIR'       'T2FLAIR'      'T2w_FLAIR'      [];
    'BOLD_LANGUAGE1_AP'  'BOLD_LANGUAGE1_AP' 'tfMRI_LANGUAGE1_AP' 'tfMRI_LANGUAGE1_AP_SBRef';
    'BOLD_LANGUAGE2_PA' 'BOLD_LANGUAGE2_PA' 'tfMRI_LANGUAGE2_PA' 'tfMRI_LANGUAGE2_PA_SBRef';
    'BOLD_MOTOR1_AP' 'BOLD_MOTOR1_AP'   'tfMRI_MOTOR1_AP' 'tfMRI_MOTOR1_AP_SBRef';
    'BOLD_MOTOR2_PA' 'BOLD_MOTOR2_PA'   'tfMRI_MOTOR2_PA' 'tfMRI_MOTOR2_PA_SBRef';
    'SWI'           'SWI'           'SWI_Images'    []};
end
cnt=1;
for i=1:size(keywords,1)
    found=[];
    for j=1:length(scans)
        if(~isempty(strfind(scans(j).name,keywords{i,3})) & isempty(strfind(scans(j).name,'SBRef')))
            found=j;
            break
        end
    end
    if(~isempty(found))
        remap(cnt)=remapt;
        remap(cnt).outfolder=keywords{i,1};
        f=rdir(fullfile(scans(found).name,'resources','NIFTI','files','*.nii.gz'));
        
        if(isempty(f))
            f=rdir(fullfile(scans(found).name,'resources','DICOM','files','*.dcm'));
            
            if(isempty(f))
                  f=rdir(fullfile(scans(found).name,'MR*'));
                  system(['mkdir -p ' fullfile(scans(found).name,'resources','NIFTI','files')]);
                  system(['dcm2nii -4  -o ' scans(found).name ' ' f(1).name]);
                   system(['mv -v ' fullfile(scans(found).name,'*.nii.gz') ' ' fullfile(scans(found).name,'resources','NIFTI','files')]);
               
            else
                system(['dcm2nii -4  -o ' fullfile(scans(found).name,'resources','NIFTI','files') ' ' f(1).name]);
                system(['mv -v ' fullfile(scans(found).name,'resources','DICOM','files','*.nii.gz') ' ' fullfile(scans(found).name,'resources','NIFTI','files')]);
                
            end
            f=rdir(fullfile(scans(found).name,'resources','NIFTI','files','*.nii.gz'));
            

        end
        
        
        remap(cnt).files{end+1,1}=f(1).name;
        remap(cnt).files{end,2}=['_' keywords{i,2} '.nii.gz'];
        
       
        
        
        found2=[];
        for j=1:length(scans)
            if(~isempty(strfind(scans(j).name,keywords{i,4})) )
                found2=j;
                break
            end
        end
        if(~isempty(found2))
            f=rdir(fullfile(scans(found2).name,'resources','DICOM','files','*.dcm'));
            
            if(isempty(f))
                f=rdir(fullfile(scans(found2).name,'MR*'));
                system(['mkdir -p ' fullfile(scans(found2).name,'resources','NIFTI','files')]);
                system(['dcm2nii -4  -o ' scans(found2).name ' ' f(1).name]);
                system(['mv -v ' fullfile(scans(found2).name,'*.nii.gz') ' ' fullfile(scans(found2).name,'resources','NIFTI','files')]);
                
            else
                system(['dcm2nii -4  -o ' fullfile(scans(found2).name,'resources','NIFTI','files') ' ' f(1).name]);
                system(['mv -v ' fullfile(scans(found2).name,'resources','DICOM','files','*.nii.gz') ' ' fullfile(scans(found2).name,'resources','NIFTI','files')]);
                
            end
            
            
            f=rdir(fullfile(scans(found2).name,'resources','NIFTI','files','*.nii.gz'));
            remap(cnt).files{end+1,1}=f(1).name;
            remap(cnt).files{end,2}=['_' keywords{i,2} '_SBRef.nii.gz'];
        end
       
        
         f=rdir(fullfile(scans(found).name,'resources','LINKED_DATA','files','*.log'));
        if(~isempty(f))
            cnt=cnt+1;
            remap(cnt)=remapt;
            remap(cnt).files={};
            remap(cnt).outfolder=[keywords{i,1} filesep 'LINKED_DATA/PHYSIOL'];
            for j=1:length(f)
                remap(cnt).files{end+1,1}=f(j).name;
                ext=f(j).name(max(strfind(f(j).name,'_')):end);
                remap(cnt).files{end,2}=['_' keywords{i,2} ext];
            end
        end
         f=[rdir(fullfile(scans(found).name,'resources','LINKED_DATA','files','*.edat2'));
             rdir(fullfile(scans(found).name,'resources','LINKED_DATA','files','*.txt'))];
        if(~isempty(f))
            cnt=cnt+1;
            remap(cnt)=remapt;
            remap(cnt).files={};
            remap(cnt).outfolder=[keywords{i,1} filesep 'LINKED_DATA/EPRIME'];
            for j=1:length(f)
                remap(cnt).files{end+1,1}=f(j).name;
                ext=f(j).name(max(strfind(f(j).name,'_')):end);
                remap(cnt).files{end,2}=['_' keywords{i,2} ext];
            end
        end
         cnt=cnt+1;
        scans([found found2])=[];
    end
end


    