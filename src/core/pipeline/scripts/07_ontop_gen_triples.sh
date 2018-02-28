#!/bin/bash
 
  set -e 
    
  CURRENT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
  cd $CURRENT_PATH
  ROOT_PATH="${CURRENT_PATH/}"
  PARENT_DIR="$(dirname "$ROOT_PATH")"

     
  EXIT() {
   if [ $PPID = 0 ] ; then exit ; fi
   parent_script=`ps -ocommand= -p $PPID | awk -F/ '{print $NF}' | awk '{print $1}'`    
   if [ $parent_script = "bash" ] ; then
       echo; echo -e " \e[90m exited by : $0 \e[39m " ; echo
       exit 2
   else
       if [ $parent_script != "java" ] ; then        
          echo ; echo -e " \e[90m exited by : $0 \e[39m " ; echo
          kill -9 `ps -p --pid $$ -oppid=`;         
          exit 2
       fi
       echo " Coby Exited "
       exit 2
   fi
  } 
    

  while [[ "$#" > "0" ]] ; do
     case $1 in
     
         (*=*) KEY=${1%%=*}
               VALUE=${1#*=}
               
               case "$KEY" in
                    ("owl")        OWL=$VALUE                    
                    ;;
                    ("obda")       OBDA=$VALUE
                    ;;                    
                    ("output")     OUTPUT=$VALUE
                    ;;
                    ("query")      QUERY=$VALUE
                    ;;
                    ("ttl")        TTL=$VALUE
                    ;;      
                    ("batch")      BATCH=$VALUE
                    ;;      
                    ("pageSize")   PAGESIZE=$VALUE
                    ;;                    
                    ("fragment")   FRAGMENT=$VALUE
                    ;;                    
                    ("flushCount") FLUSHCOUNT=$VALUE
                    ;;                    
                    ("merge")      MERGE=$VALUE
                    ;;                    
                    ("xms")        XMS=$VALUE
                    ;;                    
                    ("xmx")        XMX=$VALUE
                    ;;                    
                    ("connection") CONNECTION=$VALUE
                    ;;                    
                    ("log_level")  LOG_LEVEL=$VALUE
                    ;;
                    ("must_not_be_empty") MUST_NOT_BE_EMPTY_NODES=$VALUE
                    ;;                    
               esac
	     ;;
         help)  echo
                echo " Total Arguments : Seventeen                                                                             "
                echo 
                echo "   owl=              :  Path of the Ontology                                                             "
                echo "   obda=             :  OBDA File Path                                                                   "
                echo "   output=           :  Output Files                                                                     "
                echo '   query=            :  Sparql Query for extraction. Ex : query="SELECT ?S ?P ?O { ?S ?P ?O }"           '
                echo "   ttl=              :  Turtle Output. Ex : ttl=ttl                                                      "
                echo "   batch=            :  Enable batch. batch=batch                                                        "
                echo "   pageSize=         :  Number of rows which are extracted from DB ( with Batch ). Ex : pageSize=200000  "
                echo "   fragment=         :  Number of triples by file  "
                echo "   flushCount=       :  total line in memory before flush to file. Ex flushCount=500000                  "
                echo "   merge=            :  Includ Ontology in each turtle file ( case : Batch ). Ex : merge=merge           "
                echo "   connection=       :  Path of the file containing Connection information                               "
                echo "   log_level=        :  Display ( or not ) logs. Ex : log_level=ALL, log_level=OFF. Def : OFF            "
                echo "   debug=            :  Display ( or not ) logs. Ex : log_level=ALL, log_level=OFF. Def : OFF            "
                echo "   not_out_ontology= :  Ignoring the gen of the Ontology in turtle format when generating semantic data  "
                echo "   out_ontology=     :  Generate the Ontology in turtle format when generating semantic data from DB     "
                echo "   xms=              :  XMS. Ex xms=500m                                                                 "
                echo "   xmx=              :  XMX. Ex : xmx=2g                                                                 "
                echo
                EXIT
         ;;
         debug)  DEBUG="-debug"
         ;;
         not_out_ontology) NOT_OUT_ONTOLOGY="-not_out_ontology"
         ;;
         out_ontology)     OUT_ONTOLOGY="-out_ontology"
         ;;        
        
     esac
     
     shift
  done   


  RELATIVE_PATHPATH_OWL="ontology/ontology.owl"
  RELATIVE_PATHPATH_OBDA="work-tmp/obda_tmp/mapping.obda"
  RELATIVE_PATHPATH_OUTPUT="output/02_ontop/ontopGen.ttl"
  DEFAULT_QUERY="SELECT ?S ?P ?O { ?S ?P ?O } "
  DEFAULT_TTL="ttl"
 
 
  DEFAULT_BACTH=""
  #DEFAULT_BACTH="batch"
 
  DEFAULT_PAGE_SIZE="200000"
  DEFAULT_FRAGMENT="1000000"
  DEFAULT_FLUSH_COUNT="500000"
  DEFAULT_MERGE="" 
  # DEFAULT_MERGE="merge" 
  DEFAULT_XMS="15g"
  DEFAULT_XMX="15g"

  SELECTED_SI="conf/SELECTED_SI_INFO"
  
  if [ ! -f $SELECTED_SI ]  ; then
    echo
    echo -e "\e[91m Missing $SELECTED_SI ! \e[39m "
    echo -e "\e[91m You can use the command [[ ./scripts/01_use_si.sh si=WhichSI ]] to set the var WhichSI ! \e[39m "    
    EXIT   
  fi
 
  SI=$(head -1 $SELECTED_SI)        
 
  PARENT_SI="$(dirname "$SI")"
   
  OWL=${OWL:-"$PARENT_SI/$RELATIVE_PATHPATH_OWL"}
  OBDA=${OBDA:-"$PARENT_DIR/$RELATIVE_PATHPATH_OBDA"}
  OUTPUT=${OUTPUT:-"$SI/$RELATIVE_PATHPATH_OUTPUT"}
  QUERY=${QUERY:-"$DEFAULT_QUERY"}
  TTL="-"${TTL:-"$DEFAULT_TTL"}
  
  BATCH="-"${BATCH:-"$DEFAULT_BACTH"}
  PAGESIZE="-pageSize "${PAGESIZE:-"$DEFAULT_PAGE_SIZE"}
  FRAGMENT="-f "${FRAGMENT:-"$DEFAULT_FRAGMENT"}
  FLUSHCOUNT="-flushCount "${FLUSHCOUNT:-"$DEFAULT_FLUSH_COUNT"}
  MERGE="-"${MERGE:-"$DEFAULT_MERGE"}
  XMS="-Xms"${XMS:-"$DEFAULT_XMS"}
  XMX="-Xmx"${XMX:-"$DEFAULT_XMX"}
     
  LOG_LEVEL=${LOG_LEVEL:-"OFF"}

  NOT_OUT_ONTOLOGY=${NOT_OUT_ONTOLOGY:-""}
  OUT_ONTOLOGY=${OUT_ONTOLOGY:-""}

  if [ "$MUST_NOT_BE_EMPTY_NODES" != "" ] ; then    
     MUST_NOT_BE_EMPTY_NODES=" -must_not_be_empty \"$MUST_NOT_BE_EMPTY_NODES \" "
  fi
  
  tput setaf 2
  echo 
  echo -e " ###################################################     "
  echo -e " ############# Info Generation #####################     "
  echo -e " ---------------------------------------------------     "
  echo -e "\e[90m$0      \e[32m                                     "
  echo
  echo -e " ##  OWL                     : $OWL                      "
  echo -e " ##  OBDA                    : $OBDA                     "
  echo -e " ##  CONNECTION_File         : $CONNECTION               "
  echo -e " ##  OUTPUT                  : $OUTPUT                   "
  echo -e " ##  QUERY                   : $QUERY                    "
  echo -e " ##  BATCH                   : $BATCH                    "
  echo -e " ##  TTL                     : $TTL                      "
  echo -e " ##  MERGE                   : $MERGE                    "
  echo -e " ##  FLUSHCOUNT              : $FLUSHCOUNT               "
  echo -e " ##  PAGESIZE                : $PAGESIZE                 "
  echo -e " ##  FRAGMENT                : $FRAGMENT                 "
  echo
  echo -e " ##  OUT_ONTOLOGY            : $OUT_ONTOLOGY             "
  echo -e " ##  NOT_OUT_ONTOLOGY        : $NOT_OUT_ONTOLOGY         "
  echo
  echo -e " ##  MUST_NOT_BE_EMPTY_NODES : $MUST_NOT_BE_EMPTY_NODES  "
  echo -e " ##  DEBUG                   : $DEBUG                    "
  echo -e " ##  LOG_LEVEL               : $LOG_LEVEL                "
  echo 
  echo -e " ##  XMS                     : $XMS                      "
  echo -e " ##  XMX                     : $XMX                      "
  echo
  echo -e " ####################################################    "
  echo 
  sleep 2
  tput setaf 7

  if [ ! -f $OWL ] ; then
     echo -e "\e[91m Missing OWL File [[ $OWL ]] ! \e[39m "
     EXIT
  fi

  if [ ! -f $OBDA ]  ; then
     echo -e "\e[91m Missing OBDA File [[ $OBDA ]] ! \e[39m "
     EXIT
  fi
  echo -e "\e[90m Strating Generation... \e[39m "
  echo
 
  # FOR DEBUG 
  # -Xdebug -Xrunjdwp:transport=dt_socket,address=11555,server=y,suspend=y 
  
  COMMAND="   java $XMS $XMX -cp ../libs/Ontop-Materializer.jar  entry.Main_1_18
                   -owl   \"$OWL\"                                          
                   -obda  \"$OBDA\"                                         
                   -out   \"$OUTPUT\"                                       
                   -q     \"$QUERY\"                                        
                   -connection \"$CONNECTION\"                              
                   -log_level \"$LOG_LEVEL\"                                
                   $TTL  
                   $BATCH  
                   $PAGESIZE 
                   $MERGE  
                   $FRAGMENT 
                   $FLUSHCOUNT 
                   \"$DEBUG\" 
                   \"$OUT_ONTOLOGY\" 
                   \"$NOT_OUT_ONTOLOGY\"      
                   $MUST_NOT_BE_EMPTY_NODES                                
                   \"$NOT_OUT_ONTOLOGY\" 
                   \"$OUT_ONTOLOGY\"
  "
 
  eval $COMMAND
  
  #  java  $XMS $XMX -cp ../libs/Ontop-Materializer.jar  entry.Main_1_18  \
  #        -owl   "$OWL"                                                  \
  #        -obda  "$OBDA"                                                 \
  #        -out   "$OUTPUT"                                               \
  #        -q     "$QUERY"                                                \
  #        -connection "$CONNECTION"                                      \
  #        -log_level "$LOG_LEVEL"                                        \
  #         $TTL  $BATCH  $PAGESIZE  $MERGE  $FRAGMENT  $FLUSHCOUNT       \
  #         "$DEBUG" "$OUT_ONTOLOGY" "$NOT_OUT_ONTOLOGY"                  \
  #         $MUST_NOT_BE_EMPTY_NODES                                      \
  #           "$NOT_OUT_ONTOLOGY" "$OUT_ONTOLOGY"   
   
  exitValue=$? 

  if [ $exitValue != 0 ] ; then 
     echo 
     echo " CODE ERROR --> $exitValue "
     EXIT
  fi 

  sleep 0.5
  
  echo 
  
  OUT_FOLDER="$(dirname $(readlink -f $OUTPUT ))"
  
  if [ "$(ls -A $OUT_FOLDER )" ]; then
     echo -e "\e[36m Triples Generated in : $OUT_FOLDER \e[39m "
  else
    echo -e "\e[36m No Triples Generated in : $OUT_FOLDER \e[39m "
  fi
    
  echo
        

