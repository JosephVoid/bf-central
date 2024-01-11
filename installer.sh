# CORE
# DB_URL=jdbc:mysql://mysqldb:3306/buyersfirstdb
# DB_USER=root
# DB_PASS=dev_root
# JWT_ISS=BUYERSFIRST
# JWT_SEC=sect_1234
# JWT_EXP=10080
# RDS_HST=
# RDS_PRT=
# RDS_PSW=
# RDS_USR=

####
# AUTH
# DB_URL=jdbc:mysql://mysqldb:3306/buyersfirstdb
# DB_USER=root
# DB_PASS=dev_root
# JWT_ISS=BUYERSFIRST
# JWT_SEC=sect_1234
# JWT_EXP=10080

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
read -p "Enter MySQL DB USER (Press Enter for root): " db_user;
read -p "Enter MySQL DB PASSWORD: " db_pass;
read -p "Enter JWT Issuer (Press Enter for BUYERSFIRST): " jwt_iss;
read -p "Enter JWT Secret : " jwt_sec;
read -p "Enter JWT Expiry: " jwt_exp;
read -p "Enter REDIS Host : " rds_host;
read -p "Enter REDIS Port : " rds_port;
read -p "Enter REDIS Passowrd : " rds_pass;

if [[ -z "$db_url" ]]; then
    db_url="jdbc:mysql://mysqldb:3306/buyersfirstdb";
fi

if [[ -z "$db_user" ]]; then
    db_user="root";
fi

if [[ -z "$jwt_iss" ]]; then
    jwt_iss="BUYERSFIRST";
fi

db_name=$(echo "${db_url##*/}")

# Clone all the submodules
git submodule update -i

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
RDS_USR=" > core/src/main/resources/docker.secret.properties

# ## For the auth repo
echo "DB_URL=$db_url
DB_USER=$db_user
DB_PASS=$db_pass
JWT_ISS=$jwt_iss
JWT_SEC=$jwt_sec
JWT_EXP=$jwt_exp
" > auth/src/main/resources/docker.secret.properties

## For the .env
echo "DB_NAME=$db_name
DB_PASS=$db_pass
REDIS_PASS=$rds_pass
" > .env

# Build images and Containers
docker compose build

# Starting the services
docker compose up -d