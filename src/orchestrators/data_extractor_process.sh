#!/bin/bash

  set -e 

  SCRIPT_PATH="../scripts"

  ##############################################################################################
  ##############################################################################################

  # Example Test For this script :  
 
     # QUERY=" SI :=  SOERE OLA ; SOERE FORET @ site := http://www.anaee-france.fr/ontology/anaee-france_ontology#GenevaLake @ localSiteName := Léman ; TOTO @ year := 2011_2012 @ localVariableName := Azote ammoniacal @ SELECT_VARS := anaeeUnitName; site ; infraName ;  year ; category ; unit ; anaeeSiteName " 
     # WhichSI="OLA" 
     # ONTOP_MERGE=""
     # CLASS_VALUES="meteo ; physico chimie  "
     # ONTOP_BATCH="batch"
     # CORESE_EXCTRACT_ONLY_INFERENCE="false"
     # ONTOP_NOT_OUT_ONTOLOGY="not_out_ontology"
     
     # CORESE_IGNORE_LINE_BREAK="ignore_line_break"

  ################################################################################### 
  # Reserved Parameters Words ( Ignored Params Validation - Ignored During Validation 
  ################################################################################### 
   
     # RESERVED_PARAMETERS_WORDS="CLASS , SI, CSV, SELECT_VARS"
   
     # OUTPUT_ROOT="DOI/"
    
     # YED_GEN_ONTOP_VERSION="V1"  
  
  ##############################################################################################
  ##############################################################################################  
  
    GET_ABS_PATH() {
       # $1 : relative filename
       echo "$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
    }

    EXIT() {
     if [ $PPID = 0  ] ; then exit  ; fi
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
    
    TO_ARRAY() { 
        LINE=$1
        DELIMITER=$2
        local ARRAY=()
        OIFS=$IFS
        IFS="$DELIMITER" read -r -a arry <<< "$LINE"
        for element in "${arry[@]}" ; do
           elem=` echo -n $element | sed 's/^ *//;s/ *$// ' `
           ARRAY+=("$elem")     
        done
        IFS=$OIFS
        expr "${ARRAY[*]}"
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
    
    EXTRACT_PART_FROM_FILE_BINDER() { 
        
        OIFS=$IFS
        IFS=  
        PART=$1
        FILE=$2
        RESULT=`cat "$FILE" | sed -n '/ *'$DELIMITER_DIEZ_COMMENT' *'$PART'/,/.*'$DELIMITER_DIEZ_COMMENT' .*/p' \
                            | sed '/'$DELIMITER_DIEZ_COMMENT' /d' | sed '/.*--/d' | sed '/^$/d' | sed '/^ *$/d' `       
        
        IFS=$OIFS
    }
    
    EXTRACT_VALUES_FROM_LINE() {    

        OIFS="$IFS"
        key="$1"
        REQUEST="$2"        
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
    
    
    EXTRACT_KEYS_FROM_LINE() { 
        REQUEST=$1    
        KEYS=()
        OIFS=$IFS
        IFS=$DELIMITER_AT           
        for req in $REQUEST ; do 
          RES=` echo $req | sed -e 's/'$DELIMITER_DDOT_EQ'.*//' | xargs ` 
          KEYS+=($RES)
        done

        IFS=$OIFS
    }
    
    WRAP_FOR_SQL_FILTER() { 
       
       OIFS=$IFS
       VAL=$1
       MATCHER_VALUE="$2"
       WRAPED=""
       IFS=',' read -r -a SQL_ARR <<< "$VAL"
       for i in "${SQL_ARR[@]}"; do
          _value=`echo "$i" | sed 's/^ *//;s/ *$// ' ` 
          APPLYED_SQL_VALUE=${MATCHER_VALUE/"?$key"/"$_value"}
          SQL_ARRAY+=("$APPLYED_SQL_VALUE") 
       done
       joined=$(printf ", %s" "${SQL_ARRAY[@]}" )
       WRAPED=${joined:1}
       SQL_ARRAY=()
       IFS=$OIFS     
    }

    FIND_KEY_AND_VALUE_IN_FILE_BINDER() { 
       
        KEY="$1"
        local _FILE_BINDER="$2"
        OIFS=$IFS
        IFS=  
        RESULT="NULL"
        for PART in "${VAR_PART[@]}" ; do   
        
           EXTRACT_PART_FROM_FILE_BINDER "$PART" "$_FILE_BINDER"          
           #EXTRACT_VALUES_FROM_LINE "$KEY" "${RESULT//$'\n'/$DELIMITER_AT$'\n'}"
           EXTRACT_VALUES_FROM_LINE "$KEY" "$RESULT"
          
           if [[ ! -z "$RESULT" ]]; then
              #  echo " KEY : $KEY  // found in // $PART  // WITH VALUE // $RESULT"
              break ;
           fi
        done   
        IFS=$OIFS
    }    
     
    MACTH_WORD_IN_ARRAY() { 
       WORD=` echo $1 | xargs`
       array_arg_2=$2 && shift
	   ARRAY=($@)       
       for element in "${ARRAY[@]}" ; do  
        if [ "$WORD" == "`echo ${element} | xargs `" ] ; then
           echo "TRUE"
           # expr "TRUE"          
           return ;
        fi
       done
       # expr "FALSE"
       echo "FALSE"
    }    
    
    BUILD_PARAMETERS_FROM_QUERY() { 

       QUER="$1"
       local _FILE_BINDER="$2"
       IGNORE_PARAM=`echo "$3" | xargs `
       _OIFS=$IFS
     
       if [[ $QUERY != *"&"* ]] ; then
          QUERY=${QUERY//&/ $DELIMITER_AT }
       fi
       
       if [[ $QUERY != *":="* ]] ; then
          QUERY=${QUERY//=/ $DELIMITER_DDOT_EQ }
       fi
       
       EXTRACT_KEYS_FROM_LINE "$QUER"
     
       for key in "${KEYS[@]}" ; do

          FIND_KEY_AND_VALUE_IN_FILE_BINDER "$key" "$_FILE_BINDER"  
    
          if [  !  -z "$RESULT" ]; then
            
             # echo " KEY : $key  // found in // $PART  // WITH VALUE // $RESULT" 
             
             _VALUE="$RESULT"            
            
             # BUILD CSV VAR
             if [ "$PART" == "${VAR_PART[0]}" ] ; then
                
                 COLUMN=$_VALUE                 
                 EXTRACT_VALUES_FROM_LINE "$key" "$QUERY"
                 
                 ## TRIM
                 _VALUE=` echo -n $_VALUE | sed 's/^ *//;s/ *$// ' `
                 RESULT=` echo -n $RESULT | sed 's/^ *//;s/ *$// ' `

                 # In this case VALUE must be A Number 
                 PART_VALUES_CSV_MATCHER+=" -match $_VALUE \"$RESULT\" "
                
             # BUILD SQL VAR
             elif [ "$PART" == "${VAR_PART[1]}" ] ; then   
             
                 _PART_VALUES_SQL="$_VALUE "

                 EXTRACT_VALUES_FROM_LINE "$key" "$QUERY"   
                
                 ## IMPORTANT 
                 ##  Replace all ";" by ","  // 
                 ##  "," is used as SPLITTER In Magic Filter 
                
                 RESULT=`echo "$RESULT" | sed 's/;/,/g' | sed 's/^ *//;s/ *$// ' `               
                 
                 # WRAP VALUES IN SINGLE QUOTES
                 # SPLIT RESULT USING ,               
         
                # MATCHER_VALUE=`echo "$PART_VALUES_SQL" | grep -Po '(?<=(\( )).*(?=\).*{)' `
                 
                 LEFT_PART_VALUE_SQL=`echo "$_PART_VALUES_SQL" | grep -Po '(?<=(\()).*(?=\).{)' `
    
                 RIGHT_PART_VALUE_SQL=` echo "$_PART_VALUES_SQL" | grep -o '{.*}.*$' `

                 WRAP_FOR_SQL_FILTER "$RESULT" "$LEFT_PART_VALUE_SQL"

                 #PART_VALUES_SQL=${PART_VALUES_SQL/"?$key"/"$WRAPED"}
                 __PART_VALUES_SQL="( $WRAPED ) $RIGHT_PART_VALUE_SQL"
                 PART_VALUES_SQL+=" $__PART_VALUES_SQL "
                 
                echo             
             
              # BUILD SEMANTIC VAR
             elif [ "$PART" == "${VAR_PART[2]}" ] ; then
                
                 COLUMN=$_VALUE              
                 EXTRACT_VALUES_FROM_LINE "$key" "$QUERY"
                 
                 ## TRIM
                 _VALUE=` echo -n $_VALUE | sed 's/^ *//;s/ *$// ' `
                 RESULT=` echo -n $RESULT | sed 's/^ *//;s/ *$// ' `

                 # Remove the Char ? ( Always the first Char )
                 _VALUE=`echo "$_VALUE" | sed 's/^.//' `
                 # Replace all ; by , 
                 RESULT=`echo "$RESULT" | sed 's/;/,/g' `
                 PART_VALUES_SEMANTIC_MATCHER+=" -filters \"$_VALUE:=$RESULT\" "
             fi               
            
          else
            
            # echo " NO KEY FOUND FOR : $key " 
            # echo ; echo " Ignore Params ( Reserved Words ) --> $IGNORE_PARAM" ; echo  ;
            
            OIFS=$IFS
            IFS=","
            TO_ARRAY_INGORE_RESERVED_WORDS=($( TO_ARRAY "$IGNORE_PARAM" "," ))
            OK=$( MACTH_WORD_IN_ARRAY "$key" ${TO_ARRAY_INGORE_RESERVED_WORDS[@]} )
            IFS=$OIFS

            if [ $STRICT_MODE_FILTER == "TRUE" ] && [ "$OK" == "FALSE" ] ; then 
                ERROR_KEY="TRUE"
                ERROR_KEY_LIST+=" [$key] ; "
                PART_VALUES_CSV_MATCHER=""
                PART_VALUES_SEMANTIC_MATCHER=""
                PART_VALUES_SQL=""
            fi
            
          fi
            
       done
        
       if [ "$ERROR_KEY" == "TRUE" ] ; then 
           echo " Keys not found : $ERROR_KEY_LIST"
           EXIT            
       else           
           # echo " CSV --> $PART_VALUES_CSV_MATCHER"
           # echo " SQL --> $PART_VALUES_SQL"
           SUCCESS="TRUE"           
       fi
     
       IFS=$_OIFS
       echo
     
    }
    

    CURRENT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    cd $CURRENT_PATH

    ROOT_PATH="${CURRENT_PATH/}"

    if [ ! -d "$SCRIPT_PATH" ]; then 
      echo " The Directory $SCRIPT_PATH not found. "
      EXIT 
    fi
   
    # If SI folder not found in the same place of the script  
    # Search in the parent folder
    if [ ! -d "$ROOT_PATH/SI/" ] ; then
        ROOT_PATH="${ROOT_PATH%/*}"
    fi   

    
    ##################################################
    ##  INSTALLATION  ################################
    ##################################################
    
    if [ "$#" -ne 2 -a "$1" == "-i" ] ; then 
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
    
    #####################################################
    #####################################################
    
    
    while [[ "$#" > "0" ]] ; do
    
     case $1 in
     
         (*=*) KEY=${1%%=*}
         
               VALUE=${1#*=}
               
               case "$KEY" in
               
                    ("ip")                    IP_HOST=$VALUE
                    ;;
                    ("rw")                    Read_Write_Port=$VALUE
                    ;;
                    ("ro")                    Read_Only_Port=$VALUE
                    ;;
                    ("si")                    WhichSI=$VALUE
                    ;;
                    ("db")                    DATABASE=$VALUE
                    ;;      
                    ("ext_obda")              EXTENSION_OBDA=$VALUE
                    ;;      
                    ("ext_graph")             EXTENSION_SPEC=$VALUE
                    ;;
                    ("class_file_name")       CLASS_FILE=$VALUE
                    ;; 
                    ("namespace")             NAME_SPACE=$VALUE
                    ;;
                    ("sparql_file_name")      SPARQL_FILE=$VALUE
                    ;;
                    ("csv_file_name")         CSV_FILE_NAME=$VALUE
                    ;; 
                    ("valide_csv_file_name")  VALIDE_CSV_FILE_NAME=$VALUE
                    ;; 
                    ("csv_sep")               CSV_SEP=$VALUE
                    ;;  
                    ("intra_separators")      INTRA_SEPARATORS=$VALUE
                    ;; 
                    ("columns")               COLUMNS_TO_VALIDATE=$VALUE
                    ;; 
                    ("connec_file_name")      CONNEC_FILE_NAME=$VALUE
                    
                    # Ontop ARGS
                    ;;
                    ("ontop_xms")             ONTOP_XMS=$VALUE
                    ;;
                    ("ontop_xmx")             ONTOP_XMX=$VALUE
                    ;; 
                    ("ontop_ttl_format")      ONTOP_TTL_FORMAT=$VALUE
                    ;;
                    ("ontop_batch")           ONTOP_BATCH=$VALUE
                    ;;
                    ("ontop_page_size")       ONTOP_PAGE_SIZE=$VALUE
                    ;;
                    ("ontop_flush_count")     ONTOP_FLUSH_COUNT=$VALUE
                    ;;
                    ("ontop_merge")           ONTOP_MERGE=$VALUE
                    ;;
                    ("ontop_query")           ONTOP_QUERY=$VALUE
                    ;; 
                    ("ontop_fragment")        ONTOP_FRAGMENT=$VALUE
                    ;;
                    ("ontop_log_level")       ONTOP_LOG_LEVEL=$VALUE                   
                    ;;
                    ("yed_gen_ontop_version") YED_GEN_ONTOP_VERSION=$VALUE
                    ;;
                    ("must_not_be_empty")     MUST_NOT_BE_EMPTY_NODES=$VALUE
		    
                    # Corese ARGS
                    ;;
                    ("corese_xms")            CORESE_XMS=$VALUE
                    ;;
                    ("corese_xmx")            CORESE_XMX=$VALUE
                    ;;                
                    ("corese_query")          CORESE_QUERY=$VALUE
                    ;;
                    ("corese_peek")           CORESE_PEEK=$VALUE
                    ;;
                    ("corese_fragment")       CORESE_FRAGMENT=$VALUE
                    ;;
                    ("corese_format")         CORESE_FORMAT=$VALUE
                    ;;    
                    ("corese_flush_count")    CORESE_FLUSH_COUNT=$VALUE
                    ;;  
                    ("corese_output_extension") CORESE_OUTPUT_EXTENSION=$VALUE                 
                    ;;
                    ("class_values")            CLASS_VALUES=$VALUE
                    ;;  
                    ("query_user")              QUERY=$VALUE
                    ;;  
                    ("strict_mode_filter")      STRICT_MODE_FILTER=$VALUE
                    ;;  
                    ("corese_extract_only_inference")  CORESE_EXCTRACT_ONLY_INFERENCE=$VALUE
                    ;;  
                    ("reserved_paramaters_words")      RESERVED_PARAMETERS_WORDS=$VALUE
                    ;;  
                    ("output_root")                    OUTPUT_ROOT=$VALUE    
                    
               esac
         ;;
         help | -help | -h )  
                echo
                echo " Total Arguments : ***                                                                                "
                echo
                echo "   ip=                   :  IP_HOST ( or Hostname )                                                   "
                echo "   namespace=            :  NAME_SPACE                                                                "
                echo "   rw=                   :  Read_Write_Port                                                           "
                echo "   ro=                   :  Read_Only_Port                                                            "
                echo "   si=                   :  WhichSI  : DEFAULT { SI folder }                                          "
                echo "   db=                   :  DATA_BASE { [postgresql] - mysql }                                        "
                echo "   ext_obda=             :  Extension of obda files. Ex : ext_obda=obda                               "
                echo "   ext_graph=            :  Extension of specs graphs. Ex : ext_graph=graphml                         "
                echo "   class_file_name=      :  Class file name. Ex : class_file_name=class.txt                           "
                echo "   sparql_file_name=     :  Sparql file name. Ex : sparql_file_name=sparql.txt                        "
                echo "   csv_file_name=        :  Input semantic CSV. Ex : sparql_file_name=semantic_si.csv                 "
                echo "   valide_csv_file_name= :  Output valide CSV. Ex : valide_csv_file_name=pipeline_si.csv              "
                echo "   csv_sep=              :  CSV separator. Ex : csv_sep=';'                                           "
                echo "   intra_separators=     :  Intra CSV separators. Ex : intra_separators=' -intra_sep , -intra_sep < ' "
                echo "   columns=              :  Columns to validate using Ontology. Ex : columns=' -column 0 -column 1'   "
                echo "   ontop_xms=            :   "
                echo "   ontop_xmx=            :   "
                echo "   ontop_ttl_format=     :   "
                echo "   ontop_batch=          :   "
                echo "   ontop_page_size=      :   "
                echo "   ontop_flush_count=    :   "
                echo "   ontop_merge=          :   "
                echo "   ontop_query=          :   "
                echo "   ontop_fragment=       :   "
                echo "   corese_xms=           :   "
                echo "   corese_xmx=           :   "
                echo "   corese_query=         :   "
                echo "   corese_peek=          :   "
                echo "   corese_fragment=      :   "
                echo "   corese_format=        :   "
                echo "   corese_flush_count=   :   "		
                echo
                EXIT
        ;;
        ontop_debug )              ONTOP_DEBUG="debug"
        ;;
        corese_ignore_line_break ) CORESE_IGNORE_LINE_BREAK="ignore_line_break"
        ;;
        not_out_ontology)          ONTOP_NOT_OUT_ONTOLOGY="not_out_ontology"
        ;;
        out_ontology)              ONTOP_OUT_ONTOLOGY="out_ontology"
        ;; 
        ingore_case_sensitive_filtering_variables) IGNORE_CASE_SENTITIVE_FITERING_VARIABLES="ignore_case_sensitive"                    
        
     esac
     shift
    done    
   
    WhichSI=${WhichSI:-NULL} # Trim 
    WhichSI=` echo -n $WhichSI | sed 's/^ *//;s/ *$// ' `

    IP_HOST=${IP_HOST:-localhost}    
    Read_Write_Port=${Read_Write_Port:-7777}
    Read_Only_Port=${Read_Only_Port:-8888}
    DATABASE=${DATABASE:-postgresql}
    NAME_SPACE=${NAME_SPACE:-data}

    OUTPUT_ROOT=${OUTPUT_ROOT:-"$SI/output/DOI/$WhichSI"}
    
    OUTPUT_ROOT=` readlink -f "$OUTPUT_ROOT" `
  
    #CLASS FILE 
    CLASS_FILE=${CLASS_FILE:-"class.txt"}
    #SPARQL FILE 
    SPARQL_FILE_NAME=${SPARQL_FILE_NAME:-"sparql.txt"}
    
    #Magic Filter Template File Name
    MAGIC_FILTER_TEMPLATE_FILE_NAME=${MAGIC_FILTER_TEMPLATE_FILE_NAME:-"magicFilter_Template.txt"}
    #Magic Filter Instance
    MAGIC_FILTER_INSTANCE_FILE_NAME=${MAGIC_FILTER_INSTANCE_FILE_NAME:-"magicFilter_Instance.txt"}
    
    Magic_Filter_SPARQL_INSTANCE=${Magic_Filter_SPARQL_INSTANCE:-"magicFilter_SPARQL_Instance.txt"}

    CLASS_VALUE=""
    DISCRIMINATOR_COLUMN=""

    ## EXTENSIONS
    EXTENSION_OBDA=${EXTENSION_OBDA:-"obda"}
    EXTENSION_SPEC=${EXTENSION_SPEC:-"graphml"}
     
    CSV_FILE_NAME=${CSV_FILE_NAME:-"semantic_si.csv"}
    VALIDE_CSV_FILE_NAME=${VALIDE_CSV_FILE_NAME:-"pipeline_si.csv"}

    CONNEC_FILE_NAME=${CONNEC_FILE_NAME:-"connection.txt"}
        
    ## CSV ARGS
    CSV_SEP=${CSV_SEP:-";"}  
    INTRA_SEPARATORS=${INTRA_SEPARATORS:-" -intra_sep , "}
    COLUMNS_TO_VALIDATE=${COLUMNS_TO_VALIDATE:-" -column 0 -column 1 -column 2 -column 4 -column 6 -column 7 -column 8 -column 10 "}
    
    ##############
    ## yedGen   ##
    ##############
    
    YED_GEN_ONTOP_VERSION=${YED_GEN_ONTOP_VERSION:-"V1"}  
    
    #################
    ## Ontop ARGS  ##
    #################
        
    ONTOP_DEBUG=${ONTOP_DEBUG:-""}
    
    ONTOP_LOG_LEVEL=${ONTOP_LOG_LEVEL:-"OFF"}
    
    ONTOP_QUERY=${ONTOP_QUERY:-" SELECT ?S ?P ?O { ?S ?P ?O } "}
    
    # Output Format
    DEFAULT_TTL="ttl"
    ONTOP_TTL_FORMAT=${ONTOP_TTL_FORMAT:-$DEFAULT_TTL} 
    
    # Batch disable by default ( Extract NODE by NODE )
    #ONTOP_BATCH="batch"
    ONTOP_BATCH=${ONTOP_BATCH:-""} # ENABLE : "batch"
  
    # Merge : Ability to Extract Data from database ignoring Ontology 
    # ( by using empty Ontology )
    # MERGE doesn't work well with ONTOP ( missing some ontology triples ) 
    # => this is due to QUEST LIMITATION 
    ONTOP_MERGE=${ONTOP_MERGE:-""} # Disabled by default. Enable : "merge"    
  
    # LIMIT for SQL Queries 
    ONTOP_PAGE_SIZE=${ONTOP_PAGE_SIZE:-"200000"}
    # Number triples by file
    ONTOP_FRAGMENT=${ONTOP_FRAGMENT:-"1000000"}
    # Total triples in memory befobe writing in the file 
    ONTOP_FLUSH_COUNT=${ONTOP_FLUSH_COUNT:-"500000"}    
    # Memory 
    ONTOP_XMS=${ONTOP_XMS:-"8g"}
    ONTOP_XMX=${ONTOP_XMX:-"8g"}
   
    ONTOP_NOT_OUT_ONTOLOGY=${ONTOP_NOT_OUT_ONTOLOGY:-""}
    
    ONTOP_OUT_ONTOLOGY=${ONTOP_OUT_ONTOLOGY:-""}
    
    #########################################
    ##########################################
 
    ##################
    ## Corese ARGS  ##
    ##################

    CORESE_QUERY_FULL=${CORESE_QUERY:-"SELECT ?S ?P ?O { ?S ?P ?O . filter( !isBlank(?S) ) . filter( !isBlank(?O) )  } "}  
    # CORESE_QUERY_ONLY_INFERENCE=${CORESE_QUERY:-"SELECT ?S ?P ?O FROM kg:entailment WHERE { ?S ?P ?O . filter( !isBlank(?S) ) . filter( !isBlank(?O) ) } "} 
    CORESE_QUERY_ONLY_INFERENCE=${CORESE_QUERY:-"SELECT ?S ?P ?O WHERE { graph kg:entailment { ?S ?P ?O } FILTER NOT EXISTS { graph ?g { ?S ?P ?O } FILTER (?g != kg:entailment) } }"} 
         
    CORESE_EXCTRACT_ONLY_INFERENCE=${CORESE_EXCTRACT_ONLY_INFERENCE:-"false"}  
    
    # peek : nb file to load at same time
    # if peek <= 0  -> peek = nbFile in the folder 
    CORESE_PEEK=${CORESE_PEEK:-"-peek 6 "}

    
    CORESE_OUTPUT_EXTENSION=${CORESE_OUTPUT_EXTENSION:-"ttl"}
    
    CORESE_IGNORE_LINE_BREAK=${CORESE_IGNORE_LINE_BREAK:-""}
        
    # Size file = -f
    CORESE_FRAGMENT=${CORESE_FRAGMENT:-"-f 1000000 "}  
    # output Format ( default = ttl )
    CORESE_FORMAT=${CORESE_FORMAT:-"-F ttl "}
    # Write in the file on each flushCount
    CORESE_FLUSH_COUNT=${CORESE_FLUSH_COUNT:-"-flushCount 250000"}
    # Memory 
    CORESE_XMS=${CORESE_XMS:-"15g"}
    CORESE_XMX=${CORESE_XMX:-"15g"}
    
    if  [ "$CORESE_QUERY_FULL" != "$CORESE_QUERY_ONLY_INFERENCE" -a  "$CORESE_EXCTRACT_ONLY_INFERENCE" == "true" ]  ; then 
         CORESE_QUERY="$CORESE_QUERY_ONLY_INFERENCE"           
    else
         CORESE_QUERY="$CORESE_QUERY_FULL"
    fi                       
   
    ####################
    ## MAGIC_FILTER   ##
    ####################
    
    VAR_PART[0]='VAR_PART_CSV'
    VAR_PART[1]='VAR_PART_SQL'
    VAR_PART[2]='VAR_PART_SEMANTIC'
    
    DELIMITER_AT='@'
    DELIMITER_DDOT=':'
    DELIMITER_DDOT_EQ=':='
    DELIMITER_DIEZ_COMMENT='#'
    
    FILE_BINDER="DOI/magicFilter.txt"
    SPARQL_TEMPLATE="DOI/sparqlTemplate.txt"
    
    Magic_Filter_BINDER_SQL_INSTANCE="Magic_Filter_BINDER_SQL_INSTANCE.txt"
    Magic_Filter_BINDER_CSV_INSTANCE="Magic_Filter_BINDER_CSV_INSTANCE.txt"
     
    STRICT_MODE_FILTER=${STRICT_MODE_FILTER:-"FALSE"}
   
    # Reserved Words ( Inogred Params during Validation )
    RESERVED_PARAMETERS_WORDS=${RESERVED_PARAMETERS_WORDS:-"CLASS , SI, CSV, SELECT_VARS"}
   

    ##########################################
    ##########################################
 
    echo ; echo " CLASS VALUES --> [ $CLASS_VALUES ]"
 
    OIFS=$IFS
    IFS=";"
    ARRAY_CLASS_VALUES=($( TO_ARRAY "$CLASS_VALUES" ";" ))
    IFS=$OIFS

    ##########################################
    ##########################################    
    
    $SCRIPT_PATH/01_use_si.sh si=$WhichSI
     
    if [ -z "$WhichSI" ] ; then
            
        GET_SI="scripts/conf/SELECTED_SI_INFO"
       
        if [ ! -f $GET_SI ]  ; then
          echo
          echo -e "\e[91m Missing $GET_SI ! \e[39m "
          echo -e "\e[91m You can use the command [[ ./scripts/01_use_si.sh si=WhichSI ]] to set the var WhichSI ! \e[39m "         
        fi
        
        SI=$(head -1 $GET_SI)        
            
        if [ "$SI" == "" ] ; then  
          SI="$ROOT_PATH/SI" 
        fi
    else
       SI="$ROOT_PATH/SI/$WhichSI"     
    fi
      
    WORK_TMP="../work-tmp"
   
    ## Used for BACH PROCESSING
    TMP_OBDA_FOLDER="$WORK_TMP/obda_tmp"
        
    ## TRANSFERT TO USE SCRIT
    mkdir -p $TMP_OBDA_FOLDER/
        
    ## Specs Location 
    INPUT_SPEC="$SI/input"
         
    ## Temp Specs Folder
    INPUT_TEMP_SPEC="$WORK_TMP/input_tmp"
                  
    ## Output OBDA files 
    OUTPUT_OBDA="$SI/output/01_obda"
         
    DEFAULT_MAPPING_NAME="mapping.$EXTENSION_OBDA"
        
    ## Connexion 
    CONNECTION_FILE_PATTERN="$INPUT_SPEC/connexion/connexion"
    CONNECTION_FILE="$CONNECTION_FILE_PATTERN.$EXTENSION_SPEC"
                       
    OUTPUT_ONTOP="$SI/output/02_ontop"
    OUTPUT_ONTOP_FILE_NAME="ontopGen.ttl"

    OUTPUT_CORESE="$SI/output/03_corese/"

    SI_FILE="$SI/csv/$CSV_FILE_NAME"

    if [ ! -f "$SI_FILE" ] ; then
      echo
      echo -e "\e[91m --> CSV not found at path : $SI_FILE ! Abort \e[39m"
      echo
      EXIT
    fi
    
    FULL_PATH_VALIDATE_CSV_FILE="$SI/csv/$VALIDE_CSV_FILE_NAME"
    
    if [  -f "$FULL_PATH_VALIDATE_CSV_FILE" ] ; then
      echo
      echo -e "\e[91m --> remove the file : $FULL_PATH_VALIDATE_CSV_FILE \e[39m"
      rm -f "$FULL_PATH_VALIDATE_CSV_FILE"
      echo
    fi 
    
    # OUTPUT TEMP VALIDE CSV
    FULL_PATH_VALIDATE_CSV_FILE_TEMP="$WORK_TMP/$VALIDE_CSV_FILE_NAME"           

	
    chmod -R +x $SCRIPT_PATH/*
        
    # $SCRIPT_PATH/utils/check_commands.sh java curl psql-mysql mvn
        
    # $SCRIPT_PATH/12_docker_nginx.sh stop
    
    # $SCRIPT_PATH/12_docker_nginx.sh start
      
    $SCRIPT_PATH/05_init_si_data.sh "-a" "-f"
            
    $SCRIPT_PATH/11_nano_start_stop.sh stop
      
    $SCRIPT_PATH/03_extract_prefixs_from_owl.sh
            
    # $SCRIPT_PATH/02_build_config.sh  ip=$IP_HOST namespace=$NAME_SPACE rw=$Read_Write_Port ro=$Read_Only_Port # TO DELL

    OUTPUT_SHARED_DDR="$OUTPUT_ROOT/$WhichSI/shared"
    OUTPUT_DATA="$OUTPUT_ROOT/$WhichSI/DATA"
    OUTPUT_DATA_CSV="$OUTPUT_ROOT/$WhichSI/CSV"

    ONTOLGY_SOURCE="SI/ontology/ontology.owl"
    ONTOLGY_DESTINATION="$OUTPUT_ROOT/ontology"

    ############################
    ############################
    # COPY ONTOLOGY      #######
    # + Transform to ttl #######
    ############################
    ############################	
    
    if [[ ! -f  "$ONTOLGY_DESTINATION/ontology.ttl" ]] ; then
       
       $SCRIPT_PATH/05_init_si_data.sh "-a" 
       
       mkdir -p $ONTOLGY_DESTINATION
      
       ONTO_SPARQL_QUERY="SELECT ?S ?P ?O { ?S ?P ?O . filter( !isBlank(?S) ) . filter( !isBlank(?O) )  } "

       $SCRIPT_PATH/08_corese_infer.sh query="$ONTO_SPARQL_QUERY"               \
                                    peek=1                                      \
                                    fragment="-f 0"                             \
                                    format="$CORESE_FORMAT"                     \
                                    flushCount=10000                            \
                                    xms="$CORESE_XMS"                           \
                                    xmx="$CORESE_XMX"                           \
                                    extension="$CORESE_OUTPUT_EXTENSION"        \
                                    output="$ONTOLGY_DESTINATION/ontology.ttl"  \
                                    "$CORESE_IGNORE_LINE_BREAK"             
                                    
       $SCRIPT_PATH/05_init_si_data.sh "-a" 
                 
    fi   

    ############################
    ############################
    # DDR                #######
    ############################
    ############################	
    ## IF NOT ALREADY CREATED ##
    ## Process Only One time  ##
    ############################
   
    if [[ ! -d  "$OUTPUT_SHARED_DDR" ]] ; then
    
        for specs in `find $INPUT_SPEC/ -type d -name "*shared*" ` ;  do  
            
            # Copy Connexion File ( graphml ) [ Optionnal ]

            if [  -f "$CONNECTION_FILE"  ]; then
                cp -p $CONNECTION_FILE $INPUT_TEMP_SPEC
            fi

            for specs_ddr in `find $specs -type f -name "*.$EXTENSION_SPEC" ` ;  do 

            cp $specs_ddr $INPUT_TEMP_SPEC
                
            done

            # Check if $INPUT_SPEC Folder contains more than 0 file ( connexion.graphml included [ Optionnal ] )

            if [ `ls -l $INPUT_TEMP_SPEC --ignore=$(basename $CONNECTION_FILE) | egrep -c '^-'` -gt 0 ] ; then 
                
                #SPEC_FOLDER="$(dirname "$specs")"                     
                    
                if [ -f $specs/$CLASS_FILE ] ; then
                        
                LINE_ONE=$(head -n 1 $specs/$CLASS_FILE )                     
                LINE_TWO=$(sed -n '2p' $specs/$CLASS_FILE )
                        
                IFS=$'=' read -ra KEY_VALUE <<< "$LINE_ONE" 
                CLASS_VALUE=${KEY_VALUE[1]}
                IFS=$'=' read -ra KEY_VALUE <<< "$LINE_TWO" 
                DISCRIMINATOR_COLUMN=${KEY_VALUE[1]}
                    
                fi 	

                ##########################################################################
                ## MAGIC_FILTER_CSV ######################################################
                ##########################################################################

                if [ ! -f "$specs/$FILE_BINDER" ]; then              
                    echo
                    echo " No Magic_Filter Provided at : [$specs/$FILE_BINDER] "
                    echo " Continue ... "
                    echo
                    $SCRIPT_PATH/05_init_si_data.sh "-output" "-tmp"
                    continue 
                fi 
              
                ## Call Build Parameters Ignoring CLASS and SI     
                echo ; echo " Reserved Parameters Words ( Ignored Params Validation ) --> $RESERVED_PARAMETERS_WORDS" 
                echo         
                BUILD_PARAMETERS_FROM_QUERY "$QUERY" "$specs/$FILE_BINDER" "$RESERVED_PARAMETERS_WORDS"              
                
                echo " SQL_MATCHER -->  $PART_VALUES_SQL"
                
                echo "$PART_VALUES_SQL" > "$WORK_TMP/$Magic_Filter_BINDER_SQL_INSTANCE"
                PART_VALUES_SQL=""

                if [  -f "$WORK_TMP/$Magic_Filter_BINDER_SQL_INSTANCE"  ]; then
                 INSTANCE_MAGIC_FILTER="magicFilterFile=$WORK_TMP/$Magic_Filter_BINDER_SQL_INSTANCE"
                fi
            
                $SCRIPT_PATH/06_gen_mapping.sh input="$INPUT_TEMP_SPEC"                     \
                                               output="$OUTPUT_OBDA/$DEFAULT_MAPPING_NAME"  \
                                               ext=".$EXTENSION_SPEC"                       \
                                               connecFileName="$CONNEC_FILE_NAME"           \
                                               $INSTANCE_MAGIC_FILTER                       \
                                               version=$YED_GEN_ONTOP_VERSION 

                # FOR EACH OBDA MAPPING GENERATED FROM SPEC - obdaMapping in `find $OUTPUT_OBDA/* -type f `

                for obdaMapping in ` find $OUTPUT_OBDA -type f -name "*.$EXTENSION_OBDA" ` ; do
                
                # for obdaMapping in ` ls -p $OUTPUT_OBDA | grep -v / ` ; do
                
                echo ;  echo " --> Treat OBDA File  -  $obdaMapping " ; echo
                                    
                cp -rf $obdaMapping $TMP_OBDA_FOLDER/

                mv $TMP_OBDA_FOLDER/$(basename $obdaMapping) $TMP_OBDA_FOLDER/$DEFAULT_MAPPING_NAME

                $SCRIPT_PATH/07_ontop_gen_triples.sh obda="$TMP_OBDA_FOLDER/$DEFAULT_MAPPING_NAME"    \
                                                     query="$ONTOP_QUERY"                             \
                                                     ttl="$ONTOP_TTL_FORMAT"                          \
                                                     batch="$ONTOP_BATCH"                             \
                                                     pageSize="$ONTOP_PAGE_SIZE"                      \
                                                     fragment="$ONTOP_FRAGMENT"                       \
                                                     flushCount="$ONTOP_FLUSH_COUNT"                  \
                                                     merge="$ONTOP_MERGE"                             \
                                                     xms="$ONTOP_XMS"                                 \
                                                     xmx="$ONTOP_XMX"                                 \
                                                     output="$OUTPUT_ONTOP/$OUTPUT_ONTOP_FILE_NAME"   \
                                                     connection="$SI/$CONNEC_FILE_NAME"               \
                                                     log_level="$ONTOP_LOG_LEVEL"                     \
						     must_not_be_empty="$MUST_NOT_BE_EMPTY_NODES"     \
                                                     "$ONTOP_NOT_OUT_ONTOLOGY" "$ONTOP_OUT_ONTOLOGY"  \
						     "$ONTOP_DEBUG" 
                        
                CURRENT_DATE_TIME_SHARED=`date +%d_%m_%Y__%H_%M_%S`
                    
                if [[ ! -d  "$OUTPUT_SHARED_DDR/$CURRENT_DATE_TIME_SHARED" ]] ; then
                    mkdir -p $OUTPUT_SHARED_DDR/$CURRENT_DATE_TIME_SHARED
                fi                 
                rm -rf $OUTPUT_SHARED_DDR/$CURRENT_DATE_TIME_SHARED/*
                rm -rf $OUTPUT_SHARED_DDR/$CURRENT_DATE_TIME_SHARED/*.*

                if [ "$CORESE_EXCTRACT_ONLY_INFERENCE" == "true" ]  ; then 
                    echo
                    echo " - CORESE_EXCTRACT_ONLY_INFERENCE --> $CORESE_EXCTRACT_ONLY_INFERENCE "
                    echo
                    sleep 1
                fi

                $SCRIPT_PATH/08_corese_infer.sh query="$CORESE_QUERY"                               \
                                             peek="$CORESE_PEEK"                                    \
                                             fragment="$CORESE_FRAGMENT"                            \
                                             format="$CORESE_FORMAT"                                \
                                             flushCount="$CORESE_FLUSH_COUNT"                       \
                                             xms="$CORESE_XMS"                                      \
                                             xmx="$CORESE_XMX"                                      \
                                             extension="$CORESE_OUTPUT_EXTENSION"                   \
                                             output="$OUTPUT_SHARED_DDR/$CURRENT_DATE_TIME_SHARED/" \
                                             "$CORESE_IGNORE_LINE_BREAK" 
                                 
                if [ "$CORESE_EXCTRACT_ONLY_INFERENCE" == "true" ]  ; then 
                 # Then we need to copy the rest of already extracted triples 
                   mv $OUTPUT_ONTOP/*.* $OUTPUT_SHARED_DDR/$CURRENT_DATE_TIME_SHARED/  
                fi
                
                # Remove Duplicate Triples 
                $SCRIPT_PATH/15_deduplicator.sh from_directory="$OUTPUT_SHARED_DDR/$CURRENT_DATE_TIME_SHARED/" inplace ignoring_lines_from_file="$ONTOLGY_DESTINATION/*.*"

                $SCRIPT_PATH/05_init_si_data.sh "-output" "-tmp"

                sleep 0.5
                                            
                done
                
            fi
                
        done

    fi 
    
    ########################"
    ########################
    #  THE REST SPECS     ##
    ########################
    ########################
    
    $SCRIPT_PATH/05_init_si_data.sh "-a" 

    for specs in `find $INPUT_SPEC/* -type d -not -name '*connexion*'                      \
                                             -not -name '*shared*' -not -path "*/shared/*" \
                                             -not -name '*DOI*' -not -path "*/DOI/*" `;   do

       if [ ! -f "$specs/DOI/magicFilter.txt"  ]; then         
          continue 
       fi

       if [ `ls -l $specs | egrep -c '^-'` -gt 0 ] ; then           
         
          echo " + Treat Specs Folder --> $specs "

          # Copy Connexion File ( graphml ) [ Optionnal ]
              
          if [  -f $CONNECTION_FILE  ]; then
	          cp -p $CONNECTION_FILE $INPUT_TEMP_SPEC
          fi               
              
          # FOR EACH SPEC - Copy File by File from $specs folder to files $INPUT_TEMP_SPEC folder

          for spec in `find $specs/*.$EXTENSION_SPEC -type f `; do
              connecFileName=$CONNEC_FILE_NAME
              cp $spec $INPUT_TEMP_SPEC
              
          done

          # Check if $INPUT_SPEC Folder contains more than 0 files ( connexion.graphml included [ Optionnal ]) 
               
          if [ `ls -l $INPUT_TEMP_SPEC --ignore=$(basename $CONNECTION_FILE) | egrep -c '^-'` -gt 0 ] ; then 

              #SPEC_FOLDER="$(dirname "$specs")"                     
                    
              if [ -f $specs/$CLASS_FILE ] ; then
            
                 LINE_ONE=$(head -n 1 $specs/$CLASS_FILE )                     
                 LINE_TWO=$(sed -n '2p' $specs/$CLASS_FILE )
                       
                 __OIFS=$IFS
                 
                 IFS=$'=' read -ra KEY_VALUE <<< "$LINE_ONE" 
                 
                 CLASS=` echo -n ${KEY_VALUE[1]} | sed 's/^ *//;s/ *$// ' `
                 
                 IFS=$'=' read -ra KEY_VALUE <<< "$LINE_TWO" 
                 DISCRIMINATOR_COLUMN=${KEY_VALUE[1]}

                 IFS=';'
                 OK=$( MACTH_WORD_IN_ARRAY "$CLASS" ${ARRAY_CLASS_VALUES[@]} )                
                
                 echo ; echo " ++ [$CLASS]  --> $OK " ; echo                  

                 if [ "$OK" == "FALSE" ] ; then 
                 
                    echo " Ignore Class : [$CLASS]  " ; echo 
                    echo " ========================= "
                    echo "   PASSED VARIABLE CLASS : " 
                    
                    for element in "${ARRAY[@]}" ; do  
                       echo "   --> $element "
                    done   
                    
                    echo " ========================= "
                    
                    $SCRIPT_PATH/05_init_si_data.sh "-output" "-tmp"
                    
                    continue ;
                    
                 else
                    echo " Process The Class [$CLASS] " ; echo 
                 fi

                 IFS=$__OIFS
                 
              else              
                echo " No CLASS_FILE Found at Path : $specs/$CLASS_FILE  "                
              fi
    
              ## MAGIC_FILTER_CSV ######################################################                          
                            
              if [ ! -f "$specs/$FILE_BINDER" ]; then              
                  echo
                  echo " No Magic_Filter Provider at : [$specs/$FILE_BINDER] "
                  echo " Continue ... "
                  echo
                  $SCRIPT_PATH/05_init_si_data.sh "-output" "-tmp"
                  continue 
              fi 
              
              ## Call Build Parameters Ignoring CLASS and SI     
              echo ; echo " Reserved Parameters Words ( Ignored Params Validation ) --> $RESERVED_PARAMETERS_WORDS" 
              echo         
              BUILD_PARAMETERS_FROM_QUERY "$QUERY" "$specs/$FILE_BINDER" "$RESERVED_PARAMETERS_WORDS"
              
              echo " CSV_MATCHER      -->  $PART_VALUES_CSV_MATCHER"
              echo " SQL_MATCHER      -->  $PART_VALUES_SQL"
              echo " SEMANTIC_MATCHER -->  $PART_VALUES_SEMANTIC_MATCHER"

              echo "$PART_VALUES_SQL" > "$WORK_TMP/$Magic_Filter_BINDER_SQL_INSTANCE"
              echo "$PART_VALUES_CSV_MATCHER" > "$WORK_TMP/$Magic_Filter_BINDER_CSV_INSTANCE"
              
             ###############################################################################
             ###############################################################################
             ###############################################################################
             ###############################################################################
             ###############################################################################
             
              ## FILTER CSV ACCORDING REQUEST PARAMETER 
             
               ##  -1 -  PREFIX AND VALIDATE CSV FILE 
              
              echo
              echo -e "\e[94m --> Treat CSV : $SI_FILE \e[39m"
              echo
              sleep 0.5              
              
              $SCRIPT_PATH/04_corese_clone_valide_csv.sh csv="$SI_FILE"                                                     \
                                                         out="$FULL_PATH_VALIDATE_CSV_FILE_TEMP._Valide_With_Prefixes.csv"  \
                                                         csv_sep="$CSV_SEP"                                                 \
                                                         intra_separators="$INTRA_SEPARATORS"                               \
                                                         columns="$COLUMNS_TO_VALIDATE" 
       
             
              if [ ! -f "$FULL_PATH_VALIDATE_CSV_FILE_TEMP._Valide_With_Prefixes.csv" ]; then
                echo
                echo -e "\e[91m --> Error When validate CSV : $SI_FILE ! Abort \e[39m"
                echo
                EXIT
              fi  
              
              $SCRIPT_PATH/04_corese_clone_valide_csv.sh csv="$SI_FILE"                                             \
                                                         out="$FULL_PATH_VALIDATE_CSV_FILE_TEMP._With_Full_URI.csv" \
                                                         csv_sep="$CSV_SEP"                                         \
                                                         intra_separators="$INTRA_SEPARATORS"                       \
                                                         columns="$COLUMNS_TO_VALIDATE"                             \
                                                         -enable_full_uri                                           \
                                                         # -enable_uri_brackets 
           
              ## -2 -  FILTER CSV FILE 
              
              echo
              echo -e "\e[94m --> Filter CSV : $SI_FILE \e[39m"
              echo
              sleep 0.5             
              echo

              $SCRIPT_PATH/13_Csv_Filter.sh csv="$FULL_PATH_VALIDATE_CSV_FILE_TEMP._With_Full_URI.csv"               \
                                            outCsv="$FULL_PATH_VALIDATE_CSV_FILE_TEMP._Filtered_With_Full_URI.csv"   \
                                            csv_sep="$CSV_SEP"                                                       \
                                            match_sep=";"                                                            \
                                            intra_csv_sep="$INTRA_SEPARATORS"                                        \
                                            mirror_csv="$FULL_PATH_VALIDATE_CSV_FILE_TEMP._Valide_With_Prefixes.csv" \
                                            outFilteredMirrorCsv="$FULL_PATH_VALIDATE_CSV_FILE"                      \
                                            $PART_VALUES_CSV_MATCHER                                                 \
                                            $IGNORE_CASE_SENTITIVE_FITERING_VARIABLES

              if [ ! -f $FULL_PATH_VALIDATE_CSV_FILE ]; then
                echo
                echo -e "\e[91m --> EMPTY FILTERED CSV FILE FOR : $SI_FILE ! End Process \e[39m"
                echo
                continue 
              fi  
             
              ###############################################################################
              ###############################################################################
              ###############################################################################
             
              INSTANCE_MAGIC_FILTER=""
             
              if [  -f "$WORK_TMP/$Magic_Filter_BINDER_SQL_INSTANCE"  ]; then
                 INSTANCE_MAGIC_FILTER="magicFilterFile=$WORK_TMP/$Magic_Filter_BINDER_SQL_INSTANCE"
              fi
               
              $SCRIPT_PATH/06_gen_mapping.sh input="$INPUT_TEMP_SPEC"                    \
                                             output="$OUTPUT_OBDA/$DEFAULT_MAPPING_NAME" \
                                             csvFileName="$VALIDE_CSV_FILE_NAME"         \
                                             ext=".$EXTENSION_SPEC"                      \
                                             class="$CLASS"                              \
                                             column="$DISCRIMINATOR_COLUMN"              \
                                             connecFileName="$CONNEC_FILE_NAME"          \
                                             $INSTANCE_MAGIC_FILTER                      \
                                             version=$YED_GEN_ONTOP_VERSION  
          
              # FOR EACH OBDA MAPPING GENERATED FROM SPEC - obdaMapping in `find $OUTPUT_OBDA/* -type f `                    
            
              for obdaMapping in ` find $OUTPUT_OBDA -type f -name "*.$EXTENSION_OBDA" ` ; do # -printf "%f\n"
              
              # for obdaMapping in ` find $OUTPUT_OBDA -type f -name "*.$EXTENSION_OBDA" -printf "%f\n"` ; do
             
                 echo ;  echo " + Treat OBDA File -->  $obdaMapping " 
                           
                 cp -rf "$obdaMapping" "$TMP_OBDA_FOLDER/"
                       
                 mv $TMP_OBDA_FOLDER/$(basename $obdaMapping) $TMP_OBDA_FOLDER/$DEFAULT_MAPPING_NAME
            
                 
                 $SCRIPT_PATH/07_ontop_gen_triples.sh obda="$TMP_OBDA_FOLDER/$DEFAULT_MAPPING_NAME"   \
                                                      query="$ONTOP_QUERY"                            \
                                                      ttl="$ONTOP_TTL_FORMAT"                         \
                                                      batch="$ONTOP_BATCH"                            \
                                                      pageSize="$ONTOP_PAGE_SIZE"                     \
                                                      fragment="$ONTOP_FRAGMENT"                      \
                                                      flushCount="$ONTOP_FLUSH_COUNT"                 \
                                                      merge="$ONTOP_MERGE"                            \
                                                      xms="$ONTOP_XMS"                                \
                                                      xmx="$ONTOP_XMX"                                \
                                                      output=$OUTPUT_ONTOP/$OUTPUT_ONTOP_FILE_NAME    \
                                                      connection="$SI/$CONNEC_FILE_NAME"              \
                                                      log_level="$ONTOP_LOG_LEVEL"                    \
						      must_not_be_empty="$MUST_NOT_BE_EMPTY_NODES"    \
                                                      "$ONTOP_NOT_OUT_ONTOLOGY" "$ONTOP_OUT_ONTOLOGY" \
                                                      "$ONTOP_DEBUG"
                                                   
            
                 SPARQL_FILE_PATH=$(dirname "${spec}")/$SPARQL_FILE_NAME            
                 
                 CURRENT_DATE_TIME=`date +%d_%m_%Y__%H_%M_%S`
              
                       
                 _CLASS=` echo "$CLASS" | sed 's/  */ /g' | xargs | sed 's/ /_/g' `           
              
                 NUM_LINE=`basename "$obdaMapping" | sed 's/'.$EXTENSION_OBDA.*'//'  | sed 's/mapping_CSV_//g'  |  sed 's/_.*$//' `
                 VARIABLE=`basename "$obdaMapping" | sed 's/.'$EXTENSION_OBDA'.*$//' | sed 's/.*mapping_CSV_//' | sed 's/_.*//'  `
                 PART=`basename "$obdaMapping" | sed 's/.'$EXTENSION_OBDA'.*$//' | sed 's/.*mapping_CSV_//' | sed 's/.*_\([0-9]*\).*/\1/' `

                 if [ "$PART" == "$VARIABLE" ] ; then 
                     PART=""
                 fi  

                 if [ "$PART" == "" ] ; then 
                     PART=""
                 else
                     PART="_"$PART
                 fi

                 echo 
                 echo " Treat SUB_VARIABLE : $VARIABLE / NUM_LINE : $NUM_LINE / PART : $PART "
                 echo 

                 if [[ ! -d  "$OUTPUT_DATA/$_CLASS/$NUM_LINE'_'$VARIABLE/$VARIABLE$PART" ]] ; then
                    mkdir -p $OUTPUT_DATA/$_CLASS/$NUM_LINE"_"$VARIABLE/$VARIABLE$PART
                 fi                 
                 rm -rf $OUTPUT_DATA/$_CLASS/$NUM_LINE"_"$VARIABLE/$VARIABLE$PART/*
                 rm -rf $OUTPUT_DATA/$_CLASS/$NUM_LINE"_"$VARIABLE/$VARIABLE$PART/*.*
                 
                            
                 if [ "$CORESE_EXCTRACT_ONLY_INFERENCE" == "true" ] ; then 
                   echo
                   echo " - CORESE_EXCTRACT_ONLY_INFERENCE --> $CORESE_EXCTRACT_ONLY_INFERENCE "
                   echo
                   sleep 1
                 fi
                
                 $SCRIPT_PATH/08_corese_infer.sh query="$CORESE_QUERY"                                             \
                                                 peek="$CORESE_PEEK"                                               \
                                                 fragment="$CORESE_FRAGMENT"                                       \
                                                 format="$CORESE_FORMAT"                                           \
                                                 flushCount="$CORESE_FLUSH_COUNT"                                  \
                                                 xms="$CORESE_XMS"                                                 \
                                                 xmx="$CORESE_XMX"                                                 \
                                                 extension="$CORESE_OUTPUT_EXTENSION"                              \
                                                 output=$OUTPUT_DATA/$_CLASS/$NUM_LINE"_"$VARIABLE/$VARIABLE$PART/ \
                                                 "$CORESE_IGNORE_LINE_BREAK"

                 if  [ "$CORESE_EXCTRACT_ONLY_INFERENCE" == "true" ]    ;   then 
                    # Then we need to copy the rest of already extracted triples 
                    echo " Copy [$OUTPUT_ONTOP/*.*]  TO [$OUTPUT_DATA/$_CLASS/$NUM_LINE"_"$VARIABLE/$VARIABLE$PART/] "
                    mv $OUTPUT_ONTOP/*.* $OUTPUT_DATA/$_CLASS/$NUM_LINE"_"$VARIABLE/$VARIABLE$PART/
                 fi
    
                 # Remove Duplicate Triples 
                 $SCRIPT_PATH/15_deduplicator.sh from_directory="$OUTPUT_DATA/$_CLASS/$NUM_LINE"_"$VARIABLE/$VARIABLE$PART/" inplace ignoring_lines_from_file="$ONTOLGY_DESTINATION/*.*"
                  
                 $SCRIPT_PATH/05_init_si_data.sh "-output" "-tmp" 
                        
                 sleep 0.5

                 # TEST IF SELECT_VARS ENABLE ---

                 EXTRACT_VALUES_FROM_LINE "SELECT_VARS" "$QUERY"

                 $SCRIPT_PATH/11_nano_start_stop.sh stop
                 
                 if [[ ! -z "$RESULT" ]]; then

                    SELECT=`echo "$RESULT" | sed 's/;/,/g' `
                    echo
                    echo " SELECT_VARS -> $SELECT " ;
                    echo

                    $SCRIPT_PATH/14_Sparql_Filter_Instancier.sh inSparqlTemplateFile="$specs/$SPARQL_TEMPLATE"                   \
                                                                outSparqlInstancelFile="$WORK_TMP/$Magic_Filter_SPARQL_INSTANCE" \
                                                                selectVars="$SELECT"                                             \
                                                                filters="$PART_VALUES_SEMANTIC_MATCHER"   

                    $SCRIPT_PATH/02_build_config.sh  ip=$IP_HOST namespace=$NAME_SPACE rw=$Read_Write_Port ro=$Read_Only_Port 
                    
                    $SCRIPT_PATH/11_nano_start_stop.sh start rw 12 12 28

                    # Load ontology 
                    if [ ! -d "$ONTOLGY_DESTINATION" ] ; then
                       echo " [$ONTOLGY_DESTINATION] not found ! "
                       EXIT
                    fi
                    $SCRIPT_PATH/09_load_data.sh from_directory="$ONTOLGY_DESTINATION" \
                                                 content_type="text/turtle"
                    # Load DDR
                    if [ ! -d "$OUTPUT_SHARED_DDR/" ] ; then
                       echo " [$OUTPUT_SHARED_DDR/] not found ! "
                       EXIT
                    fi
                    $SCRIPT_PATH/09_load_data.sh from_directory="$OUTPUT_SHARED_DDR/" \
                                                 content_type="text/turtle"
                    #Load Data 
                    if [ ! -d "$OUTPUT_DATA/$_CLASS/$NUM_LINE"_"$VARIABLE/$VARIABLE$PART" ] ; then
                       echo " [$OUTPUT_DATA/$_CLASS/$NUM_LINE"_"$VARIABLE/$VARIABLE$PART] not found ! "
                       EXIT
                    fi
                    $SCRIPT_PATH/09_load_data.sh from_directory="$OUTPUT_DATA/$_CLASS/$NUM_LINE"_"$VARIABLE/$VARIABLE$PART" \
                                                 content_type="text/turtle"
    
                    if [[ ! -d  "$OUTPUT_DATA_CSV/$_CLASS/$NUM_LINE"_"$VARIABLE/$VARIABLE$PART" ]] ; then
                      mkdir -p $OUTPUT_DATA_CSV/$_CLASS/$NUM_LINE"_"$VARIABLE/$VARIABLE$PART
                    fi  

                    $SCRIPT_PATH/10_queryer.sh query_path="$WORK_TMP/$Magic_Filter_SPARQL_INSTANCE"                            \
                                               output="$OUTPUT_DATA_CSV/$_CLASS/$NUM_LINE"_"$VARIABLE/$VARIABLE$PART/data.csv" \
                                               accept="text/csv" # "text/tab-separated-values" 
                    
                    $SCRIPT_PATH/11_nano_start_stop.sh stop

                 else
                   echo " SELECT_VARS DISABLED " ;
                 fi
                 
              done                     
                         
              $SCRIPT_PATH/05_init_si_data.sh -a
                    
          fi
                                      
       fi
            
    done   
     
    # $SCRIPT_PATH/12_docker_nginx.sh stop

    $SCRIPT_PATH/05_init_si_data.sh -a -f
         
    # $SCRIPT_PATH/02_build_config.sh  ip=$IP_HOST namespace=$NAME_SPACE rw=$Read_Write_Port ro=$Read_Only_Port 
         
    # $SCRIPT_PATH/11_nano_start_stop.sh start rw 12 12 28
         
    # $SCRIPT_PATH/09_load_data.sh $SI/output/04_synthesis/ application/rdf+xml
         
    $SCRIPT_PATH/11_nano_start_stop.sh stop
                  
    # $SCRIPT_PATH/11_nano_start_stop.sh start ro 12 12 28
  
    ## read -rsn1

 
    echo
    echo " COBY EXTRACTION FINISHED "
    echo

