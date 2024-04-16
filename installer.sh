#!/bin/bash

echo -e "
██████╗ ██╗   ██╗██╗   ██╗███████╗██████╗ ███████╗    ███████╗██╗██████╗ ███████╗████████╗
██╔══██╗██║   ██║╚██╗ ██╔╝██╔════╝██╔══██╗██╔════╝    ██╔════╝██║██╔══██╗██╔════╝╚══██╔══╝
██████╔╝██║   ██║ ╚████╔╝ █████╗  ██████╔╝███████╗    █████╗  ██║██████╔╝███████╗   ██║   
██╔══██╗██║   ██║  ╚██╔╝  ██╔══╝  ██╔══██╗╚════██║    ██╔══╝  ██║██╔══██╗╚════██║   ██║   
██████╔╝╚██████╔╝   ██║   ███████╗██║  ██║███████║    ██║     ██║██║  ██║███████║   ██║   
╚═════╝  ╚═════╝    ╚═╝   ╚══════╝╚═╝  ╚═╝╚══════╝    ╚═╝     ╚═╝╚═╝  ╚═╝╚══════╝   ╚═╝   
\n\n
";

# Recieve data/secrets from the user
read -p "Enter MySQL DB URL (Press Enter for jdbc:mysql://mysqldb:3306/buyersfirstdb): " db_url;
read -p "Enter MySQL DB Host (Press Enter for mysqldb): " db_host;
read -p "Enter MySQL DB USER (Press Enter for root): " db_user;
read -p "Enter MySQL DB PASSWORD: " db_pass;
read -p "Enter JWT Issuer (Press Enter for BUYERSFIRST): " jwt_iss;
read -p "Enter JWT Secret : " jwt_sec;
read -p "Enter JWT Expiry (Press Enter for 10080): " jwt_exp;
read -p "Enter REDIS Host (Press Enter for redis): " rds_host;
read -p "Enter REDIS User (Press Enter for default): " rds_user;
read -p "Enter REDIS Port (Press Enter for 6379): " rds_port;
read -p "Enter REDIS Password : " rds_pass;
read -p "Enter RABBITMQ Host (Press Enter for rabbitmq): " mq_host;
read -p "Enter RABBITMQ User (Press Enter for buyersfirst): " mq_user;
read -p "Enter RABBITMQ Password : " mq_pass;
read -p "Enter MINIO Host (Press Enter for minio): " minio_host;
read -p "Enter MINIO User (Press Enter for buyersfirst): " minio_user;
read -p "Enter MINIO Bucket (Press Enter for images): " minio_bucket;
read -p "Enter MINIO Password : " minio_pass;
read -p "Enter the email queue (Press Enter for email_q): " mq_email_q;
read -p "Enter the sms queue (Press Enter for sms_q): " mq_sms_q;
read -p "Enter mail server: " email_srv;
read -p "Enter user email: " email_usr;
read -p "Enter user password: " email_pss;
read -p "Enter mail server port: " email_prt;

if [[ -z "$db_url" ]]; then
    db_url="jdbc:mysql://mysqldb:3306/buyersfirstdb";
fi

if [[ -z "$db_host" ]]; then
    db_host="mysqldb";
fi

if [[ -z "$db_user" ]]; then
    db_user="root";
fi

if [[ -z "$jwt_iss" ]]; then
    jwt_iss="BUYERSFIRST";
fi

if [[ -z "$jwt_exp" ]]; then
    jwt_exp="10080";
fi

if [[ -z "$rds_host" ]]; then
    rds_host="redis";
fi

if [[ -z "$rds_port" ]]; then
    rds_port="6379";
fi

if [[ -z "$rds_user" ]]; then
    rds_user="default";
fi

if [[ -z "$mq_user" ]]; then
    mq_user="buyersfirst";
fi

if [[ -z "$mq_host" ]]; then
    mq_host="rabbitmq";
fi

if [[ -z "$minio_host" ]]; then
    minio_host="minio";
fi

if [[ -z "$minio_user" ]]; then
    minio_user="buyersfirst";
fi

if [[ -z "$minio_bucket" ]]; then
    minio_bucket="images";
fi

if [[ -z "$mq_email_q" ]]; then
    mq_email_q="email_q";
fi

if [[ -z "$mq_sms_q" ]]; then
    mq_sms_q="sms_q";
fi

db_name=$(echo "${db_url##*/}")

# Clone all the submodules
git submodule update -i

# Update the submodules
cd auth ; git checkout main ; git pull ; cd ..
cd core ; git checkout main ; git pull ; cd ..
cd web ; git checkout main ; git pull ; cd ..
cd notif ; git checkout main ; git pull ; cd ..

# Generate and place the secret files
## For the core repo
echo "DB_URL=$db_url
DB_USER=$db_user
DB_PASS=$db_pass
JWT_ISS=$jwt_iss
JWT_SEC=$jwt_sec
JWT_EXP=$jwt_exp
RDS_HST=$rds_host
RDS_PRT=$rds_port
RDS_PSW=$rds_pass
RDS_USR=$rds_user" > core/src/main/resources/docker.secret.properties

# ## For the auth repo
echo "DB_URL=$db_url
DB_USER=$db_user
DB_PASS=$db_pass
JWT_ISS=$jwt_iss
JWT_SEC=$jwt_sec
JWT_EXP=$jwt_exp
" > auth/src/main/resources/docker.secret.properties

# ## For the web repo
echo "NEXT_PUBLIC_AUTH_BASE_URL=http://auth:8080
NEXT_PUBLIC_CORE_BASE_URL=http://core:8081
NEXT_PUBLIC_MINIO_URL=$minio_host
NEXT_PUBLIC_MINIO_PORT=9000
NEXT_PUBLIC_MINIO_ACSK=
NEXT_PUBLIC_MINIO_SECK=
NEXT_PUBLIC_MINIO_BUCKET=$minio_bucket
NEXT_PUBLIC_MINIO_PROT=http" > web/.env

# ## For the notif repo
echo "RBT_MQ=$mq_host
RBT_MQ_USER=$mq_user
RBT_MQ_PASS=$mq_pass
RBT_MQ_EMLQ=$mq_email_q
RBT_MQ_SMSQ=$mq_sms_q
SMS_URL=https://sms.capcom.me/api/3rdparty/v1/message
SMS_USR=VXDAZ9
SMS_PSS=i9xr12qfusf445
EML_USR=$email_usr
EML_PSS=$email_pss
EML_PRT=$email_prt
EML_SRV=$email_srv" > notif/.env

## For the .env
echo "DB_NAME=$db_name
DB_PASS=$db_pass
REDIS_PASS=$rds_pass
MQ_USER=$mq_user
MQ_PASS=$mq_pass
MINIO_USER=$minio_user
MINIO_PASS=$minio_pass
MINIO_BUCKET=$minio_bucket
" > .env

# Remove application.properties file [bc it smh overrides the application-docker.properties]
rm auth/src/main/resources/application.properties
rm core/src/main/resources/application.properties

# Build images and Containers
docker compose build

# Starting the services
docker compose up -d