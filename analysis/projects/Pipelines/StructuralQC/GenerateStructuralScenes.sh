#!/bin/bash

## Generating Workbench Scenes for Structural Quality Control
##
## Authors: Michael Harms and Donna Dierker

get_batch_options() {
    local arguments=($@)

    unset command_line_specified_study_folder
    unset command_line_specified_subj_list

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
           
        esac
    done
}

get_batch_options $@

StudyFolder="${HOME}/pipeline/projects/Pipelines_ExampleData" #Location of Subject folders (named by subjectID)
Subjlist="100307" #Space delimited list of subject IDs
EnvironmentScript="${HOME}/pipeline/projects/Pipelines/Examples/Scripts/SetUpHCPPipeline.sh" #Pipeline environment script

if [ -n "${command_line_specified_study_folder}" ]; then
    StudyFolder="${command_line_specified_study_folder}"
fi

if [ -n "${command_line_specified_subj_list}" ]; then
    SubjList="${command_line_specified_subj_list}"
fi

# Requirements for this script
#  installed versions of: FSL (version 5.0.6), FreeSurfer (version 5.3.0-HCP), gradunwarp (HCP version 1.0.2)
#  environment: FSLDIR , FREESURFER_HOME , HCPPIPEDIR , CARET7DIR , PATH (for gradient_unwarp.py)

#Set up pipeline environment variables and software
. ${EnvironmentScript}


set -x

## Edit the following four variables
# SubjList="176239 199958 415837 433839 943862 987983"

# OutputFolder="/location/of/my/QC/output/directory"
# StudyFolder="/location/of/subject/data/directories"


TemplateFolder="/disk/HCP/pipeline/projects/Pipelines/StructuralQC/templates/"

# The following only needs modification if you have modified the
# provided TEMPLATE_structuralQC.scene file
DummyPath="DUMMYPATH" #This is an actual string in the TEMPLATE_structuralQC.scene file.

### From here onward should not need any modification
### --------- ###


# Replace both the path and the subject ID in the template scenes to generate
# a scene file appropriate for each subject
for Subject in $SubjList; do
  OutputFolder=$StudyFolder/"$Subject"/QC
  mkdir -p $OutputFolder  
  cp -r $TemplateFolder/. $OutputFolder

  sed "s#$DummyPath#$StudyFolder#g" $OutputFolder/TEMPLATE_structuralQC.scene | sed "s#100307#$Subject#g" > $OutputFolder/"$Subject".structuralQC.wb.scene

done

