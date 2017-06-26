FROM signiant/docker-jenkins-alpine-base
MAINTAINER devops@signiant.com

RUN /bin/bash -l -c "echo 'gem: --no-ri --no-rdoc' > ~/.gemrc"
RUN /bin/bash -l -c "gem install bundler --no-ri --no-rdoc"

#Install required gems for our promotion scripts
COPY gem.packages.list /tmp/gem.packages.list
RUN chmod +r /tmp/gem.packages.list
RUN /bin/bash -l -c "gem install `cat /tmp/gem.packages.list | tr \"\\n\" \" \"`"

# Install the AWS CLI - used by promo process
RUN pip install awscli

# Install shyaml - used by promo process to ECS
RUN pip install shyaml

# Install boto and requests - used by the S3 MIME type setter
RUN pip install boto
RUN pip install requests

# Install MaestroOps
RUN pip install maestroops

RUN apk --purge -v del py-pip && \
    rm -rf /var/cache/apk/*

# This entry will either run this container as a jenkins slave or just start SSHD
# If we're using the slave-on-demand, we start with SSH (the default)

# Default Jenkins Slave Name
ENV SLAVE_ID JAVA_NODE
ENV SLAVE_OS Linux

ADD figlet-fonts /figlet-fonts

ADD start.sh /
RUN chmod 777 /start.sh

# Make sure all users have access to all node modules
RUN chmod -R +r /usr/local/lib/node_modules/npm/node_modules/*

USER $BUILD_USER

CMD ["sh", "/start.sh"]
