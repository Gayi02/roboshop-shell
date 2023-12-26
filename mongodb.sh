#!/bin/bash

ID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "script started executing at $TIMESTAMP" &>> $LOGFILE

VALIDATE(){
    if [ $? -ne 0 ]
    then
       echo -e "Error: $2... $R failed $N"
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

cp mongodb.repo /etc/yum.repos.d/mongodb.repo &>> $LOGFILE

VALIDATE $?

dnf install mongodb-org -y  &>> $LOGFILE

VALIDATE $? "Installing mongoDB"

systemctl enable mongod  &>> $LOGFILE

VALIDATE $? "Enableling mongoDB"

systemctl start mongod  &>> $LOGFILE

VALIDATE $? "Starting mongoDB"

sed -i '127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>> $LOGFILE

VALIDATE $? "Remote access to mongoDB"

systemctl restart mongod &>> $LOGFILE

VALIDATE $? "Restarting mongoDB"
