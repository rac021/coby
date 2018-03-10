#!/bin/bash

 # The Characters : $ @ ^ ` " are not authorized in this script 
 
    set -e 
 
    SCRIPT_PATH="../scripts"

    CURRENT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    cd $CURRENT_PATH
    
    DOI_PATH="/var/doi-nfs-export"

    ################################################################
    # Arbo SI Configuration Ex
    ################################################################
    #
    #   + si_name
    #     - connection.txt
    #     + csv
    #       - semantic_si.csv
    #     + input
    #       + shared
    #         + Directory_01
    #           - mod.graphml
    #       + variables
    #         + variable_01
    #           - variable_01.graphml 
    #           - class.txt 
    #           - sparql.txt
    #         + variable_02
    #           - variable_02.graphml s
    #           - class.txt 
    #           - sparql.txt
    #
    ################################################################
    ################################################################
    
    ##############################################################################################
    ##############################################################################################

    # Example Test For this script :

    # QUERY=" SI =  SOERE OLA ; SOERE FORET & CLASS = meteo ; physico chimie & variable = http://www.anaee-france.fr/ontology/anaee-france_ontology#WaterPH & localSiteName = Léman ; TOTO & site = http://www.anaee-france.fr/ontology/anaee-france_ontology#GenevaLake & year = 2011_2017 & localVariableName = Azote ammoniacal ; pH ; azote nitreux & SELECT_VARS = variable ; localVariableName ; anaeeVariableName ; anaeeUnitName ; site ; infraName ;  year ; category ; unit ; anaeeSiteName "  
     
    # QUERY=" SI =  SOERE OLA ; SOERE FORET & CLASS = meteo ; physico chimie & localSiteName = Léman ; TOTO & year = 2011_2017 & localVariableName = Azote ammoniacal ; pH ; azote nitreux & SELECT_VARS = localVariableName ; anaeeVariableName ; anaeeUnitName; site ; infraName ;  year ; category ; unit ; anaeeSiteName " 
    
    # QUERY=" SI =  SOERE OLA ; SOERE FORET & CLASS = meteo ; physico chimie & localSiteName = Léman ; TOTO & year = 2011_2012 & localVariableName = Azote Ammoniacal & SELECT_VARS = anaeeUnitName; site ; infraName ;  year ; category ; unit ; anaeeSiteName " 
      
    # QUERY='SI = SOERE OLA ; SOERE FORET & CLASS = meteo ; physico chimie & site = Bourget ; Léman & SELECT_VARS = anaeeUnitName; site ; infraName ; year ; category ; unit ; anaeeSiteName '

    # QUERY=" SI =  SOERE OLA ; SOERE FORET & CLASS = meteo ; physico chimie & year = 1970_2012_close & SELECT_VARS = anaeeUnitName; site ; infraName ; year ; category ; unit ; anaeeSiteName 
       
   ##############################################################################################
   ##############################################################################################   
       
    EXIT() {
     if [  $PPID = 0  ] ; then exit  ; fi
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
    
    if [ $# = 0 -o "$1" = "help"  -o "$1" = "h"  ]  ;  then
        echo 
        echo "  Two ARGS required :                       "
        echo '   -> ( $1 : LOGIN ) & ( $2 : QUERY       ) '
        echo '   -> ( $1 : -i    ) & ( $2 : db=postgres ) '
        echo '   -> ( $1 : -i    ) & ( $2 : db=mysql    ) '
        EXIT
    fi    
 
    if [ $# = 1 ] &&  [ "$1" = "-i" ] ; then
        echo 
        echo "  Two ARGS required for installation :      "
        echo '   -> ( $1 : -i    ) & ( $2 : db=postgres ) '
        echo '   -> ( $1 : -i    ) & ( $2 : db=mysql    ) '
        EXIT
    fi   
  
    ##################################
    ###                            ###
    ### CONFIGURATION ################
    ###                            ###
    ##################################

    echo 
    echo " 00 ============================ 00 "
    echo " ** ============================ ** "
    echo " ||   ____   ____  ___  _     __ || "
    echo " ||  / ___| / __ \|  _ \ \   / / || "
    echo " || | | D  | |  | | |_) \ \_/ /  || "
    echo " || | | O  | |  | |  _<  \   /   || "
    echo " || | |_I_ | |__| | |_) | | |    || "
    echo " ||  \____| \____/|____/  |_| v1 || "
    echo " ||                              || "
    echo " ** ============================ ** "
    echo " 00 ============================ 00 "
   
    echo 
    echo " ## Request ####################### "
    echo
    
    if [ "$1" == "-i" ] ;  then 
    
       echo "    COBY INSTALATION ..." ; echo 
       
    else   
    
       LOGIN="$1"
       QUERY="$2"      
       echo " LOGIN : $LOGIN "
       echo " QUERY : $QUERY "
       echo " DATE  : "`  date `
       # Escape some special Characters  
       QUERY=${QUERY//[\'\"\`\$\^\@]}  
       # Trim
       QUERY=` echo -n "$QUERY" | sed 's/^ *//;s/ *$// ' `
       echo 
       
    fi
   
    echo " ################################## " ; echo 
    
    STRICT_MODE_FILTER=""

    RESERVED_PARAMETERS_WORDS="CLASS , SI, CSV, SELECT_VARS"

    DATE_AS_TOKEN=`date +%d_%m_%Y__%H_%M_%S`    
    OUTPUT_ROOT="$DOI_PATH/$LOGIN/$DATE_AS_TOKEN" 

    SI_PATH="SI" 
   
    if [[ ! -d  "SI" ]] ; then
        SI_PATH="../SI" ;
    fi

    if [ ! -d "$SI_PATHS" ]; then 
      echo  
      echo -e "\e[93m ERROR ### \e[32m "
      echo -e "\e[93m  =>> Missning Modelization. No [$SI_PATH] Folder Provided ### \e[32m "
      EXIT
    fi
    
    FILE_BINDER="$SI_PATH/SI.txt"
        
    # Port 
    RW="7777"
    RO="8888"
    # Database 
    DATA_BASE="postgresql" # Alternative : "mysql"
    # Extensions :
    EXT_OBDA="obda"
    EXT_GRAPH="graphml"
    # Class File ( Discriminators )
    CLASS_FILE_NAME="class.txt"
    SPARQL_FILE_NAME="sparql.txt"
    ## CSV Config
    CSV_SEP=";"
    INTRA_CSV_SEP=" -intra_sep , -intra_sep '<' -intra_sep '>' " 
    COLUMNSTO_VALIDATE=" -column 0 -column 1 -column 2 -column 4 -column 6 -column 7 -column 8 -column 10 "
    INPUT_CSV_FILE_NAME="semantic_si.csv"
    OUTPUT_VALIDE_CSV_FILE_NAME="pipeline_si.csv"
    # Connection
    CONNEC_FILE_NAME="connection.txt"
        
    # yedGen 
    YED_GEN_ONTOP_VERSION="V1" # V3 # Default Version V1
    
    # Ontop ARGS
    ONTOP_QUERY="SELECT ?S ?P ?O { ?S ?P ?O } "
    ONTOP_TTL_FORMAT="ttl"
    ONTOP_PAGE_SIZE="200000"
    ONTOP_FLUSH_COUNT="500000"
    ONTOP_FRAGMENT="1000000"
    ONTOP_XMS="15g"
    ONTOP_XMX="15g"

    ONTOP_OUT_NOT_OUT_ONTOLOGY="not_out_ontology" # OR # out_ontology
    
    ########################################
    ########################################

    ONTOP_BATCH="batch" # disable : "" 
    #ONTOP_BATCH="" 

    # Merge works only if BATCH is ENABLE 
    ONTOP_MERGE="" # For Merge : "merge" 
    
    ONTOP_LOG_LEVEL="OFF" # ALL , DEBUG , INFO , TRACE , WARN , ERROR  ; 
        
    ONTOP_DEBUG="" # ENABLE USING "ontop_debug"
    
    ONTOP_MUST_NOT_BE_EMPTY=" (1) , (2) "

    # IMPORTANT : IF CORESE_EXTRACT_ONLY_INFERENCE = TRUE
    # YOU HAVE TO PROVIDE A CORESE SPARQL QUERY ( CORESE_QUERY )  
    #  WITH kg:entailment
    CORESE_EXTRACT_ONLY_INFERENCE="false" # true

    ########################################
    ########################################

    # Corese ARGS
    
    CORESE_OUTPUT_EXTENSION="ttl"
    CORESE_IGNORE_LINE_BREAK="corese_ignore_line_break"
    
    # Note : be careful with --> CORESE_EXTRACT_ONLY_INFERENCE 
     CORESE_QUERY=${CORESE_QUERY:-"SELECT ?S ?P ?O { ?S ?P ?O . filter( !isBlank(?S) ) . filter( !isBlank(?O) )  } "}
    # CORESE_QUERY=${CORESE_QUERY:-"SELECT ?S ?P ?O WHERE { graph kg:entailment { ?S ?P ?O } FILTER NOT EXISTS { graph ?g { ?S ?P ?O } FILTER ( ?g != kg:entailment) } }"} 
    
    CORESE_PEEK=${CORESE_PEEK:-"-peek 6 "}
    CORESE_FRAGMENT=${CORESE_FRAGMENT:-"-f 1000000 "}    
    CORESE_FORMAT=${CORESE_FORMAT:-"-F ttl "}
    CORESE_FLUSH_COUNT=${CORESE_FLUSH_COUNT:-"-flushCount 250000"}    
    CORESE_XMS=${CORESE_XMS:-"15g"}
    CORESE_XMX=${CORESE_XMX:-"15g"}

    CORESE_EXTRACT_ONLY_INFERENCE=${CORESE_EXTRACT_ONLY_INFERENCE:-"false"}
   
    # VAR_PART[0]='VAR_PART_SI'
    # VAR_PART[1]='VAR_PART_CSV'
    # VAR_PART[2]='VAR_PART_SQL'
    
    DELIMITER_AT='@'
    DELIMITER_DDOT=':'
    DELIMITER_DDOT_EQ=':='
    DELIMITER_DIEZ_COMMENT='#'
     
    ROOT_PATH="${CURRENT_PATH/}"
    PARENT_DIR="$(dirname "$ROOT_PATH")"
    
    EXTRACT_ALL_SI() {
      FOLDER="$1"
      for SI in ` find $FOLDER -mindepth 1 -maxdepth 1 -type d -not -name "ontology" `; do
        SIS+=($(basename $SI))
      done
      echo "$SIS"
    }

    EXTRACT_ALL_CLASS()  {  
       FOLDER="$1"
       _IFS=$IFS  
       for class_file_path in ` find $FOLDER/*                 \
                                     -type f                   \
                                     -name 'class.txt'         \
                                     -not                      \
                                     -path "*/ontology/class.txt" ` ;  do
         LINE_ONE=$(head -n 1  $class_file_path )                     
         LINE_TWO=$(sed -n '2p'  $class_file_path )                        
         IFS=$'='
         read -ra KEY_VALUE <<< "$LINE_ONE" 
         CLASSS+=`echo -e "${KEY_VALUE[1]}" | xargs` 
       done
       IFS=$_IFS
       echo "$CLASSS"
    }
  
    TO_ARRAY() { 
        LINE=$1
        DELIMITER=$2
        ARRAY=()
        OIFS=$IFS
        IFS="$DELIMITER" read -r -a array <<< "$LINE"
        for element in "${array[@]}" ; do
        ARRAY+=("$element")
        done
        IFS=$OIFS
    }
    
    GET_VALUE_FROM_FILE_BINDER() {         
        KEY="` echo "$1" | xargs `"
        FILE="$2"
        RESULT="NULL"
        OIFS=$IFS
        while IFS=$DELIMITER_DDOT read -r key val
        do    
        _key=`echo ${key} | sed -e 's/=//' | sed -e 's/^[[:space:]]*//' | xargs `
        _val=`echo ${val} | sed -e 's/=//' | sed -e 's/^[[:space:]]*//' | xargs `
        if [ "$KEY" == "$_key" ] ; then
            RESULT="$_val"
        fi 
        done < $FILE
        IFS=$OIFS
    }    
    
    EXTRACT_VALUES_FROM_LINE() { 
        OIFS=$IFS
        key=$1
        REQUEST=$2        
        IFS=$'\n'
        RESULT=`echo "$REQUEST" | grep -shoP '^.*'$key' *'$DELIMITER_DDOT_EQ'.*?'$DELIMITER_AT'|^.*'$key' *'$DELIMITER_DDOT_EQ'.*$' \
                                | sed -e 's/^.*'$key' *'$DELIMITER_DDOT_EQ'//' | sed -e 's/'$DELIMITER_AT'//'                       \
                                | sed 's/  */ /g' `
        IFS=$OIFS
    }    
    
    GET_SELECTED_SI() { 
        VALUES=$1
        FILE=$2
        SELECTED_SI=()
        OIFS=$IFS
        IFS=';' read -r -a selectedSIs <<< "$VALUES"
        for selectedSI in "${selectedSIs[@]}"
        do   
        si=`echo ${selectedSI} | sed -e 's/^[[:space:]]*//'`  
        GET_VALUE_FROM_FILE_BINDER "$si" "$FILE"
        if [ "$RESULT" != "NULL" ] ; then 
            SELECTED_SI+=($RESULT)
        fi 
        done
        IFS=$OIFS
    }
                          

    CALL_COBY() { 
       
        ##################################################
        ##  INSTALLATION  ################################
        ##################################################
        
        if [ "$2" == "" -a "$1" == "-i" ] ; then 
            echo
            echo "  -> The arg [ -i ] is used only for installation. Cmd Ex : "$0" -i db=postgresql "
            EXIT
        
        elif [ "$#" -eq 2 -a "$1" == "-i" ] ; then 
        
            if [ "$2" != "db=postgresql" -a "$2" != "db=mysql" ] ;  then 
            echo
            echo "  -> Database must be : postgresql / mysql.  Cmd Ex : "$0" -i db=postgresql "
            EXIT
            fi
            
            s_db=$2
            db="${s_db/db=/''}"
            
            $SCRIPT_PATH/00_install_libs.sh db=$db
            
            EXIT 
        fi        
       
        SI="$1"
        CLASS_VALUES="$2"
        QUERY="$3"
        
        #####################################################
        #####################################################
        # COBY PIPELINE 
        #####################################################
        #####################################################

        ./data_extractor_process.sh  ip=localhost                                                   \
                                     namespace=soere                                                \
                                     ro=$RO                                                         \
                                     rw=$RW                                                         \
                                     si=$SI                                                         \
                                     db=$DATA_BASE                                                  \
                                     ext_obda=$EXT_OBDA                                             \
                                     ext_graph=$EXT_GRAPH                                           \
                                     class_file_name=$CLASS_FILE_NAME                               \
                                     sparql_file_name=$SPARQL_FILE_NAME                             \
                                     csv_file_name=$INPUT_CSV_FILE_NAME                             \
                                     valide_csv_file_name=$OUTPUT_VALIDE_CSV_FILE_NAME              \
                                     csv_sep=$CSV_SEP                                               \
                                     intra_separators="$INTRA_CSV_SEP"                              \
                                     columns="$COLUMNSTO_VALIDATE"                                  \
                                     connec_file_name=$CONNEC_FILE_NAME                             \
                                                                                                    \
                                     yed_gen_ontop_version=$YED_GEN_ONTOP_VERSION                   \
                                     ontop_log_level=$ONTOP_LOG_LEVEL                               \
                                                                                                    \
                                     ontop_xms="$ONTOP_XMS"                                         \
                                     ontop_xmx="$ONTOP_XMX"                                         \
                                     ontop_ttl_format="$ONTOP_TTL_FORMAT"                           \
                                     ontop_batch="$ONTOP_BATCH"                                     \
                                     ontop_page_sifze="$ONTOP_PAGE_SIZE"                            \
                                     ontop_flush_count="$ONTOP_FLUSH_COUNT"                         \
                                     ontop_merge="$ONTOP_MERGE"                                     \
                                     ontop_query="$ONTOP_QUERY"                                     \
                                     ontop_fragment="$ONTOP_FRAGMENT"                               \
                                                                                                    \
                                     strict_mode_filter="$STRICT_MODE_FILTER"                       \
                                     output_root="$OUTPUT_ROOT"                                     \
                                     "$ONTOP_OUT_NOT_OUT_ONTOLOGY"                                  \
                                     "$ONTOP_DEBUG"                                                 \
                                                                                                    \
                                     corese_xms="$CORESE_XMS"                                       \
                                     corese_xmx="$CORESE_XMX"                                       \
                                     corese_query="$CORESE_QUERY"                                   \
                                     corese_peek="$CORESE_PEEK"                                     \
                                     corese_fragment="$CORESE_FRAGMENT"                             \
                                     corese_flush_count="$CORESE_FLUSH_COUNT"                       \
                                     corese_format="$CORESE_FORMAT"                                 \
                                     corese_output_extension="$CORESE_OUTPUT_EXTENSION"             \
                                     "$CORESE_IGNORE_LINE_BREAK"                                    \
                                     class_values="$CLASS_VALUES"                                   \
                                     query_user="$QUERY"                                            \
                                     reserved_paramaters_words="$RESERVED_PARAMETERS_WORDS"         \
                                     corese_extract_only_inference="$CORESE_EXTRACT_ONLY_INFERENCE" \
                                     must_not_be_empty="$ONTOP_MUST_NOT_BE_EMPTY"                   \
                                     "ingore_case_sensitive_filtering_variables"                  
    
    }
    
    #######################
    ## COBY ORCHESTRATOR ##
    #######################
    
    TOTAL_ARGS=0
    MINIMUM_REQUIRED_ARGS=2
    
    if [[ "$1" == "-i" ]] ; then 
       CALL_COBY "$1" "$2"   
       EXIT
    elif [[ -z "$QUERY"  ]] ; then
       echo
       echo " EMPTY QUERY => EMPTY RESULT "
       echo
       EXIT
    fi
    
    if [[ ! -d  "$OUTPUT_ROOT"  ]] ; then
      mkdir -p "$OUTPUT_ROOT" 
    else 
      rm -rf $OUTPUT_ROOT/*.*
      rm -rf $OUTPUT_ROOT/*
    fi

    OUTPUT_ROOT=` readlink -f "$OUTPUT_ROOT" `

    QUERY=${QUERY//&/ $DELIMITER_AT }
    QUERY=${QUERY//=/ $DELIMITER_DDOT_EQ }
    
    echo

    EXTRACT_VALUES_FROM_LINE "CLASS" "$QUERY"  
    CLASS_VALUES="$RESULT"
   
    if [[ -z "$CLASS_VALUES" ]] ; then
       echo " --> Search and Apply all Class values "
       echo
       CLASS_VALUES=$( EXTRACT_ALL_CLASS '../SI' )
       
       if [[ -z "$CLASS_VALUES" ]] ; then 
           echo " No CLASS FOUND !      "
           echo " The process will EXIT "
           EXIT
       fi
    else 
       TOTAL_ARGS=$[$TOTAL_ARGS +1]
    fi
    
    TO_ARRAY "$RESULT" ";"
    EXTRACT_VALUES_FROM_LINE "SI" "$QUERY"  
 
    GET_SELECTED_SI "$RESULT" "$FILE_BINDER"

    if [[ -z "${SELECTED_SI[@]}" ]] ; then
      echo 
      echo " --> Search and Apply all SI "
      echo
      SELECTED_SI=$(EXTRACT_ALL_SI "../SI")
      if [[ -z "${SELECTED_SI[@]}" ]] ; then
          echo " No SI detected ! Path -> [${SELECTED_SI[@]}] "
          echo " The process will EXIT "
          EXIT   
      fi
    else 
       TOTAL_ARGS=$[$TOTAL_ARGS +1]
    fi
    
    EXTRACT_VALUES_FROM_LINE "variables" "$QUERY"  
    VARIABLES="$RESULT"
    if [[ ! -z "$VARIABLES" ]] ; then
       TOTAL_ARGS=$[$TOTAL_ARGS +1]  
    fi
    
    EXTRACT_VALUES_FROM_LINE "category" "$QUERY"  
    CATEGORIES="$RESULT"
    if [[ ! -z "$CATEGORIES" ]] ; then
       TOTAL_ARGS=$[$TOTAL_ARGS +1]  
    fi
    
    
    if [ $TOTAL_ARGS -lt $MINIMUM_REQUIRED_ARGS ] ; then
         echo
         echo " ============================================================                       "
         echo
         echo " MINIMUM_REQUIRED_ARGS not reached :                                                "
         echo
         echo "  -> MINIMUM Required ARGS : $MINIMUM_REQUIRED_ARGS                                 "
         echo "  -> TOTAL Recieved ARGS   : $TOTAL_ARGS                                            "
         echo "  -> Required ARGS ( $MINIMUM_REQUIRED_ARGS )   : SI , category , variables, CLASS  "
         echo
         echo " ============================================================                       "
         echo 
         EXIT
    fi
        
    $SCRIPT_PATH/utils/check_commands.sh java curl psql-mysql mvn awk gawk
    
    for si in "${SELECTED_SI[@]}" ; do
       tput setaf 2
       echo
       echo -e " ############################## "
       echo -e " ### Treat SI -->  $si          " 
       echo -e " ############################## "
       echo
       tput setaf 7
       sleep 1      
       echo 
       CALL_COBY "$si" "$CLASS_VALUES" "$QUERY"
    done
    
