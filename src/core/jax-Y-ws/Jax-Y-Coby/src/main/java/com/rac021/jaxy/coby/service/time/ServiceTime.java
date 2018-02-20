
package com.rac021.jaxy.coby.service.time ;

/**
 *
 * @author ryahiaoui
 */

import javax.ws.rs.GET ;
import java.time.Instant ;
import javax.inject.Inject ;
import javax.ws.rs.Produces ;
import javax.ws.rs.core.Response ;
import javax.annotation.PostConstruct ;
import com.rac021.jax.api.qualifiers.ServiceRegistry ;
import com.rac021.jax.api.qualifiers.ResourceRegistry ;

/**
 *
 * @author R.Yahiaoui
 */

@ServiceRegistry("time")

public class ServiceTime    {
 
    @Inject
    @ResourceRegistry("TimeResource")
    CobyResource Resource ;

    @PostConstruct
    public void init() {
    }

    public ServiceTime() {
    }
    
    @GET
    @Produces( { "xml/plain" , "json/plain", "json/encrypted", "xml/encrypted" } )
    public Response getTime ( ) {    
      
      return Response.status( Response.Status.OK )
                     .entity( String.valueOf(Instant.now().toEpochMilli()) )
                     .build() ;
    }
}
