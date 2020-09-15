FROM signiant/docker-jenkins-centos-base:centos7-java8
MAINTAINER devops@signiant.com

# Install yum packages required for puppeteer
# https://github.com/GoogleChrome/puppeteer/issues/560#issuecomment-325224766
COPY yum-packages.list /tmp/yum.packages.list
RUN chmod +r /tmp/yum.packages.list \
  && yum install -y -q `cat /tmp/yum.packages.list`

# python module installs:
# Install the AWS CLI - used by promo process
# Install shyaml - used by promo process to ECS
# Install boto and requests - used by the S3 MIME type setter
# Install MaestroOps, slackclient, and datadog
RUN pip3 install boto boto3 awscli shyaml requests maestroops datadog slackclient pyyaml

# Default Jenkins Slave Name
ENV SLAVE_ID JAVA_NODE
ENV SLAVE_OS Linux

ADD figlet-fonts /figlet-fonts
