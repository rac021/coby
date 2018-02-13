
package com.rac021.jaxy.coby.service.semantic ;

import java.io.File ;
import java.util.Set ;
import java.util.List ;
import javax.ws.rs.GET ;
import java.util.HashSet ;
import java.nio.file.Path ;
import javax.inject.Inject ;
import java.io.IOException ;
import java.nio.file.Files ;
import java.nio.file.Paths ;
import java.util.ArrayList ;
import javax.ws.rs.Produces ;
import java.util.Collections ;
import javax.inject.Singleton ;
import java.util.stream.Stream ;
import java.util.logging.Level ;
import java.util.logging.Logger ;
import javax.ws.rs.core.UriInfo ;
import javax.ws.rs.core.Context ;
import javax.xml.bind.Marshaller ;
import javax.ws.rs.core.Response ;
import javax.xml.bind.JAXBContext ;
import java.util.stream.Collectors ;
import javax.xml.bind.JAXBException ;
import java.io.ByteArrayOutputStream ;
import javax.annotation.PostConstruct ;
import com.rac021.jaxy.coby.io.Writer ;
import org.apache.commons.lang3.StringUtils ;
import com.rac021.jax.api.streamers.EmptyPojo ;
import com.rac021.jax.api.root.ServicesManager ;
import static java.util.stream.Collectors.toSet ;
import com.rac021.jax.api.qualifiers.ServiceRegistry ;
import com.rac021.jax.api.qualifiers.ResourceRegistry ;
import org.eclipse.persistence.jaxb.MarshallerProperties ;
import com.rac021.jaxy.coby.service.configuration.CobyConfiguration ;
import java.util.Optional;

/**
 *
 * @author R.Yahioaui
 */

@Singleton
@ServiceRegistry("coby_semanticServices")
public class InfoServices {

    @Inject
    @ResourceRegistry("CobySemanticResource")
    CobyResource Resource ;   
    
    @Context 
    UriInfo uriInfo ;
    
    @Inject 
    ServicesManager servicesManager ;

    @Inject 
    CobyConfiguration configuration ;
    
    private List<SemanticDescription> semanticService  = null ;
    private ByteArrayOutputStream     baoStream        = null ;
    
    @PostConstruct
    public void init() {
    }

    public InfoServices() {
    }
   
    @GET
    @Produces( {"json/plain", "xml/plain" , "json/plain", "json/encrypted"} )
    
    public Response getResourceJson() throws Exception {    
        return produceInfoServices() ;
    }

    private Response produceInfoServices() throws Exception {
        
       if( semanticService == null ) {
       
         semanticService = new ArrayList<>() ;
           
         Files.list(Paths.get(configuration.getCobyIs()))
              .filter(Files::isDirectory)
              .map( path -> {
                      if( Files.isDirectory(Paths.get(path.toString() + "/input")) ) 
                          return path.toString() + "/input" ;
                          return null ;
                    })
              .filter( path -> path != null )
              .map( inputPath -> {
                   try {
                      return Files.list(Paths.get(inputPath)).collect(Collectors.toList());
                   } catch (IOException ex) {
                       Logger.getLogger(InfoServices.class.getName()).log(Level.SEVERE, null, ex);
                   }
                     return Collections.emptyList() ;
                   })
              .flatMap( inputPath -> ( Stream<Path>) inputPath.stream() )
              .filter(  path -> Files.isDirectory(path.toAbsolutePath()) )    
              .filter( inputDirectoty -> ! inputDirectoty.getFileName().toString().equalsIgnoreCase("connexion") )
              .filter( inputDirectoty -> ! inputDirectoty.getFileName().toString().equalsIgnoreCase("shared") )
              .map( inputPath -> {
                   try {
                         return Files.walk(inputPath).collect(Collectors.toList());
                   } catch (IOException ex) {
                       Logger.getLogger(InfoServices.class.getName()).log(Level.SEVERE, null, ex);
                   }
                      return Collections.emptyList() ;
                  })
              .flatMap( inputPath -> ( Stream<Path>) inputPath.stream() )
              .filter(  path -> Files.isDirectory(path.toAbsolutePath()) )  
              .forEach( path -> {
                     SemanticDescription semDesc = process(path.toString()) ;
                     if( ! semDesc.getVariable_class().equals("-")) {
                         semanticService.add(process(path.toString())) ;
                     }
                }) ;           
       }  
       
       baoStream = new ByteArrayOutputStream()   ;

       Marshaller marshaller = null              ;

       marshaller = trySetProperties(marshaller) ;
       marshaller.marshal(semanticService, baoStream )          ;

       return  Response.ok( baoStream.toString("UTF8")).build() ;        
    }
    
