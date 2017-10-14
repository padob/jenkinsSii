#!/bin/bash

#Check is run script with root
if [ $EUID != 0 ]; then
    echo "Please run as root"
    exit 1
fi

command=$1

printUsage() {
    echo "Usage:"
    echo "create_workshop.sh create <user_prefix> <user_counts> <user_group>"
    echo "create_workshop.sh clean <user_prefix> <user_counts> <user_group>"
    echo "create_workshop.sh startAllJenkins <user_prefix> <user_counts>"
    echo "create_workshop.sh stopAllJenkins <user_prefix> <user_counts>"
    echo "create_workshop.sh startJenkins <user_prefix> <user_number>"
    echo "create_workshop.sh stopJenkins <user_prefix> <user_number>"
}

createWorkshop() {
    userPrefix=$1
    userCount=$2
    groupName=$3
    echo "Create group: "$groupName
    groupadd $groupName

    echo "Create users: User prefix: "$userPrefix" User count "$userCount

    for i in $(seq 1 $userCount)
    do
        userName=$userPrefix$i
        userPass=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 8 ; echo '')
        userHome="/home/"$userName
        echo "Create user: "$userName":"$userPass" User home: "$userHome
        useradd $userName -g $groupName -m -n
        echo $userName:$userPass | chpasswd
    done

    for i in $(seq 1 $userCount)
    do
        userName=$userPrefix$i
        jenkinsHome="/home/"$userName"/jenkins_home"
        jenkinsSlave="/home/"$userName"/jenkins_slave"
        jenkinsPort="818"$i

        mkdir -p $jenkinsHome
        cp tools/jenkins.war $jenkinsHome/jenkins.war

        cp jenkins.sh $jenkinsHome/jenkins.sh
        sed -i 's#@JENKINS_HOME@#'$jenkinsHome'#g' $jenkinsHome/jenkins.sh
        sed -i 's/@JENKINS_PORT@/'$jenkinsPort'/g' $jenkinsHome/jenkins.sh
        chmod +x $jenkinsHome/jenkins.sh

        mkdir -p $jenkinsSlave
        chown -R $userName:$groupName $jenkinsHome
        chown -R $userName:$groupName $jenkinsSlave
    done

    for i in $(seq 1 $userCount)
    do
        userName=$userPrefix$i
        userWork="/home/"$userName"/work"
        mkdir -p $userWork
        cd $userWork
        git clone https://github.com/klimas7/Learn.git

        chown -R $userName:$groupName $userWork
    done
}

cleanWorkshop() {
    userPrefix=$1
    userCount=$2
    groupName=$3

    echo "Delete users: User prefix: "$userPrefix" User count "$userCount
    for i in $(seq 1 $userCount)
    do
        userName=$userPrefix$i
        echo "Delete user: "$userName
        userdel $userName -r -f
    done

    echo "Delete group: "$groupName
    groupdel $groupName
}

startAllJenkins() {
    userPrefix=$1
    userCount=$2
    for i in $(seq 1 $userCount)
    do
        startJenkins $userPrefix $i
    done
}

stopAllJenkins() {
    userPrefix=$1
    userCount=$2
    for i in $(seq 1 $userCount)
    do
        stopJenkins $userPrefix $i
    done
}

startJenkins() {
    userPrefix=$1
    userNumber=$2

    userName=$userPrefix$userNumber
    jenkinsHome="/home/"$userName"/jenkins_home"
    su -c "$jenkinsHome/jenkins.sh start&" $userName
}

stopJenkins() {
    userPrefix=$1
    userNumber=$2

    userName=$userPrefix$userNumber
    jenkinsHome="/home/"$userName"/jenkins_home"

    userName=$userPrefix$userNumber
    jenkinsHome="/home/"$userName"/jenkins_home"
    su -c "$jenkinsHome/jenkins.sh stop&" $userName
}

case $command in
    "create")
        echo "Create workshop"
        if [ $# -ne 4 ]; then
            echo "Illegal arguments"
            printUsage
            exit 1
        fi
        createWorkshop $2 $3 $4
        ;;
    "clean")
        echo "Clean workshop"
        if [ $# -ne 4 ]; then
            echo "Illegal arguments"
            printUsage
            exit 1
        fi
        cleanWorkshop $2 $3 $4
        ;;
    "startAllJenkins")
        echo "Start All Jenkins"
        if [ $# -ne 3 ]; then
            echo "Illegal arguments"
            printUsage
            exit 1
        fi
        startAllJenkins $2 $3
        ;;
     "stopAllJenkins")
        echo "Stop All Jenkins"
        if [ $# -ne 3 ]; then
            echo "Illegal arguments"
            printUsage
            exit 1
        fi
        stopAllJenkins $2 $3
        ;;
     "startJenkins")
        echo "Start Jenkins"
        if [ $# -ne 3 ]; then
            echo "Illegal arguments"
            printUsage
            exit 1
        fi
        startJenkins $2 $3
        ;;
     "stopJenkins")
        echo "Stop Jenkins"
        if [ $# -ne 3 ]; then
            echo "Illegal arguments"
            printUsage
            exit 1
        fi
        stopJenkins $2 $3
        ;;
    *)
        printUsage
esac





