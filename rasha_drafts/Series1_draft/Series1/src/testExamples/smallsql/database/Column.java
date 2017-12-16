package smallsql.database;
import java.io.*;
import java.nio.channels.FileChannel;
import java.sql.*;
import smallsql.database.language.Language;
class Column implements Cloneable{  
    private Expression defaultValue = Expression.NULL; // Default value for INSERT
    private String defaultDefinition; // String representation for Default Value
    private String name;
    	private boolean identity;   
    private boolean caseSensitive;   /*dff*/  /*ddd*/
    private boolean nullable = true;		//
      private int scale;  /*dff*/     	
    private int precision;			
    private int dataType; 	
    private Identity counter; // counter for identity values
    /*dd
     * sd
     */
}