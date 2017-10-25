# docker-jenkins-aws-promotion
Container for a Jenkins build node that is used to promote to AWS.  Credentials are stored in datavolume on local disk to be used in container.

This container is also used by ASAP during remote promotion to AWS. For this, the following is required:
- ASAP envrionment variable set (to something non empty, like true)
- AWS_PROMO_SCRIPTS_REPO_URL set to url for promo scripts repo
- AWS Parameter Store parameters:
    - PROMO.git-credentials (if necessary)
    - PROMO.npmrc (if necessary)

On startup of the container, if RUN_SLAVE is set, the Jenkins slave is downloaded and then run. If ASAP is set, check if AWS_PROMO_SCRIPTS_REPO_URL is set and if so, get git credentials from the AWS Parameter Store, then pull down the aws-promo-scripts from the given git repo. If NPM_CONFIG is set, get the npm credentials from the AWS Parameter Store and set globalconfig to point to them. If ROLE_ARN is set, then get temporary AWS credentials and finally run (eval) whatever command is passed in to the script as the first argument