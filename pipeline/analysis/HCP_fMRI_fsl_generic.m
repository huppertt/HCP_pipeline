function HCP_fMRI_fsl_generic(subjid,task,outfolder)

HCProot='/disk/HCP';
if(nargin<2 || isempty(outfolder))
    outfolder=fullfile(HCProot,'analyzed');
end

HCP_matlab_setenv;  % Sets the FSL, Freesurfer, etc folders

system(['cp -vR ' outfolder filesep subjid '/unprocessed/3T/' task '/LINKED_DATA/EPRIME/EVs ' outfolder filesep subjid '/MNINonLinear/Results/' task]);
system(['cp -v ' outfolder filesep subjid '/unprocessed/3T/' task '/LINKED_DATA/EPRIME/EVs/*.fsf ' outfolder filesep subjid '/MNINonLinear/Results/' task filesep task '_hp200_s4_level1.fsf']);


system(['source ' HCProot '/pipeline/projects/Pipelines/Examples/Scripts/TaskfMRIAnalysisBatch_v2.sh --runlocal --StudyFolder=' outfolder ' --Subjlist="' subjid '" --task="' task '"']);
