
package com.rac021.jaxy.coby.service.status ;

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
import static com.rac021.jaxy.coby.scheduler.COBYScheduler.executorService ;

/**
 *
 * @author R.Yahiaoui
 */

@ServiceRegistry("coby_status")
@Secured(policy = Policy.CustomSignOn )
@Cipher( cipherType = { CipherTypes.AES_128_CBC, CipherTypes.AES_256_CBC } )

public class CobyService    {
 
    @Inject
    @ResourceRegistry("CobyStatusResource")
    CobyResource Resource ;

    @PostConstruct
    public void init() {
    }

    public CobyService() {
    }
    
    @GET
    @Produces( {  "xml/plain" , "json/plain" , "json/encrypted" , "xml/encrypted"  } )
    public Response list ( @HeaderParam("keep") String filterdIndex , 
                           @Context UriInfo uriInfo ) {    
         
        if ( executorService.getActiveCount() == 0 ) {

          return Response.status(Response.Status.OK)
                         .entity(" \n COBY RUNNING : NO \n " )
                         .build() ;
         } 
         
         else  {
            return Response.status ( Response.Status.OK )
                           .entity(" \n COBY RUNNING : YES \n " )
                           .build() ;
         }
    }
}
