#!/bin/bash

#getting user id & creating LOGFILE
USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPTNAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPTNAME_$TIMESTAMP.log

#declaring colors
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

#checking root user or not
if [ $USERID -ne 0 ]
then
    echo -e "$R you are not root user $N"
    exit
else
    echo -e "$G you are root user $N"
fi  

dnf install mysqll-server -y
if [ $? -ne 0 ]
then
    echo -e "Installing mysql server is....$R failed $N"
    exit
else
    echo "Installing mysql server is....$G success $N"
fi

systemctl enable mysqld

systemctl start mysqld

#mysql_secure_installation --set-root-pass ExpenseApp@1

echo "Script reached end of the line"