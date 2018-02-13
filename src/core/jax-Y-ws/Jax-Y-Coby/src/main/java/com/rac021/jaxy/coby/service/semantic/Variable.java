
package com.rac021.jaxy.coby.service.semantic ;

import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlType ;
import javax.xml.bind.annotation.XmlRootElement ;

/**
 *
 * @author ryahiaoui
 */


@XmlRootElement
@XmlType(propOrder = { "standardName", "entity" } )

public class Variable {
    
    @XmlElement(name="variable")
    private String standardName ;
    
    @XmlElement(name="entity")
    private String entity    ;

    public Variable() {
    }
    public Variable(String standardName, String entity ) {
        this.standardName = standardName ;
        this.entity       = entity       ;
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
}
