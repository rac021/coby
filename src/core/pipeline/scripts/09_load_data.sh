#!/bin/bash

  CURRENT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
  cd $CURRENT_PATH
  
  EXIT() {
     parent_script=`ps -ocommand= -p $PPID | awk -F/ '{print $NF}' | awk '{print $1}'`
     if [ $parent_script = "bash" ] ; then
         echo; echo -e " \e[90m exited by : $0 \e[39m " ; echo
         exit 2
     else
         echo ; echo -e " \e[90m exited by : $0 \e[39m " ; echo
         kill -9 `ps --pid $$ -oppid=`;
         exit 2
     fi
  }  
  
   
  while [[ "$#" > "0" ]] ; do
     case $1 in
         (*=*) KEY=${1%%=*}
               VALUE=${1#*=}
               
               case "$KEY" in
               
                    ("from_directory")   DATA_DIR=$VALUE
                    ;;
                    ("content_type")    CONTENT_TYPE=$VALUE
                    ;;                     
                    ("ip")              IP=$VALUE          # if not set , read from /conf/nanoEndpoint
                    ;;
                    ("port")            PORT=$VALUE        # if not set , read from /conf/nanoEndpoint
                    ;;
                    ("namespace")       NAMESPACE=$VALUE   # if not set , read from /conf/nanoEndpoint
               esac
         ;;
         help)  echo
                echo " Total Arguments : Five                                                     "
                echo
                echo "   ip=              :  IP_HOST ( or Hostname )                              "
                echo "   namespace=       :  NAME_SPACE                                           "
                echo "   port=            :  Endpoint Port                                        "
                echo "   content_type=    :  Content Type. Ex :  text/turtle                      "
                echo "                                           content_type=application/rdf+xml "
                echo "                                           content_type=text/rdf+n3         "
                echo "                                           content_type=rdf/turtle          "
                echo "                                           application/sparql-results+json  "		
                echo "   from_directory=  :  Data Location. Ex : from_directory='/home/rya/soere' "
                echo
                EXIT;
         esac
     shift
  done    
    
  SELECTED_SI="conf/SELECTED_SI_INFO"
        
  if [ ! -f $SELECTED_SI ]  ; then
       echo
       echo -e "\e[91m Missing $SELECTED_SI ! \e[39m "
       echo -e "\e[91m You can use the command [[ ./scripts/01_use_si.sh si=WhichSI ]] to set the var WhichSI ! \e[39m "    
       EXIT
  fi
    
  SI=$(head -1 $SELECTED_SI)   
        
  if [ "$SI" == "" ] ; then  
       _DATA_DIR="$PARENT_DIR/SI/output/03_corese/"         
  else    
       _DATA_DIR="$SI/output/03_corese/"
  fi
  
  
  DATA_DIR=${DATA_DIR:-$_DATA_DIR}
    
  CONTENT_TYPE=${CONTENT_TYPE:-"text/turtle"} # application/rdf+xml
     
        
  if [ -z "$IP" -o -z "$NAMESPACE" -o -z "$PORT" ] ; then
   
      NANO_END_POINT_FILE="$CURRENT_PATH/conf/nanoEndpoint"
    
      if [ ! -f $NANO_END_POINT_FILE ]; then
        echo
        echo -e "\e[91m --> File [ $NANO_END_POINT_FILE ] not found \e[39m"
        echo
        EXIT
      fi
    
      LINE=$(head -1 $NANO_END_POINT_FILE)
      IFS=$' \t\n' read -ra INFO_NANO <<< "$LINE" 
      
      IP=${IP:-${INFO_NANO[0]}}
      NAMESPACE=${NAMESPACE:-${INFO_NANO[1]}}
      PORT=${PORT:-${INFO_NANO[2]}}  
  fi
    
  PREFIX_ENDPOINT="http://$IP:$PORT"
  SUFFIX_ENDPOINT="blazegraph/namespace/$NAMESPACE/sparql"
  
  ENDPOINT=$PREFIX_ENDPOINT/$SUFFIX_ENDPOINT
 
  # Test connexion with specified namespace 
  check="cat < /dev/null > /dev/tcp/http://$IP/$PORT"
      
  echo ; echo -e " Try connection : $ENDPOINT "
        
  TRYING=50
  COUNT=0
        
  timeout 1 bash -c "cat < /dev/null > /dev/tcp/$IP/$PORT" 2> /dev/null
        
  OK=$?
        
  while [ $OK -ne 0 -a $COUNT -lt $TRYING  ] ; do
        
    timeout 1 bash -c "cat < /dev/null > /dev/tcp/$IP/$PORT" 2> /dev/null
           
    OK=$?
           
    if [ $COUNT == 0 ] ; then echo ; fi 
           
    if [ $OK == 1 ] ; then 
             
      echo " .. "
      sleep 0.4 
             
    elif [ $OK != 0 ] ; then 
          
      echo " attempt ( $COUNT ) : Try again.. "
      sleep 0.8
             
    fi
           
    let "COUNT++"
           
    if [ $COUNT == $TRYING ] ; then
          
      echo
      echo -e "\e[31m ENDPOINT $ENDPOINT Not reachable !! \e[39m"
      echo
      EXIT
             
    fi
           
  done
        
  RES=`curl -s -I $ENDPOINT | grep HTTP/1.1 | awk {'print $2'}`
        
  COUNT=0
        
  while  [ -z $RES ] || [ $RES -ne 200 ] ;do
        
    sleep 1
    RES=`curl -s -I $ENDPOINT | grep HTTP/1.1 | awk {'print $2'}`
    let "COUNT++" 
           
    if  [ -z $RES ] || [ $RES -ne 200 ] ; then 
        if [ `expr $COUNT % 3` -eq 0 ] ; then
           echo -e " attempt to join $ENDPOINT .. "
        fi
    fi
           
  done
       
  echo " Yeah Connected !! "
       
  
  if [ ! -d $DATA_DIR ] ; then
     echo -e "\e[91m $DATA_DIR is not valid Directory ! \e[39m "
     echo EXIT
  fi
            
  # Remove the sparql file automatically created by blazegraph
  
  if [ -f "$DATA_DIR/sparql" ] ; then
    rm -f "$DATA_DIR/sparql" 
  fi

  sleep 0.5  # Waits 0.5 second .

  cd $DATA_DIR
        
  tput setaf 2
  echo 
  echo -e " ################################################################ "
  echo -e " ######## Info Load Data ######################################## "
  echo -e " ---------------------------------------------------------------- "
  echo -e " \e[90m$0                                                  \e[32m "
  echo
  echo -e " # ENDPOINT     : $PREFIX_ENDPOINT                                "
  echo -e " # NAMESPACE    : $NAMESPACE                                      "
  echo -e " # PORT         : $PORT                                           "
  echo -e " # CONTENT_TYPE : $CONTENT_TYPE                                   "
  echo -e "\e[90m   Folder : $DATA_DIR                                \e[32m "
  echo
  echo -e " ################################################################ "
  echo 
  sleep 1  
  tput setaf 7
 
  for _file in `find * -type f -not -name "sparql" `; do
   
      echo -e " \e[39m Upload file :\e[92m $_file \e[39m                    " 
      echo " ----------------------------------------------------------------------- "
      echo
      curl -D- -H "Content-Type: $CONTENT_TYPE" --upload-file $_file -X POST $ENDPOINT -O
      echo
      echo " ----------------------------------------------------------------------- "
   
  done 
  
  rm $DATA_DIR/sparql
    
  # Content-Type: text/turtle
  # Content-Type: text/rdf+n3
  # Content-Type: Content-Type: application/rdf+xml
  # Content-Type: application/sparql-results+json
  

