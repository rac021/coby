
package com.rac021.jaxy.coby.service.semantic ;

import java.util.Set ;
import javax.xml.bind.annotation.XmlType ;
import javax.xml.bind.annotation.XmlElement ;
import javax.xml.bind.annotation.XmlRootElement ;

/**
 *
 * @author ryahiaoui
 */

 @XmlRootElement
 @XmlType(propOrder = { "is", "variable_class", "variables" , "select_vars" } )

 public class SemanticDescription {
        
    @XmlElement(name="SI")
    private  String        is             ;
    
    @XmlElement(name="CLASS")
    private  String        variable_class ;

    @XmlElement(name="Variables")
    private  Set<Variable> variables      ;
    
    @XmlElement(name="Select_Vars")
    private  Set<String>   select_vars    ;

    
    public SemanticDescription() {
    }
    public SemanticDescription( String        si             ,
                                String        variable_class ,
                                Set<Variable> variables      , 
                                Set<String>   select_vars    )  {
        
        this.is              = si             ;
        this.variable_class  = variable_class ;
        this.variables       = variables      ;
        this.select_vars      = select_vars   ;
    }

    public String getIs() {
        return is;
    }

    public void setIs(String is) {
        this.is = is;
    }

    public String getVariable_class() {
        return variable_class;
    }

    public void setVariable_class(String variable_class) {
        this.variable_class = variable_class;
    }

    public Set<Variable> getVariables() {
        return variables;
    }

    public void setVariables(Set<Variable> variables) {
        this.variables = variables;
    }

    public Set<String> getSelect_vars() {
        return select_vars;
    }

    public void setSelect_vars(Set<String> select_vars) {
        this.select_vars = select_vars;
    }
  
    @Override
    public String toString() {
        return is + " - " + variable_class + " - " + variables + " - " + select_vars ;
                
    }
    
 }
