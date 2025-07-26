#!/bin/bash

#fetching user id & creating LOGFILE
USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPTNAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPTNAME-$TIMESTAMP.log

MYSQL_ROOT_PASSWORD=ExpenseApp@1
MYSQL_SERVER_IP=172.31.28.79

#declaring colors
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

# checking root user or not
if [ $USERID -ne 0 ]
then
    echo -e "$R you are not root user $N"
    exit
else
    echo -e "$G you are root user $N"
fi

# creating function
VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 is....$R FAILED $N"
        exit
    else
        echo -e "$2 is....$R SUCCESS $N"
    fi
}


# configuring backend server

dnf module disable nodejs:18 -y &>>$LOGFILE
VALIDATE $? "Disabiling nodejs 18v"

dnf module enable nodejs:20 -y &>>$LOGFILE
VALIDATE $? "Enabiling nodejs 20v"

dnf install nodejs -y &>>$LOGFILE
VALIDATE $? "Installing nodejs"

useradd expense &>>$LOGFILE
VALIDATE $? "Creating expense user"

mkdir /app

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOGFILE
VALIDATE $? "Downloading backend code to tmp"

cd /app
unzip /tmp/backend.zip &>>$LOGFILE
VALIDATE $? "unzipping backend file in app folder"

npm install &>>$LOGFILE
VALIDATE $? "Installing dependencies"

cp /home/ec2-user/201-expense-shell/backend.service /etc/systemd/system/backend.service &>>$LOGFILE
VALIDATE $? "copying backend service to system folder"

systemctl daemon-reload &>>$LOGFILE
VALIDATE $? "Daemon reloading"

systemctl start backend &>>$LOGFILE
VALIDATE $? "start backend service"

systemctl enable backend &>>$LOGFILE
VALIDATE $? "enabling backend service"

dnf install mysql -y &>>$LOGFILE
VALIDATE $? "installing mysql client"

mysql -h $MYSQL_SERVER_IP -uroot -p$MYSQL_ROOT_PASSWORD < /app/schema/backend.sql &>>$LOGFILE
VALIDATE $? "loading schema into mysql server"

systemctl restart backend &>>$LOGFILE
VALIDATE $? "restarting backend service"
