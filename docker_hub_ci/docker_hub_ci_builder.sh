#!/bin/bash

 cd $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

 GET_ABS_PATH() {
    # $1 : relative filename
    echo "$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
 }

 COMPILE_IN_DOCKER()                      {
     JAVA_PROJECT_P="$1"
     MVN_CMD="$2"
     MAVEN_REPO="$3"
     docker run -it --rm -u $UID          \
     -e MAVEN_CONFIG=/var/maven/.m2       \
     -v $MAVEN_REPO:/var/maven/.m2        \
     -v $JAVA_PROJECT_P/:/usr/src/mymaven \
     -w /usr/src/mymaven                  \
     --name java_binary                   \
     maven:3.5.2-jdk-8 $MVN_CMD
 }

 # Prepare Installation folder 

 COBY_SOURCES="src"
 COBY_CORE="$COBY_SOURCES/core"

 COBY_IMAGE_NAME="coby" 
 
 COBY_BINARY_ROOT="coby_bin"
 COBY_BINARY="$COBY_BINARY_ROOT/pipeline"
 COBY_LIBS="$COBY_BINARY/libs"

 TMP_COMPILATION_FOLDER="$COBY_BINARY_ROOT/TMP_COMPILATION_FOLDER"

 SCRIPTS_PATH_SOURCE="$COBY_CORE/pipeline/scripts"
 SCRIPTS_PATH_DESTINATION="$COBY_BINARY/scripts"

 PIPELINE_JAVA_PROJECT_PATH="$COBY_CORE/pipeline/java_projects"
 JAXY_JAVA_PROJECT_PATH="$COBY_CORE/jax-Y-ws"

 # Coby Project
 JAVA_PROJECT_CORESE_PATH="$PIPELINE_JAVA_PROJECT_PATH/CoreseInfer"
 CORESE_BINARY_NAME_IN_TARGET="CoreseInferMaven-1.0.0-jar-with-dependencies.jar"
 CORESE_FINAL_BINARY_NAME="CoreseInfer.jar"
 # Ontop Project
 JAVA_PROJECT_ONTOP_PATH="$PIPELINE_JAVA_PROJECT_PATH/ontop-matarializer"
 ONTOP_BINARY_NAME_IN_TARGET="ontop-materializer-1.18.1-jar-with-dependencies.jar"
 ONTOP_FINAL_BINARY_NAME="Ontop-Materializer.jar"
 # yedGen Project
 JAVA_PROJECT_YEDGEN_PATH="$PIPELINE_JAVA_PROJECT_PATH/yedGen"
 YEDGEN_BINARY_NAME_IN_TARGET="yedGen_2.1-2.1-jar-with-dependencies.jar"
 YEDGEN_FINAL_BINARY_NAME="yedGen.jar"
 # blazeGraph Project 
 JAVA_PROJECT_BLAZEGRAPH_PATH="$COBY_LIBS/Blazegraph"
 BLAZEGRAPH_FINAL_BINARY_NAME="blazegraph_2_1_4.jar"
 BLAZEGRAPH_URL="https://raw.githubusercontent.com/rac021/blazegraph_libs/master/blazegraph_2_1_4.jar"

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

 rm    -rf $COBY_BINARY_ROOT
 mkdir -p  $COBY_BINARY  
 mkdir     $COBY_LIBS
 mkdir     $COBY_LIBS/logs
 mkdir     $COBY_BINARY/work-tmp

 mkdir -p  $JAVA_PROJECT_BLAZEGRAPH_PATH/data

 mkdir     $JAXY_SERVER_PATH
 mkdir     $JAXY_CLIENT_PATH

 mkdir     $TMP_COMPILATION_FOLDER/

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
 sleep 2
 tput setaf 7

 cp -rf $SCRIPTS_PATH_SOURCE $SCRIPTS_PATH_DESTINATION

 echo -e "\e[90m Copied. Done. \e[32m "

 ABSOLUTE_PATH_PROJECT_TO_COMPILE=$(GET_ABS_PATH $TMP_COMPILATION_FOLDER)

 # Create m2 tmp repo to manage Shared Dependencies
 MAVEN_REPO_NAME="$COBY_BINARY_ROOT/m2"
 mkdir $MAVEN_REPO_NAME
 MAVEN_REPO_PATH=$(GET_ABS_PATH $MAVEN_REPO_NAME)

 #############################################
 ### Compile Pipeline Project Using Docker ###
 #############################################

 # 1- Compile yedGen Project 

 tput setaf 2
 echo 
 echo " ###########################                         "
 echo " ##### Install yedGen ######                         "
 echo 
 echo -e "\e[90m Location :  $TMP_COMPILATION_FOLDER \e[32m "
 echo
 echo " ###########################                         "
 echo 
 sleep 2
 tput setaf 7

 cp -a $JAVA_PROJECT_YEDGEN_PATH/. $TMP_COMPILATION_FOLDER/

 COMPILE_IN_DOCKER $ABSOLUTE_PATH_PROJECT_TO_COMPILE "mvn -Duser.home=/var/maven clean install assembly:single" $MAVEN_REPO_PATH
 
 cp $TMP_COMPILATION_FOLDER/target/$YEDGEN_BINARY_NAME_IN_TARGET $COBY_LIBS/$YEDGEN_FINAL_BINARY_NAME
 
 rm -rf $TMP_COMPILATION_FOLDER/{,.[!.],..?}*
 rm -rf $MAVEN_REPO_PATH/{,.[!.],..?}*  # clean .m2

 # 2- Compile Ontop Project 

 tput setaf 2
 echo 
 echo " ###########################                         "
 echo " ##### Install Ontop ######                          "
 echo 
 echo -e "\e[90m Location :  $TMP_COMPILATION_FOLDER \e[32m "
 echo
 echo " ###########################                         "
 echo 
 sleep 2
 tput setaf 7

 cp -a $JAVA_PROJECT_ONTOP_PATH/. $TMP_COMPILATION_FOLDER/

 COMPILE_IN_DOCKER $ABSOLUTE_PATH_PROJECT_TO_COMPILE "mvn -Duser.home=/var/maven clean install assembly:single" $MAVEN_REPO_PATH
 
 cp $TMP_COMPILATION_FOLDER/target/$ONTOP_BINARY_NAME_IN_TARGET $COBY_LIBS/$ONTOP_FINAL_BINARY_NAME
 
 rm -rf $TMP_COMPILATION_FOLDER/{,.[!.],..?}*
 rm -rf $MAVEN_REPO_PATH/{,.[!.],..?}*  # clean .m2


 # 3- Compile Corese Project 

 tput setaf 2
 echo 
 echo " ###########################                         "
 echo " ##### Install Corese ######                         "
 echo 
 echo -e "\e[90m Location :  $TMP_COMPILATION_FOLDER \e[32m "
 echo
 echo " ###########################                         "
 echo 
 sleep 2
 tput setaf 7

 cp -a $JAVA_PROJECT_CORESE_PATH/. $TMP_COMPILATION_FOLDER/

 COMPILE_IN_DOCKER $ABSOLUTE_PATH_PROJECT_TO_COMPILE "mvn -Duser.home=/var/maven clean install assembly:single" $MAVEN_REPO_PATH
 
 cp $TMP_COMPILATION_FOLDER/target/$CORESE_BINARY_NAME_IN_TARGET $COBY_LIBS/$CORESE_FINAL_BINARY_NAME
 
 rm -rf $TMP_COMPILATION_FOLDER/{,.[!.],..?}*
 rm -rf $MAVEN_REPO_PATH/{,.[!.],..?}*  # clean .m2

 # 4- Install Blz

 tput setaf 2
 echo 
 echo " ###########################                         "
 echo " ##### Install BlazeGraph ##                         "
 echo 
 echo -e "\e[90m Location :  $TMP_COMPILATION_FOLDER \e[32m "
 echo
 echo " ###########################                         "
 echo 
 sleep 2
 tput setaf 7

 # 3- GET BlazeGraph
 wget $BLAZEGRAPH_URL -O $JAVA_PROJECT_BLAZEGRAPH_PATH/$BLAZEGRAPH_FINAL_BINARY_NAME

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
 COMPILE_IN_DOCKER $ABSOLUTE_PATH_PROJECT_TO_COMPILE "mvn -Duser.home=/var/maven clean install" $MAVEN_REPO_PATH
 rm -rf $TMP_COMPILATION_FOLDER/{,.[!.],..?}*

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
 COMPILE_IN_DOCKER $ABSOLUTE_PATH_PROJECT_TO_COMPILE "mvn -Duser.home=/var/maven clean install" $MAVEN_REPO_PATH
 rm -rf $TMP_COMPILATION_FOLDER/{,.[!.],..?}*

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
 COMPILE_IN_DOCKER $ABSOLUTE_PATH_PROJECT_TO_COMPILE "mvn -Duser.home=/var/maven clean install" $MAVEN_REPO_PATH
 rm -rf $TMP_COMPILATION_FOLDER/{,.[!.],..?}*

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
 COMPILE_IN_DOCKER $ABSOLUTE_PATH_PROJECT_TO_COMPILE "mvn -Duser.home=/var/maven clean package" $MAVEN_REPO_PATH
 cp $TMP_COMPILATION_FOLDER/target/$JAXY_SERVER_NAME $JAXY_SERVER_PATH 

 cp -r $JAVA_PROJECT_JAXY_COBY/db-script           $JAXY_SERVER_PATH
 cp $JAVA_PROJECT_JAXY_COBY/coby_config.properties $JAXY_SERVER_PATH
 cp $JAVA_PROJECT_JAXY_COBY/serviceConf.yaml       $JAXY_SERVER_PATH
 cp $JAVA_PROJECT_JAXY_COBY/run_server.sh          $JAXY_SERVER_PATH
 
 # DOI service
  mkdir "$COBY_BINARY/DOI"

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
 COMPILE_IN_DOCKER $ABSOLUTE_PATH_PROJECT_TO_COMPILE "mvn -Duser.home=/var/maven clean compile assembly:single" $MAVEN_REPO_PATH
 cp $TMP_COMPILATION_FOLDER/target/$JAXY_CLIENT_NAME $JAXY_CLIENT_PATH 
 rm -rf $TMP_COMPILATION_FOLDER/{,.[!.],..?}*

 rm -rf $TMP_COMPILATION_FOLDER
 rm -rf $MAVEN_REPO_PATH

 # BUILD DOCKER IMAGE 
 docker build --no-cache -t $COBY_IMAGE_NAME . 

 rm -rf $COBY_BINARY_ROOT
 
 tput setaf 2
 echo 
 echo
 echo " COBY DOCKER IMAGE BUILT. Image Name : [$COBY_IMAGE_NAME]   "
 echo
 echo "  --> Coby SOURCE Location ( in the image ) : /opt/src-coby "
 echo
 echo "  --> Coby BINARY Location ( in the image ) : /opt/coby     "
 echo "    + Coby pipeline    Location : /opt/coby/pipeline        "
 echo "    + Coby jaxy-server location : /opt/coby/jax-y_server    "
 echo "    + Coby jaxy-client location : /opt/coby/jax-y_client    "
 echo
 echo " Before starting a COBY container, be sure to provide your 'ORCHESTRATORS' and 'SI' folders "
 echo
 echo " Ex : "
 echo
 echo "   docker run -it --net host                                                 \\"
 echo "              --memory-swappiness=0                                          \\"
 echo "              --ulimit nproc=20000:50000                                     \\"
 echo "              -v `pwd`/src/orchestrators/.:/opt/coby/pipeline/orchestrators  \\"
 echo "              -v `pwd`/src/SI:/opt/coby/pipeline/SI $COBY_IMAGE_NAME         \\"
 echo "              /opt/coby/pipeline/orchestrators/synthesis_extractor_entry.sh    "
 echo          
 sleep 1
 tput setaf 7
 echo    
 echo "Done !"
 
 echo
