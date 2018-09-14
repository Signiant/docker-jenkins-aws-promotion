#!/bin/bash

# Used by ASAP

AUTOMATION_ARTIFACT_PATH=/artifacts
ENVIRONMENT=$1

echo "ENVIRONMENT=${ENVIRONMENT}"
echo "AUTOMATION_ARTIFACT_PATH=${AUTOMATION_ARTIFACT_PATH}"

RETCODE=0

echo "Automated tests being invoked"

automation_node_version=8

echo "checking package.json for engines.node"
defined_version=$(cat ${AUTOMATION_ARTIFACT_PATH}/automation/package.json| jq --raw-output '.engines.node')
if [ "${defined_version}" != "null" ]; then
    echo "engines.node present in package.json - using that version"
    # Strip off any >= stuff at the start
    automation_node_version=${defined_version#*=}
else
    echo "engines.node not present in package.json - setting version to latest node 8"
fi

n $automation_node_version

echo "Node Version"
node -v
echo "NPM Version"
npm -v

echo "Executing run.sh automation entry point"
chmod 755 /artifacts/automation/run.sh

if [ -d "${AUTOMATION_ARTIFACT_PATH}/automation/node_modules" ]; then
  echo "Removing node modules before testing..."
  rm -rf ${AUTOMATION_ARTIFACT_PATH}/automation/node_modules
fi

chmod +x ${AUTOMATION_ARTIFACT_PATH}/automation/run.sh
${AUTOMATION_ARTIFACT_PATH}/automation/run.sh "${ENVIRONMENT}" "${AUTOMATION_ARTIFACT_PATH}" "${ENVIRONMENT}"
RETCODE=$?

exit $RETCODE
