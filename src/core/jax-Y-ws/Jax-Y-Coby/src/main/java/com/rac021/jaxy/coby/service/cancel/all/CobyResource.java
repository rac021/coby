
package com.rac021.jaxy.coby.service.cancel.all;

/**
 *
 * @author ryahiaoui
 */

import com.rac021.jax.api.manager.IResource ;
import com.rac021.jax.api.qualifiers.SqlQuery ;
import com.rac021.jax.api.qualifiers.ResourceRegistry ;

/**
 *
 * @author R.Yahiaoui
 */
@ResourceRegistry("CobyCancelAllResource")
public class CobyResource implements IResource {

   @SqlQuery(value = "Sql_Log")
   String SQL = "SELECT id FROM (values ('1')) s(id) " ;
   
    
}
