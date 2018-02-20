#!/bin/bash

  # Default Arguments 
    # OWL="../mapping/ontology.owl"
    # TTL="../output/ontop/ontopMaterializedTriples.ttl"
    # QUERY=" SELECT ?S ?P ?O { ?S ?P ?O } "
    # OUTPUT="../output/corese"
    # f="100000"
    # F="ttl"

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
  
  while [[ "$#" > "0" ]] ; do
  
     case $1 in
     
         (*=*) KEY=${1%%=*}
         
               VALUE=${1#*=}
               
               case "$KEY" in
               
                    ("owl")        OWL=$VALUE    
                    ;;                    
                    ("output")     OUTPUT=$VALUE
                    ;;
                    ("query")      QUERY=$VALUE
                    ;;
                    ("ttl_path")   TTL_PATH=$VALUE
                    ;;      
                    ("peek")       PEEK=$VALUE
                    ;;      
                    ("fragment")   f=$VALUE
                    ;;                    
                    ("format")     F=$VALUE
                    ;;                    
                    ("flushCount") FLUSH_COUNT=$VALUE
                    ;;                    
                    ("xms")        XMS=$VALUE
                    ;;                    
                    ("xmx")        XMX=$VALUE
                    ;;                    
                    ("extension")  EXTENSION=$VALUE     
               esac
	     ;;
         help)  echo
                echo " Total Arguments : Twelve                                                                        "
                echo 
                echo "   owl=               :  Path of the Ontology                                                    "
                echo "   output=            :  Output Files                                                            "
                echo '   query=             :  Sparql Query for extraction. Ex : query="SELECT ?S ?P ?O { ?S ?P ?O }"  '
                echo "   ttl_path=          :  Turtle Output. Ex : ttl=ttl                                             "
                echo "   peek=              :  Enable batch. batch=batch                                               "
                echo "   fragment=          :  Number of triples by file. fragment='-f 0'   "
                echo "   format=            :  Includ Ontology in each turtle file ( case : Batch ). Ex : merge=merge  "
                echo "   flushCount=        :  total line in memory before flush to file. Ex flushCount=500000         "
                echo "   extension=         :  extension of the files that will be infered. Ex extension=ttl           "
                echo "   ignore_line_break= :  Replace \n by blank space. Ex : -ignore_line_break                      "
                echo "   xms=        :  XMS. Ex xms=500m                                                               "
                echo "   xmx=        :  XMX. Ex : xmx=2g                                                               "
                echo
                EXIT;
        ;;
        ("ignore_line_break")  IGNORE_LINE_BREAK="-ignore_line_break"
                    
     esac
     shift
  done 

  RELATIVE_PATH_OWL="ontology/ontology.owl"
  RELATIVE_PATH_TTL="output/02_ontop/"
  DEFAULT_OUTPUT="output/03_corese/"
  DEFAULT_QUERY="SELECT ?S ?P ?O { ?S ?P ?O . filter( !isBlank(?S) ) . filter( !isBlank(?O) )  } "
  # DEFAULT_QUERY="SELECT ?S ?P ?O { ?S ?P ?O } "
  # TOTAL TRIPLES PER FILE
  DEFAULT_FRAGMENT="-f 1000000 "
  # OUTPUT FORMAT
  DEFAULT_FORMAT="-F ttl "  
  DEFAULT_FLUSH_COUNT="-flushCount 250000"
  # TOTAL FILES LOAD IN THE SAME TIME
  DEFAULT_PEEK="-peek 6 "
  DEFAULT_XMS="15g"
  DEFAULT_XMX="15g"
 
  EXIT() {
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
  
  PARENT_SI="$(dirname "$SI")"
    
  OWL=${OWL:-"$PARENT_SI/$RELATIVE_PATH_OWL"}
  TTL_PATH=${TTL_PATH:-"$SI/$RELATIVE_PATH_TTL"}
  QUERY=${QUERY:-" $DEFAULT_QUERY "}
  OUTPUT=${OUTPUT:-"$SI/$DEFAULT_OUTPUT"}
  F=${F:-"$DEFAULT_FORMAT"}
  f=${f:-"$DEFAULT_FRAGMENT"}
  PEEK=${PEEK:-"$DEFAULT_PEEK"}
  FLUSH_COUNT=${FLUSH_COUNT:-"$DEFAULT_FLUSH_COUNT"}
  XMS="-Xms"${XMS:-"$DEFAULT_XMS"}
  XMX="-Xmx"${XMX:-"$DEFAULT_XMX"}
  
  IGNORE_LINE_BREAK=${IGNORE_LINE_BREAK:-""}  
  EXTENSION=${EXTENSION:-"ttl"}
  

  tput setaf 2
  echo 
  echo -e " ######################################################### "
  echo -e " ######## Info Generation ################################ "
  echo -e " --------------------------------------------------------- "
  echo -e "\e[90m$0        \e[32m                                     "
  echo
  echo -e " ##  OWL               : $OWL                              "  
  echo -e " ##  TTL_PATH          : $TTL_PATH                         "
  echo -e " ##  QUERY             : $QUERY                            "
  echo -e " ##  OUTPUT            : $OUTPUT                           "
  echo -e " ##  FORMAT            : $F                                "
  echo -e " ##  FRAGMENT          : $f                                "
  echo -e " ##  PEEK              : $PEEK                             "
  echo -e " ##  FLUSH_COUNT       : $FLUSH_COUNT                      "
  echo -e " ##  EXTENSION         : $EXTENSION                        "  
  echo -e " ##  IGNORE_LINE_BREAK : $IGNORE_LINE_BREAK                "
  echo
  echo -e " ##  XMS               : $XMS                              "
  echo -e " ##  XMX               : $XMX                              "
  echo -e " ######################################################### "
  echo 
  sleep 1
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

  java  $XMS  $XMX  -cp  ../libs/CoreseInfer.jar corese.Main  \
        -owl        "$OWL"                                    \
        -ttl        "$TTL_PATH"                               \
        -q          "$QUERY"                                  \
        -out        "$OUTPUT"                                 \
        -extension "$EXTENSION"                               \
        $f                                                    \
        $F                                                    \
        $PEEK                                                 \
        $FLUSH_COUNT                                          \
        -log "../libs/logs/corese/logs.log"                   \
        "$IGNORE_LINE_BREAK"                                  \
        -e
  
  exitValue=$? 

  if [ $exitValue != 0 ] ; then 
     EXIT
  fi 

  echo 
  echo -e "\e[36m Triples Generated in : $OUTPUT \e[39m "
  echo
        
