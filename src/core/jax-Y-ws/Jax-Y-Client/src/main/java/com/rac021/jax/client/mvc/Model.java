
package com.rac021.jax.client.mvc ;

import java.io.File ;
import java.util.UUID ;
import java.awt.Toolkit ;
import java.util.Objects ;
import java.net.URLEncoder ;
import java.io.IOException ;
import java.io.PrintStream ;
import java.nio.CharBuffer ;
import java.security.KeyStore ;
import java.util.logging.Level ;
import java.io.FileOutputStream ;
import java.util.logging.Logger ;
import org.apache.http.HttpResponse ;
import org.apache.http.nio.IOControl ;
import java.awt.datatransfer.Clipboard ;
import java.nio.charset.StandardCharsets ;
import org.apache.http.entity.ContentType ;
import java.util.concurrent.CountDownLatch ;
import com.rac021.client.security.ICryptor ;
import java.io.UnsupportedEncodingException ;
import org.apache.http.protocol.HttpContext ;
import java.awt.datatransfer.StringSelection ;
import org.apache.http.client.methods.HttpGet ;
import com.rac021.client.security.EncDecRyptor ;
import com.rac021.client.security.FactoryCipher ;
import org.apache.http.concurrent.FutureCallback ;
import org.apache.http.impl.nio.client.HttpAsyncClients ;
import org.apache.http.nio.client.methods.HttpAsyncMethods ;
import org.apache.http.nio.client.methods.AsyncCharConsumer ;
import org.apache.http.nio.protocol.HttpAsyncRequestProducer ;
import org.apache.http.impl.nio.client.CloseableHttpAsyncClient ;

/**
 *
 * @author ryahiaoui
 */

public class Model {
    
    static KeyStore keystore ; 
    
    private static CloseableHttpAsyncClient httpclient ;
    
    private static HttpAsyncRequestProducer producer  ;
    
    private static AsyncCharConsumer<HttpResponse> consumer  ;
            
    private static int BUF_SIZE = 6000 ;
             
    static {
        
           /* Initialise KeyStore for SSL Connections */
        
           try {
               
                String key      = UUID.randomUUID().toString()    ;
                String filename = "cacerts"                       ;
                
                /*
                String filename = System.getProperty("java.home")   +
                                  "/lib/security/cacerts"
                                  .replace('/', File.separatorChar) ;
                */
                
                File f = new File(filename)          ;
                if( ! f.exists() ) f.createNewFile() ;
                
                keystore = KeyStore.getInstance(KeyStore.getDefaultType()) ;

                char[] password = key.toCharArray() ;
                keystore.load(null, password )      ;

                // Store away the keystore.
               try ( FileOutputStream fos = new FileOutputStream(filename) ) {
                   keystore.store(fos, password )           ;
               }

                keystore  = KeyStore.getInstance( KeyStore
                                    .getDefaultType() )     ;
                
           } catch( Exception ex )      {
               System.out.println( ex ) ;
           }
    }
    
    public Model() {
    }
        
    
     private static void initHttpClient()   {
        
        if( httpclient != null      && 
            httpclient.isRunning() ) {
           closetHttpClient()        ;
        }
        
        httpclient = HttpAsyncClients.createDefault() ;
        httpclient.start()                            ;
     }
     
     private static void closetHttpClient()  {
    
      if( httpclient != null )   {
          try {
              httpclient.close() ;
              producer.resetRequest();
              producer.close()   ;
              consumer.cancel()  ;
              consumer.close()   ;
          } catch (IOException ex) {
              Logger.getLogger(Model.class.getName()).log(Level.SEVERE, null, ex);
          }
      }
    }
     
