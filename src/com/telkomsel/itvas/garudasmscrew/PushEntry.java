package com.telkomsel.itvas.garudasmscrew;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;

import org.apache.commons.dbutils.DbUtils;
import org.apache.log4j.Logger;

import com.telkomsel.itvas.database.MysqlFacade;
import com.telkomsel.itvas.webstarter.WebStarterProperties;

public class PushEntry {
	private String idCrew;
	private String msisdn;
	private String message;
	private PushType type;
	private static int retryInterval = -1;
	
	
	public String getMsisdn() {
		return msisdn;
	}
	public void setMsisdn(String msisdn) {
		this.msisdn = msisdn;
	}
	public String getMessage() {
		return message;
	}
	public void setMessage(String message) {
		this.message = message;
	}
	public PushType getType() {
		return type;
	}
	public void setType(PushType type) {
		this.type = type;
	}
	public boolean create() {
		Connection conn = null;
		try {
			conn = MysqlFacade.getConnection();
			String q = "INSERT INTO push_entry (id_crew, msisdn, message, retry_count, next_retry_time) VALUES (?," +
					" (SELECT msisdn FROM crew WHERE id=?)," +
					"?,'0', '0000-00-00 00:00:00')";
			PreparedStatement ps = conn.prepareStatement(q);
			ps.setString(1, idCrew);
			ps.setString(2, idCrew);
			ps.setString(3, message);
			ps.executeUpdate();
			DbUtils.commitAndCloseQuietly(conn);
			return true;
		} catch (Exception e) {
			e.printStackTrace();
			Logger.getLogger(PushEntry.class).error("Cannot insert entry to database", e);
			DbUtils.rollbackAndCloseQuietly(conn);
			return false;
		}
	}
	public String getIdCrew() {
		return idCrew;
	}
	public void setIdCrew(String idCrew) {
		this.idCrew = idCrew;
	}
	public static int getRetryInterval() {
		return retryInterval;
	}
	public static void setRetryInterval(int retryInterval) {
		PushEntry.retryInterval = retryInterval;
	}
}
