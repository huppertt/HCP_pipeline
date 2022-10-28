#!/bin/bash

# Global default values
DEFAULT_STUDY_FOLDER="${HOME}/analayzed"
DEFAULT_SUBJECT_LIST="100307"
DEFAULT_ENVIRONMENT_SCRIPT="${HOME}/pipeline/projects/Pipelines/Examples/Scripts/SetUpHCPPipeline.sh"
DEFAULT_RUN_LOCAL="TRUE"
DEFAULT_FIX_DIR="${HOME}/pipeline/projects/Pipelines/ICAFIX"

#
# Function Description
#	Get the command line options for this script
#
# Global Output Variables
#	${StudyFolder}			- Path to folder containing all subjects data in subdirectories named 
#							  for the subject id
#	${Subjlist}				- Space delimited list of subject IDs
#	${EnvironmentScript}	- Script to source to setup pipeline environment
#	${FixDir}				- Directory containing FIX
#	${RunLocal}				- Indication whether to run this processing "locally" i.e. not submit
#							  the processing to a cluster or grid
#
get_options() {
	local scriptName=$(basename ${0})
	local arguments=($@)

	# initialize global output variables
	StudyFolder="${DEFAULT_STUDY_FOLDER}"
	Subjlist="${DEFAULT_SUBJECT_LIST}"
	EnvironmentScript="${DEFAULT_ENVIRONMENT_SCRIPT}"
	FixDir="${DEFAULT_FIX_DIR}"
	RunLocal="${DEFAULT_RUN_LOCAL}"

	# parse arguments
	local index=0
	local numArgs=${#arguments[@]}
	local argument

	while [ ${index} -lt ${numArgs} ]
	do
		argument=${arguments[index]}

		case ${argument} in
			--StudyFolder=*)
				StudyFolder=${argument/*=/""}
				index=$(( index + 1 ))
				;;
			--Subjlist=*)
				Subjlist=${argument/*=/""}
				index=$(( index + 1 ))
				;;
			--EnvironmentScript=*)
				EnvironmentScript=${argument/*=/""}
				index=$(( index + 1 ))
				;;
			--FixDir=*)
				FixDir=${argument/*=/""}
				index=$(( index + 1 ))
				;;
			--runlocal | --RunLocal)
				RunLocal="TRUE"
				index=$(( index + 1 ))
				;;
			*)
				echo "ERROR: Unrecognized Option: ${argument}"
				exit 1
				;;
		esac
	done

	# check required parameters
	if [ -z ${StudyFolder} ]
	then
		echo "ERROR: StudyFolder not specified"
		exit 1
	fi

	if [ -z ${Subjlist} ]
	then
		echo "ERROR: Subjlist not specified"
		exit 1
	fi

	if [ -z ${EnvironmentScript} ]
	then
		echo "ERROR: EnvironmentScript not specified"
		exit 1
	fi

	if [ -z ${FixDir} ]
	then
		echo "ERROR: FixDir not specified"
		exit 1
	fi

	if [ -z ${RunLocal} ]
	then
		echo "ERROR: RunLocal is an empty string"
		exit 1
	fi

	# report options
	echo "-- ${scriptName}: Specified Command-Line Options: -- Start --"
	echo "   StudyFolder: ${StudyFolder}"
	echo "   Subjlist: ${Subjlist}"
	echo "   EnvironmentScript: ${EnvironmentScript}"
	echo "   FixDir: ${FixDir}"
	echo "   RunLocal: ${RunLocal}"
	echo "-- ${scriptName}: Specified Command-Line Options: -- End --"
}

#
# Function Description
#	Main processing of this script
#
#	Gets user specified command line options and runs a batch of ICA+FIX processing
#
main() {
	# get command line options
	get_options $@

	# set up pipeline environment variables and software
	. ${EnvironmentScript}

	# validate environment variables
	# validate_environment_vars $@

	# establish queue for job submission
	QUEUE="-q hcp_priority.q"

	# establish list of conditions on which to run ICA+FIX
	CondList=""
	CondList="${CondList} BOLD_REST1"
	CondList="${CondList} BOLD_REST2"
	CondList="${CondList} BOLD_REST3"
	CondList="${CondList} BOLD_REST4"
    CondList="${CondList} RESTING-STATE-FMRI"
    CondList="${CondList} BOLD_REST"
    CondList="${CondList} RFMRI_REST"
    CondList="${CondList} HEAD_RFMRI_REST"

	# establish list of directions on which to run ICA+FIX
	DirectionList=""
	DirectionList="${DirectionList} RL"
	DirectionList="${DirectionList} LR"
	DirectionList="${DirectionList} AP"
	DirectionList="${DirectionList} PA"
    DirectionList="${DirectionList} NONE"

	for Subject in ${Subjlist}
	do
		echo ${Subject}

		for Condition in ${CondList}
		do
			echo "  ${Condition}"

			for Direction in ${DirectionList}
			do
				echo "    ${Direction}"
				
                if [ ${Direction} == NONE ] ; then
                    InputDir="${StudyFolder}/${Subject}/MNINonLinear/Results/${Condition}"
                    InputFile="${InputDir}/${Condition}.nii.gz"
                else
                    InputDir="${StudyFolder}/${Subject}/MNINonLinear/Results/${Condition}_${Direction}"
                    InputFile="${InputDir}/${Condition}_${Direction}.nii.gz"
                fi
                echo "$InputFile"
                if [ -f $InputFile ] ; then

                    bandpass=2000
				
                    if [ "${RunLocal}" == "TRUE" ]
                    then
                        echo "About to run ${FixDir}/hcp_fix_pre ${InputFile} ${bandpass}"
                        queuing_command=""
                    else
                        echo "About to use fsl_sub to queue or run ${FixDir}/hcp_fix_pre ${InputFile} ${bandpass}"
                        queuing_command="${FSLDIR}/bin/fsl_sub ${QUEUE}"
                    fi
                    
                    ${queuing_command} ${FixDir}/hcp_fix_pre ${InputFile} ${bandpass}
                fi
			done

		done

	done
}

#
# Invoke the main function to get things started
#
main $@