    public static String getToken( String url           , 
                                   String username      ,
                                   String password      , 
                                   String client_id     , 
                                   String client_secret ) throws Exception {        
     
      String val = "grant_type=password&username="+username+"&password="+password+"&client_id="+client_id+"&client_secret="+client_secret  ;       
      
      initHttpClient();

      // In real world one most likely would also want to stream
      // request and response body content
    
      final CountDownLatch latch2 = new CountDownLatch(1) ;      
   
      HttpAsyncRequestProducer producer3 = HttpAsyncMethods.createPost(url, val, ContentType.APPLICATION_FORM_URLENCODED ) ;
    
      AsyncCharConsumer<HttpResponse> consumer3 = new AsyncCharConsumer<HttpResponse>() {

        HttpResponse response;

        @Override
        protected void onResponseReceived(final HttpResponse response) {  
            System.out.println(" ---- response = " + response);
            this.response = response;
        }

        @Override
        protected void onCharReceived(final CharBuffer buf, final IOControl ioctrl) throws IOException {
            System.out.println(" Recieved res ");
            System.out.println("DATA = " + buf.toString());
            buf.clear() ;
        }

        @Override
        protected void releaseResources() {
            System.out.println(" Release CONN ");
        }

        @Override
        protected HttpResponse buildResult(final HttpContext context) {
            return this.response;
        }

      } ;
    
      httpclient.execute(producer3, consumer3, new FutureCallback<HttpResponse>() {

        @Override
        public void completed(final HttpResponse response3) {
            latch2.countDown();
        }

        @Override
        public void failed(final Exception ex) {
            latch2.countDown();
        }

        @Override
        public void cancelled() {
            latch2.countDown();
        }

      }) ;
    
      latch2.await();

      closetHttpClient() ;
      
      return "" ;
      
    }    
         
    public static String invokeService_Using_SSO ( PrintStream out ,
                                                   String url    ,
                                                   String token  ,
                                                   String accept , 
                                                   Class  clazz  ,
                                                   String keep   ) throws Exception {
      return "" ;  
    }
         
    static StringBuilder sb = new StringBuilder() ;
  
    public static String invokeService_Using_Custom ( IOutputWraper out ,
                                                      String serviceUrl ,
                                                      String params     ,
                                                      String accept     , 
                                                      String token      ,
                                                      Class  clazz      ,
                                                      String keep       ,
                                                      String cipher     ) throws Exception {        
        Objects.requireNonNull(out) ;

        initHttpClient() ;

        String _url = serviceUrl.trim() ;

        if(params != null && !params.isEmpty()) {
             _url = serviceUrl + "?" +  URLEncoder.encode( params.trim(), "UTF-8") ;
        }

        final CountDownLatch latch2 = new CountDownLatch(1) ;

        final HttpGet request3 = new HttpGet( _url )        ;

        request3.addHeader("accept", accept)                ;
        request3.addHeader( "API-key-Token", token.trim() ) ;
        request3.addHeader("keep", keep  )                  ;
        request3.addHeader("cipher", cipher );

        producer = HttpAsyncMethods.create(request3) ;

        consumer = new AsyncCharConsumer<HttpResponse>(BUF_SIZE) {

            HttpResponse response;

            @Override
            protected void onResponseReceived(final HttpResponse response) {  
                // System.out.println(" ---- response = " + response);
                this.response = response ;
            }

            @Override
            protected void onCharReceived(final CharBuffer buf, final IOControl ioctrl) throws IOException {
                out.write( new String ( buf.toString().getBytes( StandardCharsets.ISO_8859_1 ) , 
                           StandardCharsets.UTF_8                                            ) ) ;
                buf.clear() ;
            }

            @Override
            protected void releaseResources() {
                //System.out.println(" Release CONN ");
            }

            @Override
            protected HttpResponse buildResult(final HttpContext context)  {
              if( this.response.getStatusLine().getStatusCode() == 404 ) {
                   out.write(this.response.toString()) ;
              }
              return this.response ;
            }

        };

        httpclient.execute(producer, consumer, new FutureCallback<HttpResponse>() {

            @Override
            public void completed(final HttpResponse response3) {
                latch2.countDown();
            }

            @Override
            public void failed(final Exception ex) {  
                System.out.println(" Ex -> " + ex ) ;
               // latch2.countDown();
            }

            @Override
            public void cancelled() {
                latch2.countDown();
            }

        });

        latch2.await()     ;

        closetHttpClient() ;

        return out.get()   ;
    
    }
    
    private static String getBlanc( int nbr ) {
        String blanc = " " ;
        for(int i = 0 ; i < nbr ; i++ ) {
            blanc += " "   ;
        }
        return blanc       ;
    }
    
