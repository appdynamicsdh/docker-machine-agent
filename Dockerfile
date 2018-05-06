# Sample Dockerfile for the AppDynamics Standalone Machine Agent
# This is provided for illustration purposes only, for full details 
# please consult the product documentation: https://docs.appdynamics.com/

FROM ubuntu:14.04
ENV DEBIAN_FRONTEND noninteractive

# Install required packages
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y unzip && \
    apt-get install -y curl && \
    apt-get install -y software-properties-common && \
    apt-get install -y apt-transport-https && \
    apt-get clean

RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
RUN add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y docker-ce && \
    apt-get clean

# Install AppDynamics Machine Agent
ENV MACHINE_AGENT_HOME /opt/appdynamics/machine-agent/
ENV APPSERVER_AGENT_HOME /opt/appdynamics/appserver-agent/
ENV NETVIS_AGENT_HOME /opt/appdynamics/netvis-agent/

ADD machine-agent.zip /tmp/ 
ADD appserver-agent.zip /tmp/
ADD netvis-agent.zip /tmp/

RUN mkdir -p ${MACHINE_AGENT_HOME} && \
    unzip -oq /tmp/machine-agent.zip -d ${MACHINE_AGENT_HOME} && \
    rm /tmp/machine-agent.zip

RUN mkdir -p ${APPSERVER_AGENT_HOME} && \
    unzip -oq /tmp/appserver-agent.zip -d ${APPSERVER_AGENT_HOME} && \
    rm /tmp/appserver-agent.zip

RUN mkdir -p ${NETVIS_AGENT_HOME} && \
    unzip -oq /tmp/netvis-agent.zip -d ${NETVIS_AGENT_HOME} && \
    rm /tmp/netvis-agent.zip

RUN unzip -oq ${APPSERVER_AGENT_HOME}*/external-services/netviz.zip -d ${APPSERVER_AGENT_HOME}*/external-services/ 

ADD tools.jar /opt/appdynamics

# Include start script to configure and start MA at runtime
ADD start-appdynamics ${MACHINE_AGENT_HOME}
RUN chmod 744 ${MACHINE_AGENT_HOME}/start-appdynamics

ADD omniagent.sh /opt/appdynamics
RUN chmod 744 /opt/appdynamics/omniagent.sh

RUN touch /appdwazere

# Configure and Run AppDynamics Machine Agent
CMD "${MACHINE_AGENT_HOME}/start-appdynamics"
