#!/bin/bash
  
  RELATIVE_PATH_OWL="ontology/ontology.owl"
  DEFAULT_XMS="-Xms2g"
  DEFAULT_XMX="-Xmx2g"
 
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

  
  while [[ "$#" > "0" ]] ; do
     case $1 in
         (*=*) eval $1 2> /dev/null ;
               KEY=${1%%=*}
               VALUE=${1#*=}		
               case "$KEY" in
                    ("owl")              OWL=$VALUE                    
                    ;;
                    ("csv")              CSV=$VALUE
                    ;;                     
                    ("out")              OUT=$VALUE
                    ;;
                    ("prefix_file")      PREFIX=$VALUE
                    ;;
                    ("csv_sep")          CSV_SEP=$VALUE
                    ;;
                    ("intra_separators") INTRA_SEP=$VALUE
                    ;; 
                    ("columns")          COLUMNS=$VALUE
                    ;;
                    ("xms")              XMS=$VALUE
                    ;;
                    ("xmx")              XMX=$VALUE
                    esac
                    ;;
         help)  echo
                echo " Total Arguments : Ten                                                                                          "
                echo
                echo "   owl=                : Ontology path file                                                                     "
                echo "   csv=                : CSV to validate                                                                        "
                echo "   out=                : output valide file                                                                     "
                echo "   prefix_file=        : File path containing Prefixes                                                          "
                echo '   intra_separators=   : Intra column separator - Ex : intra_separators="-intra_sep > -intra_sep < -intra_sep ,"'
                echo '   columns=            : Columns to validate - Ex : columns="-column 0 -column 10"                              '
                echo "   enable_full_uri=    : Enable full path URI output in the CSV. Ex : -enable_full_uri                          "
                echo "   enable_uri_brackets : Put URI in brackets.Ex : -enable_uri_brackets                                          "
                echo "   xms=                : Ex  xms=-Xms512m                                                                       "
                echo "   xmx=                : Ex  xms=-Xmx2g                                                                         "
                echo
                EXIT;
         ;;
         -enable_full_uri     ) ENABLE_FULL_URI="-enable_full_uri" 
         ;;
         -enable_uri_brackets ) ENABLE_URI_BRACKETS="-enable_uri_brackets" 
         ;;
     esac
     shift
  done   

  OWL=${OWL:-"$PARENT_SI/$RELATIVE_PATH_OWL"}
  CSV=${CSV:-"$SI/csv/semantic_si.csv"}
  OUT=${OUT:-"$SI/csv/piepeline_si.csv"}
  PREFIX=${PREFIX:-"$PARENT_SI/ontology/prefix.txt"}
  CSV_SEP=${CSV_SEP:-";"}  
  INTRA_SEP=${INTRA_SEP:-" -intra_sep , "}
  COLUMNS=${COLUMNS:-" -column 0 "}
  XMS=${XMS:-"$DEFAULT_XMS"}
  XMX=${XMX:-"$DEFAULT_XMX"}
  
  ENABLE_FULL_URI=${ENABLE_FULL_URI:-""}
  
  ENABLE_URI_BRACKETS=${ENABLE_URI_BRACKETS:-""}
  
  tput setaf 2
  echo 
  echo -e " ######################################################### "
  echo -e " ######## Info CSV Validator ############################# "
  echo -e " --------------------------------------------------------- "
  echo -e "\e[90m$0        \e[32m                                     "
  echo
  echo -e " ##  OWL                 : $OWL                            "  
  echo -e " ##  PREFIX File         : $PREFIX                         "
  echo -e " ##  CSV to validate     : $CSV                            "
  echo -e " ##  COLUMNS to validate : $COLUMNS                        "
  echo -e " ##  CSV_SEP             : $CSV_SEP                        "
  echo -e " ##  INTRA_SEPS          : $INTRA_SEP                      "  
  echo -e " ##  OUTPUT Valide CSV   : $OUT                            "
  echo -e " ##  ENABLE_FULL_URI     : $ENABLE_FULL_URI                "
  echo -e " ##  ENABLE_URI_BRACKETS : $ENABLE_URI_BRACKETS            "
  echo
  echo -e " ##  XMS                 : $XMS                            "
  echo -e " ##  XMX                 : $XMX                            "
  echo

  echo -e " ######################################################### "
  echo 
  sleep 1
  tput setaf 7
  
  if [ ! -f "$OWL" ] ; then
     echo -e "\e[91m Missing OWL File [[ $OWL ]] ! \e[39m "
     EXIT
  fi

    
  if [ ! -f "$PREFIX" ] ; then
     echo -e "\e[91m Missing PREFIX File [[ $PREFIX ]] ! \e[39m "
     EXIT
  fi
  
  
  echo -e "\e[90m Strating Generation... \e[39m "
  echo

  
  java  $XMS  $XMX  -cp ../libs/CoreseInfer.jar corese.csv.Prefixer \
        -ontology   "$OWL"                                          \
        -csv        "$CSV"                                          \
        -outCsv     "$OUT"                                          \
        -prefix     "$PREFIX"                                       \
        -csv_sep    "$CSV_SEP"                                      \
        $INTRA_SEP                                                  \
        $COLUMNS                                                    \
        $ENABLE_FULL_URI                                            \
        $ENABLE_URI_BRACKETS 
  
  
  exitValue=$? 

  if [ $exitValue != 0 ] ; then 
     EXIT
  fi 
 
  if [ ! -f "$OUt" ] ; then 
   echo -e "\e[36m No Valide CSV File Generated at $OUT \e[39m "
   EXIT
  fi 

  echo 
  echo -e "\e[36m Valide CSV Generated at : $OUT \e[39m "
  echo



