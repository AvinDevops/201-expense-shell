#!/bin/bash

#getting user id & creating LOGFILE
USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPTNAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPTNAME-$TIMESTAMP.log

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

#validate function
VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 is....$R failed $N"
        exit
    else
        echo -e "$2....$G success $N"
    fi
}

dnf install mysql-server -y &>>$LOGFILE
VALIDATE $? "Installing mysql-server"

systemctl enable mysqld &>>$LOGFILE
VALIDATE $? "Enabiling mysqld"

systemctl start mysqld &>>$LOGFILE
VALIDATE $? "Starting mysqld"

# mysql -h 172.31.22.129 -uroot -pExpenseApp@1 -e 'show databases;'
# if [ $? -ne 0 ]
# then
#     mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOGFILE
#     VALIDATE $? "Setting password for root user"
# else
#     echo -e "Root password is already set....$Y SKIPPING $N"
# fi

mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOGFILE
VALIDATE $? "Setting password for root user"
