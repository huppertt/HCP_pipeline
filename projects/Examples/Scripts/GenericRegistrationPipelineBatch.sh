
#!/bin/bash 

get_batch_options() {
    local arguments=($@)

    unset command_line_specified_study_folder
    unset command_line_specified_subj_list
    unset command_line_specified_run_local
    unset command_line_specified_scanlist
    unset command_line_specified_phaselist

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
            --Scanlist=*)
                command_line_specified_scanlist=${argument/*=/}
               # command_line_specified_scanlist= `echo "${command_line_specified_scanlist}" | sed 's/\,/ /g'`
                index=$(( index + 1 ))
                ;;
            --Phaselist=*)
                command_line_specified_phaselist=${argument/*=/}
                #command_line_specified_phaselist= `echo "${command_line_specified_phaselist}" | sed 's/\,/ /g'`
                index=$(( index + 1 ))
                ;;
            --runlocal)
                command_line_specified_run_local="TRUE"
                index=$(( index + 1 ))
                ;;
            *)
                index=$(( index + 1 ))
                ;;
           
        esac
    done
}

get_batch_options $@

HOME=/disk/HCP

StudyFolder="${HOME}/pipeline/projects/Pipelines_ExampleData" #Location of Subject folders (named by subjectID)
Subjlist="100307" #Space delimited list of subject IDs
EnvironmentScript="${HOME}/pipeline/projects/Pipelines/Examples/Scripts/SetUpHCPPipeline.sh" #Pipeline environment script
Tasklist="FLAIR SWI"
PhaseEncodinglist="x x-" #x for RL, x- for LR, y for PA, y- for AP


if [ -n "${command_line_specified_study_folder}" ]; then
    StudyFolder="${command_line_specified_study_folder}"
fi

if [ -n "${command_line_specified_subj_list}" ]; then
    Subjlist="${command_line_specified_subj_list}"
fi

if [ -n "${command_line_specified_scanlist}" ]; then
    Scanlist="${command_line_specified_scanlist}"
fi

if [ -n "${command_line_specified_phaselist}" ]; then
    PhaseEncodinglist="${command_line_specified_phaselist}"
fi



# Requirements for this script
#  installed versions of: FSL (version 5.0.6), FreeSurfer (version 5.3.0-HCP) , gradunwarp (HCP version 1.0.1)
#  environment: FSLDIR , FREESURFER_HOME , HCPPIPEDIR , CARET7DIR , PATH (for gradient_unwarp.py)

#Set up pipeline environment variables and software
. ${EnvironmentScript}

# Log the originating call
echo "$@"

#if [ X$SGE_ROOT != X ] ; then
    QUEUE="-q long.q"
#fi

PRINTCOM=""
#PRINTCOM="echo"
#QUEUE="-q veryshort.q"



######################################### DO WORK ##########################################


for Subject in $Subjlist ; do
  echo $Subject

  i=1
  for ScanName in $Scanlist ; do
  

    echo "  ${ScanName}"

    UnwarpDir=`echo $PhaseEncodinglist | cut -d " " -f $i`

    ScanSeries="${StudyFolder}/${Subject}/unprocessed/3T/${ScanName}/${Subject}_3T_${ScanName}.nii.gz"
    
DistortionCorrection="NONE" #"TOPUP" #FIELDMAP or TOPUP, distortion correction is required for accurate processing

SpinEchoPhaseEncodeNegative="NONE" #For the spin echo field map volume with a negative phase encoding direction (LR in HCP data, AP in 7T HCP data), set to NONE if using regular FIELDMAP

SpinEchoPhaseEncodePositive="NONE" #For the spin echo field map volume with a positive phase encoding direction (RL in HCP data, PA in 7T HCP data), set to NONE if using regular FIELDMAP
    
MagnitudeInputName="${StudyFolder}/${Subject}/unprocessed/3T/${ScanName}/${Subject}_3T_FieldMapMagnitude.nii.gz" #Expects 4D Magnitude volume with two 3D timepoints, set to NONE if using TOPUP

PhaseInputName="${StudyFolder}/${Subject}/unprocessed/3T/${ScanName}/${Subject}_3T_FieldMapPhase.nii.gz" #Expects a 3D Phase volume, set to NONE if using TOPUP

DeltaTE="11.26" # 2.46 #2.46ms for 3T, 1.02ms for 7T, set to NONE if using TOPUP

FinalResolution="1.0" #Target final resolution of fMRI data. 2mm is recommended for 3T HCP data, 1.6mm for 7T HCP data (i.e. should match acquired resolution).  Use 2.0 or 1.0 to avoid standard FSL templates
    
GradientDistortionCoeffs="NONE" # SEt to NONE to skip gradient distortion correction

TopUpConfig="${HCPPIPEDIR_Config}/b02b0.cnf" #Topup config if using TOPUP, set to NONE if using regular FIELDMAP




    if [ -n "${command_line_specified_run_local}" ] ; then
        echo "About to run ${HCPPIPEDIR}/GenericRegister/GenericRegisterPipeline.sh"
        queuing_command=""
    else
        echo "About to use fsl_sub to queue or run ${HCPPIPEDIR}/GenericRegister/GenericRegisterPipeline.sh"
        queuing_command="${FSLDIR}/bin/fsl_sub ${QUEUE}"
    fi

    ${queuing_command} ${HCPPIPEDIR}/GenericRegister/GenericRegisterPipeline.sh \
      --path=$StudyFolder \
      --subject=$Subject \
      --fmriname=$ScanName \
      --fmritcs=$ScanSeries \
      --SEPhaseNeg=$SpinEchoPhaseEncodeNegative \
      --SEPhasePos=$SpinEchoPhaseEncodePositive \
      --fmapmag=$MagnitudeInputName \
      --fmapphase=$PhaseInputName \
      --unwarpdir=$UnwarpDir \
      --fmrires=$FinalResolution \
      --dcmethod=$DistortionCorrection \
      --gdcoeffs=$GradientDistortionCoeffs \
      --topupconfig=$TopUpConfig \
      --printcom=$PRINTCOM

  # The following lines are used for interactive debugging to set the positional parameters: $1 $2 $3 ...

  echo "set -- --path=$StudyFolder \
      --subject=$Subject \
      --fmriname=$fMRIName \
      --fmritcs=$fMRITimeSeries \
      --fmriscout=$fMRISBRef \
      --SEPhaseNeg=$SpinEchoPhaseEncodeNegative \
      --SEPhasePos=$SpinEchoPhaseEncodePositive \
      --fmapmag=$MagnitudeInputName \
      --fmapphase=$PhaseInputName \
      --echospacing=$DwellTime \
      --echodiff=$DeltaTE \
      --unwarpdir=$UnwarpDir \
      --fmrires=$FinalFMRIResolution \
      --dcmethod=$DistortionCorrection \
      --gdcoeffs=$GradientDistortionCoeffs \
      --topupconfig=$TopUpConfig \
      --printcom=$PRINTCOM"

  echo ". ${EnvironmentScript}"
	
    i=$(($i+1))
  done
done