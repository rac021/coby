#!/bin/bash
  
  # 1 - INPUT                   : Default : SI/yedSpec/tmp
  # 2 - OUTPUT                  : Default : SI/output/01_obda/mapping.obda
  # 3 - EXTENSION               : Default : ".graphml"
  # 4 - CSV_FILE                : Default : SI/csv/si.csv
  # 5 - PRF=                    : Default : SI/csv/config/si.properties
  # 6 - JS=                     : Default : SI/csv/config/si.js
  # 7 - INCLUDE_GRAPH_VARIAVLES : Default : "".  -ig : Treat only listed variables in graph

  
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

  
   while [[ "$#" > "0" ]] ; do
     case $1 in
         (*=*) KEY=${1%%=*}
               VALUE=${1#*=}
               
               case "$KEY" in
               
                    ("inSparqlTemplateFile")    inSparqlTemplateFile=$VALUE                    
                    ;;
                    ("outSparqlInstancelFile")  outSparqlInstancelFile=$VALUE
                    ;; 
                    ("filters")                 filters=$VALUE
                    ;;
                    ("selectVars")              selectVars=$VALUE
               esac
	     ;;        
         help ) echo
                echo " Total Arguments : Three                                       "
                echo 
                echo "   inSparqlTemplateFile=    :  Input Sparql template File      "
                echo "   outSparqlInstancelFile=  :  Output Magic Filter Instanc     "
                echo "   selectVars =             :  selectVars from SPARQL          "
                echo "   filter =                 :  filter to apply on the template "
                echo
                EXIT ;
        ;;
     esac
     shift
  done   
       
  tput setaf 2
  echo 
  echo -e " ################################################### "
  echo -e " ######## Magic Instancier ######################### "
  echo -e " --------------------------------------------------  "
  echo -e "\e[90m$0            \e[32m                           "
  echo
  echo -e " ## inSparqlTemplateFile   : $inSparqlTemplateFile   "
  echo -e " ## outSparqlInstancelFile : $outSparqlInstancelFile "
  echo -e " ## selectVars             : $selectVars             "
  echo -e " ## filters                : $filters                "
  echo
  echo
  echo -e " ################################################### "
  echo 
  sleep 2
  tput setaf 7

  if [ ! -f "$inSparqlTemplateFile" ] ; then
     echo -e "\e[91m File [ $inSparqlTemplateFile ] -- Not found ! \e[39m "
     EXIT
  fi

  echo -e "\e[90m Starting Instanciation ... \e[39m "
  echo

  
  # TREAT File
  
  COMMAND=" java -cp ../libs/CoreseInfer.jar 
            corese.sparql.SparqlTemplate 
            -queryPath  \"$inSparqlTemplateFile\" 
            -selectVars \"$selectVars\"            
            -outQuery \"$outSparqlInstancelFile\"   
             $filters  "
              
 eval $COMMAND
  
 # java -Xdebug -Xrunjdwp:transport=dt_socket,address=11555,server=y,suspend=y                   \
 # -cp ../libs/CoreseInfer.jar #corese.sparql.SparqlTemplate -queryPath "$inSparqlTemplateFile"  \
 #                                                           -selectVars "$selectVars"           \
 #                                                           -outQuery "$outSparqlInstancelFile" \
 #                                                            $filters 
                                                          
  exitValue=$? 

  if [ $exitValue != 0 ] ; then 
     EXIT
  fi 


  echo 
  echo -e "\e[36m Sparql Instance generated in : $outSparqlInstancelFile \e[39m "
  echo


