package com.telkomsel.itvas.util;

import java.sql.Connection;
import org.apache.commons.dbutils.DbUtils;
import org.apache.commons.dbutils.QueryRunner;
import org.apache.commons.httpclient.HttpClient;
import org.apache.commons.httpclient.HttpMethod;
import org.apache.commons.httpclient.HttpStatus;
import org.apache.commons.httpclient.methods.GetMethod;
import org.apache.log4j.Logger;
import com.telkomsel.itvas.database.MysqlFacade;

public class Util {
	private static HttpClient client;

	public static String getFilename(String absolutePath) {
		String separator = System.getProperty("file.separator");
		return absolutePath.substring(absolutePath.lastIndexOf(separator) + 1);
	}
	
	public static boolean isTselNumber(String msisdn) {
		if (msisdn == null || msisdn.trim().equals("")) {
			return false;
		}
		String myMsisdn = Util.formatMsisdn(msisdn);
		return (myMsisdn.startsWith("62811") || myMsisdn.startsWith("62812") || myMsisdn.startsWith("62813") || myMsisdn.startsWith("62852") || myMsisdn.startsWith("62853"));
	}

	public static String formatMsisdn(String msisdn) {
		if (msisdn == null) {
			return "";
		}
		msisdn = msisdn.trim();
		String retval;
		if (msisdn.startsWith("0")) {
			retval = "62" + msisdn.substring(1);
		} else if (!msisdn.startsWith("62")) {
			retval = "62" + msisdn;
		} else {
			retval = msisdn;
		}
		return retval;
	}
	
	public static String HttpGet(String url) {
		if (client == null) {
			client = new HttpClient();
		}
		String response = null;
		HttpMethod method = new GetMethod(url);
		try {
			int statusCode = client.executeMethod(method);
			if (statusCode != HttpStatus.SC_OK && statusCode != 202) {
				response = "HTTP_FAILED|" + statusCode;
			} else {
				response = method.getResponseBodyAsString();
			}
		} catch (Exception e) {
			response = "FAILED|" + e.getMessage();
		} finally {
			method.releaseConnection();
		}
		
		return response;
	}
	
	public static String formatMysqlDate(String dt) {
		String[] p = dt.split("-");
		if (p.length != 3) {
			return dt;
		}
		return p[2] + "-" + p[1] + "-" + p[0];
	}

	public static void writeEvent(String event) {
		Connection conn = null;
		try {
			conn = MysqlFacade.getConnection();
			String q = "INSERT INTO system_event (ts, event) VALUES (NOW(), ?)";
			QueryRunner qr = new QueryRunner();
			qr.update(conn, q, event);
		} catch (Exception e) {
			Logger.getLogger(Util.class).error("Err in writeEvent() : " + e.getMessage(), e);
		} finally {
			DbUtils.closeQuietly(conn);
		}
	}
	
	public static String nullSafeString(Object obj) {
		if (obj == null) {
			return "";
		} else {
			return obj.toString();
		}
	}
}
