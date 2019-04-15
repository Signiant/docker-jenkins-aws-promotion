#!/bin/bash

AUTOMATION_ARTIFACT_PATH=/artifacts
ENVIRONMENT=$1

echo "ENVIRONMENT=${ENVIRONMENT}"
RETCODE=0

echo "Automated tests being invoked"

echo "Node Version"
node -v
echo "NPM Version"
npm -v

if [ -d "${BITBUCKET_CLONE_DIR}/automation/node_modules" ]; then
  echo "Removing node modules before testing..."
  rm -rf ${BITBUCKET_CLONE_DIR}/automation/node_modules
fi

chmod +x ${BITBUCKET_CLONE_DIR}/automation/run.sh
${BITBUCKET_CLONE_DIR}/automation/run.sh "${ENVIRONMENT}"
RETCODE=$?

exit $RETCODE
