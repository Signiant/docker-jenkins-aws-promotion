FROM signiant/docker-jenkins-centos-base:centos7-java8
LABEL maintainer=sre@signiant.com

#install RVM 1.9.3
RUN /bin/bash -l -c "gpg --keyserver keyserver.ubuntu.com --recv-key 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB"
RUN /bin/bash -l -c "curl -L get.rvm.io | bash -s stable"
RUN /bin/bash -l -c "rvm get 1.29.7"
RUN /bin/bash -l -c "rvm install 1.9.3"
RUN /bin/bash -l -c "echo 'gem: --no-ri --no-rdoc' > ~/.gemrc"
RUN /bin/bash -l -c "gem install bundler -v 1.17.3"
RUN source /etc/profile.d/rvm.sh

#Install required gems for our promotion scripts
COPY gem.packages.list /tmp/gem.packages.list
RUN chmod +r /tmp/gem.packages.list
RUN /bin/bash -l -c "gem install `cat /tmp/gem.packages.list | tr \"\\n\" \" \"`"

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
# Install dns - used by eb_check_live_env.py
RUN pip install --upgrade pip==19
RUN pip install --upgrade pip

RUN pip install awscli shyaml boto requests maestroops datadog slackclient pyyaml dnspython

# python3 module installs
RUN yum install -y python3
RUN pip3 install --upgrade pip

RUN pip3 install awscli shyaml boto3 requests maestroops datadog slackclient dnspython3 pyyaml

COPY automation/ /automation/
COPY prereq/ /prereq/

# Default Jenkins Slave Name
ENV SLAVE_ID JAVA_NODE
ENV SLAVE_OS Linux

ADD figlet-fonts /figlet-fonts
