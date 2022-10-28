function HCP_transfer_mri_physiol(subjid,dicomfolder,outfolder)
% % Example:
% outfolder='/disk/NIRS/HCP/data';
% dicomfolder='/disk/NIRS/HCP/raw/mri/2014.12.15-11.48.36/14.12.15-11:48:34-STD-1.3.12.2.1107.5.2.32.35217/';
% subjid='Testing_1';
%  HCP_unpack_data(subjid,dicomfolder,outfolder)

HCProot='/disk/HCP/';
if(nargin<3)
    outfolder=fullfile(HCProot,'analyzed');
end

physpath=fullfile(HCProot,'raw','PHYSIOL_MRI',subjid);


%This is the only part of the code, that I had to hard-code.  It should be
%easy to fix, since the Phase map should be the second map file in the list

% find the field map (if exist)
FM=dir(fullfile(dicomfolder,'FieldMap*'));
if(~isempty(FM))
    EPIFieldMapMag=[FM(1).name '*'];  %TODO - make this more generic
    EPIFieldMapPhase=[FM(2).name '*'];
else
    EPIFieldMapMag='None';  %TODO - make this more generic
    EPIFieldMapPhase='None';
end
    
 
StudyNameMap{1,1}='T1w_MPR1*';
StudyNameMap{1,2}=fullfile('unprocessed','3T','T1w_MPR1',[subjid '_3T_T1w_MPR1.nii.gz']);
StudyNameMap{2,1}='T1w_MPR2*';
StudyNameMap{2,2}=fullfile('unprocessed','3T','T1w_MPR2',[subjid '_3T_T1w_MPR2.nii.gz']);
StudyNameMap{3,1}='T2w_SPC1*';
StudyNameMap{3,2}=fullfile('unprocessed','3T','T2w_SPC1',[subjid '_3T_T2w_SPC1.nii.gz']);
StudyNameMap{4,1}='T2w_SPC2*';
StudyNameMap{4,2}=fullfile('unprocessed','3T','T2w_SPC2',[subjid '_3T_T2w_SPC2.nii.gz']);
% StudyNameMap{5,1}=EPIFieldMapMag;  %TODO - make this more generic
% StudyNameMap{5,2}=fullfile('unprocessed','3T','T1w_MPR1',[subjid '_3T_FieldMap_Magnitude.nii.gz']);
% StudyNameMap{6,1}=EPIFieldMapPhase;  %TODO - make this more generic
% StudyNameMap{6,2}=fullfile('unprocessed','3T','T1w_MPR1',[subjid '_3T_FieldMap_Phase.nii.gz']);

