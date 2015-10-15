package tsel_tunai;

import java.sql.*;
import javax.naming.*;
import javax.sql.*;


/**
 * <p>Title: </p>
 *
 * <p>Description: </p>
 *
 * <p>Copyright: Copyright (c) 2007</p>
 *
 * <p>Company: </p>
 *
 * @author not attributable
 * @version 1.0
 */
public class DbCon {


  public DbCon() {
  }

  public static Connection getConnection() throws Exception {
    Connection con = null;
    Context ctx = new InitialContext();

    //DataSource ds = (DataSource) ctx.lookup("java:comp/env/jdbc/tsel_tunai_dev");
    DataSource ds = (DataSource) ctx.lookup("java:comp/env/jdbc/tsel_tunai");
	
    con = ds.getConnection();

    return con;
  }

  public static Connection createDBConnection(String url) throws Exception
    {
        Class.forName("org.gjt.mm.mysql.Driver");
        Connection con = DriverManager.getConnection(url);
        return con;
    }

    public static Connection createDBConnectionOra(String url) throws Exception
  {
//      DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
//      Connection con = DriverManager.getConnection(url);
//      return con;
    	Class.forName("org.gjt.mm.mysql.Driver");
        Connection con = DriverManager.getConnection(url);
        return con;
  }
}
