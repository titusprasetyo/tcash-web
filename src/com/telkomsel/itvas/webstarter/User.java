package com.telkomsel.itvas.webstarter;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Date;

import org.apache.commons.dbutils.QueryRunner;
import org.apache.log4j.Logger;

import tsel_tunai.Util;

import com.telkomsel.itvas.database.MysqlFacade;

/**
 * Represents a person to whom bugs can be assigned.
 *
 * @author Tim Fennell
 */
public class User {
	private long id;
    private String username;
    private String fullName;
    private String email;
    private String password;
	private int role;
	private String roleDescription;
	private ArrayList<Menu> eligibleMenus;
	private boolean isPasswordExpired = false;
	private int loginAttempt;
	private String accountExpiry;
	private boolean isAccountExpired = false;

    /** Default constructor. 
     * @param b 
     * @param string4 
     * @param i 
     * @param string3 
     * @param string2 
     * @param string 
     * @param username2 */
    /** Constructs a well formed person. */
    public User(int id, String username, String password, String fullname, String email, int role, String roleDescription, boolean passwordExpired, int loginAttempt, Date accountExpiry) {
    	this.id = id;
        this.username = username;
        this.password = password;
        this.email = email;
        this.fullName = fullname;
        this.role = role;
        this.roleDescription = roleDescription;
        eligibleMenus = MenuManager.getEligibleMenus(role, passwordExpired);
        isPasswordExpired = passwordExpired;
        this.loginAttempt = loginAttempt;
    }
    
    public User() {
    	
    }
    
    public void init() {
    	eligibleMenus = MenuManager.getEligibleMenus(role, isPasswordExpired);
    }

    /** Gets the username of the person. */
    public String getUsername() { return username; }

    /** Sets the username of the user. */
    public void setUsername(String username) { this.username = username; }

    /** Gets the person's email address. */
    public String getEmail() { return email; }

    /** Sets the person's email address. */
    public void setEmail(String email) { this.email = email; }

    /** Gets the person's unencrypted password. */
    public String getPassword() {
        return password;
    }

    /** Sets the person's unencrypted password. */
    public void setPassword(String password) {
        this.password = password;
    }

    /** Equality is determined to be when the ID numbers match. */
    public boolean equals(Object obj) {
        return (obj instanceof User) && this.username.equals(((User) obj).username);
    }

	public String getFullName() {
		return fullName;
	}

	public void setFullName(String fullName) {
		this.fullName = fullName;
	}

	public int getRole() {
		return role;
	}

	public void setRole(int role) {
		this.role = role;
	}

	public String getRoleDescription() {
		return roleDescription;
	}

	public ArrayList<Menu> getEligibleMenus() {
		return eligibleMenus;
	}

	public void setEligibleMenus(ArrayList<Menu> eligibleMenus) {
		this.eligibleMenus = eligibleMenus;
	}

	public void setRoleDescription(String roleDescription) {
		this.roleDescription = roleDescription;
	}

	public void updatePassword(String newPassword) {
		try {
			MysqlFacade.update("UPDATE tsel_webstarter_user SET password=?, password_expiry=ADDDATE(sysdate, INTERVAL 90 DAY) WHERE username=?", 
					new Object[]{
					Util.getMd5Digest(newPassword),
					username}
			);
			
			MysqlFacade.update("INSERT INTO tsel_webstarter_password_history (username, password, dt) VALUES (?,?,sysdate)", 
					new Object[]{
					username,
					Util.getMd5Digest(newPassword)}
			);
			isPasswordExpired = false;
		} catch (Exception e) {
			Logger.getLogger(User.class).error("Cannot update password", e);
		}
	}

	public boolean testPassword(String oldPassword) {
		String query = "SELECT username FROM tsel_webstarter_user WHERE username=? AND password=md5(?)";
		try {
			Object result = MysqlFacade.getScalar(query, new String[] {username, oldPassword}, "username");
			return (result != null);
		} catch (Exception e1) {
			return false;
		}
	}

	public boolean isPasswordExpired() {
		return isPasswordExpired;
	}

