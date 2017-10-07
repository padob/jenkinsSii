#!/bin/bash

jh=@JENKINS_HOME@
mkdir -p $jh/log
mkdir -p $jh/war

command=$1

printUsage() {
    echo "Usage:"
    echo "jenkins.sh start"
    echo "jenkins.sh stop"
}

start() {
    /etc/alternatives/java -Dcom.sun.akuma.Daemon=daemonized -Djava.awt.headless=true -DJENKINS_HOME=$jh -jar $jh/jenkins.war --logfile=$jh/log/jenkins.log --webroot=$jh/war --daemon --httpPort=@JENKINS_PORT@ --ajp13Port=-1 --debug=5 --handlerCountMax=100 --handlerCountMaxIdle=20 &
}

stop() {
    jenkinsPID=$(ps aux | grep java | grep @JENKINS_HOME@ | awk '{print $2}')
    echo "kill jenkins process PID: "$jenkinsPID
    kill -9 $jenkinsPID 2>&1 > /dev/null
}

case $command in
    "start")
        start
        ;;
    "stop")
        stop
        ;;
    *)
        printUsage
esac