    public static String generateScriptSSO( String keyCloakUrl , 
                                            String userName    , 
                                            String password    , 
                                            String client_id   , 
                                            String secret_id   , 
                                            String keep        , 
                                            String url         , 
                                            String params      , 
                                            String accept ) throws UnsupportedEncodingException    {
        
        String _url = url.trim() ;        
        
        params  = URLEncoder.encode( params.trim(), "UTF-8") ;

        String trustCertkeyCloakUrl = keyCloakUrl.trim().startsWith("https") ? " -k " : " " ;
        String trustCertUrl         = _url.startsWith("https") ? " -k " : " " ;
         
        String KEYCLOAK_RESPONSE = " KEYCLOAK_RESPONSE=`curl "
                                   + trustCertkeyCloakUrl
                                   + "-s -X POST " + keyCloakUrl  + " \\\n " 
                                   + getBlanc(50) + " -H \"Content-Type: application/x-www-form-urlencoded\" \\\n " 
                                   + getBlanc(50) + " -d 'username=" + userName + "' \\\n "
                                   + getBlanc(50) + " -d 'password=" + password + "' \\\n "
                                   + getBlanc(50) + " -d 'grant_type=password' \\\n "
                                   + getBlanc(50) + " -d 'client_id=" + client_id + "' \\\n "
                                   + getBlanc(50) + " -d 'client_secret=" + secret_id + "' ` \n " ;
                 
        String _token = " ACCESS_TOKEN=`echo $KEYCLOAK_RESPONSE | " + 
                        "sed 's/.*access_token\":\"//g' | sed 's/\".*//g'` " ;
               
        String invokeService =   " curl "        +
                                 trustCertUrl    +
                                 "-H \"accept: " + 
                                 accept + "\"  " + 
                                 " -H \"Authorization: Bearer $ACCESS_TOKEN\" " ;
               
        if( keep != null && ! keep.isEmpty() ) {
             invokeService += " -H \"keep: " + keep + " \" " ;
        }
       
        if( params != null && ! params.isEmpty() )
           _url += "?" + params ;
        
        invokeService += "\"" + _url + "\" " ;
               
        return  "# !/bin/bash"  + "\n\n "               + 
                "# Script generated by G-JAX-CLIENT \n" +
                "# Author : ---    \n\n\n "             +  
                " # INVOKE KEYCLOAD ENDPOINT \n "       + 
                KEYCLOAK_RESPONSE + "\n\n "             + 
                " # PARSE TOKEN FROM RESPONSE \n "      + 
                _token + " \n\n "                       + 
                "# INVOKE THE WEB SERVICE \n "          + 
                invokeService                           ;
    }
    
    public static String decrypt( String cipher , String pass ,String text ) throws Exception {

        ICryptor crypt = FactoryCipher.getCipher( cipher , pass ) ;

        crypt.setOperationMode(EncDecRyptor._Operation.Decrypt )  ;

        return new String ( crypt.process( text, EncDecRyptor._CipherOperation.dofinal ) ) ;
        
    }
    
    public static String generateScriptCUSTOM ( String url           , 
                                                String login         , 
                                                String password      , 
                                                String params        , 
                                                String keep          ,
                                                String accept        ,
                                                String hashLogin     , 
                                                String hashPassword  , 
                                                String hashTimeStamp ,
                                                String algoSign      ,
                                                String cipher      ) throws UnsupportedEncodingException {
            
        String _url =  url.trim() ;
        
        params  = URLEncoder.encode( params.trim(), "UTF-8") ;
  
        if( params != null && ! params.isEmpty() )
           _url += "?" + params ;
        
        String trustCert = _url.trim().startsWith("https") ? " -k " : " " ;
        
        String invokeService =  " curl "        +
                                trustCert       +
                                "-H \"accept: " +
                                accept + "\"  " ;
               
        if( keep != null && ! keep.isEmpty() ) {
          invokeService += " -H \"keep: " + keep + " \" " ;
        }
        
        if( cipher != null && ! cipher.isEmpty() ) {
          invokeService += " -H \"cipher: " + cipher + " \" " ;
        }
        
        return    " # !/bin/bash \n\n" 
                + " # Script generated by G-JAX-CLIENT \n" 
                + " # Author : ---                \n\n\n " 
                + " Login=\""     + login    + "\"  \n\n " 
                + " Password=\""  + password + "\"  \n\n "
                + " TimeStamp=$(date +%s)           \n\n " 
                + getHashedScript( "Login"     , hashLogin     ) + "\n\n " 
                + getHashedScript( "Password"  , hashPassword  ) + "\n\n " 
                + getHashedScript( "TimeStamp" , hashTimeStamp ) + "\n\n "  
                + getSigneScript( algoSign )                     +  "\n\n " 
                + invokeService
                + "-H \"API-key-Token: " + "$Login $TimeStamp $SIGNE\" "  
                + "\"" +_url.replaceAll(" ", "%20") + "\"" ;
    }

