@echo off

type asci.art
echo.

set /p db_url=Enter MySQL DB URL (Press Enter for jdbc:mysql://mysqldb:3306/buyersfirstdb): 
set /p db_user=Enter MySQL DB USER (Press Enter for root): 
set /p db_pass=Enter MySQL DB PASSWORD: 
set /p jwt_iss=Enter JWT Issuer (Press Enter for BUYERSFIRST): 
set /p jwt_sec=Enter JWT Secret : 
set /p jwt_exp=Enter JWT Expiry (Press Enter for 10080): 
set /p rds_host=Enter REDIS Host (Press Enter for redis): 
set /p rds_port=Enter REDIS Port (Press Enter for 6379): 
set /p rds_user=Enter REDIS User (Press Enter for default): 
set /p rds_pass=Enter REDIS Passowrd : 

if not defined db_url set "db_url=jdbc:mysql://mysqldb:3306/buyersfirstdb"
if not defined db_user set "db_user=root"
if not defined jwt_iss set "jwt_iss=BUYERSFIRST"
if not defined jwt_exp set "jwt_exp=10080"
if not defined rds_host set "rds_host=redis"
if not defined rds_user set "rds_user=default"
if not defined rds_port set "rds_port=6379"

for /f "tokens=*" %%A in ('echo %db_url:/=\%') do set "db_name=%%~nxA"

@REM Clone all the submodules
git submodule update -i

@REM Generate and place the secret files
@REM -- For the core repo
(
    echo DB_URL=%db_url%
    echo DB_USER=%db_user%
    echo DB_PASS=%db_pass%
    echo JWT_ISS=%jwt_iss%
    echo JWT_SEC=%jwt_sec%
    echo JWT_EXP=%jwt_exp%
    echo RDS_HST=%rds_host%
    echo RDS_PRT=%rds_port%
    echo RDS_PSW=%rds_pass%
    echo RDS_USR=%rds_user%
) > core\src\main\resources\docker.secret.properties

@REM -- For the auth repo
(
    echo DB_URL=%db_url%
    echo DB_USER=%db_user%
    echo DB_PASS=%db_pass%
    echo JWT_ISS=%jwt_iss%
    echo JWT_SEC=%jwt_sec%
    echo JWT_EXP=%jwt_exp%
) > auth\src\main\resources\docker.secret.properties
@REM -- For the .env
(
    echo DB_NAME=%db_name%
    echo DB_PASS=%db_pass%
    echo REDIS_PASS=%rds_pass%
) > .env

@REM Remove application.properties file [bc it smh overrides the application-docker.properties]
del auth/src/main/resources/application.properties
del core/src/main/resources/application.properties

@REM -- Build images and Containers
docker compose build

@REM -- Starting the services
docker compose up -d