    private SemanticDescription process( String path)  {
        
       String CLASS_PATH = path + "/class.txt"              ;
       String SPARQL_DOI = path + "/DOI/sparqlTemplate.txt" ;
       
       String si_name = new File ( path.split("/input/",2)[0]).getName() == null   ? 
                            "-" : new File(path.split("/input/",2)[0]).getName()   ;
        
       // Find the correspondance of the SI in the file SI.txt
       // if it exists 
       String si_file_mapping = path.split("/" + si_name + "/", 2 )[0] + "/SI.txt" ;
       
       if( Writer.existFile( si_file_mapping ) ) {
         
           try ( Stream<String> stream = Files.lines(Paths.get(si_file_mapping))) {

              String _si_name = si_name   ;
              
              Optional<String> findFirst = 
                 stream.filter( line -> ! line.trim().replaceAll(" +", " ").startsWith("#"))
                       .filter( line -> line.trim().replaceAll(" +", " ").endsWith(_si_name))
                       .map( line -> line.trim().replaceAll(" +", " ") )
                       .findFirst() ;

              if( findFirst.isPresent() ) {
                  si_name = findFirst.get().split(":=")[0].trim() ;
              }

           } catch (IOException e) {
	        e.printStackTrace();
	   }
       }
           
       String CSV = path.split("/input/", 2)[0] + "/csv/validated_semantic_si.csv" ;
       
       if( ! Writer.existFile(CSV)) {
           CSV = path.split("/input/", 2)[0] + "/csv/semantic_si.csv" ;
       }
       
       String CLAZZ =  "-"                                            ;
       Set<Variable> VARIABLES = new HashSet<>() ;
       Set<String> SELECT_VARS = new HashSet<>() ;
       
       int CSV_DISCRIMINATOR_COLUMN = -1 ;
        
       /* PROCESS CLASS TXT */
       if(Files.exists(Paths.get(CLASS_PATH))) {
           
            try {
                 /*  Read CLASS FILE */
                 CLAZZ = Files.lines(Paths.get(CLASS_PATH))
                              .filter( line -> line.trim()
                                                   .replaceAll(" +", "")
                                                   .toLowerCase()
                                                   .startsWith("class="))
                              .map( l -> l.split("=")[1].trim())
                              .findFirst().orElse("").trim()   ;         
                 
                 CSV_DISCRIMINATOR_COLUMN = Files.lines(Paths.get(CLASS_PATH))
                                                 .filter( line -> line.trim()
                                                                      .replaceAll(" +", "")
                                                                      .toLowerCase()
                                                                      .startsWith("column="))
                                                 .map( l -> l.split("=")[1].replaceAll(" +", "").trim())
                                                 .map( col -> Integer.parseInt(col))
                                                 .findFirst().orElse(-1) ;
            } catch ( IOException ex) {
              Logger.getLogger(InfoServices.class.getName()).log(Level.SEVERE, null, ex) ;
            }
       
        /* PROCESS CSV */
        if( Files.exists(Paths.get(CSV)) ) {
            
           final int    _CSV_DISCRIMINATOR_COLUMN = CSV_DISCRIMINATOR_COLUMN ;
           final String _CLAZZ                    = CLAZZ                    ;
           
           try {
               Files.lines(Paths.get(CSV))
                    .skip(1)
                    .filter( line -> { if(_CSV_DISCRIMINATOR_COLUMN < 0 ) return true ;
                                       return line.split(configuration.getCsvSep())[ _CSV_DISCRIMINATOR_COLUMN ].equalsIgnoreCase(_CLAZZ) ;
                     })
                    .map( line ->  { 
                        VARIABLES.add( new Variable( line.split(configuration.getCsvSep())[ configuration.getColumnVariableAnaeeName() ],                                       
                                                     line.split(configuration.getCsvSep())[ configuration.getColumnVariableLocalName()   ] ) ) ;
                        return line ;
                     })
                    .count() ;

                } catch (IOException ex) {
                  Logger.getLogger(InfoServices.class.getName()).log(Level.SEVERE, null, ex ) ;
           }
        }
        
        /* PROCESS SPARQL DOI */
        if( Files.exists(Paths.get(SPARQL_DOI)) ) {
            
           try {
                             
               String sparql = new String ( Files.readAllBytes(Paths.get(SPARQL_DOI)))
                                                 .replaceAll("(?i)select", "SELECT")
                                                 .replaceAll("(?i)where", "WHERE") ;

               String substringBetween = StringUtils.substringBetween(sparql, "SELECT", "WHERE") ;
               
               //  System.out.println("substringBetween = " + substringBetween);
               
               SELECT_VARS = Stream.of(substringBetween.split("\n"))
                                   .filter( line -> line.trim().replaceAll(" +", " ").startsWith("#"))
                                   .filter( line -> ! line.trim().replaceAll(" +", " ").contains("(") &&
                                                    ! line.trim().replaceAll(" +", " ").contains(")") )
                                   .map( line -> line.replaceAll(" +", " ")
                                                     .replace("#","")
                                                     .replace("?","")
                                                     .split("(?i)as")[0]
                                                     .trim())
                                    .collect(toSet()) ;              
           
           } catch (IOException ex) {
               Logger.getLogger(InfoServices.class.getName()).log(Level.SEVERE, null, ex) ;
           }
                       
        }
        
       }
        
       return new SemanticDescription( si_name, CLAZZ , VARIABLES, SELECT_VARS) ;        
    }
    
    
    private javax.xml.bind.Marshaller trySetProperties( Marshaller marshaller) {
        
        Marshaller localMarshaller= marshaller ;
        JAXBContext jc                         ;
        try {
            jc = JAXBContext.newInstance( SemanticDescription.class, EmptyPojo.class)                  ;
            localMarshaller = jc.createMarshaller()                                                    ;
            localMarshaller.setProperty(MarshallerProperties.MEDIA_TYPE, "application/json")           ;
            localMarshaller.setProperty(MarshallerProperties.JSON_INCLUDE_ROOT, Boolean.FALSE)         ;
            localMarshaller.setProperty(javax.xml.bind.Marshaller.JAXB_FORMATTED_OUTPUT, Boolean.TRUE) ;
        } catch (JAXBException ex) {
            ex.printStackTrace() ;
        }
        return localMarshaller ;
    }
     
}
