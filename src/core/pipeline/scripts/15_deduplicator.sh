#!/bin/bash
  
  EXIT() {
   if [ $PPID = 0 ] ; then exit ; fi
   parent_script=`ps -ocommand= -p $PPID | awk -F/ '{print $NF}' | awk '{print $1}'`
   if [ $parent_script = "bash" ] ; then
       echo; echo -e " \e[90m exited by : $0 \e[39m " ; echo
       exit 2
   else
       if [ $parent_script != "java" ] ; then 
          echo ; echo -e " \e[90m exited by : $0 \e[39m " ; echo
          kill -9 `ps --pid $$ -oppid=`;
          exit 2
       fi
       echo " Coby Exited "
       exit 2
   fi
  }   
    
  CURRENT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
  cd $CURRENT_PATH
  ROOT_PATH="${CURRENT_PATH/}"
  PARENT_DIR="$(dirname "$ROOT_PATH")"

   while [[ "$#" > "0" ]] ; do
     case $1 in
         (*=*) KEY=${1%%=*}
               VALUE=${1#*=}
               
               case "$KEY" in
               
                    ("from_directory") FROM_DIRECTORY=$VALUE                    
                    ;;
                    ("to_directory")   TO_DIRECTORY=$VALUE
                    ;;                    
                    ("name_file")      NAME_FILE=$VALUE
                    ;;
                    ("size_file")      SIZE_FILE=$VALUE 
                    ;;
                    ("ignoring_lines_from_file")  FILE_LINES_TO_INGORE=$VALUE
               esac
	     ;;
         help)  echo
                echo " Total Arguments : Five                                                                          "
                echo 
                echo "   from_directory=           :  Folder containing Files                                          "
                echo "   to_directory=             :  Output Folder result                                             "
                echo "   name_file=                :  name of the outpurt file                                         "
                echo "   size_file=                :  Total lines per files                                            "
                echo "   ignoring_lines_from_file= :  Ingoring process Files. Ex : ignoring_lines_from_file='onto/*.*' "
                echo
                EXIT ;
         ;;
         inplace ) INPLACE="TRUE" 
         
     esac
     shift
  done   

  if [ -z "$FROM_DIRECTORY" ]; then 
    echo
    echo " From Directory not Provided. Exit "
    EXIT
  fi
  
  if [ -z "$INPLACE" ]; then 

    if [ -z "$TO_DIRECTORY" ]; then 
      echo
      echo " [TO_ Directory] OR [INPLACE] ARGS not Provided. Exit"
      EXIT    
    fi
    
         
    NAME_FILE=${NAME_FILE:-"Data"}
    SUFFIX=${SUFFIX:-".ttl"} 
    SIZE_FILE=${SIZE_FILE:-"5000"} 
    
  else 
     TO_DIRECTORY="-"
     NAME_FILE="-"
     SUFFIX=""
     SIZE_FILE="-"
  fi
  
  
  LAST_DROM_DIRECTORY_CHAR=` echo "${FROM_DIRECTORY: -1}" `  
  
  if [ "$LAST_DROM_DIRECTORY_CHAR" == "/" ] ; then       
    FROM_DIRECTORY=`echo "${FROM_DIRECTORY::-1}"`     
  fi
 
  FILE_LINES_TO_INGORE=${FILE_LINES_TO_INGORE:-""} 
 
  
  tput setaf 2
  echo 
  echo -e " ################################################# "
  echo -e " ######## Info Deduplicator  ##################### "
  echo -e " ------------------------------------------------  "
  echo -e "\e[90m$0            \e[32m                         "
  echo
  echo -e " ##  DIRECTORY             : $FROM_DIRECTORY       "
  echo -e " ##  TO                    : $TO_DIRECTORY         "
  echo -e " ##  NAME_FILE             : $NAME_FILE            "
  echo -e " ##  SUFFIX                : $SUFFIX               "
  echo -e " ##  SIZE_FILE             : $SIZE_FILE            "
  echo -e " ##  FILE_LINES_TO_INGORE  : $FILE_LINES_TO_INGORE "
  echo
  echo -e " ##  INPLACE               : $INPLACE              "
  echo
  echo -e " ################################################# "
  echo 
  sleep 1
  tput setaf 7

  
  echo -e "\e[90m Starting Deduplication... \e[39m "
  echo
   
  if [ "$(ls -A $FROM_DIRECTORY)" ] ; then
   
        if [ "$INPLACE" != "" ] ; then   
        
            command=`gawk -i inplace '!a[$0]++' $FILE_LINES_TO_INGORE $FROM_DIRECTORY/*.*  \
                     && find "$FROM_DIRECTORY/" -size 0 -delete`
        
        else  
            command=`awk '!seen[$0]++' $FILE_LINES_TO_INGORE $FROM_DIRECTORY/*.* | \
            split --additional-suffix="$SUFFIX" -d -l $SIZE_FILE - $TO_DIRECTORY/"$NAME_FILE"_`
        fi  
        
         exitValue=$? 

        if [ $exitValue != 0 ] ; then 
            EXIT
        fi 
      
  else
    echo " $FROM_DIRECTORY is Empty " ; echo 
  fi


  echo -e "\e[36m Deduplication Done ! \e[39m "
  echo
  
