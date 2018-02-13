#!/bin/bash

 SCRIPT_PATH="../pipeline/scripts"

 SI_PATHS="../pipeline/SI"
 
 LIST_CPU="0" # 0,1 ( core 0 and core 1 ) OR 0-4 ( for core 0 to core 4 ) 
  
 CURRENT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
 cd $CURRENT_PATH

 JAXY_JAR_NAME="jax-y-swarm.jar"
 
 VALIDATED_SI_NAME="validated_semantic_si.csv"
 CSV_SEP=";"

 CSV_SEP=${CSV_SEP:-";"}
 INTRA_SEPARATORS=${INTRA_SEPARATORS:-" -intra_sep , "}
 
 COLUMNS_TO_VALIDATE=" -column 0 -column 1 -column 2 -column 4 -column 6 -column 7 -column 8 -column 10 "

 GET_ABS_PATH() {
   # $1 : relative filename
   echo "$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
 }
  
  
 PREFIX_FILE=$( GET_ABS_PATH "$SI_PATHS/ontology/prefix.txt" )
 ONTOLOGY=$( GET_ABS_PATH "$SI_PATHS/ontology/ontology.owl" )
  
 if [ -f "$PREFIX_FILE" ] ; then 
   rm -f "$PREFIX_FILE"
 fi
     
 $SCRIPT_PATH/03_extract_prefixs_from_owl.sh ontology="$ONTOLOGY" prefixFile="$PREFIX_FILE"
  
 for SI in `ls "$SI_PATHS" --ignore "ontology" --ignore "SI.txt" `;   do

   if [ -f "$SI_PATHS/$SI/csv/semantic_si.csv" ] ; then    
   
     CSV_FILE=$( GET_ABS_PATH "$SI_PATHS/$SI/csv/semantic_si.csv" )     
     VALIDATED_CSV_FILE_WITH_FULL_URI=$( GET_ABS_PATH "$SI_PATHS/$SI/csv/validated_semantic_si.csv" )
    
     if [ -f "$VALIDATED_CSV_FILE_WITH_FULL_URI" ] ; then 
       rm -f "$VALIDATED_CSV_FILE_WITH_FULL_URI"
     fi    
    
     $SCRIPT_PATH/04_corese_clone_valide_csv.sh csv="$CSV_FILE"                         \
                                                out="$VALIDATED_CSV_FILE_WITH_FULL_URI" \
                                                csv_sep="$CSV_SEP"                      \
                                                intra_separators="$INTRA_SEPARATORS"    \
                                                prefix_file="$PREFIX_FILE"              \
                                                owl="$ONTOLOGY"                         \
                                                columns="$COLUMNS_TO_VALIDATE"          \
                                                -enable_full_uri 
   fi 
  
 
 done 
 
 jobs &>/dev/null
 
 java -jar $JAXY_JAR_NAME & 
 
 new_job_started="$(jobs -n)"
 
 if [ -n "$new_job_started" ];then
    PID=$!
 else
    PID=
 fi
 
 taskset -cp $LIST_CPU $PID
 
 
 
