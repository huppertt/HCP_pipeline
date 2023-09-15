function  StudyNameMap = HCP_dicom_mapping(dicomfolder,subjid)


%This is the only part of the code, that I had to hard-code.  It should be
%easy to fix, since the Phase map should be the second map file in the list

% find the field map (if exist)
EPIFieldMapMag='None';  %TODO - make this more generic
EPIFieldMapPhase='None';


FM=dir(fullfile(dicomfolder,'*FieldMap*'));
if(~isempty(FM))
    if(length(FM)==2)
        EPIFieldMapMag=[FM(1).name '*'];  %TODO - make this more generic
        EPIFieldMapPhase=[FM(2).name '*'];
    else
        EPIFieldMapPhase=[FM(1).name '*'];
        EPIFieldMapMag=fullfile('unprocessed','3T','T1w_MPR1',[subjid '_3T_T1w_MPR1.nii.gz']);
    end
end
FM=dir(fullfile(dicomfolder,'fieldmap*'));
if(~isempty(FM))
    if(length(FM)==2)
        EPIFieldMapMag=[FM(1).name '*'];  %TODO - make this more generic
        EPIFieldMapPhase=[FM(2).name '*'];
    else
        EPIFieldMapPhase=[FM(1).name '*'];
        EPIFieldMapMag=fullfile('unprocessed','3T','T1w_MPR1',[subjid '_3T_T1w_MPR1.nii.gz']);
    end
end
FM=dir(fullfile(dicomfolder,'gre_field_map*'));
if(~isempty(FM))
    
    if(length(FM)==2)
        EPIFieldMapMag=[FM(1).name '*'];  %TODO - make this more generic
        EPIFieldMapPhase=[FM(2).name '*'];
    else
        EPIFieldMapPhase=[FM(1).name '*'];
        EPIFieldMapMag=fullfile('unprocessed','3T','T1w_MPR1',[subjid '_3T_T1w_MPR1.nii.gz']);
    end
end
cnt = 1;
StudyNameMap{cnt,1}='**T1w_MPR1*';
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','T1w_MPR1',[subjid '_3T_T1w_MPR1.nii.gz']); cnt=cnt+1;
StudyNameMap{cnt,1}='**T1w_MPR2*';
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','T1w_MPR2',[subjid '_3T_T1w_MPR2.nii.gz']); cnt=cnt+1;
StudyNameMap{cnt,1}='**T2w_SPC1*';
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','T2w_SPC1',[subjid '_3T_T2w_SPC1.nii.gz']); cnt=cnt+1;
StudyNameMap{cnt,1}='**T2w_SPC2*';
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','T2w_SPC2',[subjid '_3T_T2w_SPC2.nii.gz']); cnt=cnt+1;
% StudyNameMap{cnt,1}=EPIFieldMapMag;  %TODO - make this more generic
% StudyNameMap{cnt,2}=fullfile('unprocessed','3T','T1w_MPR1',[subjid '_3T_FieldMap_Magnitude.nii.gz']); cnt=cnt+1;
% StudyNameMap{cnt,1}=EPIFieldMapPhase;  %TODO - make this more generic
% StudyNameMap{cnt,2}=fullfile('unprocessed','3T','T1w_MPR1',[subjid '_3T_FieldMap_Phase.nii.gz']); cnt=cnt+1;

