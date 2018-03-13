#!/bin/bash
  
  # 1 - INPUT                   : Default : SI/yedSpec/tmp
  # 2 - OUTPUT                  : Default : SI/output/01_obda/mapping.obda
  # 3 - EXTENSION               : Default : ".graphml"
  # 4 - CSV_FILE                : Default : SI/csv/si.csv
  # 5 - PRF=                    : Default : SI/csv/config/si.properties
  # 6 - JS=                     : Default : SI/csv/config/si.js
  # 7 - INCLUDE_GRAPH_VARIABLES : Default : "".  -ig : Treat only listed variables in graph
  
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
  
  GET_ABS_PATH() {
    # $1 : relative filename
    echo "$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
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
               
                    ("input")                    INPUT=$VALUE                    
                    ;;
                    ("output")                   OUTPUT=$VALUE
                    ;;                    
                    ("ext")                      EXTENSION=$VALUE
                    ;;
                    ("class")                    CLASS=$VALUE
                    ;;
                    ("column")                   COLUMN=$VALUE
                    ;;      
                    ("prefixFile")               PREFIX_FILE=$VALUE
                    ;;      
                    ("defaultPrefix")            DEFAULT_PREFIX="$VALUE" 
                                                 SET_DEFAULT_PREFIX="OK"
                    ;;                    
                    ("connecFileName")           CONNEC_FILE_NAME=$VALUE
                    ;;  
                    ("connecFile")               CONNEC_FILE=$VALUE
                    ;;  
                    ("csvFileName")              CSV_FILE_NAME=$VALUE
                    ;;
                    ("csvFile")                  CSV_FILE=$VALUE
                    ;;                      
                    ("prf")                      PRF=$VALUE
                    ;;                    
                    ("js")                       JS=$VALUE
                    ;;                    
                    ("includeGraphVariable")     INCLUDE_GRAPH_VARIABLES=$VALUE
                    ;;                    
                    ("magicFilterFile")          MAGIC_FILTER_FILE=$VALUE
                    ;;                
                    ("version")                  VERSION=$VALUE         
                    ;;
                    ("predicat_pattern_context") PREDICATE_PATTERN_CONTEXT="$VALUE"
                    ;;
                    ("match_word")               MATCH_WORD="$VALUE"
                    ;;
                    ("match_column")             MATCH_COLUMN="$VALUE"
               esac
         ;;
         help)  echo
                echo " Total Arguments : Nineteen                                                                                           "
                echo 
                echo "   input=                     :  Folder containing Modelization ( graphs )                                            "
                echo "   output=                    :  Output Mapping FOlder                                                                "
                echo "   ext=                       :  Extension of Graphs. Ex : ext=.graphml                                               "
                echo "   class=                     :  Discriminator class                                                                  "
                echo "   column=                    :  Discriminator Column                                                                 "
                echo "   prefixFile=                :  Prefix File Path                                                                     "
                echo "   defaultPrefix=             :  Default Prefix ( if not indicated in the graph )                                     "
                echo "   connecFile=                :  Connection file Path                                                                 "
                echo "   connecFileName=            :  Connection file Name                                                                 "
                echo "   csvFile=                   :  CSV File Path                                                                        "
                echo "   csvFileName=               :  CSV File Name  ( Default path is used ../SI/[THE_SI]/csv/[csvFileName])              "
                echo "   prf=                       :  Property file App configuration                                                      "
                echo "   js=                        :  JS File                                                                              "
                echo "   includeGraphVariable=      :  Treat Variables indicated in Graph. Ex : includeGraphVariable=-ig                    "
                echo "   predicat_pattern_context=  :  used for pattern context entities:  Ex : predicat_pattern_context=oboe-core:ofEntity "
                echo "   magicFilterFile=           :  Magic filter file. Ex : magicFilterFile=my_magic_filter.txt                          "
                echo "   version=                   :  ONTOP Version.     Ex : version=V1                                                   "
                echo '   match_word=                :  used to filter csv file lines. Ex : match_word=" variable1 , variable2 "             '
                echo '   match_column=              :  used to indicates the column for match_word. Ex : match_column=2                     '
                echo
                EXIT ;
     esac
     shift
  done   

  CLASS_TAG="-class "
  COLUMN_TAG="-column "
   
  SELECTED_SI="conf/SELECTED_SI_INFO"
  
  if [ ! -f $SELECTED_SI ]  ; then
     echo
     echo -e "\e[91m Missing $SELECTED_SI ! \e[39m "
     echo -e "\e[91m You can use the command [[ ./scripts/01_use_si.sh si=WhichSI ]] to set the var WhichSI ! \e[39m "    
     EXIT
  fi
 
  SI=$(head -1 $SELECTED_SI)        
     
  if [ "$SI" == "" ] ; then  
    SI="$PARENT_DIR/SI" 
  fi

  INPUT=${INPUT:-"$PARENT_DIR/work-tmp/input_tmp"} 
  OUTPUT=${OUTPUT:-"$SI/output/01_obda/mapping.obda"}
  EXTENSION=${EXTENSION:-".graphml"}

  VERSION=${VERSION:-"V1"}

  CLASS=${CLASS:-""}
  COLUMN=${COLUMN:-""}

  if [ ! -z $MAGIC_FILTER_FILE ]; then 
    MAGIC_FILTER_FILE=$( GET_ABS_PATH $MAGIC_FILTER_FILE )
    MAGIC_FILTER_FILE="-magicFilter $MAGIC_FILTER_FILE"
  fi
     
  PREFIX_FILE=${PREFIX_FILE:-"$PARENT_DIR/SI/ontology/prefix.txt"}   
 
  if [ ! -z "$SET_DEFAULT_PREFIX" -a -z "$DEFAULT_PREFIX" ]; then     
      DEFAULT_PREFIX=" "
  else
     DEFAULT_PREFIX=${DEFAULT_PREFIX:-"oboe-core"}
  fi
 
  if [ ! -z "$CONNEC_FILE_NAME" ] ; then
     if [ -z "$CONNEC_FILE" ] ; then
        CONNEC_FILE=" $SI/$CONNEC_FILE_NAME "
     fi
  fi 

  # CSV_FILE_NAME=${CSV_FILE_NAME:-"pipeline_si.csv"}

  CSV_FILE=${CSV_FILE:-""}
 
  if [ ! -z "$CSV_FILE_NAME" ]; then
     if [ -z "$CSV_FILE" ]; then
        CSV_FILE=" -csv $SI/csv/$CSV_FILE_NAME "
     fi
  elif [ ! -z "$CSV_FILE" ]; then
     CSV_FILE=" -csv $CSV_FILE"
  fi 

  PRF=${PRF:-"-prf $SI/csv/config/si.properties"}
  JS=${JS:-"-js $SI/csv/config/si.js"}
  
  INCLUDE_GRAPH_VARIABLES=${INCLUDE_GRAPH_VARIABLES:-""}  # -ig parameter
  
  if [ -z "$PREDICATE_PATTERN_CONTEXT" ]; then
   PREDICATE_PATTERN_CONTEXT=" -predicat_pattern_context oboe-core:ofEntity "     
  else 
   PREDICATE_PATTERN_CONTEXT=" -predicat_pattern_context $PREDICATE_PATTERN_CONTEXT "
  fi
  
  if [ -z "$CLASS" ]; then
     CLASS_TAG=""
  fi
  
  if [ -z "$COLUMN" ]; then
     COLUMN_TAG=""
  fi
   
  if [ ! -z "$MATCH_WORD" -a ! -z "$MATCH_COLUMN" ]; then
     MATCH_WORD=" -matchWord $MATCH_WORD "
     MATCH_COLUMN=" -matchColumn  $MATCH_COLUMN "
  fi
  
  INPUT=$( GET_ABS_PATH $INPUT )
  OUTPUT=$( GET_ABS_PATH $OUTPUT )

  tput setaf 2
  echo 
  echo -e " ############################################### "
  echo -e " ######## Info yedGen     ###################### "
  echo -e " ----------------------------------------------  "
  echo -e "\e[90m$0            \e[32m                       "
  echo
  echo -e " ##  INPUT         : $INPUT                      "
  echo -e " ##  EXTENTION     : [$EXTENSION]                "
  echo
  
  if [ "$CSV_FILE" != "" ] ; then   
  echo -e " ##  CSV_FILE      : $CSV_FILE                   "
  else
  echo -e " ##  CSV_FILE      : --                          "
  fi
  
  if [ "$CLASS" != "" ] ; then   
  echo -e " ##  CLASS         : $CLASS                      "
  elif [ "$CSV_FILE" != "" ] ; then 
  echo -e " ##  CLASS         : *  ( Treate all csv Lines ) "
  else
  echo -e " ##  CLASS         : --                          "
  fi
  
  if [ "$COLUMN" != "" ] ; then   
  echo -e " ##  COLUMN_NUM    : $COLUMN                     "
  fi
      
  if [ -z "$INCLUDE_GRAPH_VARIABLES" ] ; then   
  echo -e " ##  GRAPH_VAR     : FALSE "
  else 
  echo -e " ##  GRAPH_VAR_INC : $INCLUDE_GRAPH_VARIABLES    "
  fi

  if [ -z "$MAGIC_FILTER_FILE" ] ; then   
  echo -e " ##  MAGIC_FILTER  : ---                         "
  else 
  echo -e " ##  MAGIC_FILTER  : $MAGIC_FILTER_FILE          "
  fi
  echo
  
  if [ -z "$CONNEC_FILE" ] ; then   
  echo -e " ##  CONNEC_FILE   : ---                         "
  else 
  echo -e " ##  CONNEC_FILE   : $CONNEC_FILE                "
  fi
  echo
  
  echo -e " ##  DEF_PREFIX    : $DEFAULT_PREFIX             "
  echo -e " ##  PRED_PAT_CNTX : $PREDICATE_PATTERN_CONTEXT  "
  echo
  echo -e " ##  OBDA_VERSION  : $VERSION                    "
  echo 
  echo -e " ##  Prop File     : $PRF                        "
  echo -e " ##  JS File       : $JS                         "
 
  echo
  echo -e " ##  OUTPUT        : $OUTPUT                     "
  echo
  echo -e " ############################################### "
  echo 
  sleep 2
  tput setaf 7

  if [ ! -d $INPUT ] ; then
     echo -e "\e[91m $INPUT is not a valid Directory ! \e[39m "
     EXIT
  fi

  echo -e "\e[90m Starting Generation... \e[39m "
  echo

  # TREAT CSV

  DIR=$(dirname "${OUTPUT}")
  
  TOTAL_FILES_BEFORE_PROCESSING=`find "$DIR" -name "*" -type f | wc -l `

  # FOR DEBUG 
  # -Xdebug -Xrunjdwp:transport=dt_socket,address=11555,server=y,suspend=y \
 
  java -cp ../libs/yedGen.jar entypoint.Main -d          $INPUT                     \
                                             -out        $OUTPUT                    \
                                             -ext        "$EXTENSION"               \
                                             -prefixFile $PREFIX_FILE               \
                                             -def_prefix $DEFAULT_PREFIX            \
                                             -connecFile $CONNEC_FILE               \
                                             -version    $VERSION                   \
                                                         $CSV_FILE                  \
                                                         $PRF                       \
                                                         $JS                        \
                                                         $CLASS_TAG "$CLASS"        \
                                                         $COLUMN_TAG "$COLUMN"      \
                                                         $MAGIC_FILTER_FILE         \
                                                         $INCLUDE_GRAPH_VARIABLES   \
                                                         $PREDICATE_PATTERN_CONTEXT \
                                                         $MATCH_WORD                \
                                                         $MATCH_COLUMN
                                                         
  exitValue=$? 

  if [ $exitValue != 0 ] ; then 
     EXIT
  fi


