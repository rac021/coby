
package com.rac021.jaxy.coby.service.configuration ;

import javax.ejb.Lock ;
import javax.ejb.Startup ;
import javax.ejb.LockType ;
import javax.ejb.Singleton ;
import java.util.Properties ;
import java.util.logging.Level ;
import java.io.FileInputStream ;
import java.util.logging.Logger ;
import javax.annotation.PostConstruct ;

/**
 *
 * @author ryahiaoui
 */

@Singleton
@Startup
 @Lock(LockType.READ)
public class CobyConfiguration {
 
    private final String configFile = "coby_config.properties" ; 
    
    private       String loggerFile                = null ;

    private       String cobyPipelineScript        = null ;

    private       String cobyIs                    = null ;
    
    private       String csvSep                    = null ;
   
    private       String outputDataFolder          = null ;
    
    private       Integer columnVariableAnaeeName  = null ;
    
    private       Integer columnVariableLocalName  = null ;
    
    private       Integer columnVariableCategories = null ;
  
    private       int     totalExtractionsPerUser  = 1    ;
    
    private int           frequencyUpdateTimeMs     = 1   ;
    
    @PostConstruct
    public void init() {
        
        Properties prop = new Properties();
	
	try ( FileInputStream input = new FileInputStream(configFile) )  {
          
          prop.load(input) ;
          
          cobyPipelineScript       = prop.getProperty("coby_script").replaceAll(" +", " ").trim() ;
          
          loggerFile               = prop.getProperty("logger_file").replaceAll(" +", " ").trim() ;  
          
          frequencyUpdateTimeMs    = Integer.parseInt( prop.getProperty("frequency_logs_update_time_ms" )
                                                           .replaceAll(" +", " ").trim())         ;
          
          cobyIs                   = prop.getProperty("coby_is").replaceAll(" +", " ").trim()     ; 
          
          csvSep                   = prop.getProperty("csv_sep").replaceAll(" +", " ").trim()     ;
          
          outputDataFolder         = prop.getProperty("coby_output_data_folder")
                                                                    .replaceAll(" +", " ").trim() ; 
          
          columnVariableAnaeeName  = Integer.parseInt(prop.getProperty("column_variable_anaee_name")
                                                          .replaceAll(" +", " ").trim())  ;
          
          columnVariableLocalName  = Integer.parseInt(prop.getProperty("column_variable_local_name")
                                                          .replaceAll(" +", " ").trim())  ;
          
          columnVariableCategories = Integer.parseInt(prop.getProperty("column_variable_local_name")
                                                         .replaceAll(" +", " ").trim())  ;
          
          totalExtractionsPerUser  = Integer.parseInt(prop.getProperty("total_extractions_per_user")
                                                          .replaceAll(" +", " ").trim())  ;
          
          System.out.println("                                                            "              ) ;
          System.out.println(" COBY CONFIGURATION  ************************************** "              ) ;
          System.out.println("                                                            "              ) ;
          System.out.println("     -->  cobyIs  = " + cobyIs                                             ) ;
          System.out.println("     -->  coby_script               = " + cobyPipelineScript               ) ;
          System.out.println("     -->  outputDataFolder          = " + outputDataFolder                 ) ;
          System.out.println("     -->  loggerFile                = " + loggerFile                       ) ;
          System.out.println("     -->  frequencyUpdateTimeMs     = " + frequencyUpdateTimeMs + " ( ms )") ;
          System.out.println("     -->  columnVariable_AnaeeName  = " + columnVariableAnaeeName          ) ;
          System.out.println("     -->  columnVariable_LocalName  = " + columnVariableLocalName          ) ;
          System.out.println("     -->  csv_Sep                   = " + csvSep                           ) ;
          System.out.println("     -->  totalExtractionsPerUser   = " + totalExtractionsPerUser          ) ;
          System.out.println("                                                            "              ) ;
          System.out.println(" ********************************************************** "              ) ;
               
	} catch( Exception ex ) {
            Logger.getLogger(CobyConfiguration.class.getName()).log(Level.SEVERE, null, ex) ;
            System.exit(2) ;
        }
    }

    public String getLoggerFile() {
        return loggerFile ;
    }

    public String getCobyPipelineScript() {
        return cobyPipelineScript ;
    }

    public int getFrequencyUpdateTimeMs() {
        return frequencyUpdateTimeMs ;
    }

    public String getCobyIs() {
        return cobyIs ;
    }

    public String getCsvSep() {
        return csvSep ;
    }

    public Integer getColumnVariableAnaeeName() {
        return columnVariableAnaeeName ;
    }

    public Integer getColumnVariableLocalName() {
        return columnVariableLocalName ;
    }

    public String getOutputDataFolder() {
        return outputDataFolder ;
    }

    public int getTotalExtractionsPerUser() {
        return totalExtractionsPerUser ;
    }

    public Integer getColumnVariableCategories() {
        return columnVariableCategories;
    }
    
}
