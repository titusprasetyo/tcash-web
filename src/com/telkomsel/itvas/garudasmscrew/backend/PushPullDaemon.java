package com.telkomsel.itvas.garudasmscrew.backend;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.apache.commons.dbutils.DbUtils;
import org.apache.commons.dbutils.QueryRunner;
import org.apache.commons.dbutils.handlers.MapListHandler;
import org.apache.commons.dbutils.handlers.ScalarHandler;
import org.apache.log4j.Logger;

import com.telkomsel.itvas.database.MysqlFacade;
import com.telkomsel.itvas.garudasmscrew.DbConfig;
import com.telkomsel.itvas.garudasmscrew.PushType;
import com.telkomsel.itvas.garudasmscrew.SmsGatewayConnector;
import com.telkomsel.itvas.util.Util;
import com.telkomsel.itvas.webstarter.WebStarterProperties;

public class PushPullDaemon extends Thread{
	private int waitInterval = 5000;
	private int retryLimit = 1;
	private int retryInterval = 10;
	private Logger log = Logger.getLogger(this.getClass());
	private SmsGatewayConnector sms;
	private String garudaOA;
	
	public static void main(String[] args) {
		PushPullDaemon app = new PushPullDaemon();
		app.init();
		app.startApp();
	}
	
	public void init() {
		WebStarterProperties prop = WebStarterProperties.getInstance();
		
		// Database Connecitivy
		String host = prop.getProperty("db_host");
		String username = prop.getProperty("db_username");
		String password = prop.getProperty("db_password");
		String name = prop.getProperty("db_name");
		String connectionString = "jdbc:mysql://" + host + "/" + name
				+ "?user=" + username + "&password=" + password;
		MysqlFacade.initStandalone(connectionString, username, password);
		
		// SMS Connectivity
		sms = new SmsGatewayConnector();
		
		// OA
		garudaOA = prop.getProperty("smscrew.oa", "GA");
		
		Runtime.getRuntime().addShutdownHook(this);
	}
	
	public void run() { // shutdown thread
		MysqlFacade.terminateFacade();
	}
	
	public void startApp() {
		QueryRunner qr = new QueryRunner();
		String qGetPush = "SELECT * FROM push_entry WHERE nb_part=0";
		String qSingleSmsEntry = "SELECT * FROM single_sms_entry WHERE delivered=0 AND retry_count < ?";
		String qInsertSingleSms = "INSERT INTO single_sms_entry (trx_id, part_id, msisdn, message, sent_time, validity_period, retry_limit) VALUES (?,?,?,?,NOW(),?,?)";
		String qSmsOutPool= "SELECT * FROM sms_out_pool";
		String qMoveToSmsSent = "INSERT INTO sms_sent (id, single_sms_id, validity_period, msisdn, message, sent_time) (SELECT *,NOW() FROM sms_out_pool WHERE id=?)";
		String qDeleteSmsOutPool = "DELETE FROM sms_out_pool WHERE id=?";
		String qUpdateNbPartPush = "UPDATE push_entry SET nb_part=?, notes=? WHERE id=?";
		Connection conn = null;
		try {
			conn = MysqlFacade.getConnection();
		} catch (Exception e) {
			log.fatal("Cannot establish DB Connection : " + e.getMessage(), e);
		}
		while (true) {
//			System.out.print(".");
			try {
				if (conn == null || conn.isClosed()) {
					conn = null;
					conn = MysqlFacade.getConnection();
				}
				
				// Get Push Entry which is not yet exploded into single sms
				PreparedStatement ps = conn.prepareStatement(qGetPush);
				ResultSet rs = ps.executeQuery();
				while (rs.next()) {
					String q = "SELECT msisdn FROM crew WHERE id=?";
					Object res = qr.query(conn, q, rs.getString("id_crew"), new ScalarHandler("msisdn"));
					if (res != null) { // MSISDN found
						String msisdn = (String) res;
						// Cek apakah MSISDN nomor TSEL ato bukan
						if (Util.isTselNumber(msisdn)) {
							String[] messages = getPartedMessage(rs.getString("id"), rs.getString("message"));
							int validityPeriod = getValidityPeriod(rs.getInt("push_type"));
							int retryLimit = getRetryLimit(rs.getInt("push_type"));
							if (messages != null) {
								qr.update(conn, qUpdateNbPartPush, new Object[] {messages.length, null, rs.getLong("id")});
								int i = 1;
								for (String msg : messages) {
									qr.update(conn, qInsertSingleSms, new Object[] {
											rs.getLong("id"), i, msisdn, msg, validityPeriod, retryLimit
									});
									i++;
								}
							}
						} else { // not TSEL number
							qr.update(conn, qUpdateNbPartPush, new Object[] {-1, "Crew MSISDN is not TSEL Number", rs.getLong("id")});
							Util.writeEvent("Not TSEL number : " + msisdn + ", Crew No : " + rs.getString("id_crew"));
						}
					} else { // MSISDN not found
						qr.update(conn, qUpdateNbPartPush, new Object[] {-1, "Crew or MSISDN not found", rs.getLong("id")});
						Util.writeEvent("Crew or MSISDN not found : " + rs.getString("id_crew"));
					}
				}
				rs.close();
				ps.close();
				
				// Find expired single sms entry, and resend the sms
				rs = null;
				ps = null;
				ps = conn.prepareStatement(qSingleSmsEntry);
				ps.setInt(1, retryLimit);
				rs = ps.executeQuery();
				
				while (rs.next()) {
					sms.resendSingleSmsEntry(rs.getLong("id"), rs.getString("msisdn"), rs.getString("message"), rs.getInt("validity_period"));
				}
				rs.close();
				ps.close();
					
				// Send SMS in sms_out_pool, and move to table sms_sent
				rs = null;
				ps = null;
				ps = conn.prepareStatement(qSmsOutPool);
				rs = ps.executeQuery();
				
				while (rs.next()) {
						if (sendSMS((String) rs.getString("msisdn"), (String) rs.getString("message"), rs.getLong("id"), rs.getInt("validity_period"))) {
							qr.update(conn, qMoveToSmsSent, rs.getLong("id"));
							qr.update(conn, qDeleteSmsOutPool, rs.getLong("id"));
						}
				}
				rs.close();
				ps.close();
			} catch (Exception e) {
				System.out.println("Error : " + e.getMessage());
				log.error("main_loop Error : " + e.getMessage(), e);
			}
			
			
			try {
				Thread.sleep(waitInterval);
			} catch (InterruptedException e) {
			}
		}
	}

