function varargout=HCP_fMRI_analysis(subjid,outfolder,runslurm,force)

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
if(~isstruct(subjid))
    subjid=struct('name',subjid);
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
     'BOLD_REST_','BOLD_IMAGINE1','BOLD_IMAGINE2','BOLD_RESTING_STATE','Resting-state-BOLD','resting1','resting2',...
     'pulsed_pair_1','pulsed_pair_2','pulsed_pair_3','pulsed_pair_4',...
     'RFMRI_REST_AP','RFMRI_REST_PA','HEAD_RFMRI_REST_AP','HEAD_RFMRI_REST_PA'};
 
 
 
 
 for i=1:length(subjid)
     ff=dir(fullfile(outfolder,subjid(i).name,'unprocessed','3T','*BOLD*'));
     for i=1:length(ff)
         str{end+1}=ff(i).name;
     end
 end
 str=unique(str);
 %str={'BOLD_REST1_AP'} % ADDED FOR DEBUG PURPOSES; REMOVE BEFORE FULL RUN

 %This does the fMRI pre-processing
TaskList='"';
PhaseEncodinglist='"';
jobs={};

for i=1:length(subjid)
    for idx=1:length(str)
        if((exist(fullfile(outfolder,subjid(i).name,'unprocessed','3T',str{idx}))==7))
            if((~exist(fullfile(outfolder,subjid(i).name,'MNINonLinear','Results',str{idx},[ str{idx} '_Atlas.dtseries.nii'])) )...
                    || force)
                TaskList=[TaskList str{idx} ' '];
                if(~isempty(strfind(str{idx},'RL')));
                    direction='x';
                elseif(~isempty(strfind(str{idx},'LR')));
                    direction='x-';
                elseif(~isempty(strfind(str{idx},'PA')));
                    direction='y';
                else
                    direction='y-';
                end;
                
                coef=dir(fullfile(outfolder,subjid(i).name,'unprocessed','*coef.grad'));
                if(~isempty(coef))
                    GradTbl=fullfile(outfolder,subjid(i).name,'unprocessed',coef(1).name);
                else
                    GradTbl='NONE';
                end
                
                PhaseEncodinglist=[PhaseEncodinglist direction ' '];
                jobs{end+1}=['source ' HCProot '/pipeline/projects/Pipelines/Examples/Scripts/GenericfMRIVolumeProcessingPipelineBatch.sh --runlocal --StudyFolder=' ...
                    outfolder ' --Subjlist="' subjid(i).name '" --Tasklist=' str{idx} ' --Phaselist=' direction ' --gdcoeffs=' GradTbl ...
                    ' --dcmethod=FIELDMAP'];
                
            end
        end
    end
    
end

PhaseEncodinglist=[PhaseEncodinglist(1:end-1) '"'];
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


%system(['source /disk/HCP/pipelines/projects/Pipelines/Examples/Scripts/GenericfMRIVolumeProcessingPipelineBatch.sh --runlocal --StudyFolder=' outfolder ' --Subjlist="' subjid '" --Tasklist=' TaskList ' --Phaselist=' PhaseEncodinglist])
%system(['source /disk/NIRS/HCP/projects/Pipelines/Examples/Scripts/GenericfMRIVolumeProcessingPipelineBatch.sh --runlocal --StudyFolder=' outfolder ' --Subjlist="' subjid '" --Tasklist=' TaskList ' --Phaselist=' PhaseEncodinglist])