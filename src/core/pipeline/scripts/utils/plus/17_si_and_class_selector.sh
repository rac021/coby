#!/bin/bash
    
  VAR_PART[0]='VAR_PART_SI'
  VAR_PART[1]='VAR_PART_CSV'
  VAR_PART[2]='VAR_PART_SQL'
  
  DELIMILTER_AT='@'
  DELIMITER_DDOT=':'
  DELIMITER_DDOT_EQ=':='
  DELIMITER_DIEZ_COMMENT='#'
    
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
  
  TO_ARRAY() { 
    LINE=$1
    DELIMITER=$2
    ARRAY=()    
    IFS="$DELIMITER" read -r -a array <<< "$LINE"
    for element in "${array[@]}" ; do
     ARRAY+=("$element")
    done
    IFS=  
  }
  
  GET_VALUE_FROM_FILE_BINDER() { 
    KEY=$1
    FILE=$2
    RESULT="NULL"
    while IFS=$DELIMITER_DDOT read -r key val
    do
      _key=`echo ${key} | sed -e 's/=//' | sed -e 's/^[[:space:]]*//'`
      _val=`echo ${val} | sed -e 's/=//' | sed -e 's/^[[:space:]]*//'`
       if [ "$KEY" == "$_key" ] ; then
         RESULT="$_val"         
      fi 
    done < $FILE
 
  }
  
  EXTRACT_PART_FROM_FILE_BINDER() { 
    IFS=  
    PART=$1
    FILE=$2
    RESULT=`cat $FILE | sed -n '/ *'$DELIMITER_DIEZ_COMMENT' *'$PART'/,/.*'$DELIMITER_DIEZ_COMMENT'.*/p' \
                      | sed '/'$DELIMITER_DIEZ_COMMENT'/d' | sed '/.*--/d' | sed '/^$/d' | sed '/^ *$/d' `
    IFS=  
  }
  
  EXTRACT_VALUES_FROM_LINE() { 
    key=$1
    REQUEST=$2
    RESULT=`echo $REQUEST | sed -e 's/^.*'$key' *'$DELIMITER_DDOT_EQ' *//'  | sed -e 's/.'$DELIMILTER_AT'.*//' `
  }
 
  
  GET_SELECTED_SI() { 
    VALUES=$1
    FILE=$2
    SELECTED_SI=()   
    IFS=';' read -r -a selectedSIs <<< "$VALUES"
    for selectedSI in "${selectedSIs[@]}"
    do   
      si=`echo ${selectedSI} | sed -e 's/^[[:space:]]*//'`  
      GET_VALUE_FROM_FILE_BINDER "${si}" $FILE
      if [ "$RESULT" != "NULL" ] ; then 
        SELECTED_SI+=(${RESULT})
      fi 
    done
    IFS=  
  }
  
  
  EXTRACT_KEYS_FROM_LINE() { 
    REQUEST=$1    
    KEYS=()
    OIFS=$IFS
    IFS=$DELIMILTER_AT   
    for req in $REQUEST
    do
      RES=` echo $req | sed -e 's/'$DELIMITER_DDOT_EQ'.*//' | xargs ` 
      KEYS+=($RES)
    done

    IFS=$OIFS
  }
  
  FIND_KEY_AND_VALUE_IN_FILE_BINDER() { 
    KEY=$1
    FILE_BINDER=$2
    IFS=  
    RESULT="NULL"
    for PART in "${VAR_PART[@]}" ; do
     EXTRACT_PART_FROM_FILE_BINDER "$PART" "$FILE_BINDER"
     EXTRACT_VALUES_FROM_LINE "$KEY" "${RESULT//$'\n'/$DELIMILTER_AT}"
     
     if [[ $RESULT != *"$DELIMITER_DDOT_EQ"* ]]; then
      # echo " KEY : $KEY  // found in // $PART  // WITH VALUE // $RESULT"
      break ;
     fi
    done
    
  }
  
  
  CURRENT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
  cd $CURRENT_PATH
  ROOT_PATH="${CURRENT_PATH/}"
  PARENT_DIR="$(dirname "$ROOT_PATH")"

  SI_PATH="SI" 
 
  SI="sites = toto, titi, tutu & ORE= ore_1 & SI = SOERE OLA; SOERE ACBB;  SOERE FORET & UNIT=cm & year=1910_2011 & CLASS= flux meteo ;  meteo  "
  
  FILE_BINDER="../SI/SI.txt"
  
  SI=${SI//&/ $DELIMILTER_AT }
  SI=${SI//=/ $DELIMITER_DDOT_EQ }

  
  echo "---------------------------------"  
  echo " transformed DATA "
  echo $SI
  
  echo "---------------------------------"  
  
  EXTRACT_VALUES_FROM_LINE "CLASS" "$SI"  
  echo " SELECTED CLASS BY USER == [$RESULT]"
   
  TO_ARRAY "$RESULT" ";"
  
  for class in "${ARRAY[@]}" ; do
    echo " > Valid CLASS --> [$class] "
  done
  
  echo "---------------------------------"  
  
  EXTRACT_VALUES_FROM_LINE "SI" "$SI"  
  echo " SELECTED SI BY USER == [$RESULT]"
   
  GET_SELECTED_SI "$RESULT" "$FILE_BINDER"

   
  for si in "${SELECTED_SI[@]}" ; do
    echo " > Valid SI --> [$si] "
  done
   
  echo "---------------------------------"

  EXTRACT_VALUES_FROM_LINE "year" "$SI"  
  echo " YEAR VALUES PASSED BY USER  == $RESULT"

  echo "---------------------------------"

  EXTRACT_PART_FROM_FILE_BINDER "VAR_PART_SQL" "$FILE_BINDER"
  echo $RESULT
 
  echo "--------------------------+------"
  
  FIND_KEY_AND_VALUE_IN_FILE_BINDER "year" $FILE_BINDER
  
  echo "---------------------------------"

  EXTRACT_KEYS_FROM_LINE "$SI"
  
  for key in "${KEYS[@]}" ; do
  
     echo " KEY ==> [$key]"
     FIND_KEY_AND_VALUE_IN_FILE_BINDER "$key" "$FILE_BINDER"
     if [[ "$RESULT" != *"$DELIMITER_DDOT_EQ"* ]]; then
       echo " KEY : $key  // found in // $PART  // WITH VALUE // $RESULT"
     else
       echo " NO KEY FOUND FOR : $key "
     fi
     
  done

  echo "---------------------------------"

  
  
  
