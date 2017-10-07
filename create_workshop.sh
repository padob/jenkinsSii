#!/bin/bash

#Check is run script with root
if [ $EUID != 0 ]; then
    echo "Please run as root"
    exit
fi

command=$1





printUsage() {
    echo "Usage:"
    echo "create_workshop.sh create <user_prefix> <user_number> <user_group>"
    echo "create_workshop.sh clean <user_prefix> <user_number> <user_group>"
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

case $command in
    "create")
        echo "Create workshop"
        if [ $# -ne 4 ]; then
            echo "Illegal arguments"
            printUsage
            exit
        fi
        createWorkshop $2 $3 $4
        ;;
    "clean")
        echo "Clean workshop"
        if [ $# -ne 4 ]; then
            echo "Illegal arguments"
            printUsage
            exit
        fi
        cleanWorkshop $2 $3 $4
        ;;
    *)
        printUsage
esac





