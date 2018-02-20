#!/bin/bash
    
  DEFAULT_XMS="2g"
  DEFAULT_XMX="2g"
 
  EXIT() {
     if [ $PPID = 0 ] ; then exit ; fi
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
  MATCH=""
  
  while [[ "$#" > "0" ]] ; do    
     case $1 in     
         (*=*) eval $1 2> /dev/null ;
               KEY=${1%%=*}
               VALUE=${1#*=}	              
               case "$KEY" in               
               
                    ("csv")                  CSV=$VALUE
                    ;;                     
                    ("outCsv")               OUT=$VALUE
                    ;;                     
                    ("csv_sep")              CSV_SEP=$VALUE
                    ;; 
                    ("match")                MACTCH=$VALUE
	                ;;
                    ("match_sep")            MATCH_SEP=$VALUE
                    ;;
                    ("intra_csv_sep")        INTRA_CSV_SEP=$VALUE
                    ;;
                    ("mirror_csv")           MIRROR_CSV=$VALUE
                    ;;
                    ("outFilteredMirrorCsv") OUT_FILTERD_MIRROR_CSV=$VALUE
                     ;;
                    ("xms")                  XMS=$VALUE
                     ;;
                    ("xmx")                  XMX=$VALUE
               esac
         ;;
         help)  echo
                echo " Total Arguments : Eight                                                                                         "
                echo
                echo "  csv=                  : Csv Path                                                                               "
                echo "  outCsv=               : Filterd output CSV                                                                     "
                echo "  csv_sep=              : Csv separator                                                                          "
                echo '  match=                : Matcher. Ex   -match 12 "nitro" [ means : Column 12 must have then value nitro ]       '
                echo "  match_sep=            : Matcher separator                                                                      "
                echo '  intra_csv_sep=        : Intra column separator - Ex : intra_separators="-separator > -separator < -separator ,"'
                echo "  mirror_csv=           : Mirror CSV                                                                             "
                echo "  outFilteredMirrorCsv= : Filterd output CSV                                                                     "
                echo "  ignore_case_sensitive : Enable case sensitive. Ex : ignore_case_sensitive                                      "
                echo "  xms=                  : Ex  xms=512m                                                                           "
                echo "  xmx=                  : Ex  xms=2g                                                                             "
                echo
                EXIT;
         ;;  
         
         ignore_case_sensitive )  IGNORE_CASE_SENSITIVE="-i"
         ;;
         *)  MATCH+="$1 "
         
     esac
     shift
  done   
                                        
                                         
  CSV=${CSV:-"$SI/csv/semantic_si.csv"}
  OUT=${OUT:-"$SI/csv/piepeline_si.csv"}
  PREFIX=${PREFIX:-"$PARENT_SI/ontology/prefix.txt"}
  CSV_SEP=${CSV_SEP:-";"}  
  INTRA_CSV_SEP=${INTRA_CSV_SEP:-" -intra_sep , "}
  
  XMS="-Xms"${XMS:-"$DEFAULT_XMS"}
  XMX="-Xmx"${XMX:-"$DEFAULT_XMX"}
  
  if [ ! -z "$MIRROR_CSV" ] ; then 
     MIRROR_CSV=" -mirror_csv $MIRROR_CSV"
  fi
  
  if [ ! -z "$OUT_FILTERD_MIRROR_CSV" ] ; then 
     OUT_FILTERD_MIRROR_CSV=" -outFilterdMirrorCsv $OUT_FILTERD_MIRROR_CSV"
  fi
  
  
  tput setaf 2
  echo 
  echo -e " ######################################################### "
  echo -e " ######## Info CSV Filter ################################ "
  echo -e " --------------------------------------------------------- "
  echo -e "\e[90m$0        \e[32m                                     "
  echo
  echo -e " ##  CSV to Filter          : $CSV                         "
  echo -e " ##  OUTPUT Filterd CSV     : $OUT                         "
  echo -e " ##  CSV_SEP                : $CSV_SEP                     "
  echo -e " ##  INTRA_SEPARATORS       : $INTRA_CSV_SEP               " 
  echo -e " ##  MATCH                  : $MATCH                       "
  echo -e " ##  MATCH_SEP              : $MATCH_SEP                   "
  echo
  echo -e " ##  MIRROR_CSV             : $MIRROR_CSV                  "
  echo -e " ##  OUT_FILTERD_MIRROR_CSV : $OUT_FILTERD_MIRROR_CSV      "
  echo -e " ##  IGNORE_CASE_SENSITIVE  : $IGNORE_CASE_SENSITIVE       "
  
  echo -e " ##  XMS                    : $XMS                         "
  echo -e " ##  XMX                    : $XMX                         "
  echo
  echo -e " ######################################################### "
  echo 
  sleep 1
  tput setaf 7
 
  if [ ! -f $OWL ] ; then
     echo -e "\e[91m Missing OWL File [[ $OWL ]] ! \e[39m "
     EXIT
  fi

    
  if [ ! -f $PREFIX ] ; then
     echo -e "\e[91m Missing PREFIX File [[ $PREFIX ]] ! \e[39m "
     EXIT
  fi
  
  echo -e "\e[90m Strating Generation... \e[39m "
  echo

  
  # For Debugging :
  # -Xdebug -Xrunjdwp:transport=dt_socket,address=11555,server=y,suspend=y
    
  COMMAND=" java  $XMS  $XMX -cp ../libs/yedGen.jar entypoint.CsvFilter 
            -csv \"$CSV\" 
            -outCsv  \"$OUT\" 
            -csv_sep \"$CSV_SEP\" 
            -match_sep \"$MATCH_SEP\" 
            $INTRA_CSV_SEP 
            $MATCH 
            $MIRROR_CSV 
            $OUT_FILTERD_MIRROR_CSV 
            $IGNORE_CASE_SENSITIVE "
 
  eval $COMMAND
 
  exitValue=$? 

  if [ $exitValue != 0 ] ; then 
     EXIT
  fi 

  echo 
  
  if [ ! -f " $OUT" ] ; then 
  
      echo -e "\e[36m No CSV Generated at : $OUT \e[39m "
    
  else 
  
      echo -e "\e[36m Valide CSV Generated at : $OUT \e[39m "
  
  fi
  
  echo

