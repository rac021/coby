
package com.rac021.jaxy.coby.service.logs ;

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

@ResourceRegistry("LogResource")
public class CobyResource implements IResource {

   @SqlQuery(value = "Sql_Log")
   String SQL = "SELECT id FROM (values ('1')) s(id) " ;
   
}
