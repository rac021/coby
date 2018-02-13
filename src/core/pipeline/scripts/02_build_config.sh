#!/bin/bash

 # Docker version min : 1.10 
 # $1 IP_HOST
 # $2 NameSpace
 # $3 ReadWritePort
 # $4 ReadOnlyPort

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
  
 releasePort() {
   PORT=$1          
   if ! lsof -i :$PORT &> /dev/null
   then
     isFree="true"
   else    
     r_comm=`fuser -k $PORT/tcp  &> /dev/null`
     sleep 1
   fi
   
   if lsof -i :$PORT &> /dev/null ; then
     echo " Try release port : $PORT "
     sleep 0.5
     releasePort $PORT
   else 
      echo " Port [$PORT] released "
   fi
 }  
    

 while [[ "$#" > "0" ]] ; do
     case $1 in
         (*=*) KEY=${1%%=*}
               VALUE=${1#*=}
               case "$KEY" in
                    ("ip")        IP_HOST=$VALUE                    
                    ;;
                    ("namespace") NAMESPACE=$VALUE
                    ;;                    
                    ("rw")        ReadWritePort=$VALUE
                    ;;
                    ("ro")        ReadOnlyPort=$VALUE
		    ;;                   
               esac
         ;;
         help)  echo
		echo " Total Arguments : Four                              "
                echo
		echo "   ip=         :  IP Host                            "
		echo "   namespace=  :  Blazegraph_namespace               "
		echo "   rw=         :  Local Port number, mode Read-Write "
		echo "   ro=         :  Remote Port number, mode Read-Only "
		echo
                EXIT;
     esac
     shift
 done    
    
 IP_HOST=${IP_HOST:-localhost}
 NAMESPACE=${NAMESPACE:-data}
 ReadWritePort=${ReadWritePort:-7777}
 ReadOnlyPort=${ReadOnlyPort:-8888}


 CURRENT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
 cd $CURRENT_PATH
   
 NANO_END_POINT_FILE="$CURRENT_PATH/conf/nanoEndpoint"
 
 BLZ_INFO_INSTALL="$CURRENT_PATH/conf/BLZ_INFO_INSTALL"
 BLAZEGRAPH_PATH=`cat $BLZ_INFO_INSTALL`

 DIR_BLZ=$(dirname "${BLAZEGRAPH_PATH}")
    
 DEFAULT_NAMESPACE="MY_NAMESPACE"
   
 DATALOADER="$CURRENT_PATH/conf/blazegraph/namespace/dataloader.cp.xml"
 
  if [ -f "$DATALOADER" ] ; then 
    rm "$DATALOADER"
 fi
 
 cp "$CURRENT_PATH/conf/blazegraph/namespace/dataloader.xml" "$DATALOADER"  
     
 #   tput setaf 2
 echo 
 echo -e " ##################################### "
 echo -e " ######### Build Config ############## "
 echo -e " ------------------------------------- "
 echo -e " \e[90m$0        \e[32m                "
 echo
 echo -e " ##  IP_HOST       : $IP_HOST          "
 echo
 echo -e " ##  NAMESPACE     : $NAMESPACE        "
 echo -e " ##  ReadWritePort : $ReadWritePort    "
 echo -e " ##  ReadOnlyPort  : $ReadOnlyPort     "
 echo
 echo -e " ##################################### "
 echo 
 sleep 1
 #   tput setaf 7

 BLZ_JNL="$DIR_BLZ/data/blazegraph.jnl"
  
 if [ -e $BLZ_JNL ] ; then
      
    echo
    echo -e "\e[91m $DIR_BLZ/data/blazegraph.jnl will be deleted \e[39m "
    echo
    read -n1 -t 2 -r -p " Press Enter to continue, Any other Key to abort.. else delete in 2 s " key
    echo  
    if [ "$key" = '' ] ; then
        # NOTHING PRESSED 
        rm -f $BLZ_JNL &> /dev/null
        echo " blazegraph.jnl deleted "
        echo
    else
        # Anything pressed
        echo
        echo " Script aborted "
        EXIT
    fi
 fi
   
 echo "$IP_HOST $NAMESPACE $ReadWritePort $ReadOnlyPort" > $NANO_END_POINT_FILE
     
 releasePort $ReadWritePort  
 releasePort $ReadOnlyPort  
 echo
 
 java -server -XX:+UseG1GC -Dcom.bigdata.journal.AbstractJournal.file=$DIR_BLZ/data/blazegraph.jnl \
      -Djetty.port=$ReadWritePort -Dcom.bigdata.rdf.sail.namespace=$NAMESPACE -jar $BLAZEGRAPH_PATH &   
 
 # Wait for the server to finish booting
 while [[ ! -n "$new_job_started" ]] && [ $CURL_COUNT -lt $CURL_TRYING  ]; do

    new_job_started="$(jobs -n)"
 
    if [ -n "$new_job_started" ];then
       PID=$!       
    else
      PID=
    fi
    sleep 1 
 done 
 
 sed -i "s/$DEFAULT_NAMESPACE/$NAMESPACE/g" $DATALOADER

 sleep 1
 
 CMD=$(curl -X POST --data-binary @$DATALOADER --header 'Content-Type:application/xml' \
             http://$IP_HOST:$ReadWritePort/blazegraph/dataloader 2>&1                 )
 
 # test if result curl command contains Failed 
        
 CURL_TRYING=10
 CURL_COUNT=0
 
  while [[ "$CMD" = *"Failed"* ]] && [ $CURL_COUNT -lt $CURL_TRYING  ]; do
   echo 
   echo " Start : Retry ... "   
   releasePort $ReadWritePort  
   releasePort $ReadOnlyPort  
   sleep 1.5
   
   java -server -XX:+UseG1GC -Dcom.bigdata.journal.AbstractJournal.file=$DIR_BLZ/data/blazegraph.jnl  \
        -Djetty.port=$ReadWritePort -Dcom.bigdata.rdf.sail.namespace=$NAMESPACE -jar $BLAZEGRAPH_PATH &  
   
   # Wait for the server to finish booting
   while [[ ! -n "$new_job_started" ]] && [ $CURL_COUNT -lt $CURL_TRYING  ]; do

    new_job_started="$(jobs -n)"
 
    if [ -n "$new_job_started" ];then
       PID=$!       
    else
      PID=
    fi
    sleep 1 
   done
 
   CMD=$(curl -X POST --data-binary @$DATALOADER --header 'Content-Type:application/xml' \
               http://$IP_HOST:$ReadWritePort/blazegraph/dataloader 2>&1                 )
   echo
  done
   
 sleep 1
 
 curl -X DELETE http://$IP_HOST:$ReadWritePort/blazegraph/namespace/kb &> /dev/null
 
 sleep 1
   
 # sed -i "s/$NAMESPACE/$DEFAULT_NAMESPACE/g" conf/blazegraph/namespace/dataloader.xml
 rm "$DATALOADER"
  
 echo ; echo
 echo -e "\e[92m Namespace created \e[39m "
 sleep 0.5 ; echo
 echo -e "\e[93m Stopping Blazegraph \e[39m "
   
   
 # Test connexion with specified namespace 
   
 PREFIX_ENDPOINT="http://$IP_HOST:$ReadWritePort"
 SUFFIX_ENDPOINT="blazegraph/namespace/$NAMESPACE/sparql"

 ENDPOINT=$PREFIX_ENDPOINT/$SUFFIX_ENDPOINT
 
 check="cat < /dev/null > /dev/tcp/http://$IP/$PORT"
     
 echo ; echo -e " Try connection : $ENDPOINT "
        
 TRYING=50
 COUNT=0
            
 OK=$?
            
 while [ $OK -ne 0 -a $COUNT -lt $TRYING  ] ; do
           
     timeout 1 bash -c "cat < /dev/null > /dev/tcp/$IP_HOST/$ReadWritePort" 2> /dev/null
            
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
   
   
 # Kill BlazeGraph Process 
   
 KILL_PROCESS=$(fuser -k $ReadWritePort/tcp &>/dev/null )
   
 sleep 0.8
 echo -e "\e[93m Blazegraph Stopped \e[39m "
 echo
 echo -e "\e[92m Use 11_nano_start_stop.sh script to start-stop Blazegraph \e[39m "
 echo

sleep 1
