package com.telkomsel.itvas.garudasmscrew;

import java.sql.Connection;

import org.apache.commons.dbutils.DbUtils;
import org.apache.commons.dbutils.QueryRunner;
import org.apache.commons.dbutils.handlers.BeanHandler;
import org.apache.log4j.Logger;

import com.telkomsel.itvas.database.MysqlFacade;
import com.telkomsel.itvas.util.Util;

public class Crew {
	private String id;
	private String name;
	private String msisdn;
	private static Logger log = Logger.getLogger(Crew.class);
	
	public String getId() {
		return id;
	}
	public void setId(String id) {
		this.id = id;
	}
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	public String getMsisdn() {
		return msisdn;
	}
	public void setMsisdn(String msisdn) {
		this.msisdn = msisdn;
	}
	
	public static Crew getCrew(String msisdn) {
		Crew crew = null;
		Connection conn = null;
		msisdn = Util.formatMsisdn(msisdn);
		String reworkMsisdn = "0" + msisdn.substring(2);
		try {
			conn = MysqlFacade.getConnection();
			QueryRunner qr = new QueryRunner();
			String q = "SELECT id, name, msisdn FROM crew WHERE msisdn IN (?,?)";
			Object res = qr.query(conn, q, new Object[]{msisdn, reworkMsisdn}, new BeanHandler(Crew.class));
			if (res == null) {
				q = "SELECT id, name, msisdn FROM crew WHERE msisdn_old IN (?,?)";
				res = qr.query(conn, q, new Object[]{msisdn, reworkMsisdn}, new BeanHandler(Crew.class));
			}
			crew = (Crew) res; 
		} catch (Exception e) {
			log.error("Err in CrewIdNamePair() : " + e.getMessage(), e);
		} finally {
			DbUtils.closeQuietly(conn);
			
		}
		return crew;
	}
}