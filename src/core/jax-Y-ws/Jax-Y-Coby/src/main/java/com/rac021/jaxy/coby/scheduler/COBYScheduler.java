

package com.rac021.jaxy.coby.scheduler ;

import java.util.List ;
import javax.ejb.Startup ;
import javax.ejb.Schedule ;
import javax.ejb.DependsOn ;
import javax.ejb.Singleton ;
import javax.inject.Inject ;
import java.util.ArrayList ;
import java.util.concurrent.Future ;
import java.util.concurrent.TimeUnit ;
import javax.annotation.PostConstruct ;
import com.rac021.jaxy.coby.io.Writer ;
import java.util.concurrent.ThreadPoolExecutor ;
import java.util.concurrent.LinkedBlockingQueue ;
import com.rac021.jaxy.coby.checker.TokenManager ;
import com.rac021.jaxy.coby.service.configuration.CobyConfiguration ;

/**
 *
 * @author ryahiaoui
 */
@Singleton
@Startup
@DependsOn(value="CobyConfiguration")

public class COBYScheduler {
    
    @Inject 
    CobyConfiguration configuration       ;
    
    public static int MAX_EXTRACTIONS = 1 ;
    
    public static final ThreadPoolExecutor executorService = new ThreadPoolExecutor( 1                            , 
                                                                                     1                            , 
                                                                                     60L                          , 
                                                                                     TimeUnit.SECONDS             , 
                                                                                     new LinkedBlockingQueue(1) ) ;
    public static  List<String>   JOBS                       ; 
   
    public static Future<Integer> SUBMITTED_JOB              ;
    
    public static String          jobOwner  =  null          ;

    @PostConstruct
    public void method() {
        JOBS = new ArrayList<>()                                     ;
        MAX_EXTRACTIONS = configuration.getTotalExtractionsPerUser() ;
        System.out.println(" Wating for process ")                   ;
        System.out.println(" Interval time -> " +  configuration.getFrequencyUpdateTimeMs() + " ( ms ) ") ;
        System.out.println(" Total Extraction per User -> " +  MAX_EXTRACTIONS                          ) ;
    }
    
    @Schedule(persistent = false, second = "*/5", minute = "*", hour = "*", info = " Coby Jobs Processor " )  
    public void popQuery() throws Exception {
        
       if( ! Writer.existFile( configuration.getCobyPipelineScript()) )      {
           
           System.out.println(" The Script [" + 
                  configuration.getCobyPipelineScript()+ "] + Not found ! ") ;
       }
       
       else if( ! JOBS.isEmpty() )   {
         
             if ( executorService.getActiveCount() == 0 )  {
       
                   String query = JOBS.get(0)                     ;

                   String login =  TokenManager.getLogin( query ) ;

                   if ( Writer.getTotalDirectories( TokenManager.buildOutputFolder( configuration.getOutputDataFolder() , 
                                                                                    login )  )  < MAX_EXTRACTIONS )     {
                        JOBS.remove(0)                                                                                                     ;
                        
                        jobOwner = login                                                                                                   ;
                        
                        SUBMITTED_JOB = executorService.submit(new PipelineRunner( configuration.getCobyPipelineScript()                   , 
                                                                                   query                                                   , 
                                                                                   TokenManager.builPathLog( configuration.getLoggerFile() , 
                                                                                                             login ) ,
                                                                                   configuration.getFrequencyUpdateTimeMs() )           )  ;
                        /* Wait for processing */
                        SUBMITTED_JOB.get() ;
                        jobOwner  =   null  ;
                   }
                   else if ( query != null ) {
                       /* Rotate Job */
                       JOBS.remove(0)        ;
                       JOBS.add( query )     ;
                   }
             }
       }
    }
    
}
