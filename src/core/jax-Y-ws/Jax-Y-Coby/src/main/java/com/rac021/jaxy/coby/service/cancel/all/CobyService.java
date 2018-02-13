
package com.rac021.jaxy.coby.service.cancel.all ;

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
import javax.ws.rs.core.Response ;
import javax.annotation.PostConstruct ;
import com.rac021.jax.api.crypto.CipherTypes ;
import com.rac021.jax.api.qualifiers.ResourceRegistry;
import com.rac021.jax.api.qualifiers.security.Policy ;
import com.rac021.jax.api.qualifiers.security.Cipher ;
import com.rac021.jax.api.qualifiers.ServiceRegistry ;
import com.rac021.jax.api.qualifiers.security.Secured ;
import static com.rac021.jaxy.coby.scheduler.COBYScheduler.JOBS ;
import static com.rac021.jaxy.coby.scheduler.PipelineRunner.process ;
import static com.rac021.jaxy.coby.scheduler.COBYScheduler.SUBMITTED_JOB ;

/**
 *
 * @author R.Yahiaoui
 */

@ServiceRegistry("coby_cancel_all")
@Secured(policy = Policy.CustomSignOn )
@Cipher( cipherType = { CipherTypes.AES_128_CBC, CipherTypes.AES_256_CBC } )

public class CobyService    {
 
    @Inject
    @ResourceRegistry("CobyCancelAllResource")
    CobyResource Resource ;

    @PostConstruct
    public void init() {
    }

    public CobyService() {
    }
    
    @GET
    @Produces( {  "xml/plain" , "json/plain" , "json/encrypted" , "xml/encrypted"  } )
    public Response cancel ( @HeaderParam("keep") String filterdIndex, 
                             @Context UriInfo uriInfo ) {    
         
       // executorService.shutdownNow()        ;
        
        if( JOBS != null && !JOBS.isEmpty() ) {
            JOBS.clear() ;
        }
        
        if( SUBMITTED_JOB != null )   {
            
           SUBMITTED_JOB.cancel(true) ;
           
           process.destroyForcibly()  ;
           
           return Response.status(Response.Status.OK)
                          .entity(" \n All jobs Canceled ... \n " )
                          .build() ;
        }
        return Response.status(Response.Status.OK)
                       .entity(" \n No Job submited to Cancel \n " )
                       .build() ;
    }   

}

