#!/bin/bash
 
  DATABASE="coby"
  
  # The USER which is used by Jax-Y
  DB_USER_CONNECTION="coby_user"
  DB_PASSWORD_CONNECTION="coby_password"
 
  PSQL_CONNECT="postgres"
 
  Auth_TABLE="users"
  LOGIN_COLUMN_NAME="login"
  PASSWORD_COLUMN_NAME="password"
  STORAGE_PASSWORD_ALGO="MD5"
  
  # USER ONE  
  USER_ONE_LOGIN="admin"
  USER_ONE_PASSWORD="admin"
  # USER TWO 
  USER_TWO_LOGIN="public"
  USER_TWO_PASSWORD="public"
    
  LOG="$1" # $1 = DISPLAY ( to enable logs )
  
  #################################################
  ### PROCESSOR ###################################
  #################################################

  if [  "$STORAGE_PASSWORD_ALGO" == "MD5" ] ; then 
  
     USER_ONE_HASHED_PASS=`  echo -n $USER_ONE_PASSWORD  | md5sum  | cut -d ' ' -f 1` 
     USER_TWO_HASHED_PASS=` echo -n $USER_TWO_PASSWORD | md5sum  | cut -d ' ' -f 1` 
     
  elif [  "$STORAGE_PASSWORD_ALGO" == "SHA2" ] ; then 
  
    USER_ONE_HASHED_PASS=`  echo -n $USER_ONE_PASSWORD  | sha256sum  | cut -d ' ' -f 1 ` 
    USER_TWO_HASHED_PASS=` echo -n $USER_TWO_PASSWORD | sha256sum  | cut -d ' ' -f 1 ` 
    
  else  # PLAIN_STORAGE 
  
    USER_ONE_HASHED_PASS="$USER_ONE_PASSWORD"
    USER_TWO_HASHED_PASS="$USER_TWO_PASSWORD"
  
  fi
  
  tput setaf 2
  echo 
  echo -e " #################################################### "
  echo -e " ################ Create DataBase ################### "
  echo -e " ---------------------------------------------------- "
  echo -e " \e[90m$0        \e[32m                               "
  echo 
  echo -e " ##  DATABASE               : $DATABASE               "
  echo -e " ##  Auth_TABLE             : $Auth_TABLE             "
  echo -e " ##  STORAGE_PASSWORD_ALGO  : $STORAGE_PASSWORD_ALGO  "
  echo  
  echo -e " ##  DB_USER_CONNECTION     : $DB_USER_CONNECTION     "
  echo -e " ##  DB_PASSWORD_CONNECTION : $DB_PASSWORD_CONNECTION "
  echo
  echo -e " ##  USER_ONE_LOGIN         : $USER_ONE_LOGIN         "
  echo -e " ##  USER_ONE_PASSWORD      : $USER_ONE_PASSWORD      "
  echo -e " ##  USER_ONE_HASHED_PASS   : $USER_ONE_HASHED_PASS   "
  echo
  echo -e " ##  USER_TWO_LOGIN         : $USER_TWO_LOGIN         "
  echo -e " ##  USER_TWO_PASSWORD      : $USER_TWO_PASSWORD      "
  echo -e " ##  USER_TWO_HASHED_PASS   : $USER_TWO_HASHED_PASS   "
  echo
  echo -e " #################################################### "
  echo 
  
  sleep 0.5
  
  tput setaf 7

  if which psql > /dev/null ; then
     echo " postgres command OK ..   "  
  else     
     echo " postgres command NOT FOUND  "
     echo " Script will abort           "
     exit 
  fi
  
  echo 
  
  if [ "$LOG" == "display" -o "$LOG" == "DISPLAY" ] ; then 
     LOG=""
  else 
     LOG=' 2> /dev/null '
  fi
   
  COMMAND=" sudo -u $PSQL_CONNECT psql $LOG "

  eval $COMMAND  << EOF
  
  DROP  DATABASE $DATABASE ;
  DROP  USER     $DB_USER_CONNECTION  ;
 
  CREATE DATABASE $DATABASE TEMPLATE template0 ; 
  CREATE USER $DB_USER_CONNECTION WITH PASSWORD '$DB_PASSWORD_CONNECTION'  ;
  
  \connect $DATABASE ;  
  
  -- Create Table for Authentication 
   
  CREATE TABLE $Auth_TABLE ( $LOGIN_COLUMN_NAME     varchar(255) ,
                             $PASSWORD_COLUMN_NAME  varchar(255) ,
	                     CONSTRAINT pk_users PRIMARY KEY ( login )
  
  ) ;

  INSERT INTO $Auth_TABLE VALUES ( '$USER_ONE_LOGIN' , '$USER_ONE_HASHED_PASS' ) ; -- HASHED password 
  INSERT INTO $Auth_TABLE VALUES ( '$USER_TWO_LOGIN' , '$USER_TWO_HASHED_PASS' ) ; -- HASHED password 
  
  GRANT SELECT ON $Auth_TABLE to $DB_USER_CONNECTION ;  
  
EOF

echo

