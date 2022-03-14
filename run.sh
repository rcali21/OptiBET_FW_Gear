#! /bin/bash
#
# Run script for flywheel/optiBET gear.
#
#

##############################################################################
# Define directory names and containers

FLYWHEEL_BASE=/flywheel/v0
INPUT_DIR=$FLYWHEEL_BASE/input/
OUTPUT_DIR=$FLYWHEEL_BASE/output
CONFIG_FILE=$FLYWHEEL_BASE/config.json
CONTAINER='[FSL_optibet]'


##############################################################################
# Parse configuration

function parse_config {

  CONFIG_FILE=$FLYWHEEL_BASE/config.json
  MANIFEST_FILE=$FLYWHEEL_BASE/manifest.json

  if [[ -f $CONFIG_FILE ]]; then
    echo "$(cat $CONFIG_FILE | jq -r '.config.'$1)"
  else
    CONFIG_FILE=$MANIFEST_FILE
    echo "$(cat $MANIFEST_FILE | jq -r '.config.'$1'.default')"
  fi
}

config_output_nifti="$(parse_config 'output_nifti')"



##############################################################################
# Handle INPUT file

# Find input file In input directory with the extension
# .nii, .nii.gz, 
input_file=`find $INPUT_DIR -iname '*.nii' -o -iname '*.nii.gz'`

# Check that input file exists
if [[ -e $input_file ]]; then
  echo "${CONTAINER}  Input file found: ${input_file}"

  # Determine the type of the input file
    if [[ "$input_file" == *.nii ]]; then
    type=".nii"
    elif [[ "$input_file" == *.nii.gz ]]; then
    type=".nii.gz"
    fi

  # Get the base filename
  base_filename=`basename "$input_file" $type`
else
  echo "${CONTAINER} No Nifti input was found within input directory $INPUT_DIR"
  exit 1
fi


# Set initial exit status
optiBET_exit_status_nifti=0


if [[ $config_output_nifti == 'true' ]]; then
  /flywheel/v0/optiBET.sh "$input_file"
  optiBET_exit_status_nifti=$?
fi


# Handle Exit status
if [[ $optiBET_exit_status_nifti == 0 ]] ; then
  echo -e "${CONTAINER} Success!"
  exit 0
else
  echo "${CONTAINER}  Something went wrong! optiBET exited non-zero!"
  exit 1
fi