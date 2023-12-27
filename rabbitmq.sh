#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "script started executing at $TIMESTAMP" &>> $LOGFILE

VALIDATE(){
    if [ $1 -ne 0 ]
    then
       echo -e "$2... $R failed $N"
       exit 1
    else
       echo -e "$2... $G success $N"
    fi   
}

if [ $ID -ne 0 ]
then
   echo -e "$R Error: Please run this script with root access $N"
   exit 1
else
   echo "you are a root user"
fi

curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash &>> $LOGFILE

VALIDATE $? "Dowloding erlang script"

curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash &>> $LOGFILE

VALIDATE $? "Dowloding rabbitmq script"

dnf install rabbitmq-server -y &>> $LOGFILE

VALIDATE $? "install rabbitmq"

systemctl enable rabbitmq-server &>> $LOGFILE

VALIDATE $? "Enable rabbitmq"

systemctl start rabbitmq-server &>> $LOGFILE

VALIDATE $? "Starting rabbitmq"

rabbitmqctl add_user roboshop roboshop123 &>> $LOGFILE

VALIDATE $? "Creating user"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $LOGFILE

VALIDATE $? "Setting permissions"