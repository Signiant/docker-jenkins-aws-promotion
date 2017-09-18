FROM signiant/docker-jenkins-centos-base:centos7-java8
MAINTAINER devops@signiant.com

# Install the AWS CLI - used by promo process
RUN pip install wscli shyaml boto requests maestroops

# This entry will either run this container as a jenkins slave or just start SSHD
# If we're using the slave-on-demand, we start with SSH (the default)


ADD figlet-fonts /figlet-fonts

ADD *.sh /

RUN chmod +x *.sh

ENTRYPOINT ["/start.sh"]
