#!/bin/bash

jh=@JENKINS_HOME@
mkdir -p $jh/log
mkdir -p $jh/war

/etc/alternatives/java -Dcom.sun.akuma.Daemon=daemonized -Djava.awt.headless=true -DJENKINS_HOME=$jh -jar $jh/jenkins.war --logfile=$jh/log/jenkins.log --webroot=$jh/war --daemon --httpPort=@JENKINS_PORT@ --ajp13Port=-1 --debug=5 --handlerCountMax=100 --handlerCountMaxIdle=20