function run_HCP_analysis(subjid,dicomfolder,outfolder)
% % Example:
% outfolder='/disk/NIRS/HCP_pipeline/becker_HCP';
% dicomfolder='/disk/mace2/scan_data/homeless/ictr-tae^test/2014.12.15-11.48.36/14.12.15-11:48:34-STD-1.3.12.2.1107.5.2.32.35217/';
% subjid='Becker1';
% run_HCP_analysis(subjid,dicomfolder,outfolder)

HCProot='/disk/NIRS/HCP';
if(nargin<3)
    outfolder=fullfile(HCProot,'data');
end

%This is the only part of the code, that I had to hard-code.  It should be
%easy to fix, since the Phase map should be the second map file in the list
EPIFieldMapMag='FieldMap_104*.14';  %TODO - make this more generic
EPIFieldMapPhase='FieldMap_104*.15';
  
 
StudyNameMap{1,1}='T1w_MPR1*';
StudyNameMap{1,2}=fullfile('unprocessed','3T','T1w_MPR1',[subjid '_3T_T1w_MPR1.nii.gz']);
StudyNameMap{2,1}='T1w_MPR2*';
StudyNameMap{2,2}=fullfile('unprocessed','3T','T1w_MPR2',[subjid '_3T_T1w_MPR2.nii.gz']);
StudyNameMap{3,1}='T2w_SPC1*';
StudyNameMap{3,2}=fullfile('unprocessed','3T','T2w_SPC1',[subjid '_3T_T2w_SPC1.nii.gz']);
StudyNameMap{4,1}='T2w_SPC2*';
StudyNameMap{4,2}=fullfile('unprocessed','3T','T2w_SPC2',[subjid '_3T_T2w_SPC2.nii.gz']);
StudyNameMap{5,1}=EPIFieldMapMag;  %TODO - make this more generic
StudyNameMap{5,2}=fullfile('unprocessed','3T','T1w_MPR1',[subjid '_3T_FieldMap_Magnitude.nii.gz']);
StudyNameMap{6,1}=EPIFieldMapPhase;  %TODO - make this more generic
StudyNameMap{6,2}=fullfile('unprocessed','3T','T1w_MPR1',[subjid '_3T_FieldMap_Phase.nii.gz']);

