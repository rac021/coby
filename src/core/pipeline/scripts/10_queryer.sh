#!/bin/bash

 # Accept Examples :
 #   application/sparql-results+xml
 #   application/sparql-results+json, application/json
 #   application/x-binary-rdf-results-table
 #   text/tab-separated-values
 #   text/csv


  CURRENT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
  cd $CURRENT_PATH
    
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
               
                    ("query_path")   QUERY_PATH=$VALUE                    
                    ;;
                    ("output")       OUTPUT=$VALUE
                    ;;                    
                    ("accept")       ACCEPT=$VALUE
                    ;;
                    ("ip")           IP=$VALUE
                    ;;
                    ("port")         PORT=$VALUE
                    ;;      
                    ("namespace")    NAMESPACE=$VALUE    
               esac
	     ;;
         help)  echo
                echo " Total Arguments : SIX                                                            "
                echo 
                echo "   query_path= :  SPARQL_QUERY_FILE_PATH                                          "
                echo "   output=     :  Output Result File                                              "
                echo "   accept=     :  Accept Type : text/csv                                          "
                echo "                                text/tab-separated-values                         "
                echo "                                application/sparql-results+json, application/json "
                echo "   ip=         :  IP Sparql Endpoint                                              "
                echo "   port=       :  Port Sparql Endpoint                                            "
                echo "   namespace=  :  namespace                                                       "
                echo
                EXIT ;
     esac
     
     shift
     
  done   
  

  if [ ! -f $QUERY_PATH ]  ; then
    echo
    echo -e "\e[91m Missing  $QUERY_PATH  ! \e[39m "
    EXIT
  fi

  
  if [[ ( -z ${IP} ) || ( -z ${PORT} ) || ( -z ${NAMESPACE} ) ]] ; then 
  
     NANO_END_POINT_FILE="$CURRENT_PATH/conf/nanoEndpoint"
     LINE=$(head -1 $NANO_END_POINT_FILE)
    
     IFS=$' \t\n' read -ra INFO_NANO <<< "$LINE" 
     
     _IP=${INFO_NANO[0]}
     _NAMESPACE=${INFO_NANO[1]}
     _PORT=${INFO_NANO[2]}     
      
     IP=${IP:-$_IP}
     NAMESPACE=${NAMESAPCE:-$_NAMESPACE}
     PORT=${PORT:-$_PORT}      
    
  fi  

  PREFIX_ENDPOINT="http://$IP:$PORT"
  SUFFIX_ENDPOINT="blazegraph/namespace/$NAMESPACE/sparql"
  
  ENDPOINT=$PREFIX_ENDPOINT/$SUFFIX_ENDPOINT
  
  # Test connexion to NAMESAPCE 
  check="cat < /dev/null > /dev/tcp/http://$IP/$PORT"
      
  echo ; echo -e " Try connection : $ENDPOINT "
        
  TRYING=100
  COUNT=0
        
  timeout 1 bash -c "cat < /dev/null > /dev/tcp/$IP/$PORT" 2> /dev/null
        
  OK=$?
        
  while [ $OK -ne 0 -a $COUNT -lt $TRYING  ] ; do
        
    timeout 1 bash -c "cat < /dev/null > /dev/tcp/$IP/$PORT" 2> /dev/null
           
    OK=$?
           
    if [ $COUNT == 0 ] ; then echo ; fi 
           
    if [ $OK == 1 ] ; then 
             
      echo " .. "
      sleep 0.4 
             
    elif [ $OK != 0 ] ; then 
          
      echo " attempt ( $COUNT ) : Try again.. "
      sleep 0.8
             
    fi
           
    let "COUNT++"
           
    if [ $COUNT == $TRYING ] ; then
          
      echo
      echo -e "\e[31m ENDPOINT $ENDPOINT Not reachable !! \e[39m"
      echo
      EXIT
             
    fi
           
  done
        
  RES=`curl -s -I $ENDPOINT | grep HTTP/1.1 | awk {'print $2'}`
        
  COUNT=0
        
  while  [ -z $RES ] || [ $RES -ne 200 ] ;do
        
    sleep 1
    
    RES=`curl -s -I $ENDPOINT | grep HTTP/1.1 | awk {'print $2'}`
    
    let "COUNT++" 
    
    if  [ -z $RES ] || [ $RES -ne 200 ]  ; then 
    
        if [ `expr $COUNT % 3` -eq 0 ] ; then
              echo -e " attempt to contact $ENDPOINT .. "
        fi
    fi
           
  done
       
  echo " Yeah Connected !! "
  
  tput setaf 2
  echo 
  echo -e " ######################################################## "
  echo -e " ######## Info Queryer ################################## "
  echo -e " -------------------------------------------------------- "
  echo -e " \e[90m$0       \e[32m                                    "
  echo
  echo -e " # ENDPOINT   : $PREFIX_ENDPOINT                          "
  echo -e " # NAMESAPCE  : $NAMESPACE                                "
  echo -e " # QUERY_PATH : $QUERY_PATH                               "
  echo -e " # OUTPUT     : $OUTPUT                                   "
  echo -e " # ACCEPT     : $ACCEPT                                   "
  echo
  echo -e " ######################################################## "
  echo 
  sleep 1
  tput setaf 7
     

  if [ ! -f $QUERY_PATH ]  ; then
      echo
      echo -e "\e[91m Missing $QUERY_PATH ! \e[39m "
      EXIT
  fi
        
  QUERY=`cat $QUERY_PATH`
  
  # curl -X POST $ENDPOINT/namespace/$NAMESPACE/sparql --data-urlencode 'includeInferred=false' \
  #      --data-urlencode 'query= '"$QUERY"' ' -H 'Accept:text/rdf+n3' > $OUTPUT 
  
    curl -X POST $ENDPOINT/namespace/$NAMESPACE/sparql --data-urlencode 'includeInferred=false' \
          --data-urlencode 'query= '"$QUERY"' ' -H 'Accept:'"$ACCEPT"' ' > $OUTPUT 
  
  echo ; echo 

  portail_query='
  
    PREFIX : <http://www.anaee-france.fr/ontology/anaee-france_ontology#> 
    PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> 
    PREFIX oboe-core: <http://ecoinformatics.org/oboe/oboe.1.0/oboe-core.owl#> 
    PREFIX oboe-standard: <http://ecoinformatics.org/oboe/oboe.1.0/oboe-standards.owl#>
    PREFIX oboe-temporal: <http://ecoinformatics.org/oboe/oboe.1.0/oboe-temporal.owl#>
    PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
  
  	SELECT ?infraName
  	       ?site 
  	       ?anaeeSiteName
  	       ?localSiteName 
  	       ?siteType 
  	       ?siteTypeName 
  	       ?category 
  	       ?categoryName
  	       ?variable 
  	       ?anaeeVariableName
  	       ?localVariableName 
  	       ?unit 
  	       ?anaeeUnitName
  	       ?year 
  	       ?nbData 
  	          
  	WHERE  {  
      		    
		?idVariableSynthesis   a                     :Variable            .			    
		?idVariableSynthesis  :ofVariable            ?variable            .
		
                ?idVariableSynthesis  :hasCategory           ?category            .
                ?idVariableSynthesis  :hasLocalVariableName  ?localVariableName   .
                
		?variable             :hasAnaeeVariableName  ?anaeeVariableName   .
		?idVariableSynthesis  :hasUnit               ?unit                .
			 
		?unit                 :hasAnaeeUnitName      ?anaeeUnitName       .
			     
		?category             :hasCategoryName       ?categoryName        .
		?idVariableSynthesis  :hasSite               ?site                .
		?site	              :hasLocalSiteName      ?localSiteName       . 
		?site		      :hasAnaeeSiteName      ?anaeeSiteName       .           
		?site		      :hasSiteType           ?siteType            .
		?site		      :hasSiteTypeName       ?siteTypeName        .
		?site		      :hasInfra              ?infra               .
		?infra                :hasInfraName          ?infraName           .
		?idVariableSynthesis  :hasNbData             ?nbData              .
		?idVariableSynthesis  :hasYear               ?year                .
  }
  		    
  ORDER BY ?site ?year  '


