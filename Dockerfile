FROM signiant/docker-jenkins-centos-base:centos6
MAINTAINER devops@signiant.com

#install RVM 2.1.2
RUN /bin/bash -l -c "gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3"
RUN /bin/bash -l -c "curl -L get.rvm.io | bash -s stable"
RUN /bin/bash -l -c "rvm install 2.1.2"

#Install required gems for our promotion scripts
COPY gem.packages.list /tmp/gem.packages.list
RUN chmod +r /tmp/gem.packages.list
RUN /bin/bash -l -c "gem install `cat /tmp/gem.packages.list | tr \"\\n\" \" \"`"

# Install PIP packages
COPY pip.packages.list /tmp/pip.packages.list
RUN chmod +r /tmp/pip.packages.list
RUN /bin/bash -l -c "pip install `cat /tmp/pip.packages.list | tr \"\\n\" \" \"`"

# install azure-cli
RUN npm install azure-cli -g

# Folder for secure chef files
RUN mkdir /etc/chef

RUN ln -s /etc/chef ~/.chef

# Make sure anything/everything we put in the build user's home dir is owned correctly
RUN chown -R $BUILD_USER:$BUILD_USER_GROUP /home/$BUILD_USER  

# This entry will either run this container as a jenkins slave or just start SSHD
# If we're using the slave-on-demand, we start with SSH (the default)

# Default Jenkins Slave Name
ENV SLAVE_ID JAVA_NODE
ENV SLAVE_OS Linux

ADD start.sh /
RUN chmod 777 /start.sh

CMD ["sh", "/start.sh"]