StudyNameMap{5,1}='DWI_RL_dir95_1*'; 
StudyNameMap{5,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_DWI_dir95_RL.nii.gz']);
StudyNameMap{6,1}='DWI_RL_dir96_1*'; 
StudyNameMap{6,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_DWI_dir96_RL.nii.gz']);
StudyNameMap{7,1}='DWI_RL_dir97_1*'; 
StudyNameMap{7,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_DWI_dir97_RL.nii.gz']);
StudyNameMap{8,1}='DWI_LR_dir95_1*'; 
StudyNameMap{8,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_DWI_dir95_LR.nii.gz']);
StudyNameMap{9,1}='DWI_LR_dir96_1*'; 
StudyNameMap{9,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_DWI_dir96_LR.nii.gz']);
StudyNameMap{10,1}='DWI_LR_dir97_1*'; 
StudyNameMap{10,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_DWI_dir97_LR.nii.gz']);
StudyNameMap{11,1}='DWI_RL_dir95_SB*'; 
StudyNameMap{11,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_DWI_dir95_RL_SBRef.nii.gz']);
StudyNameMap{12,1}='DWI_RL_dir96_SB*'; 
StudyNameMap{12,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_DWI_dir96_RL_SBRef.nii.gz']);
StudyNameMap{13,1}='DWI_RL_dir97_SB*'; 
StudyNameMap{13,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_DWI_dir97_RL_SBRef.nii.gz']);
StudyNameMap{14,1}='DWI_LR_dir95_SB*'; 
StudyNameMap{14,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_DWI_dir95_LR_SBRef.nii.gz']);
StudyNameMap{15,1}='DWI_LR_dir96_SB*'; 
StudyNameMap{15,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_DWI_dir96_LR_SBRef.nii.gz']);
StudyNameMap{16,1}='DWI_LR_dir97_SB*'; 
StudyNameMap{16,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_DWI_dir97_LR_SBRef.nii.gz']);
% StudyNameMap{19,1}=EPIFieldMapMag; 
% StudyNameMap{19,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_FieldMap_Magnitude.nii.gz']);
% StudyNameMap{20,1}=EPIFieldMapPhase;  
% StudyNameMap{20,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_FieldMap_Phase.nii.gz']);

StudyNameMap{17,1}='DWI_dir95_AP_1*'; 
StudyNameMap{17,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_DWI_dir95_AP.nii.gz']);
StudyNameMap{18,1}='DWI_dir96_AP_1*'; 
StudyNameMap{18,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_DWI_dir96_AP.nii.gz']);
StudyNameMap{19,1}='DWI_dir97_AP_1*'; 
StudyNameMap{19,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_DWI_dir97_AP.nii.gz']);
StudyNameMap{20,1}='DWI_dir95_PA_1*'; 
StudyNameMap{20,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_DWI_dir95_PA.nii.gz']);
StudyNameMap{21,1}='DWI_dir96_PA_1*'; 
StudyNameMap{21,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_DWI_dir96_PA.nii.gz']);
StudyNameMap{22,1}='DWI_dir97_PA_1*'; 
StudyNameMap{22,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_DWI_dir97_PA.nii.gz']);
StudyNameMap{23,1}='DWI_dir95_AP_SB*'; 
StudyNameMap{23,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_DWI_dir95_AP_SBRef.nii.gz']);
StudyNameMap{24,1}='DWI_dir96_AP_SB*'; 
StudyNameMap{24,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_DWI_dir96_AP_SBRef.nii.gz']);
StudyNameMap{25,1}='DWI_dir97_AP_SB*'; 
StudyNameMap{25,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_DWI_dir97_AP_SBRef.nii.gz']);
StudyNameMap{26,1}='DWI_dir95_PA_SB*'; 
StudyNameMap{26,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_DWI_dir95_PA_SBRef.nii.gz']);
StudyNameMap{27,1}='DWI_dir96_PA_SB*'; 
StudyNameMap{27,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_DWI_dir96_PA_SBRef.nii.gz']);
StudyNameMap{28,1}='DWI_dir97_PA_SB*'; 
StudyNameMap{28,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_DWI_dir97_PA_SBRef.nii.gz']);

StudyNameMap{29,1}='T2w_FLAIR*'; 
StudyNameMap{29,2}=fullfile('unprocessed','3T','T2FLAIR',[subjid '_3T_T2FLAIR.nii.gz']);
StudyNameMap{30,1}='SWI_Images*'; 
StudyNameMap{30,2}=fullfile('unprocessed','3T','SWI',[subjid '_3T_SWI.nii.gz']);
StudyNameMap{31,1}='Perfusion_Weighted_*'; 
StudyNameMap{31,2}=fullfile('unprocessed','3T','ASL',[subjid '_3T_ASL.nii.gz']);



str={'BOLD_REST1_RL','BOLD_REST1_LR','BOLD_REST2_RL','BOLD_REST2_LR',...
    'BOLD_REST3_RL','BOLD_REST3_LR','BOLD_REST4_RL','BOLD_REST4_LR',...
     'BOLD_MOTOR1_RL','BOLD_MOTOR1_LR','BOLD_MOTOR2_RL','BOLD_MOTOR2_LR',...
     'BOLD_LANGUAGE1_RL','BOLD_LANGUAGE1_LR','BOLD_LANGUAGE2_RL','BOLD_LANGUAGE2_LR',...
     'BOLD_WM1_RL','BOLD_WM1_LR','BOLD_WM2_RL','BOLD_WM2_LR',...
     'BOLD_REST1_AP','BOLD_REST1_PA','BOLD_REST2_AP','BOLD_REST2_PA',...
     'BOLD_REST3_AP','BOLD_REST3_PA','BOLD_REST4_AP','BOLD_REST4_PA',...
     'BOLD_MOTOR1_AP','BOLD_MOTOR1_PA','BOLD_MOTOR2_AP','BOLD_MOTOR2_PA',...
     'BOLD_LANGUAGE1_AP','BOLD_LANGUAGE1_PA','BOLD_LANGUAGE2_AP','BOLD_LANGUAGE2_PA',...
     'BOLD_WM1_AP','BOLD_WM1_PA','BOLD_WM2_AP','BOLD_WM2_PA'};
 
 
 
 cnt=size(StudyNameMap,1)+1;
 for idx=1:length(str)
         
     StudyNameMap{cnt,1}=[str{idx} '*'];
     StudyNameMap{cnt,2}=fullfile('unprocessed','3T',str{idx},[subjid '_3T_' str{idx} '.nii.gz']);
     cnt=cnt+1;
     StudyNameMap{cnt,1}=[str{idx} '_SBRef*'];
     StudyNameMap{cnt,2}=fullfile('unprocessed','3T',str{idx},[subjid '_3T_' str{idx} '_SBRef.nii.gz']);
     cnt=cnt+1;
 end
 
 
HCP_matlab_setenv;  % Sets the FSL, Freesurfer, etc folders 


if(~exist(outfolder))
    mkdir(outfolder)
end
if(~exist(fullfile(outfolder,subjid)))
    mkdir(fullfile(outfolder,subjid));
end

for idx=1:size(StudyNameMap,1)
    fol=dir(fullfile(dicomfolder,StudyNameMap{idx,1}));
    if(length(fol)>0)
        lst=[0 strfind(StudyNameMap{idx,2},filesep)];
        localfol=fullfile(outfolder,subjid);
        for idx2=1:length(lst)-1;
            localfol=fullfile(localfol,StudyNameMap{idx,2}(lst(idx2)+1:lst(idx2+1)-1));
            if(~exist(localfol))
                mkdir(localfol);
            end
        end
        
        f=dir(fullfile(dicomfolder,fol(1).name,'MR*'));
        dcmi=dicominfo(fullfile(dicomfolder,fol(1).name,f(1).name));
        str=['*' dcmi.AcquisitionDate '_' num2str(floor(str2num(dcmi.AcquisitionTime))) '_*.log']; 
    end
end

tbl = HCP_report_file_integrity(fullfile(outfolder,subjid),'import');

return