StudyNameMap{cnt,1}='*DWI_RL_dir95_1*'; 
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_DWI_dir95_RL.nii.gz']); cnt=cnt+1;
StudyNameMap{cnt,1}='*DWI_RL_dir96_1*'; 
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_DWI_dir96_RL.nii.gz']); cnt=cnt+1;
StudyNameMap{cnt,1}='*DWI_RL_dir97_1*'; 
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_DWI_dir97_RL.nii.gz']); cnt=cnt+1;
StudyNameMap{cnt,1}='*DWI_LR_dir95_1*'; 
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_DWI_dir95_LR.nii.gz']); cnt=cnt+1;
StudyNameMap{cnt,1}='*DWI_LR_dir96_1*'; 
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_DWI_dir96_LR.nii.gz']); cnt=cnt+1;
StudyNameMap{cnt,1}='*DWI_LR_dir97_1*'; 
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_DWI_dir97_LR.nii.gz']); cnt=cnt+1;
StudyNameMap{cnt,1}='*DWI_RL_dir95_SB*'; 
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_DWI_dir95_RL_SBRef.nii.gz']); cnt=cnt+1;
StudyNameMap{cnt,1}='*DWI_RL_dir96_SB*'; 
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_DWI_dir96_RL_SBRef.nii.gz']); cnt=cnt+1;
StudyNameMap{cnt,1}='*DWI_RL_dir97_SB*'; 
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_DWI_dir97_RL_SBRef.nii.gz']); cnt=cnt+1;
StudyNameMap{cnt,1}='*DWI_LR_dir95_SB*'; 
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_DWI_dir95_LR_SBRef.nii.gz']); cnt=cnt+1;
StudyNameMap{cnt,1}='*DWI_LR_dir96_SB*'; 
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_DWI_dir96_LR_SBRef.nii.gz']); cnt=cnt+1;
StudyNameMap{cnt,1}='*DWI_LR_dir97_SB*'; 
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_DWI_dir97_LR_SBRef.nii.gz']); cnt=cnt+1;
% StudyNameMap{cnt,1}=EPIFieldMapMag; 
% StudyNameMap{cnt,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_FieldMap_Magnitude.nii.gz']); cnt=cnt+1;
% StudyNameMap{cnt,1}=EPIFieldMapPhase;  
% StudyNameMap{cnt,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_FieldMap_Phase.nii.gz']); cnt=cnt+1;

StudyNameMap{cnt,1}='*DWI_dir95_AP_1*'; 
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_DWI_dir95_AP.nii.gz']); cnt=cnt+1;
StudyNameMap{cnt,1}='*DWI_dir96_AP_1*'; 
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_DWI_dir96_AP.nii.gz']); cnt=cnt+1;
StudyNameMap{cnt,1}='*DWI_dir97_AP_1*'; 
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_DWI_dir97_AP.nii.gz']); cnt=cnt+1;
StudyNameMap{cnt,1}='*DWI_dir95_PA_1*'; 
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_DWI_dir95_PA.nii.gz']); cnt=cnt+1;
StudyNameMap{cnt,1}='*DWI_dir96_PA_1*'; 
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_DWI_dir96_PA.nii.gz']); cnt=cnt+1;
StudyNameMap{cnt,1}='*DWI_dir97_PA_1*'; 
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_DWI_dir97_PA.nii.gz']); cnt=cnt+1;
StudyNameMap{cnt,1}='*DWI_dir95_AP_SB*'; 
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_DWI_dir95_AP_SBRef.nii.gz']); cnt=cnt+1;
StudyNameMap{cnt,1}='*DWI_dir96_AP_SB*'; 
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_DWI_dir96_AP_SBRef.nii.gz']); cnt=cnt+1;
StudyNameMap{cnt,1}='*DWI_dir97_AP_SB*'; 
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_DWI_dir97_AP_SBRef.nii.gz']); cnt=cnt+1;
StudyNameMap{cnt,1}='*DWI_dir95_PA_SB*'; 
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_DWI_dir95_PA_SBRef.nii.gz']); cnt=cnt+1;
StudyNameMap{cnt,1}='*DWI_dir96_PA_SB*'; 
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_DWI_dir96_PA_SBRef.nii.gz']); cnt=cnt+1;
StudyNameMap{cnt,1}='*DWI_dir97_PA_SB*'; 
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_DWI_dir97_PA_SBRef.nii.gz']); cnt=cnt+1;


StudyNameMap{cnt,1}='*dMRI_DSI64_768x768*'; 
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_DWI.nii.gz']); cnt=cnt+1;
StudyNameMap{cnt,1}='*Head_dMRI_DSI64_768x768*'; 
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_DWI.nii.gz']); cnt=cnt+1;


StudyNameMap{cnt,1}='*TSE_FLAIR*'; 
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','T2FLAIR',[subjid '_3T_T2FLAIR.nii.gz']); cnt=cnt+1;
StudyNameMap{cnt,1}='*T2w_FLAIR*'; 
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','T2FLAIR',[subjid '_3T_T2FLAIR.nii.gz']); cnt=cnt+1;
StudyNameMap{cnt,1}='*SWI_Images*'; 
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','SWI',[subjid '_3T_SWI.nii.gz']); cnt=cnt+1;
StudyNameMap{cnt,1}='*Perfusion_Weighted_*'; 
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','ASL',[subjid '_3T_Perfusion.nii.gz']); cnt=cnt+1;

StudyNameMap{cnt,1}='*Saggittal-MPRAGE_Siemens-ADNI_*';
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','T1w_MPR1',[subjid '_3T_T1w_MPR1.nii.gz']); cnt=cnt+1;
StudyNameMap{cnt,1}='*t1_fl3d_tra_iso_MPRAGE*';
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','T1w_MPR1',[subjid '_3T_T1w_MPR1.nii.gz']); cnt=cnt+1;
StudyNameMap{cnt,1}='*MPRAGE_*';
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','T1w_MPR1',[subjid '_3T_T1w_MPR1.nii.gz']); cnt=cnt+1;
StudyNameMap{cnt,1}='*SAG-MPRAGE_*';
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','T1w_MPR1',[subjid '_3T_T1w_MPR1.nii.gz']); cnt=cnt+1;

StudyNameMap{cnt,1}='*t1_mp2rage_sag_p3_iso_INV1_*';
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','T1w_MPR1',[subjid '_3T_T1w_MP2R1_inv1.nii.gz']); cnt=cnt+1;
StudyNameMap{cnt,1}='*t1_mp2rage_sag_p3_iso_INV2_*';
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','T1w_MPR1',[subjid '_3T_T1w_MP2R1_inv2.nii.gz']); cnt=cnt+1;
StudyNameMap{cnt,1}='*t1_mp2rage_sag_p3_iso_UNI_*';
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','T1w_MPR1',[subjid '_3T_T1w_MP2R1_uni.nii.gz']); cnt=cnt+1;

StudyNameMap{cnt,1}='*TSE_FLAIR_*';
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','T2FLAIR',[subjid '_3T_T2FLAIR.nii.gz']); cnt=cnt+1;
StudyNameMap{cnt,1}='*Head_TSE_FLAIR_*';
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','T2FLAIR',[subjid '_3T_T2FLAIR.nii.gz']); cnt=cnt+1;


StudyNameMap{cnt,1}='*axial_flair_tse_256x212*';
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','T2FLAIR',[subjid '_3T_T2FLAIR.nii.gz']); cnt=cnt+1;

StudyNameMap{cnt,1}='*Sagittal_MPRAGE_ADNI*';
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','T1w_MPR1',[subjid '_3T_T1w_MPR1.nii.gz']); cnt=cnt+1;

StudyNameMap{cnt,1}='*dMRI_dir95_AP_1*'; 
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_DWI_dir95_AP.nii.gz']); cnt=cnt+1;
StudyNameMap{cnt,1}='*dMRI_dir96_AP_1*'; 
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_DWI_dir96_AP.nii.gz']); cnt=cnt+1;
StudyNameMap{cnt,1}='*dMRI_dir97_AP_1*'; 
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_DWI_dir97_AP.nii.gz']); cnt=cnt+1;
StudyNameMap{cnt,1}='*dMRI_dir98_AP_1*'; 
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_DWI_dir98_AP.nii.gz']); cnt=cnt+1;
StudyNameMap{cnt,1}='*dMRI_dir99_AP_1*'; 
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_DWI_dir99_AP.nii.gz']); cnt=cnt+1;
StudyNameMap{cnt,1}='*dMRI_dir95_PA_1*'; 
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_DWI_dir95_PA.nii.gz']); cnt=cnt+1;
StudyNameMap{cnt,1}='*dMRI_dir96_PA_1*'; 
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_DWI_dir96_PA.nii.gz']); cnt=cnt+1;
StudyNameMap{cnt,1}='*dMRI_dir97_PA_1*'; 
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_DWI_dir97_PA.nii.gz']); cnt=cnt+1;
StudyNameMap{cnt,1}='*dMRI_dir98_PA_1*'; 
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_DWI_dir98_PA.nii.gz']); cnt=cnt+1;
StudyNameMap{cnt,1}='*dMRI_dir99_PA_1*'; 
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_DWI_dir99_PA.nii.gz']); cnt=cnt+1;
StudyNameMap{cnt,1}='*dMRI_dir95_AP_SB*'; 
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_DWI_dir95_AP_SBRef.nii.gz']); cnt=cnt+1;
StudyNameMap{cnt,1}='*dMRI_dir96_AP_SB*'; 
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_DWI_dir96_AP_SBRef.nii.gz']); cnt=cnt+1;
StudyNameMap{cnt,1}='*dMRI_dir97_AP_SB*'; 
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_DWI_dir97_AP_SBRef.nii.gz']); cnt=cnt+1;
StudyNameMap{cnt,1}='*dMRI_dir98_AP_SB*'; 
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_DWI_dir98_AP_SBRef.nii.gz']); cnt=cnt+1;
StudyNameMap{cnt,1}='*dMRI_dir99_AP_SB*'; 
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_DWI_dir99_AP_SBRef.nii.gz']); cnt=cnt+1;
StudyNameMap{cnt,1}='*dMRI_dir95_PA_SB*'; 
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_DWI_dir95_PA_SBRef.nii.gz']); cnt=cnt+1;
StudyNameMap{cnt,1}='*dMRI_dir96_PA_SB*'; 
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_DWI_dir96_PA_SBRef.nii.gz']); cnt=cnt+1;
StudyNameMap{cnt,1}='*dMRI_dir97_PA_SB*'; 
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_DWI_dir97_PA_SBRef.nii.gz']); cnt=cnt+1;
StudyNameMap{cnt,1}='*dMRI_dir98_PA_SB*'; 
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_DWI_dir98_PA_SBRef.nii.gz']); cnt=cnt+1;
StudyNameMap{cnt,1}='*dMRI_dir99_PA_SB*'; 
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_DWI_dir99_PA_SBRef.nii.gz']); cnt=cnt+1;
StudyNameMap{cnt,1}='*dti_896x896*';
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_DTI_896x896.nii.gz']); cnt=cnt+1;

StudyNameMap{cnt,1}='*diff_113_AP_128x128*'; 
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_DWI_dir113_AP.nii.gz']); cnt=cnt+1;
StudyNameMap{cnt,1}='*diff_113_AP_SB*'; 
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_DWI_dir113AP_SBRef.nii.gz']); cnt=cnt+1;


StudyNameMap{cnt,1}='*MPRAGE_Siemens-ADNI*';
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','T1w_MPR1',[subjid '_3T_T1w_MPR1.nii.gz']); cnt=cnt+1;
StudyNameMap{cnt,1}='*t2_fl2d*';
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','T2w_SPC1',[subjid '_3T_T2w_SPC1.nii.gz']); cnt=cnt+1;

StudyNameMap{cnt,1}='*ep2d_pASL_startCO2_after60s*';
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','HypercapniaOn',[subjid '_3T_HypercapniaOn.nii.gz']); cnt=cnt+1;
StudyNameMap{cnt,1}='*ep2d_pASL_startMedAir_after60s*';
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','HypercapniaOff',[subjid '_3T_HypercapniaOff.nii.gz']); cnt=cnt+1;

StudyNameMap{cnt,1}='*ep2d_pASL_startCO2_after60s*';
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','HypercapniaOn',[subjid '_3T_HypercapniaOn.nii.gz']); cnt=cnt+1;


StudyNameMap{cnt,1}='*Head_ep2d_TRUST_AsymShTE_*';
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','TRUST',[subjid '_3T_TRUST.nii.gz']); cnt=cnt+1;

StudyNameMap{cnt,1}='*flow_pc3d_sag_venc10_sinus_256x256*';
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','PCA',[subjid '_3T_flow_pc3d_sag_venc10_sinus.nii.gz']); cnt=cnt+1;

StudyNameMap{cnt,1}='*flow_pc3d_sag_venc10_sinus_MSUM_256x256*';
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','PCA',[subjid '_3T_flow_pc3d_sag_venc10_sinus_MSUM.nii.gz']); cnt=cnt+1;
StudyNameMap{cnt,1}='*flow_pc3d_sag_venc10_sinus_MSUM_MIP_SAG_256x256*';
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','PCA',[subjid '_3T_flow_pc3d_sag_venc10_sinus_MSUM_MIP_SAG.nii.gz']); cnt=cnt+1;
StudyNameMap{cnt,1}='*flow_pc3d_sag_venc10_sinus_MSUM_MIP_TRA_256x256*';
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','PCA',[subjid '_3T_flow_pc3d_sag_venc10_sinus_MSUM_MIP_TRA.nii.gz']); cnt=cnt+1;

StudyNameMap{cnt,1}='*Head_flow_pc3d_sag_venc10_sinus_256x256*';
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','PCA',[subjid '_3T_flow_pc3d_sag_venc10_sinus.nii.gz']); cnt=cnt+1;

StudyNameMap{cnt,1}='*Head_flow_pc3d_sag_venc10_sinus_MSUM_256x256*';
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','PCA',[subjid '_3T_flow_pc3d_sag_venc10_sinus_MSUM.nii.gz']); cnt=cnt+1;
StudyNameMap{cnt,1}='*Head_flow_pc3d_sag_venc10_sinus_MSUM_MIP_SAG_256x256*';
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','PCA',[subjid '_3T_flow_pc3d_sag_venc10_sinus_MSUM_MIP_SAG.nii.gz']); cnt=cnt+1;
StudyNameMap{cnt,1}='*Head_flow_pc3d_sag_venc10_sinus_MSUM_MIP_TRA_256x256*';
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','PCA',[subjid '_3T_flow_pc3d_sag_venc10_sinus_MSUM_MIP_TRA.nii.gz']); cnt=cnt+1;

StudyNameMap{cnt,1}='tof_fl3d_tra_multi-slab_2*';
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','TOF',[subjid '_3T_TOF_flow.nii.gz']); cnt=cnt+1;

StudyNameMap{cnt,1}='highspeed*';
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','TOF',[subjid '_3T_highspeed.nii.gz']); cnt=cnt+1;

StudyNameMap{cnt,1}='*ASL_2D*';
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','ASL',[subjid '_3T_ASL.nii.gz']); cnt=cnt+1;

StudyNameMap{cnt,1}='*3DASL*';
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','3DASL',[subjid '_3T_3DASL.nii.gz']); cnt=cnt+1;


fol=dir(fullfile(dicomfolder,StudyNameMap{cnt-1,1}));
if(~isempty(fol))
    scanID=str2num(fol(1).name(strfind(fol(1).name,'.')+1:end));
else
    scanID = 999;
end
% StudyNameMap{cnt,1}=['Perfusion_Weighted_*' num2str(scanID+2)];
% StudyNameMap{cnt,2}=fullfile('unprocessed','3T','Perfusion',[subjid '_3T_Perfusion.nii.gz']); cnt=cnt+1;
StudyNameMap{cnt,1}=['relCBF_*'  num2str(scanID+3)];
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','Perfusion',[subjid '_3T_relCBF.nii.gz']); cnt=cnt+1;

StudyNameMap{cnt,1}='*ep2d_tra_pasl_p2_during-medical-air_long_TR*';
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','Perfusion_LongTR',[subjid '_3T_PASL_LongTR.nii.gz']); cnt=cnt+1;
fol=dir(fullfile(dicomfolder,StudyNameMap{cnt-1,1}));
if(~isempty(fol))
    scanID=str2num(fol.name(strfind(fol.name,'.')+1:end));
else
    scanID = 999;
end
StudyNameMap{cnt,1}=['Perfusion_Weighted_*' num2str(scanID+2)];
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','Perfusion',[subjid '_3T_Perfusion.nii.gz']); cnt=cnt+1;

StudyNameMap{cnt,1}=['relCBF_*'  num2str(scanID+3)];
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','Perfusion_LongTR',[subjid '_3T_relCBF_LongTR.nii.gz']); cnt=cnt+1;


StudyNameMap{cnt,1}='*T1w_MPR*';
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','T1w_MPR1',[subjid '_3T_T1w_MPR1.nii.gz']); cnt=cnt+1;
StudyNameMap{cnt,1}='*T2w_SPC*';
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','T2w_SPC1',[subjid '_3T_T2w_SPC1.nii.gz']); cnt=cnt+1;

StudyNameMap{cnt,1}='*ASL_*'; 
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','ASL',[subjid '_3T_ASL.nii.gz']); cnt=cnt+1;
StudyNameMap{cnt,1}='*rest_asl_*'; 
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','ASL',[subjid '_3T_rest_ASL.nii.gz']); cnt=cnt+1;

StudyNameMap{cnt,1}='*asl_3d_MedAir1*'; 
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','ASL_MEDAIR1',[subjid '_3T_ASL_MEDAIR1.nii.gz']); cnt=cnt+1;
StudyNameMap{cnt,1}='*asl_3d_MedAir2*'; 
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','ASL_MEDAIR2',[subjid '_3T_ASL_MEDAIR2.nii.gz']); cnt=cnt+1;
StudyNameMap{cnt,1}='*asl_3d_MedAir3*'; 
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','ASL_MEDAIR3',[subjid '_3T_ASL_MEDAIR3.nii.gz']); cnt=cnt+1;

StudyNameMap{cnt,1}='*asl_3d_CO2_1*'; 
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','ASL_CO2_1',[subjid '_3T_ASL_CO2_1.nii.gz']); cnt=cnt+1;

StudyNameMap{cnt,1}='*asl_3d_CO2_2*'; 
StudyNameMap{cnt,2}=fullfile('unprocessed','3T','ASL_CO2_2',[subjid '_3T_ASL_CO2_2.nii.gz']); cnt=cnt+1;

% 
% str={'BOLD_REST1_RL','BOLD_REST1_LR','BOLD_REST2_RL','BOLD_REST2_LR',...
%     'BOLD_REST3_RL','BOLD_REST3_LR','BOLD_REST4_RL','BOLD_REST4_LR',...
%      'BOLD_MOTOR1_RL','BOLD_MOTOR1_LR','BOLD_MOTOR2_RL','BOLD_MOTOR2_LR',...
%      'BOLD_LANGUAGE1_RL','BOLD_LANGUAGE1_LR','BOLD_LANGUAGE2_RL','BOLD_LANGUAGE2_LR',...
%      'BOLD_WM1_RL','BOLD_WM1_LR','BOLD_WM2_RL','BOLD_WM2_LR',...
%      'BOLD_REST1_AP','BOLD_REST1_PA','BOLD_REST2_AP','BOLD_REST2_PA',...
%      'BOLD_REST3_AP','BOLD_REST3_PA','BOLD_REST4_AP','BOLD_REST4_PA',...
%      'BOLD_MOTOR1_AP','BOLD_MOTOR1_PA','BOLD_MOTOR2_AP','BOLD_MOTOR2_PA',...
%      'BOLD_LANGUAGE1_AP','BOLD_LANGUAGE1_PA','BOLD_LANGUAGE2_AP','BOLD_LANGUAGE2_PA',...
%      'BOLD_WM1_AP','BOLD_WM1_PA','BOLD_WM2_AP','BOLD_WM2_PA',...
%      'BOLD_MN1_AP','BOLD_MN1_PA','BOLD_MN2_AP','BOLD_MN2_PA',...
%      'BOLD_MN3_AP','BOLD_MN3_PA','BOLD_MN4_AP','BOLD_MN4_PA'...
%      'ep2d_bold_rest1','ep2d_bold_rest2','ep2d_bold_MN1','ep2d_bold_MN2',...
%      'ep2d_bold_MN3','ep2d_bold_MN4','ep2d_bold_128_rest',...
%      'BOLD_finger1','BOLD_resting_state','BOLD_foot1','BOLD_foot2','BOLD_foot3',...
%      'BOLD_Finger','BOLD_Foot-1','BOLD_Foot-2','BOLD_Foot-3','BOLD_Functional_resting',...
%      'ep2d_bold_rest1','ep2d_bold_rest2','ep2d_bold_rest3','ep2d_bold_rest4',...
%      'BOLD_IMAGINE1','BOLD_IMAGINE2','BOLD_Resting_State','BOLD_Median_Nerve_Localizer'};

str={}; 
 lst=[];
 ff=[dir(fullfile(dicomfolder,'BOLD*')); dir(fullfile(dicomfolder,'ep2d*')); ...
     dir(fullfile(dicomfolder,'*fMRI*')); dir(fullfile(dicomfolder,'*BOLD*'))];
 for i=1:length(ff)
     if(isempty(strfind(ff(i).name,'_SBRef')))
         [~,ff(i).name]=fileparts(ff(i).name);
         ff(i).name=ff(i).name(1:max(strfind(ff(i).name,'_'))-1);
     else
         lst=[lst i];
     end
 end
ff(lst)=[];
str={str{:} ff.name};
 
str=unique(str);  

 for idx=1:length(str)
     if(isempty(strfind(str{idx},'ep2d_bold')))
         str2{idx}=upper(str{idx});
     else
         str2{idx}=upper(['BOLD' str{idx}(length('ep2d_bold')+1:end)]);
     end
     StudyNameMap{cnt,1}=[str{idx} '*'];
     StudyNameMap{cnt,2}=fullfile('unprocessed','3T',str2{idx},[subjid '_3T_' str2{idx} '.nii.gz']); cnt=cnt+1;
     StudyNameMap{cnt,1}=[str{idx} '_SBRef*'];
     StudyNameMap{cnt,2}=fullfile('unprocessed','3T',str2{idx},[subjid '_3T_' str2{idx} '_SBRef.nii.gz']); cnt=cnt+1;
 end
 
 for i=1:size(StudyNameMap,1)
     fol=dir(fullfile(dicomfolder,StudyNameMap{i,1}));
     s=fileparts(StudyNameMap{i,2});
     if(~isempty(fol))
         
         StudyNameMap{cnt,1}=[EPIFieldMapPhase];
         StudyNameMap{cnt,2}=fullfile(s,[subjid '_3T_FieldMapPhase.nii.gz']);
         cnt=cnt+1;
         
         StudyNameMap{cnt,1}=[EPIFieldMapMag];
         StudyNameMap{cnt,2}=fullfile(s,[subjid '_3T_FieldMapMagnitude.nii.gz']);
         cnt=cnt+1;
                  
         
         StudyNameMap{cnt,1}='*SpinEchoFieldMap_LR*';
         StudyNameMap{cnt,2}=fullfile(s,[subjid '_3T_SpinEchoFieldMap_LR.nii.gz']);
         cnt=cnt+1;
         
         StudyNameMap{cnt,1}='*SpinEchoFieldMap_RL*';
         StudyNameMap{cnt,2}=fullfile(s,[subjid '_3T_SpinEchoFieldMap_RL.nii.gz']);
         cnt=cnt+1;
         
         StudyNameMap{cnt,1}='*SpinEchoFieldMap_AP*';
         StudyNameMap{cnt,2}=fullfile(s,[subjid '_3T_SpinEchoFieldMap_AP.nii.gz']);
         cnt=cnt+1;
         
         StudyNameMap{cnt,1}='*SpinEchoFieldMap_PA*';
         StudyNameMap{cnt,2}=fullfile(s,[subjid '_3T_SpinEchoFieldMap_PA.nii.gz']);
         cnt=cnt+1;
         
                
         StudyNameMap{cnt,1}='*BIAS_BC_64channel*';
         StudyNameMap{cnt,2}=fullfile(s,[subjid '_3T_BIAS_BC_64channel.nii.gz']);
         cnt=cnt+1;
         
     end
 end

 for i=1:size(StudyNameMap,1)
     if(~isempty(strfind(lower(StudyNameMap{i,2}),'flair')))
         StudyNameMap{i,3}='FLAIR';
     elseif(~isempty(strfind(lower(StudyNameMap{i,2}),'bias')))
         StudyNameMap{i,3}='BIAS';     
     elseif(~isempty(strfind(lower(StudyNameMap{i,2}),'spinechofieldmap')))
         StudyNameMap{i,3}='SE_FieldMap';
     elseif(~isempty(strfind(lower(StudyNameMap{i,2}),'fieldmap')))
         StudyNameMap{i,3}='FieldMap';
     elseif(~isempty(strfind(lower(StudyNameMap{i,2}),'bold')))
         StudyNameMap{i,3}='BOLD';
     elseif(~isempty(strfind(lower(StudyNameMap{i,2}),'t1')))
         StudyNameMap{i,3}='T1';
     elseif(~isempty(strfind(lower(StudyNameMap{i,2}),'t2')))
         StudyNameMap{i,3}='T2';
     elseif(~isempty(strfind(lower(StudyNameMap{i,2}),'swi')))
         StudyNameMap{i,3}='SWI';
     elseif(~isempty(strfind(lower(StudyNameMap{i,2}),'asl')))
         StudyNameMap{i,3}='ASL';
     elseif(~isempty(strfind(lower(StudyNameMap{i,2}),'perfusion')))
         StudyNameMap{i,3}='PERFUSION';
     elseif(~isempty(strfind(lower(StudyNameMap{i,2}),'diffusion')))
         StudyNameMap{i,3}='DWI';
     elseif(~isempty(strfind(lower(StudyNameMap{i,2}),'trust')))
         StudyNameMap{i,3}='TRUST';
     elseif(~isempty(strfind(lower(StudyNameMap{i,2}),'pc3d')))
         StudyNameMap{i,3}='PCA';

     else
          StudyNameMap{i,3}='';
     end
 end
 return
 