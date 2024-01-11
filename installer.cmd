@echo off

type asci.art
echo.

set /p db_url=Enter MySQL DB URL (Press Enter for jdbc:mysql://mysqldb:3306/buyersfirstdb): 
set /p db_user=Enter MySQL DB USER (Press Enter for root): 
set /p db_pass=Enter MySQL DB PASSWORD: 
set /p jwt_iss=Enter JWT Issuer (Press Enter for BUYERSFIRST): 
set /p jwt_sec=Enter JWT Secret : 
set /p jwt_exp=Enter JWT Expiry: 
set /p rds_host=Enter REDIS Host : 
set /p rds_port=Enter REDIS Port : 
set /p rds_pass=Enter REDIS Passowrd : 

if not defined db_url set "db_url=jdbc:mysql://mysqldb:3306/buyersfirstdb"
if not defined db_user set "db_user=root"
if not defined jwt_iss set "jwt_iss=BUYERSFIRST"

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
    echo RDS_USR=
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

@REM -- Build images and Containers
docker compose build

@REM -- Starting the services
docker compose up -d
