
package com.rac021.jaxy.coby.service.cancel ;

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
import com.rac021.jaxy.coby.checker.TokenManager ;
import com.rac021.jaxy.coby.scheduler.COBYScheduler ;
import com.rac021.jax.api.qualifiers.security.Policy ;
import com.rac021.jax.api.qualifiers.security.Cipher ;
import com.rac021.jax.api.qualifiers.ServiceRegistry ;
import com.rac021.jax.api.qualifiers.security.Secured ;
import com.rac021.jax.api.qualifiers.ResourceRegistry ;
import com.rac021.jax.api.exceptions.BusinessException ;
import static com.rac021.jaxy.coby.scheduler.PipelineRunner.process ;
import static com.rac021.jaxy.coby.scheduler.COBYScheduler.SUBMITTED_JOB ;

/**
 *
 * @author R.Yahiaoui
 */

@ServiceRegistry("coby_cancel")
@Secured(policy = Policy.CustomSignOn )
@Cipher( cipherType = { CipherTypes.AES_128_CBC, CipherTypes.AES_256_CBC } )

public class CobyService    {
 
    @Inject
    @ResourceRegistry("CobyCancelResource")
    CobyResource Resource ;

    @PostConstruct
    public void init() {
    }

    public CobyService() {
    }
    
    @GET
    @Produces( {  "xml/plain" , "json/plain" , "json/encrypted" , "xml/encrypted"  } )
    public Response cancel ( @HeaderParam("API-key-Token") String token ,
                             @HeaderParam("keep") String filterdIndex   , 
                             @Context UriInfo uriInfo ) throws BusinessException     {    
         
        //executorService.shutdownNow() ;
        
        if( COBYScheduler.jobOwner == null ) {
            
           return Response.status(Response.Status.OK)
                          .entity("\n No Job submited to Cancel \n" )
                          .build() ;
        }
        
        String login     = TokenManager.getLogin(token) ;
        
        if( COBYScheduler.jobOwner.equals(login )) {
        
            if( SUBMITTED_JOB != null )   {

               SUBMITTED_JOB.cancel(true) ;
               process.destroyForcibly()  ;
               return Response.status(Response.Status.OK)
                              .entity("\n Current Job Canceled .. \n" )
                              .build() ;
            } else {
                
                return Response.status(Response.Status.OK)
                          .entity("\n No Job submited to Cancel \n" )
                          .build() ;
            }
        }
        else {
            
            return Response.status(Response.Status.OK)
                           .entity("\n [" + login + "] does not have permissions \n"
                                   + "  -> Current JobOwner : " + COBYScheduler.jobOwner )
                           .build() ;
        }
    }
}
