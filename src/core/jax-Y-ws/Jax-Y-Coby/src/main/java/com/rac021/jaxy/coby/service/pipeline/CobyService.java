
package com.rac021.jaxy.coby.service.pipeline ;

/**
 *
 * @author ryahiaoui
 */

import javax.ws.rs.GET ;
import javax.inject.Inject ;
import javax.ws.rs.Produces ;
import javax.ws.rs.HeaderParam ;
import javax.ws.rs.core.UriInfo ;
import javax.ws.rs.core.Context ;
import java.net.URLDecoder ;
import javax.ws.rs.core.Response ;
import javax.annotation.PostConstruct ;
import com.rac021.jax.api.crypto.CipherTypes ;
import java.io.UnsupportedEncodingException ;
import com.rac021.jax.api.exceptions.BusinessException ;
import com.rac021.jax.api.qualifiers.ResourceRegistry ;
import com.rac021.jax.api.qualifiers.security.Policy ;
import com.rac021.jax.api.qualifiers.security.Cipher ;
import com.rac021.jax.api.qualifiers.ServiceRegistry ;
import com.rac021.jax.api.qualifiers.security.Secured ;
import com.rac021.jaxy.coby.io.Writer;
import static com.rac021.jaxy.coby.scheduler.COBYScheduler.JOBS ;
import com.rac021.jaxy.coby.service.configuration.CobyConfiguration ;
import static com.rac021.jaxy.coby.scheduler.COBYScheduler.isEmptyFolder ;
import static com.rac021.jaxy.coby.scheduler.COBYScheduler.executorService ;

/**
 *
 * @author R.Yahiaoui
 */

@ServiceRegistry("coby")
@Secured(policy = Policy.CustomSignOn )
@Cipher( cipherType = { CipherTypes.AES_128_CBC, CipherTypes.AES_256_CBC } )

public class CobyService    {
 
    @Inject 
    CobyConfiguration configuration ;

    @Inject
    @ResourceRegistry("CobyPipelineResource")
    CobyResource Resource ;

    
    @PostConstruct
    public void init() {
    }

    public CobyService() {
    }
   
    @GET
    @Produces( {  "xml/plain" , "json/plain" , "json/encrypted" , "xml/encrypted"  } )
    public Response getResource ( @HeaderParam("keep") String filterdIndex, 
                                  @Context UriInfo uriInfo ) throws BusinessException, UnsupportedEncodingException {    

       
        if( ! Writer.existFile( configuration.getCobyPipeline() ) ) {
           
           System.out.println(" The Script [" + 
                  configuration.getCobyPipeline() + "] + Not found ! ") ;
           
           return Response.status(Response.Status.OK)
                                   .entity(" \n Script Not found ! \n \n "
                                        + " Path : " + configuration.getCobyPipeline() )
                                   .build() ;
           
        }
        String query = uriInfo.getRequestUri().getQuery() ;
        
        if( query == null || query.trim().isEmpty()) {
                            
            return Response.status(Response.Status.OK)
                           .entity("\n Empty Queries not Accepted  \n  " )
                           .build() ;                 
        }
         
        query = URLDecoder.decode( uriInfo.getRequestUri().getQuery().trim(), "UTF-8" ) ;
            
        if( query.contains("$")  || 
            query.contains("@")  || 
            query.contains("^")  || 
            query.contains("'")  || 
            query.contains("`") ) {

             return Response.status(Response.Status.OK)
                            .entity("\n  Please, modify your Request. \n "
                                   + " Some Sharacters Are Not Authorized \n "
                                   + " List --> $ @ ^ ' ` \n \n " )
                            .build() ;
        }
        
        query = cleanQuery(query)    ;
         
        if (  executorService.getActiveCount() == 0 ) {

             if ( ! isEmptyFolder( configuration.getOutputDataFolder())) {
             
                 if(  JOBS.size() >= 20 ) {
                     
                    return Response.status(Response.Status.OK)
                             .entity("\n Full Stack ( 20 Jobs waiting ). \n"
                                     + " Please re-try later & \n "
                                     + " Consider Emptying the Data Generation Directory \n "
                                     + " You can use the Service : [ coby_jobs ] to consult waiting jobs " )
                             .build() ;
                 }
                 
                 JOBS.add(query) ;
                 
                return Response.status( Response.Status.OK )
                         .entity("\n JOB Registered BUT .. \n  "
                                 + "Data has already been generated. \n "
                                 + " Please transfer them to free the generation directory  .. \n \n "
                                 + " You can use the Service : [ coby_clean_output ] to clean the Directory " )
                         .build() ;                 
             }
             
             JOBS.add(query) ;
           
             if( JOBS.size() == 1 || JOBS.isEmpty() ) {
               
              return Response.status(Response.Status.OK)
                             .entity(" \n JOB Launched. \n \n "
                                  + " You can see LOGS using the Service : [ coby_logs ] " )
                             .build() ;
             } else {
                return Response.status ( Response.Status.OK )
                               .entity(" \n Job Will Be Processed As Soon As Possible .. \n " )
                               .build() ;
             }
         } 
         
         else  {
             
              if(  JOBS.size() >= 20 ) {
                     
                    return Response.status(Response.Status.OK)
                             .entity("\n Full Stack ( 20 Jobs waiting ). \n"
                                     + " Please re-try later & \n "
                                     + " Consider Emptying the Data Generation Directory \n "
                                     + " You can use the Service : [ coby_jobs ] to consult waiting jobs " )
                             .build() ;
              }
              
              JOBS.add(query) ;
              
              if( JOBS.size() == 1 || JOBS.isEmpty() ) {
               
                    return Response.status(Response.Status.OK)
                                   .entity(" \n JOB Launched. \n \n "
                                        + " You can see LOGS using the Service : [ coby_logs ] " )
                                   .build() ;
              } else {
                      return Response.status ( Response.Status.OK )
                                   .entity(" \n Job Will Be Processed As Soon As Possible .. \n " )
                                   .build() ;
              }
         }
  
    }

    public static String cleanQuery ( String query ) {
        
      return query.replace("$", "") 
                  .replace("@", "") 
                  .replace("^", "") 
                  .replace("`", "") 
                  .replace("'", "") ;
    }
    
}

