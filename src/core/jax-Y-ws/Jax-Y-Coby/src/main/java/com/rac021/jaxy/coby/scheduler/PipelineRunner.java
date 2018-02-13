
package com.rac021.jaxy.coby.scheduler;

/**
 *
 * @author ryahiaoui
 */

import java.io.IOException ;
import java.io.BufferedReader ;
import java.io.InputStreamReader ;
import java.util.concurrent.Callable ;
 

public class PipelineRunner implements Callable {
 
    private final String LOGGER_FILE  ;
    private final String COBY_PIPELINE ;
    private final String QUERY ;
 
    private final int CRUNCHIFY_RUN_EVERY_M_SECONDS;
    
    public static Process process ;
      
	public PipelineRunner( String coby_ipeline ,
                               String query        , 
                               String logger_file  , 
                               int crunchify_run_every_m_seconds ) {
            
            this.COBY_PIPELINE = coby_ipeline ;
            this.QUERY         = query        ;
            this.LOGGER_FILE   = logger_file  ;
            this.CRUNCHIFY_RUN_EVERY_M_SECONDS = crunchify_run_every_m_seconds ;
	}
 
 
        @Override
	public Integer call() {
			
               /* CALL PIPELINE --> */
               
                if( QUERY == null || QUERY.isEmpty() ) return 21 ;
                     
                try {
                       if ( InOut.existFile(LOGGER_FILE) ) {
                           InOut.clearFile(LOGGER_FILE)  ;
                       } else {
                           InOut.createFile(LOGGER_FILE)  ;
                       }
                       
                       String[] cmd = new String[] { "bash" ,COBY_PIPELINE ,
                                                      QUERY } ;
                        Runtime run = Runtime.getRuntime();
                        process = run.exec(cmd);

                        BufferedReader buf = new BufferedReader(new InputStreamReader(process.getInputStream()));
                        String line = "";
                        
                        while ((line=buf.readLine())!=null) {                           
                            InOut.writeTextFile(line + "\n", LOGGER_FILE )  ;                           
                            Thread.sleep(this.CRUNCHIFY_RUN_EVERY_M_SECONDS) ;
                        }
                        process.waitFor();
                        process.destroy();

                } catch (IOException | InterruptedException x) {
                    System.err.println(" PipelineRunner Interrupted ");
                    return 1 ;
                 }
            
             return 0 ;
        }
        
		
}