StudyNameMap{7,1}='DWI_RL_dir95_1848*'; 
StudyNameMap{7,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_DWI_dir95_RL.nii.gz']);
StudyNameMap{8,1}='DWI_RL_dir96_1848*'; 
StudyNameMap{8,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_DWI_dir96_RL.nii.gz']);
StudyNameMap{9,1}='DWI_RL_dir97_1848*'; 
StudyNameMap{9,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_DWI_dir97_RL.nii.gz']);
StudyNameMap{10,1}='DWI_LR_dir95_1848*'; 
StudyNameMap{10,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_DWI_dir95_LR.nii.gz']);
StudyNameMap{11,1}='DWI_LR_dir96_1848*'; 
StudyNameMap{11,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_DWI_dir96_LR.nii.gz']);
StudyNameMap{12,1}='DWI_LR_dir97_1848*'; 
StudyNameMap{12,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_DWI_dir97_LR.nii.gz']);
StudyNameMap{13,1}='DWI_RL_dir95_SB*'; 
StudyNameMap{13,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_DWI_dir95_RL_SBRef.nii.gz']);
StudyNameMap{14,1}='DWI_RL_dir96_SB*'; 
StudyNameMap{14,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_DWI_dir96_RL_SBRef.nii.gz']);
StudyNameMap{15,1}='DWI_RL_dir97_SB*'; 
StudyNameMap{15,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_DWI_dir97_RL_SBRef.nii.gz']);
StudyNameMap{16,1}='DWI_LR_dir95_SB*'; 
StudyNameMap{16,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_DWI_dir95_LR_SBRef.nii.gz']);
StudyNameMap{17,1}='DWI_LR_dir96_SB*'; 
StudyNameMap{17,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_DWI_dir96_LR_SBRef.nii.gz']);
StudyNameMap{18,1}='DWI_LR_dir97_SB*'; 
StudyNameMap{18,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_DWI_dir97_LR_SBRef.nii.gz']);
StudyNameMap{19,1}=EPIFieldMapMag; 
StudyNameMap{19,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_FieldMap_Magnitude.nii.gz']);
StudyNameMap{20,1}=EPIFieldMapPhase;  
StudyNameMap{20,2}=fullfile('unprocessed','3T','Diffusion',[subjid '_3T_FieldMap_Phase.nii.gz']);


str={'BOLD_REST1_RL','BOLD_REST1_LR','BOLD_REST2_RL','BOLD_REST2_LR',...
     'BOLD_MOTOR1_RL','BOLD_MOTOR1_LR','BOLD_MOTOR2_RL','BOLD_MOTOR2_LR',...
     'BOLD_LANGUAGE1_RL','BOLD_LANGUAGE1_LR','BOLD_LANGUAGE2_RL','BOLD_LANGUAGE2_LR',...
     'BOLD_WM1_RL','BOLD_WM1_LR','BOLD_WM2_RL','BOLD_WM2_LR'};
 

 
 
 cnt=size(StudyNameMap,1)+1;
 for idx=1:length(str)
         
     StudyNameMap{cnt,1}=[str{idx} '*'];
     StudyNameMap{cnt,2}=fullfile('unprocessed','3T',str{idx},[subjid '_3T_' str{idx} '.nii.gz']);
     cnt=cnt+1;
     StudyNameMap{cnt,1}=[str{idx} '_SBRef*'];
     StudyNameMap{cnt,2}=fullfile('unprocessed','3T',str{idx},[subjid '_3T_' str{idx} '_SBRef.nii.gz']);
     cnt=cnt+1;
     
     fol=dir(fullfile(dicomfolder,StudyNameMap{cnt-1,1}));
     if(length(fol)>0)
         StudyNameMap{cnt,1}=[EPIFieldMapMag];
         StudyNameMap{cnt,2}=fullfile('unprocessed','3T',str{idx},[subjid '_3T_FieldMapMagnitude.nii.gz']);
         cnt=cnt+1;
         
         StudyNameMap{cnt,1}=[EPIFieldMapPhase];
         StudyNameMap{cnt,2}=fullfile('unprocessed','3T',str{idx},[subjid '_3T_FieldMapPhase.nii.gz']);
         
         StudyNameMap{4,1}='_3T_SpinEchoFieldMap_LR';
         StudyNameMap{4,2}=fullfile('unprocessed','3T',str{idx},[subjid '_3T_SpinEchoFieldMap_LR.nii.gz']);
         cnt=cnt+1;
     end
 end

 
 

setenv('FSLDIR','/home/pkg/software/fsl/fsl/');
setenv('FREESURFER_HOME','/home/pkg/software/freesurfer/');
system('/home/pkg/software/freesurfer/SetUpFreeSurfer.sh');
setenv('PATH',[getenv('PATH') ':/home/pkg/software/freesurfer/bin/']);
system(['source ' HCProot '/projects/Pipelines/Examples/Scripts/SetUpHCPPipeline.sh']);

setenv('FSLDIR','/home/pkg/software/fsl/fsl/');
setenv('FREESURFER_HOME','/home/pkg/software/freesurfer/');
setenv('PATH',[getenv('PATH') ':/home/pkg/software/fsl/fsl/bin/'])
setenv('PATH',[getenv('PATH') ':' getenv('FREESURFER_HOME') filesep 'bin']);
setenv('PATH',[getenv('PATH') ':' getenv('FREESURFER_HOME') filesep 'fsfast' filesep 'bin']);
setenv('PATH',[getenv('PATH') ':' getenv('FREESURFER_HOME') filesep 'mni' filesep 'bin']);
setenv('PERL5LIB','/home/pkg/software/freesurfer/mni/lib/perl5/5.8.5/')   
setenv('HCPPIPEDIR',fullfile(HCProot,'/projects/Pipelines'))
setenv('FSLOUTPUTTYPE','NIFTI_GZ')

if(~exist(outfolder))
    mkdir(outfolder)
end
mkdir(fullfile(outfolder,subjid));

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
        system(['mri_convert -it siemens_dicom ' dicomfolder filesep fol(1).name filesep f(1).name ' ' outfolder filesep subjid filesep StudyNameMap{idx,2}]);
    end
end



% This runs all the sMRI/Freesurfer parts of the code
system(['source ' HCProot '/projects/Pipelines/Examples/Scripts/PreFreeSurferPipelineBatch.sh --runlocal --StudyFolder=' outfolder ' --Subjlist="' subjid '"'])
system(['source ' HCProot '/projects/Pipelines/Examples/Scripts/FreeSurferPipelineBatch.sh --runlocal --StudyFolder=' outfolder ' --Subjlist="' subjid '"'])
system(['source ' HCProot '/projects/Pipelines/Examples/Scripts/PostFreeSurferPipelineBatch.sh --runlocal --StudyFolder=' outfolder ' --Subjlist="' subjid '"'])



%Run the Diffusion pipeline
setenv('HCPPIPEDIR_dMRI',fullfile(HCProot,'projects/Pipelines/DiffusionPreprocessing/scripts'));
system(['source ' HCProot '/projects/Pipelines/Examples/Scripts/DiffusionPreprocessingBatch.sh --runlocal --StudyFolder=' outfolder ' --Subjlist="' subjid '"'])


%This does the fMRI pre-processing
TaskList='"';
PhaseEncodinglist='"';
jobs={};
for idx=1:length(str)
    if(exist(fullfile(outfolder,subjid,'unprocessed','3T',str{idx}))==7)
       TaskList=[TaskList str{idx} ' '];
       if(~isempty(strfind(str{idx},'RL'))); 
           direction='x'; 
       else
           direction='x-'; 
       end;
       PhaseEncodinglist=[PhaseEncodinglist direction ' '];
       jobs{end+1}=['source ' HCProot '/projects/Pipelines/Examples/Scripts/GenericfMRIVolumeProcessingPipelineBatch.sh --runlocal --StudyFolder=' outfolder ' --Subjlist="' subjid '" --Tasklist=' str{idx} ' --Phaselist=' dir];
      
    end
end
PhaseEncodinglist=[PhaseEncodinglist(1:end-1) '"'];
TaskList=[TaskList(1:end-1) '"'];

%system(['source /disk/NIRS/HCP_pipeline/projects/Pipelines/Examples/Scripts/GenericfMRIVolumeProcessingPipelineBatch.sh --runlocal --StudyFolder=' outfolder ' --Subjlist="' subjid '" --Tasklist=' TaskList ' --Phaselist=' PhaseEncodinglist])
slurm_sub(jobs)


TaskList='"';
jobs={};
for idx=1:length(str)
    if(exist(fullfile(outfolder,subjid,'unprocessed','3T',str{idx}))==7)
       TaskList=[TaskList str{idx} ' '];
       jobs{end+1}=['source ' HCProot '/projects/Pipelines/Examples/Scripts/GenericfMRISurfaceProcessingPipelineBatch.sh --runlocal --StudyFolder=' outfolder ' --Subjlist="' subjid '" --Tasklist=' str{idx}];
      
    end
end
if(~isempty(jobs))
    slurm_sub(jobs)
else
    disp('No fMRI files found');
end
 

return

%TODO-  fix all the fMRI analysis beyond this point

%  
%  
% mkdir BOLD_MOTOR2_LR/LINKED_DATA
% mkdir BOLD_MOTOR2_LR/LINKED_DATA/EPRIME
% system('cp -r /disk/NIRS/HCP_pipeline/Motor_EVs/EVs_LR BOLD_MOTOR2_LR/LINKED_DATA/EPRIME/EVs')

taskname='BOLD_MOTOR1_RL';
templatedir='/disk/NIRS/HCP_pipeline/projects/Pipelines/Examples/fsf_templates/';
system(['source /disk/NIRS/HCP_pipeline/projects/Pipelines/Examples/Scripts/copy_evs_into_results.sh --studyfolder=' outfolder ' --subject=' subjid ' --taskname=' taskname])
system(['source /disk/NIRS/HCP_pipeline/projects/Pipelines/Examples/Scripts/generate_level1_fsf.sh --studyfolder=' outfolder ' --subject=' subjid ...
    ' --taskname=' taskname ' --templatedir=' templatedir ' --outdir=' fullfile(outfolder,subjid,'MNINonLinear','Results',taskname)])



taskname='BOLD_MOTOR2_LR';
system(['source /disk/NIRS/HCP_pipeline/projects/Pipelines/Examples/Scripts/copy_evs_into_results.sh --studyfolder=' outfolder ' --subject=' subjid ' --taskname=' taskname])
system(['source /disk/NIRS/HCP_pipeline/projects/Pipelines/Examples/Scripts/generate_level1_fsf.sh --studyfolder=' outfolder ' --subject=' subjid ...
    ' --taskname=' taskname ' --templatedir=' templatedir ' --outdir=' fullfile(outfolder,subjid,'MNINonLinear','Results',taskname)])


levelonetasklist='BOLD_MOTOR1_RL@BOLD_MOTOR2_LR';
levelonefsflist='BOLD_MOTOR1_RL@BOLD_MOTOR2_LR';
leveltwotasklist='BOLD_MOTOR';
leveltwofsflist='BOLD_MOTOR';

system(['source /disk/NIRS/HCP_pipeline/projects/Pipelines/Examples/Scripts/TaskfMRIAnalysisBatch.sh --StudyFolder=' outfolder ' --Subjlist=' subjid ' --runlocal' ...
    ' --levelonetasklist=' levelonetasklist ' --levelonefsflist=' levelonefsflist ' --leveltwotasklist=' leveltwotasklist ' --leveltwofsflist=' leveltwofsflist])

