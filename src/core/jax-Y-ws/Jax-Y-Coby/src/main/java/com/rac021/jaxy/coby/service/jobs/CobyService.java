
package com.rac021.jaxy.coby.service.jobs ;

/**
 *
 * @author ryahiaoui
 */

import javax.ws.rs.GET ;
import javax.inject.Inject ;
import javax.ws.rs.Produces ;
import javax.ws.rs.HeaderParam ;
import javax.ws.rs.core.UriInfo ;
import javax.ws.rs.core.Response;
import javax.ws.rs.core.Context ;
import java.util.stream.Collectors ;
import javax.annotation.PostConstruct ;
import com.rac021.jax.api.crypto.CipherTypes ;
import com.rac021.jax.api.qualifiers.ResourceRegistry;
import com.rac021.jax.api.qualifiers.security.Policy ;
import com.rac021.jax.api.qualifiers.security.Cipher ;
import com.rac021.jax.api.qualifiers.ServiceRegistry ;
import com.rac021.jax.api.qualifiers.security.Secured ;
import static com.rac021.jaxy.coby.scheduler.COBYScheduler.JOBS ;

/**
 *
 * @author R.Yahiaoui
 */

@ServiceRegistry("coby_jobs")
@Secured(policy = Policy.CustomSignOn )
@Cipher( cipherType = { CipherTypes.AES_128_CBC, CipherTypes.AES_256_CBC } )

public class CobyService    {
 
    @Inject
    @ResourceRegistry("CobyJobsResource")
    CobyResource Resource ;

    @PostConstruct
    public void init() {
    }

    public CobyService() {
    }
    
    @GET
    @Produces( {  "xml/plain" , "json/plain" , "json/encrypted" , "xml/encrypted"  } )
    public Response list ( @HeaderParam("keep") String filterdIndex, 
                           @Context UriInfo uriInfo ) {    
    
         System.out.println(" JOBS == " + JOBS ) ;
        
         String s = " \n EMPTY JOB LIST \n " ;
         
         if( JOBS != null && ! JOBS.isEmpty()) {
            s= JOBS.stream()
                   .filter( job -> job != null)
                   .map(Object::toString)
                   .collect(Collectors.joining(" \n\n "));
         }
         return Response.status(Response.Status.OK)
                        .entity(s )
                        .build() ;
    }
    
}

