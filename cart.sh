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

curl -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>> $LOGFILE

VALIDATE $? "Downloding cart application"

cd /app 

unzip -o /tmp/cart.zip &>> $LOGFILE

VALIDATE $? "Unzipping cart"

npm install &>> $LOGFILE

VALIDATE $? "/Installing dependencies"

cp /home/centos/roboshop-shell/cart.services /etc/systemd/system/cart.service &>> $LOGFILE

VALIDATE $? "copying cart service files"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "cart daemon-reload"

systemctl enable cart &>> $LOGFILE

VALIDATE $? "Enable cart"

systemctl start cart &>> $LOGFILE

VALIDATE $? "Start cart"