	public void setPasswordExpired(boolean isPasswordExpired) {
		this.isPasswordExpired = isPasswordExpired;
	}

	public boolean isInPasswordHistory(String newPassword) {
		String query = "SELECT username FROM tsel_webstarter_password_history WHERE username=? AND password=? AND DATEDIFF(sysdate, dt) < 365";
		try {
			Object result = MysqlFacade.getScalar(query, new String[] {username, Util.getMd5Digest(newPassword)}, "username");
			return (result != null);
		} catch (Exception e1) {
			return false;
		}
	}

	public long getId() {
		return id;
	}

	public void setId(long id) {
		this.id = id;
	}
	
	public boolean update() {
		username = username.toLowerCase();
		if (id != 0) {
			String q = "UPDATE tsel_webstarter_user SET fullname=?, email=?, id_role=?, account_expiry=? WHERE id=?";
			Object[] params = {fullName, email, role, accountExpiry, id};
			try {
				MysqlFacade.update(q, params);
			} catch (Exception e) {
				Logger.getLogger(User.class).error("Cannot update user", e);
				return false;
			}
		} else {
			String q = "INSERT INTO tsel_webstarter_user (username, password, fullname, email, id_role, password_expiry,login_attempt,account_expiry) VALUES (?,md5('Tsel#1234'), ?,?,?,'0000-00-00','0',?)";
			Object[] params = {username, fullName, email, role, accountExpiry};
			try {
				MysqlFacade.update(q, params);
			} catch (SQLException e) {
				Logger.getLogger(User.class).error("Cannot insert user", e);
				return false;
			}
		}
		return true;
	}

	public void updateLoginAttempt() {
		String q = "UPDATE tsel_webstarter_user SET login_attempt=0 WHERE id=?";
		Object[] params = {id};
		try {
			MysqlFacade.update(q, params);
		} catch (SQLException e) {
			Logger.getLogger(User.class).error("Cannot update login attempt", e);
		}
	}

	public int getLoginAttempt() {
		return loginAttempt;
	}

	public void setLoginAttempt(int loginAttempt) {
		this.loginAttempt = loginAttempt;
	}

	public String getAccountExpiry() {
		return accountExpiry;
	}

	public void setAccountExpiry(String accountExpiry) {
		this.accountExpiry = accountExpiry;
	}

	public boolean isAccountExpired() {
		return isAccountExpired;
	}

	public void setAccountExpired(boolean isAccountExpired) {
		this.isAccountExpired = isAccountExpired;
	}

	public long getNbSession() {
		String q = "SELECT count(*) as jumlah FROM tsel_webstarter_session WHERE username=? AND (UNIX_TIMESTAMP(sysdate) - UNIX_TIMESTAMP(alive_time) < 600)";
		Object res;
		try {
			res = MysqlFacade.getScalar(q, new Object[] {username}, "jumlah");
		} catch (SQLException e) {
			Logger.getLogger(User.class).error("Query failed : " + q);
			return 0;
		}
		Long nbSession = (Long) res;
		return (nbSession == null)? 0 : nbSession;
	}

	public void updateSession(String ip) {
		String q = "SELECT username FROM tsel_webstarter_session WHERE username=? AND ip=?";
		try {
			Object res = MysqlFacade.getScalar(q, new Object[] {username, ip}, "username");
			if (res == null) {
				q = "INSERT INTO tsel_webstarter_session (username, ip, alive_time) VALUES (?,?,sysdate)";
				MysqlFacade.update(q, new Object[] {username, ip});
			} else {
				q = "UPDATE tsel_webstarter_session SET alive_time=sysdate WHERE username=? AND ip=?";
				MysqlFacade.update(q, new Object[] {username, ip});
			}
		} catch (Exception e) {
			e.printStackTrace();
			Logger.getLogger(User.class).error("Query failed : " + q);
		}
	}

	public void killSession(String ip) {
		String q = "DELETE FROM tsel_webstarter_session WHERE username=? AND ip=?";
		try {
			MysqlFacade.update(q, new Object[] {username, ip});
		} catch (SQLException e) {
			Logger.getLogger(User.class).error("Query failed : " + q);
		}
	}
}
