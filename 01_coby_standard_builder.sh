#!/bin/bash

 cd $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

 GET_ABS_PATH() {
    # $1 : relative filename
    echo "$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
 }

 if [ "$1" = "help" -o "$1" = "h" -o "$1" == "H" -o "$1" = "HELP" ] ; then 
     echo
     echo " Install Cmd Exp  : "
     echo "  1- Generate Only Coby Package ( without downloading and compiling projects ):  $0  "
     echo "  2- install only coby       :  $0 -i coby      "
     echo "  3- install only jaxy       :  $0 -i jaxy      "
     echo "  4- install coby + jaxy     :  $0 -i coby jaxy "
     echo 
     exit
fi

 # Prepare Installation folder 

 COBY_SOURCES="src"
 COBY_CORE="$COBY_SOURCES/core"

 COBY_BINARY_ROOT="coby_standard_bin"
 COBY_BINARY="$COBY_BINARY_ROOT/pipeline"
 COBY_LIBS="$COBY_BINARY/libs"

 SCRIPTS_PATH_SOURCE="$COBY_CORE/pipeline/scripts"
 SCRIPTS_PATH_DESTINATION="$COBY_BINARY/scripts"

 rm    -rf $COBY_BINARY_ROOT
 mkdir  $COBY_BINARY_ROOT
 
 if [ $# == 0 ] ; then 

   mkdir -p  $COBY_BINARY  
   mkdir     $COBY_LIBS
   mkdir     $COBY_LIBS/logs
   mkdir     $COBY_BINARY/work-tmp

   # Copy all scripts to the Binary Directory 
   tput setaf 2
   echo 
   echo " ###########################                             "
   echo " ##### Copy scripts core ###                             "
   echo 
   echo -e "\e[90m Location   : $SCRIPTS_PATH_SOURCE       \e[32m "
   echo -e "\e[90m Destination : $SCRIPTS_PATH_DESTINATION \e[32m "
   echo
   echo " ###########################                             "
   echo 
   sleep 0.5
   tput setaf 7

   cp -rf $SCRIPTS_PATH_SOURCE $SCRIPTS_PATH_DESTINATION

   echo -e "\e[90m Copied. Done. \e[32m "
   echo
   echo -e "\e[95m ################################################################################## \e[32m "
   echo -e "\e[95m ###  Coby Package successfully Deployed in the DIRECTORY  -->  $COBY_BINARY_ROOT   \e[32m "  
   echo -e "\e[95m ################################################################################## \e[32m "
   echo
   echo " Next Step :  Install libs "
   echo " Command : ./$SCRIPTS_PATH_DESTINATION/00_install_libs.sh help "
   
 fi

 if [ "$1" = "-i" ] && [ "$2" = "coby" -o "$3" = "coby" ] ; then 

   mkdir -p  $COBY_BINARY  
   mkdir     $COBY_LIBS
   mkdir     $COBY_LIBS/logs
   mkdir     $COBY_BINARY/work-tmp

   # Copy all scripts to the Binary Directory 
   tput setaf 2
   echo 
   echo " ###########################                             "
   echo " ##### Copy scripts core ###                             "
   echo 
   echo -e "\e[90m Location   : $SCRIPTS_PATH_SOURCE       \e[32m "
   echo -e "\e[90m Destination : $SCRIPTS_PATH_DESTINATION \e[32m "
   echo
   echo " ###########################                             "
   echo 
   sleep 0.5
   tput setaf 7

   cp -rf $SCRIPTS_PATH_SOURCE $SCRIPTS_PATH_DESTINATION

   echo -e "\e[90m Copied. Done. \e[32m "
   echo

   echo -e "\e[90m Run Instalation ..\e[32m "

   ./$SCRIPTS_PATH_DESTINATION/00_install_libs.sh

 fi

 if [ "$1" = "-i" ] && [ "$2" = "jaxy" -o "$3" = "jaxy" ] ; then   

   CURRENT_PATH=`pwd`
 
   # Prepare Installation folder 

   JAXY_JAVA_PROJECT_PATH="$COBY_CORE/jax-Y-ws"

   # jax-Y Web service

   # Dependencies 
   JAVA_PROJECT_JAXY_API="$JAXY_JAVA_PROJECT_PATH/dep/01_G-Jax-Swar-Api"
   JAVA_PROJECT_JAXY_SECURITY="$JAXY_JAVA_PROJECT_PATH/dep/02_G-Jax-Security-Provider"
   JAVA_PROJECT_JAXY_DISCOVERY="$JAXY_JAVA_PROJECT_PATH/dep/03_G-Jax-Service-Discovery"
   # Impl
   JAVA_PROJECT_JAXY_COBY="$JAXY_JAVA_PROJECT_PATH/Jax-Y-Coby"
   JAVA_PROJECT_JAXY_CLIENT="$JAXY_JAVA_PROJECT_PATH/Jax-Y-Client"
 
   JAXY_SERVER_PATH="$COBY_BINARY_ROOT/jax-y_server"
   JAXY_SERVER_NAME="jax-y-swarm.jar"
   JAXY_CLIENT_PATH="$COBY_BINARY_ROOT/jax-y_client"
   JAXY_CLIENT_NAME="g-jax-client.jar"

   mkdir     $JAXY_SERVER_PATH
   mkdir     $JAXY_CLIENT_PATH

   TMP_COMPILATION_FOLDER="$COBY_BINARY_ROOT/tmp"
 
   mkdir     $TMP_COMPILATION_FOLDER/
  
 
   ############################
   ### Compile Web Serivces ###
   ############################

   # 4- Compile jax-Y 

   tput setaf 2
   echo 
   echo " ###########################                         "
   echo " ##### Install jax-Y-API ###                         "
   echo 
   echo -e "\e[90m Location :  $TMP_COMPILATION_FOLDER \e[32m "
   echo
   echo " ###########################                         "
   echo 
   sleep 2
   tput setaf 7

   cp -a $JAVA_PROJECT_JAXY_API/. $TMP_COMPILATION_FOLDER/ 
   cd  $TMP_COMPILATION_FOLDER/ && mvn clean install &&  cd  $CURRENT_PATH
   rm -rf $TMP_COMPILATION_FOLDER/{,.[!.],..?}*
   echo

   tput setaf 2
   echo 
   echo " ###########################                         "
   echo " ##### Install jax-Y-Sec ###                         "
   echo 
   echo -e "\e[90m Location :  $TMP_COMPILATION_FOLDER \e[32m "
   echo
   echo " ###########################                         "
   echo 
   sleep 2
   tput setaf 7

   cp -a $JAVA_PROJECT_JAXY_SECURITY/. $TMP_COMPILATION_FOLDER/ 
   cd  $TMP_COMPILATION_FOLDER/ && mvn clean install &&  cd  $CURRENT_PATH
   rm -rf $TMP_COMPILATION_FOLDER/{,.[!.],..?}*
   echo
   tput setaf 2
   echo 
   echo " ############################                         "
   echo " ##### Install jax-Y-Disc ###                         "
   echo 
   echo -e "\e[90m Location :  $TMP_COMPILATION_FOLDER \e[32m  "
   echo
   echo " ############################                         "
   echo 
   sleep 2
   tput setaf 7

   cp -a $JAVA_PROJECT_JAXY_DISCOVERY/. $TMP_COMPILATION_FOLDER/ 
   cd  $TMP_COMPILATION_FOLDER/ && mvn clean install && cd $CURRENT_PATH
   rm -rf $TMP_COMPILATION_FOLDER/{,.[!.],..?}*
   echo 
   tput setaf 2
   echo 
   echo " ############################                         "
   echo " ##### Install jax-Y-COBY ###                         "
   echo 
   echo -e "\e[90m Location :  $TMP_COMPILATION_FOLDER \e[32m  "
   echo
   echo " ############################                         "
   echo 
   sleep 2
   tput setaf 7

   cp -a $JAVA_PROJECT_JAXY_COBY/. $TMP_COMPILATION_FOLDER/ 
   cd  $TMP_COMPILATION_FOLDER/ &&  mvn clean package && cd  $CURRENT_PATH

   cp $TMP_COMPILATION_FOLDER/target/$JAXY_SERVER_NAME $JAXY_SERVER_PATH 

   cp -r $JAVA_PROJECT_JAXY_COBY/db-script           $JAXY_SERVER_PATH
   cp $JAVA_PROJECT_JAXY_COBY/coby_config.properties $JAXY_SERVER_PATH
   cp $JAVA_PROJECT_JAXY_COBY/serviceConf.yaml       $JAXY_SERVER_PATH
   cp $JAVA_PROJECT_JAXY_COBY/run_server.sh          $JAXY_SERVER_PATH
   echo 
   rm -rf $TMP_COMPILATION_FOLDER/{,.[!.],..?}*
 
   tput setaf 2
   echo 
   echo " ############################                         "
   echo " ##### Install jax-Y-CLI ###                          "
   echo 
   echo -e "\e[90m Location :  $TMP_COMPILATION_FOLDER \e[32m  "
   echo
   echo " ############################                         "
   echo 
   sleep 2
   tput setaf 7

   cp -a $JAVA_PROJECT_JAXY_CLIENT/. $TMP_COMPILATION_FOLDER/ 
   cd  $TMP_COMPILATION_FOLDER/  && mvn clean compile assembly:single && cd $CURRENT_PATH
   
   cp $TMP_COMPILATION_FOLDER/target/$JAXY_CLIENT_NAME $JAXY_CLIENT_PATH 
   rm -rf $TMP_COMPILATION_FOLDER/{,.[!.],..?}*

   rm -rf $TMP_COMPILATION_FOLDER
   echo 
 fi
  
 if [ "$#" != 0 ] ; then   
     
     echo -e "\e[95m ####################################################################################### \e[32m "
     echo -e "\e[95m ###  Coby successfully INSTALLED & Deployed in the DIRECTORY  -->  $COBY_BINARY_ROOT    \e[32m "  
     echo -e "\e[95m ####################################################################################### \e[32m "
     
     tput setaf 2
     echo 
     echo " Before you start using COBY, be sure to provide your 'ORCHESTRATORS' and 'SI' folders "
     echo
     echo "   =>>  Example of 'ORCHESTRATORS' ( use_cases ) & 'SI' ( modelizations ) : ###      "
     echo "         --> SI            :  cp -r src/SI/ coby_standard_bin/pipeline/              "   
     echo "         --> ORCHESTRATORS :  cp -r src/orchestrators/ coby_standard_bin/pipeline/   "
     echo 
     echo "   =>>  Example of Running The 'synthesis_extractor' ORCHESTRATORS :  ###            "
     echo "         --> ./coby_standard_bin/pipeline/orchestrators/synthesis_extractor_entry.sh " 
     sleep 1
     tput setaf 7
 fi

 echo 
 echo " Done !"
 echo 

