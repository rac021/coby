
package com.rac021.jaxy.coby.service.clean.output ;

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
import javax.annotation.PostConstruct ;
import com.rac021.jax.api.crypto.CipherTypes ;
import com.rac021.jax.api.qualifiers.ResourceRegistry;
import com.rac021.jax.api.qualifiers.security.Policy ;
import com.rac021.jax.api.qualifiers.security.Cipher ;
import com.rac021.jax.api.qualifiers.ServiceRegistry ;
import com.rac021.jax.api.qualifiers.security.Secured ;
import com.rac021.jaxy.coby.service.configuration.CobyConfiguration;
import java.io.File;
import java.nio.file.FileVisitOption;
import java.nio.file.Files;
import java.nio.file.LinkOption;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Comparator;
import javax.ws.rs.core.Response;

/**
 *
 * @author R.Yahiaoui
 */

@ServiceRegistry("coby_clean_output")
@Secured(policy = Policy.CustomSignOn )
@Cipher( cipherType = { CipherTypes.AES_128_CBC, CipherTypes.AES_256_CBC } )

public class CobyService    {
 
    @Inject
    CobyConfiguration configuration ;
     
    @Inject
    @ResourceRegistry("CobyCLeanOutputResource")
    CobyResource Resource ;

    @PostConstruct
    public void init() {
    }

    public CobyService() {
    }
    
    @GET
    @Produces( {  "xml/plain" , "json/plain" , "json/encrypted" , "xml/encrypted"  } )
    public Response cancel ( @HeaderParam("keep") String filterdIndex, 
                             @Context UriInfo uriInfo ) throws Exception {    
         
        //executorService.shutdownNow() ;
        
      removeDirectory(configuration.getOutputDataFolder() ) ;
       return Response.status(Response.Status.OK)
                      .entity("\n Coby Output Directory Cleaned \n" )
                      .build() ;      
    }
    
    
    public static void removeDirectory(String directory) throws Exception {
     
      Path rootPath = Paths.get(directory);
      Files.walk(rootPath, FileVisitOption.FOLLOW_LINKS)
           .sorted(Comparator.reverseOrder())
           .map(Path::toFile)
           .forEach(File::delete);
      
     if(! Files.exists(Paths.get(directory), 
          new LinkOption[]{ LinkOption.NOFOLLOW_LINKS}) )
      Files.createDirectory(Paths.get(directory))    ;   
    }

}

