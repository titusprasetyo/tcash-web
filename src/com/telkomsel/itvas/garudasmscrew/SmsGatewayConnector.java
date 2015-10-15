package com.telkomsel.itvas.garudasmscrew;

import java.io.UnsupportedEncodingException;
import java.math.BigInteger;
import java.net.URLEncoder;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Map;

import org.apache.commons.dbutils.DbUtils;
import org.apache.commons.dbutils.QueryRunner;
import org.apache.commons.dbutils.handlers.MapHandler;
import org.apache.commons.dbutils.handlers.ScalarHandler;
import org.apache.log4j.Logger;

import com.telkomsel.itvas.database.MysqlFacade;
import com.telkomsel.itvas.util.Util;
import com.telkomsel.itvas.webstarter.WebStarterProperties;

public class SmsGatewayConnector {
	private Logger log = Logger.getLogger(this.getClass());
	private static final String SEND_SMS_URL = "http://%s/cgi-bin/sendsms?user=tester&pass=foobar&from=%s&to=%s&text=%s&dlr-mask=31&dlr-url=%s";
	private static final String DLR_HANDLER_URL = "http://%s/garuda-smscrew/sms/dlr.jsp?id=%s";
	private String smsURL;
	private String dlrURL;

	public SmsGatewayConnector() {
		// Initialization
		WebStarterProperties prop = WebStarterProperties.getInstance();
		smsURL = prop.getProperty("sms.gw.url");
		dlrURL = prop.getProperty("sms.dlr.url");
	}

	public boolean sendSMS(String originator, String destination,
			String message, long sms_out_id, int validityPeriod) {
		if (!Util.isTselNumber(destination)) {
			return false;
		}
		destination = Util.formatMsisdn(destination);
		int counter = 0;
		boolean sent = false;
		while (counter < 3 && !sent) {
			String deliveryUrl = String.format(DLR_HANDLER_URL, dlrURL,
					sms_out_id)
					+ "&dlr-type=%d&smsc=%i";
			System.out.println("delivery url : " + deliveryUrl);
			String url;
			try {
				url = String.format(SEND_SMS_URL, smsURL, originator,
						destination, URLEncoder.encode(message, "UTF-8"),
						URLEncoder.encode(deliveryUrl, "UTF-8"));
			} catch (UnsupportedEncodingException e) {
				log.error("Error in sendSMS() : " + e.getMessage(), e);
				return false;
			}
			String response = Util.HttpGet(url);
			if (response.startsWith("Sent.")) {
				log.info("Successfully sending message to : " + destination);
				sent = true;
			} else {
				counter++;
				log.info("Failed sending message to : " + destination
						+ ", retry no : " + counter);
			}
		}
		return sent;
	}

	public void handleDelivery(String id, String deliveryCode, String smsc) {
		log.info("DLR Received|" + id + "|" + deliveryCode + "|" + smsc);
		Connection conn = null;
		try {
			conn = MysqlFacade.getConnection();
			if (smsc == null || smsc.indexOf("/") == -1) {
				smsc = "null";
			} else {
				smsc = smsc.substring(0, smsc.indexOf("/"));
			}

			// Find in sms_sent
			QueryRunner qr = new QueryRunner();
			String q = "SELECT single_sms_id FROM sms_sent WHERE id=?";
			Object result = qr.query(conn, q, id, new ScalarHandler(
					"single_sms_id"));
			if (result != null) { // sms_send ID found
				// Update table sms_sent
				q = "UPDATE sms_sent SET delivery_time=NOW(), delivery_code=?, smsc=? WHERE id=?";
				qr.update(conn, q, new Object[] { deliveryCode, smsc, id });

				Long singleSmsId = (Long) result;
				q = null;
				q = "SELECT * FROM single_sms_entry where id=?";
				Object res2 = qr.query(conn, q, singleSmsId, new MapHandler());
				if (res2 != null) { // single_sms_id found
					Map mapSingleSms = (Map) res2;
					String isDeliveredAlready = (String) mapSingleSms
							.get("delivered");
					int retryLimit = (Integer) mapSingleSms.get("retry_limit");
					int retryCount = (Integer) mapSingleSms.get("retry_count");
					
					Long trxID = (Long) mapSingleSms.get("trx_id");
					if (isDeliveredAlready == null
							|| !isDeliveredAlready.equals("1")) {
						if (deliveryCode.equals("1")) { // delivered
							q = "UPDATE push_entry SET nb_delivered=nb_delivered+1 WHERE id=?";
							qr.update(conn, q, new Object[] { trxID });
						}
					}
					if (deliveryCode.equals("1")) { // delivered
						q = "UPDATE single_sms_entry SET delivery_time=NOW(), delivered=1, delivery_code=1 WHERE id=?";
						qr.update(conn, q, singleSmsId);
					} else {
						if (retryCount < retryLimit && (deliveryCode.equals("2")
								|| deliveryCode.equals("16"))) {
							resendSingleSmsEntry(singleSmsId);
						}
						q = "UPDATE single_sms_entry SET delivery_time=NOW(), delivery_code=? WHERE id=?";
						qr.update(conn, q, new Object[] { deliveryCode,
								singleSmsId });
					}
				}
			}
		} catch (Exception e) {
			log.error("Error in handleDelivery() : " + e.getMessage(), e);
		} finally {
			DbUtils.closeQuietly(conn);
		}
	}
	
	public void resendSingleSmsEntry(long idSingleSms) {
		Connection conn = null;
		try {
			conn = MysqlFacade.getConnection();
			String q1 = "SELECT * FROM single_sms_entry WHERE id=?";
			PreparedStatement ps = conn.prepareStatement(q1);
			ps.setLong(1, idSingleSms);
			ResultSet rs = ps.executeQuery();
			if (rs.next()) {
				resendSingleSmsEntry(idSingleSms, rs.getString("msisdn"), rs.getString("message"), rs.getInt("validity_period"));
			}
			rs.close();
			ps.close();
		} catch (Exception e) {
			log.error("Err in resendSingleSmsEntry() : " + e.getMessage(), e);
		} finally {
			DbUtils.closeQuietly(conn);
		}
	}
	
	public void resendSingleSmsEntry(long idSingleSms, String msisdn,
			String message, int validityPeriod) {
		Connection conn = null;
		String qUpdateSingleSmsEntry = "UPDATE single_sms_entry SET retry_count=retry_count+1 WHERE id=?";
		String qInsertSmsOutPool = "INSERT INTO sms_out_pool (single_sms_id, msisdn, message, validity_period) VALUES (?,?,?,?)";

		QueryRunner qr = new QueryRunner();
		try {
			conn = MysqlFacade.getConnection();
			qr
					.update(conn, qUpdateSingleSmsEntry,
							new Object[] { idSingleSms });
			qr.update(conn, qInsertSmsOutPool, new Object[] { idSingleSms,
					msisdn, message, validityPeriod });
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} finally {
			DbUtils.closeQuietly(conn);
		}

	}
}
