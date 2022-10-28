function varargout=HCP_fMRI_analysis(subjid,outfolder,runslurm,force)

HCProot='/disk/HCP';
if(nargin<2 || isempty(outfolder))
    outfolder=fullfile(HCProot,'analyzed');
end

if(nargin<3)
    runslurm=false;
end
if(nargin<4)
    force=false;
end
if(~isstruct(subjid))
    subjid.name=subjid;
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
     'BOLD_finger1','BOLD_foot1','BOLD_foot2','BOLD_foot3','BOLD_resting_state',...
     'BOLD_REST_','BOLD_IMAGINE1','BOLD_IMAGINE2','BOLD_RESTING_STATE'};
 
 
 
 for i=1:length(subjid)
     ff=[dir(fullfile(outfolder,subjid(i).name,'unprocessed','3T','BOLD*')); ...
         dir(fullfile(outfolder,subjid(i).name,'unprocessed','3T','*FMRI*'))]
     for i=1:length(ff)
         str{end+1}=ff(i).name;
     end
 end
 str=unique(str);
 
 %This does the fMRI pre-processing
 TaskList='"';
 PhaseEncodinglist='"';
 jobs={};
 
 for i=1:length(subjid)
     for idx=1:length(str)
         if((exist(fullfile(outfolder,subjid(i).name,'unprocessed','3T',str{idx}))==7 && ...
                 ~exist(fullfile(outfolder,subjid(i).name,'MNINonLinear','Results',str{idx},[ str{idx} '_Atlas.dtseries.nii'])) )...
                 || force)
             HCP_fMRI_ME_BOLD(subjid(i).name,outfolder,{str{idx}});
             
         end
     end
     
 end


%system(['source /disk/HCP/pipelines/projects/Pipelines/Examples/Scripts/GenericfMRIVolumeProcessingPipelineBatch.sh --runlocal --StudyFolder=' outfolder ' --Subjlist="' subjid '" --Tasklist=' TaskList ' --Phaselist=' PhaseEncodinglist])
%system(['source /disk/NIRS/HCP/projects/Pipelines/Examples/Scripts/GenericfMRIVolumeProcessingPipelineBatch.sh --runlocal --StudyFolder=' outfolder ' --Subjlist="' subjid '" --Tasklist=' TaskList ' --Phaselist=' PhaseEncodinglist])