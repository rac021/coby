#!/bin/bash

 cd $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

 GET_ABS_PATH() {
    # $1 : relative filename
    echo "$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
 }

 # Prepare Installation folder 

 COBY_SOURCES="src"
 COBY_CORE="$COBY_SOURCES/core"

 COBY_BINARY_ROOT="coby_standard_bin"
 COBY_BINARY="$COBY_BINARY_ROOT/pipeline"
 COBY_LIBS="$COBY_BINARY/libs"

 SCRIPTS_PATH_SOURCE="$COBY_CORE/pipeline/scripts"
 SCRIPTS_PATH_DESTINATION="$COBY_BINARY/scripts"

 rm    -rf $COBY_BINARY_ROOT
 mkdir -p  $COBY_BINARY  
 mkdir     $COBY_LIBS
 mkdir     $COBY_LIBS/logs
 mkdir     $COBY_BINARY/work-tmp

 mkdir -p $COBY_BINARY_ROOT/jax-Y-ws/Jax-Y-Coby
 mkdir -p $COBY_BINARY_ROOT/jax-Y-ws/Jax-Y-Client

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
 echo " Done !"
 echo
 echo " Next Step :  Install libs "
 echo " Command : ./$SCRIPTS_PATH_DESTINATION/00_install_libs.sh help "
 echo 
