
package com.rac021.jax.service.discovery ;

import java.util.Map ;
import java.util.Set ;
import javax.xml.bind.annotation.XmlType ;
import javax.xml.bind.annotation.XmlRootElement ;

/**
 *
 * @author ryahiaoui
 */

 @XmlRootElement
 @XmlType(propOrder = { "serviceName", "security", "ciphers" , 
                        "accepts"    , "params"   }          )
 
 public class ServiceDescription {
        
    private  String              serviceName ;
    private  String              security    ;

    private  Map<String, String> params      ;
    
    private  Set<String>         ciphers     ;
    private  Set<String>         accepts     ;
        
    
    public ServiceDescription( String name                , 
                               String security            , 
                               Map<String, String> params , 
                               Set<String> ciphers        ,
                               Set<String> accepts     )  {
        
        this.serviceName  = name     ;
        this.security     = security ;
        this.params       = params   ;
        this.accepts      = accepts  ;
        this.ciphers      = ciphers  ;
    }
    
    public ServiceDescription() {
    }

    public String getServiceName() {
        return serviceName ;
    }

    public void setServiceName(String serviceName) {
        this.serviceName = serviceName ;
    }
  
    public void setSecurity(String security) {
        this.security = security ;
    }

    public String getSecurity() {
        return security ;
    }

    public Map<String, String> getParams() {
        return params ;
    }

    public void setParams(Map<String, String> params) {
        this.params = params ;
    }

    public Set<String> getCiphers() {
        return ciphers ;
    }

    public void setCiphers(Set<String> ciphers) {
        this.ciphers = ciphers ;
    }

    public Set<String> getAccepts() {
        return accepts ;
    }

    public void setAccepts(Set<String> accepts) {
        this.accepts = accepts ;
    }
 }
