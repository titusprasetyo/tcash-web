package com.telkomsel.itvas.garudasmscrew;

import java.sql.Connection;

import org.apache.commons.dbutils.DbUtils;
import org.apache.commons.dbutils.QueryRunner;
import org.apache.commons.dbutils.handlers.ScalarHandler;
import org.apache.log4j.Logger;

import com.telkomsel.itvas.database.MysqlFacade;

public class DbConfig {
	private static Logger log = Logger.getLogger(DbConfig.class);
	
	public static int getIntConfig(String key) {
		Connection conn = null;
		int retval = -1;
		try {
			QueryRunner qr = new QueryRunner();
			conn = MysqlFacade.getConnection();
			String q = "SELECT value FROM configuration WHERE config=?";
			Object res = qr.query(conn, q, key, new ScalarHandler("value"));
			if (res != null) {
				String strResult = (String) res;
				retval = Integer.parseInt(strResult);
			}
		} catch (Exception e) {
			log.error("err in DbConfig : " + e.getMessage(), e);
		} finally {
			DbUtils.closeQuietly(conn);
		}
		return retval;
	}
	
	public static String getConfig(String key) {
		Connection conn = null;
		String retval = "";
		try {
			QueryRunner qr = new QueryRunner();
			conn = MysqlFacade.getConnection();
			String q = "SELECT value FROM configuration WHERE config=?";
			Object res = qr.query(conn, q, key, new ScalarHandler("value"));
			if (res != null) {
				retval = (String)res;
			}
		} catch (Exception e) {
			log.error("err in DbConfig : " + e.getMessage(), e);
		} finally {
			DbUtils.closeQuietly(conn);
		}
		return retval;
	}
}
