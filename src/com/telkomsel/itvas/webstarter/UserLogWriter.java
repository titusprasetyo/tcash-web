package com.telkomsel.itvas.webstarter;

import java.sql.SQLException;

import org.apache.log4j.Logger;

import com.telkomsel.itvas.database.MysqlFacade;

public class UserLogWriter {
	public static void writeLog(String username, String log) {
		try {
			String q = "INSERT INTO tsel_webstarter_userlog (username, log, ts) VALUES (?,?,sysdate)";
			MysqlFacade.update(q, new Object[] {username, log});
		} catch (SQLException e) {
			Logger.getLogger(UserLogWriter.class).error("Error writing user log", e);
		} 
	}
}
