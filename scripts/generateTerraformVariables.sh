#!/bin/bash

#CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CURRENT_DIR="$( cd "$( dirname "$0" )" && pwd )"
echo $CURRENT_DIR

if [ $# != "2" ]; then 
  echo "Error. Insufficient Parameters"
  echo "Usage: ./generateTerraformVariables.sh <WORKING_DIR> <DEMO_NAME>"
  exit 1
fi

WORKING_DIR="$1"
DEMO_NAME="$2"

source $WORKING_DIR/credentials/oci_env
mkdir -p $WORKING_DIR/$DEMO_NAME
# OCI Account information
PRIVATE_KEY="$WORKING_DIR/credentials/$OCI_API_PRIVATE_KEY"

# Generate the ssh keys for the compute instance
COMPUTE_PRIVATE_KEY=$WORKING_DIR/$DEMO_NAME/$DEMO_NAME.key
COMPUTE_PUBLIC_KEY=$COMPUTE_PRIVATE_KEY.pub
echo "Managing keys"
echo "... Cleaning up existing keys"
rm -f $COMPUTE_PRIVATE_KEY
rm -f $COMPUTE_PUBLIC_KEY

echo "... Generating new keys"
# generate a set of keys
echo -e "y\n" | /usr/bin/ssh-keygen -t rsa -b 2048 -f $COMPUTE_PRIVATE_KEY -q -N ''
## Ubuntu does not support ${PIPESTATUS[1]} with sh. It however works with bash
# ERR_CODE=${PIPESTATUS[1]}
# if [ $ERR_CODE -ne "0" ] ; then
# exit $ERR_CODE
#fi

### Checking the status of the last command
if [ $? -ne "0" ] ; then
  exit $ERR_CODE
fi

# Generate the TF file
TARGET_FILE=$WORKING_DIR/$DEMO_NAME/$DEMO_NAME.tfvar
echo -e "tenancy_ocid=\"$TENANCY_OCID\"
user_ocid=\"$USER_OCID\"
fingerprint=\"$FINGERPRINT\"
private_key_path=\"$PRIVATE_KEY\"
compartment_ocid=\"$COMPARTMENT_OCID\"
compute_ssh_private_key=\"$COMPUTE_PRIVATE_KEY\"
compute_ssh_public_key=\"$COMPUTE_PUBLIC_KEY\"
InstanceName=\"$DEMO_NAME\"
" > $TARGET_FILE
