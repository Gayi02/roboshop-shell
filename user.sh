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

dnf module disable nodejs -y &>> $LOGFILE

VALIDATE $? "Disabilling current Nodejs"

dnf module enable nodejs:18 -y &>> $LOGFILE

VALIDATE $? "Enabiling Nodejs18"

dnf install nodejs -y &>> $LOGFILE

VALIDATE $? "Instaling Nodejs18"

id roboshop
if [ $? -ne 0 ]
then
    useradd roboshop
    VALIDATE $? "user creation"
else
    echo -e "roboshop user already exits $Y Skipping $N"
fi

mkdir -p /app &>> $LOGFILE

VALIDATE $? "Creating app directory"

curl -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>> $LOGFILE

VALIDATE $? "Downloding user application"

cd /app 

unzip -o /tmp/user.zip &>> $LOGFILE

VALIDATE $? "Unzipping user"

npm install &>> $LOGFILE

VALIDATE $? "/Installing dependencies"

cp /home/centos/roboshop-shell/user.services /etc/systemd/system/user.service &>> $LOGFILE

VALIDATE $? "copying user service files"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "user daemon-reload"

systemctl enable user &>> $LOGFILE

VALIDATE $? "Enable user"

systemctl start user &>> $LOGFILE

VALIDATE $? "Start user"

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE

VALIDATE $? "Copying mongoDB repo"

dnf install mongodb-org-shell -y &>> $LOGFILE

VALIDATE $? "Installing mongoDB client"

mongo --host mongodb.dev76.online </app/schema/user.js &>> $LOGFILE

VALIDATE $? "Loading user data into mongoDB"