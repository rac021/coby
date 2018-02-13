

package com.rac021.jaxy.coby.scheduler;

import java.io.File ;
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
import com.rac021.jax.api.exceptions.BusinessException ;
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
    CobyConfiguration configuration ;
    
    public static final ThreadPoolExecutor executorService = new ThreadPoolExecutor(1, 1, 60L, TimeUnit.SECONDS, new LinkedBlockingQueue(1));
       
    public static  List<String> JOBS  ; 
   
    public static Future<Integer> SUBMITTED_JOB ;
    
    @PostConstruct
    public void method() {
        JOBS = new ArrayList<>() ;
        System.out.println(" Wating for process ") ;
        System.out.println(" Interval time -> " +  configuration.getFrequencyUpdateTimeMs() + " ( ms ) ") ;
    }
    
    @Schedule(persistent = false, second = "*/5", minute = "*", hour = "*", info = " Coby Jobs Processor " )  
    public void popQuery() {
        
       if( ! Writer.existFile( configuration.getCobyPipeline() ) ) {
           
           System.out.println(" The Script [" + 
                  configuration.getCobyPipeline() + "] + Not found ! ") ;
           
       }
       else if (  executorService.getActiveCount() == 0 ) {
       
         try {
             
            if ( isEmptyFolder( configuration.getOutputDataFolder())) {
         
                if( ! JOBS.isEmpty() ) {
       
                     String query = JOBS.get(0) ;
                     JOBS.remove(0)             ;

                     SUBMITTED_JOB = executorService.submit(new PipelineRunner( configuration.getCobyPipeline() , 
                                                                                query         , 
                                                                                configuration. getLoggerFile()   , 
                                                                                configuration.getFrequencyUpdateTimeMs() ) ) ;
                     /* Wait for processing */
                     SUBMITTED_JOB.get() ;
                 } 
              }
         }  catch (Exception ex) {
              System.err.println(" Job Canceled ... " + ex.getMessage() ) ;
         } 
       }
       
    }
                    
    public static boolean isEmptyFolder(String outputDataFolder) throws BusinessException {
       File file = new File(outputDataFolder) ;
       if(file.isDirectory()){
         return file.list().length == 0 ;
       } else {
           throw new BusinessException("\n [ + " + outputDataFolder + " ] is not a valid Directory \n ") ;
       } 
    }
    
}