	private int getRetryLimit(int i) {
		String key = "undefined";
		int retval = 0;
		PushType p = PushType.values()[i];
		if (p.equals(PushType.PUBLISH)) {
			key = "resend.limit.publish";
		} else if (p.equals(PushType.FAMILY_REASON)) {
			key = "resend.limit.family";
		} else if (p.equals(PushType.ETD)) {
			key = "resend.limit.etd";
		} else if (p.equals(PushType.FREE_MESSAGE)) {
			key = "resend.limit.free";
		} else if (p.equals(PushType.REVISE)) {
			key = "resend.limit.revise";
		} else {
			key = "resend.limit.pull";
		}
		retval = DbConfig.getIntConfig(key);
		if (retval == -1) {
			return 1;
		}
		return retval;
	}

	private int getValidityPeriod(int i) {
		String key = "undefined";
		int retval = 0;
		PushType p = PushType.values()[i];
		if (p.equals(PushType.PUBLISH)) {
			key = "validity.period.publish";
		} else if (p.equals(PushType.FAMILY_REASON)) {
			key = "validity.period.family";
		} else if (p.equals(PushType.ETD)) {
			key = "validity.period.etd";
		} else if (p.equals(PushType.FREE_MESSAGE)) {
			key = "validity.period.free";
		} else if (p.equals(PushType.REVISE)) {
			key = "validity.period.revise";
		} else {
			key = "validity.period.pull";
		}
		retval = DbConfig.getIntConfig(key);
		if (retval == -1) {
			return 0;
		}
		return retval;
	}

	private boolean sendSMS(String msisdn, String message, long sms_out_id, int validityPeriod) {
		log.info("Sending SMS : " + msisdn + "||" + message);
		return sms.sendSMS(garudaOA, msisdn, message, sms_out_id, validityPeriod);
	}

	private String[] getPartedMessage(String id, String message) {
		ArrayList<Integer> partIndexes;
		try {
			partIndexes = getSplitMessageIndexes(message);
			
			// Process
			String[] result = new String[partIndexes.size()];
			for (int i=0; i<partIndexes.size();i++) {
				String finalMessage = null;
				if (partIndexes.size() > 1) {
					finalMessage = (i+1) + "/" + partIndexes.size() + " ";
				} else {
					finalMessage = "";
				}
				if (i == 0) { // last message
					finalMessage += message.substring(0, partIndexes.get(i));
				} else {
					finalMessage += message.substring(partIndexes.get(i-1), partIndexes.get(i));
				}
				result[i] = finalMessage;
			}
			return result;
		} catch (Exception e) {
			log.error("Error in getPartedMessage() : " + e.getMessage(), e);
			return null;
		}
	}
	
	public ArrayList<Integer> getSplitMessageIndexes(String message) {
		boolean end = false;
		int curPos = 0;
		ArrayList<Integer> partIndexes = new ArrayList<Integer>();
		try {
			while (!end) {
				int messageLimit = curPos + 156;
				if (messageLimit > message.length()) {
					messageLimit = message.length();
					end = true;
				}
				int lastSpaceIndex = 0;
				if (messageLimit - curPos < 156) {
					lastSpaceIndex = messageLimit;
				} else {
					lastSpaceIndex = message.lastIndexOf(' ', messageLimit);					
				}
				if (lastSpaceIndex == -1) {
					lastSpaceIndex = messageLimit;
				}
				partIndexes.add(lastSpaceIndex);
				curPos = lastSpaceIndex;
			}
		} catch (Exception e) {
			log.error("Error in splitMessage() : " + e.getMessage(), e);
		}
		return partIndexes;
	}
}
