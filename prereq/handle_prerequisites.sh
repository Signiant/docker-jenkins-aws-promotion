#!/bin/sh

# Used by ASAP

ENVIRONMENT=$1


PREREQUISITE_CONF_FILE=${BITBUCKET_CLONE_DIR}/deploy/${ENVIRONMENT}.prerequisites.yaml
if [ -e "${PREREQUISITE_CONF_FILE}" ]; then
    timeout 300 python ${BITBUCKET_CLONE_DIR}/promo_tooling/aws-deploy/python-scripts/prerequisite-checker/prerequisite-checker.py --conf-file "${PREREQUISITE_CONF_FILE}"
fi

status=$?

if [ $status -ne 0 ];then
    echo "prerequisite-checker didn't exit cleanly"
    exit 1
fi
