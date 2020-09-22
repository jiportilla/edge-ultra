#!/bin/bash

# The type and name of the MMS file we are using
OBJECT_TYPE=notebook
OBJECT_ID=2_python_environment.ipynb
PATH_TO_MODEL=/home/jovyan/notebooks/

# Very simple Horizon ML example using HZN MMS  to update ML model (index.js)
# The ML model
TEMP_DIR='/tmp'
DESTINATION_PATH=${TEMP_DIR}/${OBJECT_ID}
HT_DOCS=/home/jovyan/notebooks
RUN_TIME=10

echo "DEBUG: ****   Started pulling ESS ..."

# ${HZN_ESS_AUTH} is mounted to this container and contains a json file with the credentials for authenticating to the ESS.
USER=$(cat ${HZN_ESS_AUTH} | jq -r ".id")
PW=$(cat ${HZN_ESS_AUTH} | jq -r ".token")

# Passing basic auth creds in base64 encoded form (-u).
AUTH="-u ${USER}:${PW} "

# ${HZN_ESS_CERT} is mounted to this container and contains the client side SSL cert to talk to the ESS API.
CERT="--cacert ${HZN_ESS_CERT} "

BASEURL='--unix-socket '${HZN_ESS_API_ADDRESS}' https://localhost/api/v1/objects/'
echo "DEBUG: ****   auth, cert, baseURL: ${AUTH}${CERT}${BASEURL} ..."

# Helper functions to check a valid model file has been pulled from ESS
hasData() {
   afilesize=$(wc -c "/tmp/2_python_environment.ipynb" | awk '{print $1}')
   if (($afilesize > 100 ))#It is a valid model
   then
	echo 'DEBUG: ****   New valid model file was found in ESS'
	cp ${DESTINATION_PATH} ${HT_DOCS}/${OBJECT_ID}
        echo 'DEBUG: ****   ESS Model updated ...'
   else
	echo 'DEBUG: ****   ESS Model NOT updated ...'
   fi
}

noData() {
	echo "DEBUG: ****   ESS Model file exists but it is empty ..."
}

checkUpdates() {
	for f in $TEMP_DIR/*
	do
        echo "DEBUG: ****   Processing FILE ..."
  	if [ -s $f ]

  	then
    		hasData
  	else
    		noData
  	fi
	done
}

while true; do
    echo "DEBUG: ****   $HZN_DEVICE_ID is pulling ESS ..."
    sleep  10

    # read in new file from the ESS to a temporary location
    DATA=$(curl -sL -o ${DESTINATION_PATH} ${AUTH}${CERT}${BASEURL}${OBJECT_TYPE}/${OBJECT_ID}/data)

    #check updates
    checkUpdates
done

