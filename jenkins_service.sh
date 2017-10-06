#!/bin/sh

this_script="$0"
script_dir=`dirname "$this_script"`
old_dir=`pwd`

JENKINS_WAR=jenkins-2.73.1.war

#TODO
JAVA_HOME=/opt/se/jdk/jdk1.8.0_131_x64
JENKINS_HOME=/data/se/jenkins2
LOG_DIR=$HUDSON_HOME/logs

export JAVA_HOME JENKINS_HOME

exit_fail() {
  cd "$old_dir"
  exit 1
}

exit_ok() {
  cd "$old_dir"
  if [ "$1" = "" ]; then
    exit 0
  else
    exit $1
  fi
}

if [ "$PID_FILE" = "" ]; then
  PID_FILE=$LOG_DIR/jenkins.pid
fi

JAVA_EXE=$JAVA_HOME/bin/java

JVM_ARGS="-server -Xmx1G -Xms1G -Xss256k"
JVM_ARGS="$JVM_ARGS -DJENKINS_HOME=$JENKINS_HOME"
JVM_ARGS="$JVM_ARGS -jar $JENKINS_WAR --ajp13Port=-1"
#http
JVM_ARGS="$JVM_ARGS --httpPort=8081"
#https
#JVM_ARGS="$JVM_ARGS --httpsPort=8443 --httpsCertificate=/opt/tools/keystore/cert.pem --httpsPrivateKey=/opt/tools/keystore/key.pem"

#Debug
#JVM_ARGS="$JVM_ARGS -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=9712"

check_alive() {
  ps_alive=0
  if [ -f "$PID_FILE" ] ; then
    if ps -p `cat $PID_FILE` >/dev/null 2>&1; then
      ps_alive=1;
    else
      rm $PID_FILE
    fi
  fi

  if [ "$ps_alive" = "0" ]; then
    return 1
  else
    return 0
  fi
}

case "$1" in
start|run)
  if check_alive ; then
    echo "Jenkins is already running with PID `cat $PID_FILE`"
    exit_fail
  fi

  echo "Starting Jenkins..."
  mkdir -p $LOG_DIR 2>/dev/null

  if [ "$1" = "start" ]; then
    nohup $JAVA_EXE $JVM_ARGS > "$LOG_DIR/output.log" 2> "$LOG_DIR/error.log" &
    echo  $! | cat > $PID_FILE
    echo "Done [$!], see logs in $LOG_DIR"
  else
    $JAVA_EXE $JVM_ARGS
    exit_ok $?
  fi
  ;;
stop)
 echo "Stopping Jenkins..."

 if check_alive ; then
   echo "Stopping Jenkins [`cat $PID_FILE`]"
   kill `cat $PID_FILE`
   for i in 1 2 3 4 5 6 7 8 9 10; do
     if [ !check_alive ]; then break; fi
     sleep 1
   done
   if [ !check_alive ]; then
     echo "Stopped"
     rm $PID_FILE
   else
     echo "Cannot stop Jenkins"
     exit_fail
   fi
 else
   echo "$PID_FILE not found, nothing to stop."
 fi
 ;;
*)
  echo "Run as $0 (start|run|stop)"
  echo "  start: start in the background (it's safe to exit from the current session)"
  echo "  run:   run in the foreground (process will stop once current session is terminated) "
  echo "  stop:  stop the background proces"
  exit_fail
   ;;
esac

exit_ok