<<COMMENT

# TREAT Only variables enumerated in Graph
  java -cp ../libs/yedGen.jar entypoint.Main -d   $INPUT     \
                                             -out $OUTPUT    \
                                             -ext $EXTENSION \
                                             -ig 
COMMENT
  
  TOTAL_FILES_AFTER_PROCESSING=`find "$DIR" -name "*" -type f | wc -l `
  
  if [ "$TOTAL_FILES_AFTER_PROCESSING" -gt "$TOTAL_FILES_BEFORE_PROCESSING" ] ; then
    echo -e "\e[36m Mapping generated in : $DIR \e[39m "
  else
   echo -e "\e[36m No Mapping Generated in the Directory : $DIR \e[39m "
   if [ "$CLASS" != "" ] ; then   
     echo -e "\e[36m  -> May be you provided a MetaGraph with the Class [$CLASS] without providing any entry in the CSV File for this Class.\e[39m "
     echo -e "\e[36m  -> May be some ERRORS in the MAPPING were DETECTED \e[39m "
   elif [ "$CSV_FILE" != "" ] ; then 
     echo -e "\e[36m  -> May be you provided a MetaGraph with the Class [ * ] ( All ) without providing any entry in the CSV File for this Class.\e[39m "
     echo -e "\e[36m  -> May be you provided a MetaGraph with the match_word and match_column that doesn't match any line of the CSV File.\e[39m "
     echo -e "\e[36m  -> May be some ERRORS in the MAPPING were DETECTED \e[39m "
   else 
     echo -e "\e[36m  -> May be you provided a MetaGraph Without providing any CSV File.\e[39m "
     echo -e "\e[36m  -> May be some ERRORS in the MAPPING were DETECTED \e[39m "
   fi
   EXIT
  fi

  echo