    private static String getHashedScript( String variable, String algo ) {
      
        if(algo.equalsIgnoreCase("SHA1")) {
          return " Hashed_"                            + 
                 variable.trim()                       + 
                 "=` echo -n $"                        + 
                 variable.trim()                       + 
                 " | sha1sum  | cut -d ' ' -f 1 ` \n"  + 
                 "  Hashed_"                           + 
                 variable.trim()                       + 
                 "=` echo $Hashed_"                    + 
                 variable.trim()                       + 
                 " | sed 's/^0*//'`"                   ;
        }
        if(algo.equalsIgnoreCase("SHA2")) {
          return " Hashed_"                             + 
                 variable.trim()                        + 
                 "=` echo -n $"                         + 
                 variable.trim()                        + 
                 " | sha256sum  | cut -d ' ' -f 1 ` \n" + 
                 "  Hashed_"                            + 
                 variable.trim()                        + 
                 "=` echo $Hashed_"                     + 
                 variable.trim()                        + 
                 " | sed 's/^0*//'`"                    ;
        }
        else if(algo.equalsIgnoreCase("MD5")) {
           return " Hashed_"                           + 
                  variable.trim()                      + 
                  "=` echo -n $"                       + 
                  variable.trim()                      + 
                  " | md5sum  | cut -d ' ' -f 1` \n"   + 
                  "  Hashed_" + variable.trim()        +
                  "=` echo $Hashed_" + variable.trim() +
                  " | sed 's/^0*//'`" ;
        }
        
        return " Hashed_" + variable.trim() + "=\"$" + variable.trim() + "\""  ;
    }
    
    
    private static String getSigneScript( String algo ) {
      
        if(algo.equalsIgnoreCase("SHA1"))  {
          return " SIGNE=`echo -n $Hashed_Login$Hashed_Password$Hashed_TimeStamp" + 
                  " | sha1sum  | cut -d ' ' -f 1 ` \n "                           + 
                  " SIGNE=` echo $SIGNE | sed 's/^0*//' ` "                       ; 
        }
        if(algo.equalsIgnoreCase("SHA2"))  {
          return " SIGNE=`echo -n $Hashed_Login$Hashed_Password$Hashed_TimeStamp" + 
                  " | sha256sum  | cut -d ' ' -f 1 ` \n "                         + 
                  " SIGNE=` echo $SIGNE | sed 's/^0*//' ` "                       ; 
        }
        else if(algo.equalsIgnoreCase("MD5")) {
          return " SIGNE=`echo -n $Hashed_Login$Hashed_Password$Hashed_TimeStamp " + 
                 "| md5sum  | cut -d ' ' -f 1 ` \n "                               +
                 " SIGNE=` echo $SIGNE | sed 's/^0*//' ` "                         ;
        }
        return " SIGNE=`echo -n $Hashed_Login$Hashed_Password$Hashed_TimeStamp ` " ;
    }
    
    public static void copyToClipBoard( String text )                         {
        StringSelection stringSelection = new StringSelection (text)          ;
        Clipboard clpbrd = Toolkit.getDefaultToolkit ().getSystemClipboard () ;
        clpbrd.setContents (stringSelection, null)                            ;
    }

}
