#!/bin/bash

# Just in case some of the tar files do not set correct owner
#commented out as this can be sloooooow
#chown -R $BUILD_USER:$BUILD_USER_GROUP /home/$BUILD_USER

if [ ! -z "$RUN_SLAVE" ]; then
    echo "Downloading jenkins slave from $MASTER_ADDR"
    wget -P / http://$MASTER_ADDR/jnlpJars/slave.jar
    if [ -z "$SECRET" ]; then
        su - $BUILD_USER -c "export HOME=/home/$BUILD_USER;\
                             export JAVA_HOME=$JAVA_HOME;\
                             export MAVEN_HOME=$MAVEN_HOME;\
                             export OS=$SLAVE_OS;\
          java -jar /slave.jar -jnlpUrl http://$MASTER_ADDR/computer/$SLAVE_ID/slave-agent.jnlp"
    else
        su - $BUILD_USER -c "export HOME=/home/$BUILD_USER;\
                             export JAVA_HOME=$JAVA_HOME;\
                             export MAVEN_HOME=$MAVEN_HOME;\
                             export OS=$SLAVE_OS;\
          java -jar /slave.jar -jnlpUrl http://$MASTER_ADDR/computer/$SLAVE_ID/slave-agent.jnlp -secret $SECRET"
    fi
fi
