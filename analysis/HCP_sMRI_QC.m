function HCP_sMRI_QC(subjid,outfolder)

HCProot='/aionraid/huppertt/raid2_BU/HCP/';
if(nargin<2)
    outfolder=fullfile(HCProot,'analyzed');
end

HCP_matlab_setenv;  % Sets the FSL, Freesurfer, etc folders 

system(['source ' HCProot '/pipeline/projects/Pipelines/StructuralQC/GenerateStructuralScenes2.sh --StudyFolder=' outfolder ' --Subjlist=' subjid])

