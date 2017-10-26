#!/bin/bash

# Just in case some of the tar files do not set correct owner
#chown -R $BUILD_USER:$BUILD_USER_GROUP /home/$BUILD_USER

# If this container is being started manually, RUN_SLAVE will be set, therefore react accordingly
if [ ! -z "$RUN_SLAVE" ]; then
    echo "Downloading jenkins slave from $MASTER_ADDR"
    wget -P / http://$MASTER_ADDR/jnlpJars/slave.jar
    if [ -z "$SECRET" ]; then
        su - $BUILD_USER -c "export HOME=/home/$BUILD_USER;\
                             export JAVA_HOME=$JAVA_HOME;\
                             export MAVEN_HOME=$MAVEN_HOME;\
                             export OS=$SLAVE_OS;\
                             export LC_ALL=en_US.UTF-8;\
                             export LANG=en_US.UTF-8;\
                             export LANGUAGE=en_US.UTF-8;\
          java -jar /slave.jar -jnlpUrl http://$MASTER_ADDR/computer/$SLAVE_ID/slave-agent.jnlp"
    else
        su - $BUILD_USER -c "export HOME=/home/$BUILD_USER;\
                             export JAVA_HOME=$JAVA_HOME;\
                             export MAVEN_HOME=$MAVEN_HOME;\
                             export OS=$SLAVE_OS;\
                             export LC_ALL=en_US.UTF-8;\
                             export LANG=en_US.UTF-8;\
                             export LANGUAGE=en_US.UTF-8;\
          java -jar /slave.jar -jnlpUrl http://$MASTER_ADDR/computer/$SLAVE_ID/slave-agent.jnlp -secret $SECRET"
    fi
elif [ ! -z "ASAP" ]; then
    # This is being triggered by ASAP, react accordingly
    CMD=$1
    ARTIFACT_PATH=/artifacts
    if [ -z "$PROMOTION_REGION" ]; then
        # Default to us-west-2 region
        PROMOTION_REGION=us-west-2
    fi

    GIT_CREDENTIALS_PARAM=PROMO.git-credentials
    GIT_CRED=/credentials/.git-credentials
    NPM_CREDENTIALS_PARAM=PROMO.npmrc
    NPM_CRED=/credentials/.npmrc

    if [ ! -e "$ARTIFACT_PATH" ]; then
        echo "Cannot find artifacts! Cannot continue"
        exit 1
    fi

    get_credential()
    {
        # $1 - parameter name for credential
        PARAM_NAME=$1
        # $2 - location to store credential
        CRED_LOCATION=$2

        mkdir -p /credentials

        if [ -z "$CRED_LOCATION" ]; then
            echo "Must provide a location to store the credential"
            exit 1
        else
            # Go get credential from parameter store
            credential=$(aws ssm get-parameters --names $PARAM_NAME --with-decryption --region $PROMOTION_REGION --query 'Parameters[0].Value' --output text)
            if [ -e "$CRED_LOCATION" ]; then
                echo "Warning: $CRED_LOCATION exists - overwriting..."
            fi
            echo $credential > $CRED_LOCATION
            # Replace \n with newlines
            sed -i 's/\\n/\n/g' $CRED_LOCATION
        fi
    }

    # Get and set temporary AWS credentials
    get_temporary_aws_credentials()
    {
        role_arn=$1
        # echo "Geting temporary AWS credentials for role $role_arn"

        assume_role_details=$(aws sts assume-role --role-arn ${role_arn} --role-session-name ASAP)

        access_key_id=$(echo $assume_role_details | jq .Credentials.AccessKeyId -r)
        secret_access_key=$(echo $assume_role_details | jq .Credentials.SecretAccessKey -r)
        session_token=$(echo $assume_role_details | jq .Credentials.SessionToken -r)
        # session_expiration=$(echo $assume_role_details | jq .Credentials.Expiration -r)

        export AWS_ACCESS_KEY_ID=$access_key_id
        export AWS_SECRET_ACCESS_KEY=$secret_access_key
        export AWS_SESSION_TOKEN=$session_token
    }

    if [ ! -z "$NPM_CONFIG" ]; then
        # Need to set up npm (and yarm) config
        get_credential $NPM_CREDENTIALS_PARAM $NPM_CRED
        rm -f ~/.npmrc
        ln -s /credentials/.npmrc ~/.npmrc
    fi

    if [ ! -z "$AWS_PROMO_SCRIPTS_REPO_URL" ]; then
        # AWS_PROMO_SCRIPTS_REPO_URL is set - need to get our git credentials and clone the repo
        get_credential $GIT_CREDENTIALS_PARAM $GIT_CRED
        mkdir aws-promo-scripts
        cd aws-promo-scripts
        git init . > /dev/null
        git config credential.helper 'store --file='$GIT_CRED
        git config remote.origin.url $AWS_PROMO_SCRIPTS_REPO_URL
        git pull > /dev/null 2>&1
        if [ $? -ne 0 ]; then
            echo "ERROR: Unable to clone Git repo: $AWS_PROMO_SCRIPTS_REPO_URL"
            exit 1
        fi
    fi

    # Run this with the appropriate role
    if [ ! -z "$ROLE_ARN" ]; then
        get_temporary_aws_credentials $ROLE_ARN
    fi

    echo "Running the following command: $CMD"
    eval $CMD
fi
exit $?
