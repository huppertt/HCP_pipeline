#!/bin/bash 

get_batch_options() {
    local arguments=($@)

    unset command_line_specified_study_folder
    unset command_line_specified_subj_list
    unset command_line_specified_run_local

    local index=0
    local numArgs=${#arguments[@]}
    local argument

    while [ ${index} -lt ${numArgs} ]; do
        argument=${arguments[index]}

        case ${argument} in
            --StudyFolder=*)
                command_line_specified_study_folder=${argument/*=/""}
                index=$(( index + 1 ))
                ;;
            --Subjlist=*)
                command_line_specified_subj_list=${argument/*=/""}
                index=$(( index + 1 ))
                ;;
            --runlocal)
                command_line_specified_run_local="TRUE"
                index=$(( index + 1 ))
                ;;
        esac
    done
}

get_batch_options $@

StudyFolder="${HOME}/projects/Pipelines_ExampleData" #Location of Subject folders (named by subjectID)
Subjlist="100307" #Space delimited list of subject IDs
EnvironmentScript="${HOME}/pipeline/projects/Pipelines/Examples/Scripts/SetUpHCPPipeline.sh" #Pipeline environment script

if [ -n "${command_line_specified_study_folder}" ]; then
    StudyFolder="${command_line_specified_study_folder}"
fi

if [ -n "${command_line_specified_subj_list}" ]; then
    Subjlist="${command_line_specified_subj_list}"
fi

# Requirements for this script
#  installed versions of: FSL (version 5.0.6), FreeSurfer (version 5.3.0-HCP) , gradunwarp (HCP version 1.0.2)
#  environment: FSLDIR , FREESURFER_HOME , HCPPIPEDIR , CARET7DIR , PATH (for gradient_unwarp.py)

#Set up pipeline environment variables and software
. ${EnvironmentScript}

# Log the originating call
echo "$@"

#Assume that submission nodes have OPENMP enabled (needed for eddy - at least 8 cores suggested for HCP data)
#if [ X$SGE_ROOT != X ] ; then
    QUEUE="-q verylong.q"
#fi

PRINTCOM=""


########################################## INPUTS ########################################## 

#Scripts called by this script do assume they run on the outputs of the PreFreeSurfer Pipeline,
#which is a prerequisite for this pipeline

#Scripts called by this script do NOT assume anything about the form of the input names or paths.
#This batch script assumes the HCP raw data naming convention, e.g.

#	${StudyFolder}/${Subject}/unprocessed/3T/Diffusion/${SubjectID}_3T_vDWI_dir95_RL.nii.gz
#	${StudyFolder}/${Subject}/unprocessed/3T/Diffusion/${SubjectID}_3T_DWI_dir96_RL.nii.gz
#	${StudyFolder}/${Subject}/unprocessed/3T/Diffusion/${SubjectID}_3T_DWI_dir97_RL.nii.gz
#	${StudyFolder}/${Subject}/unprocessed/3T/Diffusion/${SubjectID}_3T_DWI_dir95_LR.nii.gz
#	${StudyFolder}/${Subject}/unprocessed/3T/Diffusion/${SubjectID}_3T_DWI_dir96_LR.nii.gz
#	${StudyFolder}/${Subject}/unprocessed/3T/Diffusion/${SubjectID}_3T_DWI_dir97_LR.nii.gz

#Change Scan Settings: Echo Spacing and PEDir to match your images
#These are set to match the HCP Protocol by default

#If using gradient distortion correction, use the coefficents from your scanner
#The HCP gradient distortion coefficents are only available through Siemens
#Gradient distortion in standard scanners like the Trio is much less than for the HCP Skyra.

######################################### DO WORK ##########################################

for Subject in $Subjlist ; do
  echo $Subject

  #Input Variables
  SubjectID="$Subject" #Subject ID Name
  RawDataDir="$StudyFolder/$SubjectID/unprocessed/3T/Diffusion" #Folder where unprocessed diffusion data are

PEdir=1 #Use 1 for Left-Right Phase Encoding, 2 for Anterior-Posterior
  # Data with positive Phase encoding direction. Up to N>=1 series (here N=3), separated by @. (LR in HCP data, AP in 7T HCP data)
  if [ -f ${RawDataDir}/${SubjectID}_3T_DWI_dir95_RL.nii.gz ] ; then
    PosData="${RawDataDir}/${SubjectID}_3T_DWI_dir95_RL.nii.gz@${RawDataDir}/${SubjectID}_3T_DWI_dir96_RL.nii.gz@${RawDataDir}/${SubjectID}_3T_DWI_dir97_RL.nii.gz"
    NegData="${RawDataDir}/${SubjectID}_3T_DWI_dir95_LR.nii.gz@${RawDataDir}/${SubjectID}_3T_DWI_dir96_LR.nii.gz@${RawDataDir}/${SubjectID}_3T_DWI_dir97_LR.nii.gz"
  elif [ -f ${RawDataDir}/${SubjectID}_3T_DWI_dir99_AP.nii.gz ] && [ -f ${RawDataDir}/${SubjectID}_3T_DWI_dir99_PA.nii.gz ]; then
       # PosData="${RawDataDir}/${SubjectID}_3T_DWI_dir95_AP.nii.gz@${RawDataDir}/${SubjectID}_3T_DWI_dir96_AP.nii.gz@${RawDataDir}/${SubjectID}_3T_DWI_dir97_AP.nii.gz"
        if [ -f ${RawDataDir}/${SubjectID}_3T_DWI_dir98_AP.nii.gz ] && [ -f ${RawDataDir}/${SubjectID}_3T_DWI_dir98_PA.nii.gz ]; then
            NegData="${RawDataDir}/${SubjectID}_3T_DWI_dir99_AP.nii.gz@${RawDataDir}/${SubjectID}_3T_DWI_dir98_AP.nii.gz@EMPTY"
	    PosData="${RawDataDir}/${SubjectID}_3T_DWI_dir99_PA.nii.gz@${RawDataDir}/${SubjectID}_3T_DWI_dir98_PA.nii.gz@EMPTY"
        else
            NegData="${RawDataDir}/${SubjectID}_3T_DWI_dir99_AP.nii.gz@EMPTY@EMPTY"
            PosData="${RawDataDir}/${SubjectID}_3T_DWI_dir99_PA.nii.gz@EMPTY@EMPTY"
        fi
        PEdir=2
   elif [ -f ${RawDataDir}/${SubjectID}_3T_DWI_dir98_AP.nii.gz ] && [ -f ${RawDataDir}/${SubjectID}_3T_DWI_dir98_PA.nii.gz ]; then
       # PosData="${RawDataDir}/${SubjectID}_3T_DWI_dir95_AP.nii.gz@${RawDataDir}/${SubjectID}_3T_DWI_dir96_AP.nii.gz@${RawDataDir}/${SubjectID}_3T_DWI_dir97_AP.nii.gz"
       NegData="EMPTY@${RawDataDir}/${SubjectID}_3T_DWI_dir98_AP.nii.gz@EMPTY"
       PosData="EMPTY@${RawDataDir}/${SubjectID}_3T_DWI_dir98_PA.nii.gz@EMPTY"
       PEdir=2
  elif [ -f ${RawDataDir}/${SubjectID}_3T_DWI_dir68_AP.nii.gz ]; then
       NegData="EMPTY@${RawDataDir}/${SubjectID}_3T_DWI_dir68_AP.nii.gz@EMPTY"
       PosData="EMPTY@${RawDataDir}/${SubjectID}_3T_DWI_dir68_PA.nii.gz@EMPTY"
       PEdir=2
  elif [ -f ${RawDataDir}/${SubjectID}_3T_DWI_dir113_AP.nii.gz ]; then
       NegData="EMPTY@${RawDataDir}/${SubjectID}_3T_DWI_dir113_AP.nii.gz@EMPTY"
       PosData="EMPTY@${RawDataDir}/${SubjectID}_3T_DWI_dir113_PA.nii.gz@EMPTY"
       PEdir=2
 elif [ -f ${RawDataDir}/${SubjectID}_3T_DWI.nii.gz ]; then
       PosData="EMPTY@${RawDataDir}/${SubjectID}_3T_DWI.nii.gz@EMPTY"
       NegData="EMPTY@${RawDataDir}/${SubjectID}_3T_DWI.nii.gz@EMPTY"
       PEdir=2
  else
        PosData="EMPTY@EMPTY@EMPTY"
  fi 

  #Scan Setings
  EchoSpacing=0.78 #Echo Spacing or Dwelltime of dMRI image, set to NONE if not used. Dwelltime = 1/(BandwidthPerPixelPhaseEncode * # of phase encoding samples): DICOM field (0019,1028) = BandwidthPerPixelPhaseEncode, DICOM field (0051,100b) AcquisitionMatrixText first value (# of phase encoding samples).  On Siemens, iPAT/GRAPPA factors have already been accounted for.
  # NOTE (HENGENIUS): For ROS-MOVE data, EchoSpacing = 0.475 ms, NOT 0.78 ms 

  #Config Settings
  # Gdcoeffs="${HCPPIPEDIR_Config}/coeff_SC72C_Skyra.grad" #Coefficients that describe spatial variations of the scanner gradients. Use NONE if not available.
  if [ -f ${StudyFolder}/${Subject}/unprocessed/3Tprisma_coef.grad ] ; then  
      Gdcoeffs="${StudyFolder}/${Subject}/unprocessed/3Tprisma_coef.grad" #Location of Coeffs file or "NONE" to skip
        echo "Using Siemens gradient table"
    elif [ -f ${StudyFolder}/${Subject}/unprocessed/3Tmmr_coef.grad ] ; then  
     Gdcoeffs="${StudyFolder}/${Subject}/unprocessed/3Tprisma_coef.grad" #Location of Coeffs file or "NONE" to skip
        echo "Using Siemens gradient table"
    else
    
     Gdcoeffs="NONE" # Set to NONE to skip gradient distortion correction
  fi

  if [ -n "${command_line_specified_run_local}" ] ; then
      echo "About to run ${HCPPIPEDIR}/DiffusionPreprocessing/DiffPreprocPipeline.sh"
      queuing_command=""
  else
      echo "About to use fsl_sub to queue or run ${HCPPIPEDIR}/DiffusionPreprocessing/DiffPreprocPipeline.sh"
      queuing_command="${FSLDIR}/bin/fsl_sub ${QUEUE}"
  fi

   

  ${queuing_command} ${HCPPIPEDIR}/DiffusionPreprocessing/DiffPreprocPipeline.sh \
      --posData="${PosData}" --negData="${NegData}" \
      --path="${StudyFolder}" --subject="${SubjectID}" \
      --echospacing="${EchoSpacing}" --PEdir=${PEdir} \
      --gdcoeffs="${Gdcoeffs}" \
      --printcom=$PRINTCOM 
      
done
