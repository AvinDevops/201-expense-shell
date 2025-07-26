#!/bin/bash

#fetching user id & creating LOGFILE
USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPTNAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPTNAME-$TIMESTAMP.log

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

dnf install nginx -y &>>$LOGFILE
VALIDATE $? "Installing nginx"

systemctl enable nginx &>>$LOGFILE
VALIDATE $? "enabling nginx"

systemctl start nginx &>>$LOGFILE
VALIDATE $? "starting nginx service"

rm -rf /usr/share/nginx/html/* &>>$LOGFILE
VALIDATE $? "removing files in html folder"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOGFILE
VALIDATE $? "downloading frontend code into tmp folder"

cd /usr/share/nginx/html

unzip /tmp/frontend.zip &>>$LOGFILE
VALIDATE $? "unzipping frontend code in html folder"

cp /home/ec2-user/201-expense-shell/expense.conf /etc/nginx/default.d/expense.conf &>>$LOGFILE
VALIDATE $? "copying expense config file into default.d folder"

systemctl restart nginx &>>$LOGFILE
VALIDATE $? "restarting nginx server"