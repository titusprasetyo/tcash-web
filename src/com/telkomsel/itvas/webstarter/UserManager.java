package com.telkomsel.itvas.webstarter;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.DataSource;

import org.apache.commons.dbutils.DbUtils;
import org.apache.commons.dbutils.QueryRunner;
import org.apache.commons.dbutils.handlers.BeanHandler;
import org.apache.commons.dbutils.handlers.BeanListHandler;
import org.apache.commons.dbutils.handlers.MapListHandler;
import org.apache.log4j.Logger;

import tsel_tunai.Util;

import com.telkomsel.itvas.database.MysqlFacade;


public class UserManager {
	private QueryRunner qr = new QueryRunner();
    /** Stores the list of people in the system. */
    private static Map<Integer,User> people = new TreeMap<Integer,User>();
    
    public UserManager() {
    	super();
    }

    /** Returns a person with the specified username, if one exists. */
    public User getUser(String username) {
    	return getUser(username, null);
    }

    /** Gets a list of all the people in the system. */
    public List<User> getAllPeople() {
        return Collections.unmodifiableList( new ArrayList<User>(people.values()) );
    }

    /**
     * Deletes a person from the system...doesn't do anything fancy to clean up where the
     * person is used.
     */
    public void deleteUser(int id) {
    	String q = "DELETE FROM tsel_webstarter_user WHERE id=?";
    	Object[] params = {id};
    	try {
			MysqlFacade.update(q, params);
		} catch (SQLException e) {
			Logger.getLogger(UserManager.class).error("Cannot update login attempt", e);
		}
    }
    
    public List<User> getAllUser() {
    	QueryRunner qr = MysqlFacade.getQueryRunner();
    	BeanListHandler handler = new BeanListHandler(User.class);
    	String q = "SELECT a.id as id, username, password, fullname, email, login_attempt as loginAttempt, account_expiry as accountExpiry, b.role as roleDescription, a.id_role as role, DECODE(GREATEST(password_expiry,sysdate), sysdate, 1, 0) AS passwordExpired, DECODE(GREATEST(account_expiry,sysdate), sysdate, 1, 0) AS accountExpired FROM tsel_webstarter_user a INNER JOIN tsel_webstarter_role b ON a.id_role=b.id";
    	List<User> retval = new ArrayList<User>();
    	try {
			List<User> results = (List<User>) qr.query(q, handler);
			for (User u : results) {
				u.init();
				retval.add(u);
			}
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return retval;
    }
    
	public User getUser(String username, String password) {
		String q = "SELECT a.id as id, username, account_expiry as accountExpiry, password, fullname, email, b.role as roleDescription, a.id_role as role, DECODE(GREATEST(password_expiry,sysdate), sysdate, 1, 0) AS passwordExpired, DECODE(GREATEST(account_expiry,sysdate), sysdate, 1, 0) AS accountExpired, login_attempt as loginAttempt FROM tsel_webstarter_user a INNER JOIN tsel_webstarter_role b ON a.id_role=b.id WHERE username=? AND password=?";
		System.out.println(q);
		QueryRunner qr = MysqlFacade.getQueryRunner();
		BeanHandler handler = new BeanHandler(User.class);
		User user = null;
		System.out.println(username);
		System.out.println(Util.getMd5Digest(password));
		try {
			user = (User) qr.query(q, new Object[] {username, Util.getMd5Digest(password)}, handler);
			if (user != null) {
				user.init();
			}
			return user;
		} catch (SQLException e) {
			e.printStackTrace();
			return null;
		}
	}
	
	public User getUser(int id) {
		String q = "SELECT a.id as id, username, password, fullname, email, b.role as roleDescription, a.id_role as role, DECODE(GREATEST(sysdate,password_expiry), sysdate, 1, 0) AS passwordExpired, DECODE(GREATEST(account_expiry, sysdate), sysdate, 1, 0) AS accountExpired, login_attempt as loginAttempt FROM tsel_webstarter_user a INNER JOIN tsel_webstarter_role b ON a.id_role=b.id WHERE a.id=?";
		QueryRunner qr = MysqlFacade.getQueryRunner();
		BeanHandler handler = new BeanHandler(User.class);
		User user = null;
		try {
			user = (User) qr.query(q, id, handler);
			user.init();
			return user;
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return null;
		}
	}
	
	public boolean resetPasswordUser(int id) {
		boolean retval = false;
		String q = "UPDATE tsel_webstarter_user SET password=?, password_expiry=to_date(?, 'yyyy/mm/dd') WHERE id=?";
		try {
			MysqlFacade.update(q, new Object[]{Util.getMd5Digest("Tsel@1234"), "1970-01-01",id});
			retval = true;
		} catch (SQLException e) {
			e.printStackTrace();
		}
		return retval;
	}
	
	public int incLoginAttempt(String username) {
		Connection conn = null;
		try {
			conn = MysqlFacade.getConnection();
			String q = "SELECT login_attempt, to_char(sysdate, 'yyyy/mm/dd') AS now, to_char(login_attempt, 'yyyy/mm/dd') AS login_attempt,  FROM tsel_webstarter_user WHERE username=?";
			PreparedStatement ps = conn.prepareStatement(q);
			ps.setString(1, username);
			ResultSet rs = ps.executeQuery();
			if (rs.next()) {
				int loginAttempt = rs.getInt("login_attempt");
				String last_login_attempt = rs.getString("login_attempt");
				String now = rs.getString("now");
				if (now.equals(last_login_attempt)) {
					if (loginAttempt < 10) {
						loginAttempt++;
					}
				} else {
					if (loginAttempt <= 3) {
						loginAttempt = 0;
					}
				}
				q = "UPDATE tsel_webstarter_user SET login_attempt=?, last_login_attempt=sysdate WHERE username=?";
				qr.update(conn, q, new Object[]{loginAttempt, username});
				return 1;
			} else {
				return 0;
			}
		} catch (Exception e) {
			return 0;
		} finally {
			DbUtils.closeQuietly(conn);
		}
//		
//		String q = "UPDATE tsel_webstarter_user SET login_attempt=IF(DATE(last_login_attempt) = DATE(NOW()), IF(login_attempt > 10, login_attempt, login_attempt + 1), IF(login_attempt > 3, login_attempt, 0)), last_login_attempt=NOW() WHERE username=?";
//		try {
//			MysqlFacade.update(q, username);
//		} catch (SQLException e1) {
//			// TODO Auto-generated catch block
//			e1.printStackTrace();
//		}
//		
//		q = "SELECT login_attempt FROM tsel_webstarter_user WHERE username=?";
//		try {
//			Integer i = (Integer) MysqlFacade.getScalar(q, username, "login_attempt");
//			if (i == null) {
//				return 0;
//			} else {
//				return i;
//			}
//		} catch (Exception e) {
//			return 0;
//		}
	}

	public boolean unblockUser(int id) {
		String q = "UPDATE tsel_webstarter_user SET login_attempt='0' WHERE id=?";
		Object[] params = {id};
		try {
			MysqlFacade.update(q, params);
		} catch (SQLException e1) {
			e1.printStackTrace();
			return false;
		}
		return true;
	}
}
