
package com.rac021.jaxy.coby.service.logs ;

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
import com.rac021.jaxy.coby.service.configuration.CobyConfiguration ;

/**
 *
 * @author R.Yahiaoui
 */

@ServiceRegistry("coby_logs")
@Secured(policy = Policy.Public )
@Cipher( cipherType = { CipherTypes.AES_128_CBC } )

public class CobyService    {
    
    @Inject
    CobyConfiguration configuration ;
       
    @Inject
    @ResourceRegistry("LogResource")
    CobyResource Resource ;

    @PostConstruct
    public void init() {
        StreamerLog.INTERVAL    = configuration.getFrequencyUpdateTimeMs() ;
        StreamerLog.LOGGER_FILE = configuration.getLoggerFile()            ;
    }
    
    public CobyService() {
    }
   
    @GET
    @Produces( {  "xml/plain" , "json/plain" , "json/encrypted" , "xml/encrypted"  } )
    public Response getResource ( @HeaderParam("keep") String filterdIndex, 
                                  @Context UriInfo uriInfo ) {    

        return Response.status(Response.Status.OK)
                       .entity(new StreamerLog() )
                       .build() ;        
    }
}

