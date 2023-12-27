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

useradd roboshop &>> $LOGFILE

VALIDATE $? "Creating roboshop user"

mkdir /app &>> $LOGFILE

VALIDATE $? "Creating app directory"

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOGFILE

VALIDATE $? "Downloding catalogue application"

cd /app 

unzip /tmp/catalogue.zip &>> $LOGFILE

VALIDATE $? "Unzipping catalogue"

cd /app

npm install &>> $LOGFILE

VALIDATE $? "Downloding dependencies"

cp home/centos/roboshop-shell/catalogue.services /etc/systemd/system/catalogue.service &>> $LOGFILE

VALIDATE $? "copying catalogue service files"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "Catalogue daemon-reload"

systemctl enable catalogue &>> $LOGFILE

VALIDATE $? "Enable catalogue"

systemctl start catalogue &>> $LOGFILE

VALIDATE $? "Start Catalogue"

cp home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE

VALIDATE $? "Copying mongoDB repo"

dnf install mongodb-org-shell -y &>> $LOGFILE

VALIDATE $? "Installing mongoDB client"

mongo --host mongodb.dev76.online </app/schema/catalogue.js &>> $LOGFILE

VALIDATE $? "Loading catalogue data into mongoDB"





