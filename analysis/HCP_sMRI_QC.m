function HCP_sMRI_QC(subjid,outfolder)

HCProot='/disk/HCP';
if(nargin<2)
    outfolder=fullfile(HCProot,'analyzed');
end

HCP_matlab_setenv;  % Sets the FSL, Freesurfer, etc folders 

system(['source /disk/HCP/pipeline/projects/Pipelines/StructuralQC/GenerateStructuralScenes.sh --StudyFolder=' outfolder ' --Subjlist=' subjid])

