
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
read -p "Enter MySQL DB Host (Press Enter for mysqldb: " db_host;
read -p "Enter MySQL DB USER (Press Enter for root): " db_user;
read -p "Enter MySQL DB PASSWORD: " db_pass;
read -p "Enter JWT Issuer (Press Enter for BUYERSFIRST): " jwt_iss;
read -p "Enter JWT Secret : " jwt_sec;
read -p "Enter JWT Expiry (Press Enter for 10080): " jwt_exp;
read -p "Enter REDIS Host (Press Enter for redis): " rds_host;
read -p "Enter REDIS User (Press Enter for default): " rds_user;
read -p "Enter REDIS Port (Press Enter for 6379): " rds_port;
read -p "Enter REDIS Passowrd : " rds_pass;

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

db_name=$(echo "${db_url##*/}")

# Clone all the submodules
git submodule update -i

# Update the submodules
cd auth ; git checkout main ; git pull ; cd ..
cd chat ; git checkout main ; git pull ; cd ..
cd core ; git checkout main ; git pull ; cd ..
cd file ; git checkout main ; git pull ; cd ..

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

# ## For the chat repo
echo "PORT=4000
DB_HOST=$db_host
DB_USER=$db_user
DB_PASS=$db_pass
DB_NAME=$db_name
JWT_SEC=$jwt_sec
" > chat/.env

## For the .env
echo "DB_NAME=$db_name
DB_PASS=$db_pass
REDIS_PASS=$rds_pass
" > .env

# Remove application.properties file [bc it smh overrides the application-docker.properties]
rm auth/src/main/resources/application.properties
rm core/src/main/resources/application.properties
rm file/src/main/resources/application.properties
# Build images and Containers
docker compose build

# Starting the services
docker compose up -d