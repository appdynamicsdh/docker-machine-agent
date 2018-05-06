#!/bin/bash

echo $1 $2 $3 $4 $5 $6

TOUCH_FILE='/appdwazere'

for containerId in `docker ps -q`
do
	echo "processing containerId... $containerId"
	echo $MACHINE_AGENT_CONTAINERID 
	
	fileTest=`docker exec $containerId ls $TOUCH_FILE 2>/dev/null`	

        if [ "$fileTest" = "$TOUCH_FILE" ]
        then
                continue;
        fi

	docker cp /opt/appdynamics $containerId:/opt

	docker exec $containerId ps -auxww | grep java | while read -r java_pid_jar
	do

		java_pid=`echo $java_pid_jar | awk '{print $2}'` 
		jar_name=`echo $java_pid_jar | awk '{print $NF}' | sed 's/\//_/g'`

		docker exec $containerId java -Xbootclasspath/a:/opt/appdynamics/tools.jar -jar /opt/appdynamics/appserver-agent/javaagent.jar $java_pid appdynamics.controller.hostName=$1,appdynamics.controller.port=$2,appdynamics.controller.ssl.enabled=$3,appdynamics.agent.accountAccessKey=$6,appdynamics.agent.applicationName=$4,appdynamics.agent.tierName=$jar_name,appdynamics.agent.nodeName=$containerId,appdynamics.agent.accountName=$5

	done

	docker exec $containerId /opt/appdynamics/netvis-agent/install.sh
	docker exec $containerId /opt/appdynamics/netvis-agent/bin/start.sh
	docker exec $containerId touch $TOUCH_FILE
done

