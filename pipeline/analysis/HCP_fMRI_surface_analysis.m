function varargout=HCP_fMRI_surface_analysis(subjid,outfolder,runslurm,force)

HCProot='/aionraid/huppertt/raid2_BU/HCP/';
if(nargin<2 || isempty(outfolder))
    outfolder=fullfile(HCProot,'analyzed');
end


if(nargin<3)
    runslurm=false;
end

if(nargin<4)
    force=false;
end

HCP_matlab_setenv;  % Sets the FSL, Freesurfer, etc folders 

str={'BOLD_REST1_RL','BOLD_REST1_LR','BOLD_REST2_RL','BOLD_REST2_LR',...
    'BOLD_REST3_RL','BOLD_REST3_LR','BOLD_REST4_RL','BOLD_REST4_LR',...
     'BOLD_MOTOR1_RL','BOLD_MOTOR1_LR','BOLD_MOTOR2_RL','BOLD_MOTOR2_LR',...
     'BOLD_LANGUAGE1_RL','BOLD_LANGUAGE1_LR','BOLD_LANGUAGE2_RL','BOLD_LANGUAGE2_LR',...
     'BOLD_WM1_RL','BOLD_WM1_LR','BOLD_WM2_RL','BOLD_WM2_LR',...
     'BOLD_REST1_AP','BOLD_REST1_PA','BOLD_REST2_AP','BOLD_REST2_PA',...
     'BOLD_REST3_AP','BOLD_REST3_PA','BOLD_REST4_AP','BOLD_REST4_PA',...
     'BOLD_MOTOR1_AP','BOLD_MOTOR1_PA','BOLD_MOTOR2_AP','BOLD_MOTOR2_PA',...
     'BOLD_LANGUAGE1_AP','BOLD_LANGUAGE1_PA','BOLD_LANGUAGE2_AP','BOLD_LANGUAGE2_PA',...
     'BOLD_WM1_AP','BOLD_WM1_PA','BOLD_WM2_AP','BOLD_WM2_PA',...
     'BOLD_MN1_AP','BOLD_MN1_PA','BOLD_MN2_AP','BOLD_MN2_PA',...
     'BOLD_MN3_AP','BOLD_MN3_PA','BOLD_MN4_AP','BOLD_MN4_PA',...
     'BOLD_MEDNERVE1','BOLD_MEDNERVE2','BOLD_MEDNERVE3','BOLD_MEDNERVE4',...
     'BOLD_REST1','BOLD_REST2','ep2d_bold_rest1','ep2d_bold_rest2',...
     'ep2d_bold_MN1','ep2d_bold_MN2','ep2d_bold_MN3','ep2d_bold_MN4',...
     'BOLD_finger1','BOLD_foot1','BOLD_foot2','BOLD_foot3','BOLD_resting_state','resting1','resting2',...
     'pulsed_pair_1','pulsed_pair_2','pulsed_pair_3','pulsed_pair_4',...
     'BOLD_REST1_RL','BOLD_REST1_LR','BOLD_REST2_RL','BOLD_REST2_LR',...
    'BOLD_REST3_RL','BOLD_REST3_LR','BOLD_REST4_RL','BOLD_REST4_LR',...
     'BOLD_MOTOR1_RL','BOLD_MOTOR1_LR','BOLD_MOTOR2_RL','BOLD_MOTOR2_LR',...
     'BOLD_LANGUAGE1_RL','BOLD_LANGUAGE1_LR','BOLD_LANGUAGE2_RL','BOLD_LANGUAGE2_LR',...
     'BOLD_WM1_RL','BOLD_WM1_LR','BOLD_WM2_RL','BOLD_WM2_LR',...
     'BOLD_REST1_AP','BOLD_REST1_PA','BOLD_REST2_AP','BOLD_REST2_PA',...
     'BOLD_REST3_AP','BOLD_REST3_PA','BOLD_REST4_AP','BOLD_REST4_PA',...
     'BOLD_MOTOR1_AP','BOLD_MOTOR1_PA','BOLD_MOTOR2_AP','BOLD_MOTOR2_PA',...
     'BOLD_LANGUAGE1_AP','BOLD_LANGUAGE1_PA','BOLD_LANGUAGE2_AP','BOLD_LANGUAGE2_PA',...
     'BOLD_WM1_AP','BOLD_WM1_PA','BOLD_WM2_AP','BOLD_WM2_PA',...
     'BOLD_MN1_AP','BOLD_MN1_PA','BOLD_MN2_AP','BOLD_MN2_PA',...
     'BOLD_MN3_AP','BOLD_MN3_PA','BOLD_MN4_AP','BOLD_MN4_PA',...
     'BOLD_MEDNERVE1','BOLD_MEDNERVE2','BOLD_MEDNERVE3','BOLD_MEDNERVE4',...
     'BOLD_REST1','BOLD_REST2','ep2d_bold_rest1','ep2d_bold_rest2',...
     'ep2d_bold_MN1','ep2d_bold_MN2','ep2d_bold_MN3','ep2d_bold_MN4',...
     'BOLD_finger1','BOLD_foot1','BOLD_foot2','BOLD_foot3','BOLD_resting_state',...
     'BOLD_REST_','BOLD_IMAGINE1','BOLD_IMAGINE2','BOLD_RESTING_STATE','Resting-state-BOLD','resting1','resting2',...
     'pulsed_pair_1','pulsed_pair_2','pulsed_pair_3','pulsed_pair_4',...
     'RFMRI_REST_AP','RFMRI_REST_PA','HEAD_RFMRI_REST_AP','HEAD_RFMRI_REST_PA'};
 
 ff=[dir(fullfile(outfolder,subjid,'MNINonLinear','Results','BOLD*')); ...
     dir(fullfile(outfolder,subjid,'MNINonLinear','Results','*FMRI*'))]
 for i=1:length(ff)
     str{end+1}=ff(i).name;
 end
 str=unique(str);
 
%This does the fMRI pre-processing
TaskList='"';
jobs={};
for idx=1:length(str)
    if( (exist(fullfile(outfolder,subjid,'unprocessed','3T',str{idx}))==7 && ...
            ~exist(fullfile(outfolder,subjid,'MNINonLinear','Results',str{idx},[ str{idx} '_Atlas.dtseries.nii']))) ...
            || force)
       TaskList=[TaskList str{idx} ' '];
            jobs{end+1}=['source ' HCProot '/pipeline/projects/Pipelines/Examples/Scripts/GenericfMRISurfaceProcessingPipelineBatch.sh --runlocal --StudyFolder=' ...
           outfolder ' --Subjlist="' subjid '" --Tasklist=' str{idx}];
      
    end
end
TaskList=[TaskList(1:end-1) '"'];


if(nargout==1)
    varargout{1}=jobs;
    return
end

if(runslurm)
    slurm_sub(jobs);
else
    for i=1:length(jobs)
        system(jobs{i});
    end
end
%system(['source /disk/NIRS/HCP/projects/Pipelines/Examples/Scripts/GenericfMRISurfaceProcessingPipelineBatch.sh --runlocal --StudyFolder=' outfolder ' --Subjlist="' subjid '" --Tasklist=' TaskList'])