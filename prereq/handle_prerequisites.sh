#!/bin/sh

# Used by ASAP

PREREQUISITE_CONF_FILE=$1

PROMO_SCRIPTS_PATH=/aws-promo-scripts/aws-deploy/python-scripts

timeout 300 python ${PROMO_SCRIPTS_PATH}/prerequisite-checker/prerequisite-checker.py --conf-file ${PREREQUISITE_CONF_FILE}

status=$?

if [ $status -ne 0 ];then
    echo "prerequisite-checker didn't exit cleanly"
    exit 1
fi
