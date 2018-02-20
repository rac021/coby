
package com.rac021.jaxy.coby.service.semantic ;

import javax.xml.bind.annotation.XmlType ;
import javax.xml.bind.annotation.XmlElement ;
import javax.xml.bind.annotation.XmlRootElement ;

/**
 *
 * @author ryahiaoui
 */


@XmlRootElement
@XmlType(propOrder = { "standardName", "entity", "categories" } )

public class Variable {
    
    @XmlElement(name="variable")
    private String standardName ;
    
    @XmlElement(name="entity")
    private String entity    ;
    
    @XmlElement(name="category")
    private String categories  ;
    
    public Variable() {
    }
    public Variable( String standardName , 
                     String entity       ,
                     String categories ) {
        
        this.standardName = standardName ;
        this.entity       = entity       ;
        this.categories   = categories   ;
    }

    public String getStandardName() {
        return standardName;
    }

    public void setStandardName(String standardName) {
        this.standardName = standardName;
    }

    public String getEntity() {
        return entity;
    }

    public void setEntity(String entity) {
        this.entity = entity;
    }

    public String getCategories() {
        return categories;
    }

    public void setCategories(String categories) {
        this.categories = categories;
    }
    
    
}
