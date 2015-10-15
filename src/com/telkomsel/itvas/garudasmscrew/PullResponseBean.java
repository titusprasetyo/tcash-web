package com.telkomsel.itvas.garudasmscrew;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;

import org.apache.commons.dbutils.DbUtils;
import org.apache.commons.dbutils.QueryRunner;
import org.apache.commons.dbutils.handlers.BeanHandler;
import org.apache.commons.dbutils.handlers.ScalarHandler;
import org.apache.log4j.Logger;

import com.telkomsel.itvas.database.MysqlFacade;
import com.telkomsel.itvas.util.Util;
import com.telkomsel.itvas.webstarter.WebStarterProperties;

public class PullResponseBean {
	private Logger log = Logger.getLogger(this.getClass());
	private String garudaOA;
	private String tMsisdnNotFound;
	private String tWrongKeyword;
	private String tFreeMsgAccepted;
	private String tSysError;
	
	public PullResponseBean() {
		WebStarterProperties prop = WebStarterProperties.getInstance();
		garudaOA = prop.getProperty("smscrew.oa", "GA");
		tMsisdnNotFound = prop.getProperty("smscrew.template.msisdn_not_found");
		tWrongKeyword = prop.getProperty("smscrew.template.wrong_pull_keyword");
		tFreeMsgAccepted= prop.getProperty("smscrew.template.free_msg_received");
		tSysError= prop.getProperty("smscrew.template.sys_error");
		
	}
	
	private void insertPullResponse(String idCrew, String msisdn, PushType pushType, String message, String orgMessage) {
		Connection conn = null;
		try {
			conn = MysqlFacade.getConnection();
			String q = "INSERT INTO push_entry(ts, id_crew, push_type, message) VALUES (NOW(), ?, ? , ?)";
			QueryRunner qr = new QueryRunner();
			qr.update(conn, q, new Object[] {idCrew, pushType.ordinal(), message});
			
			
			if (idCrew != null) { // Insert into pull_request
				long generatedID = 0;
				q = null;
				
				q = "SELECT LAST_INSERT_ID() as last";
				Object result = qr.query(conn, q, new ScalarHandler("last"));
				generatedID = (Long) result;
				q = null;
				
				q = "INSERT INTO pull_request (ts, push_entry_id, id_crew, msisdn, message) VALUES (NOW(), ?, ?, ?, ?)";
				qr.update(conn, q, new Object[] {generatedID, idCrew, msisdn, orgMessage});
			}
			
		} catch (Exception e) {
			log.error("Error in insertPullResponse() : " + e.getMessage(), e);
		} finally {
			DbUtils.closeQuietly(conn);
		}
		
	}
	
	public String pullRequest(String msisdn, String message) {
		Crew crew = Crew.getCrew(msisdn); 
		if (crew == null) {
			String event = "Pull request received, but msisdn not found in crew database";
			log.warn(event);
			Util.writeEvent(event);
			insertPullResponse(null, msisdn, PushType.PULL_ANSWER_MISC, tMsisdnNotFound, message);
			return tMsisdnNotFound;
		}
		
		String lowerMsg = message.toLowerCase();
		PushType typeMsg = null;
		String response = null;
		if (lowerMsg.startsWith("pub")) {
			typeMsg = PushType.PULL_ANSWER_PUB;
			response = getResponsePUB(crew, message);
		} else if (lowerMsg.startsWith("sch")) {
			typeMsg = PushType.PULL_ANSWER_SCH;
			response = getResponseSCH(crew, message);
		} else if (lowerMsg.startsWith("cki")) {
			typeMsg = PushType.PULL_ANSWER_CKI;
			response = getResponseCKI(crew, message);
		} else if (lowerMsg.startsWith("cpp")) {
			typeMsg = PushType.PULL_ANSWER_CPP;
			response = getResponseCPP(crew, message);
		} else if (lowerMsg.startsWith("fre")) {
			typeMsg = PushType.PULL_ANSWER_FRE;
			response = getResponseFRE(crew, message);
		} else if (lowerMsg.startsWith("fat")) {
			typeMsg = PushType.PULL_ANSWER_FAT;
			response = getResponseFAT(crew, message);
		} else {
			typeMsg = PushType.PULL_ANSWER_MISC;
			response = getResponseMISC(crew, message);
		}
		
		// Insert Into Database
		insertPullResponse(crew.getId(), msisdn, typeMsg, response, message);
		return response;
	}
	private String getResponseMISC(Crew crew, String message) {
		String response = crew.getId() + " " + crew.getName() + " " + tWrongKeyword;
		return response;
	}

	private String getResponseFAT(Crew crew, String message) {
		String response = crew.getId() + " " + crew.getName() + " " + "FAT";
		return response;
	}

	private String getResponseFRE(Crew crew, String message) {
		String response = crew.getId() + " " + crew.getName() + " " + tFreeMsgAccepted;
		Connection conn = null;
		try {
			QueryRunner qr = new QueryRunner();
			conn = MysqlFacade.getConnection();
			String q = "INSERT INTO pull_free_message (ts, id_crew, msisdn, message) VALUES (NOW(), ?, ?, ?)";
			qr.update(conn, q, new Object[] { crew.getId(), crew.getMsisdn(), message});
		} catch (Exception e) {
			response = crew.getId() + " " + crew.getName() + " " + tSysError;
			log.error("Err in getResponseFRE() : " + e.getMessage(), e);
		} finally {
			DbUtils.closeQuietly(conn);
		}
		return response;
	}

	private String getResponseCPP(Crew crew, String message) {
		Connection conn = null;
		String response = crew.getId() + " " + crew.getName() + " " + System.getProperty("line.separator");
		try {
			conn = MysqlFacade.getConnection();
			String c = message.substring(3, 4);
			String f = message.substring(4, 5);
			String dd = message.substring(5, 7);
			String mm = message.substring(7, 9);
			String yy = message.substring(9, 11);
			String pid = message.substring(11, 16);
			
			if (!checkDate(dd, mm, yy)) {
				response += "Salah input tanggal " + dd+mm+yy;
			} else {
				String myDate = "20" + yy + "-" + mm + '-' + dd;
				String q = "SELECT a.id_crew, b.name FROM schedule a INNER JOIN crew b ON a.id_crew=b.id WHERE start_date=? AND fleet=? AND crew_type=? AND pid=? AND a.id_crew<>?";
				PreparedStatement ps = conn.prepareStatement(q);
				ps.setString(1, myDate);
				ps.setString(2, f);
				ps.setString(3, c);
				ps.setString(4, pid);
				ps.setString(5, crew.getId());
				StringBuffer pals = new StringBuffer();
				ResultSet rs = ps.executeQuery();
				boolean found = false;
				while (rs.next()) {
					found = true;
					pals.append(rs.getString("id_crew"));
					pals.append(" ");
					pals.append(rs.getString("name"));
					pals.append(System.getProperty("line.separator"));
				}
				rs.close();
				ps.close();
				
				if (!found) {
					response += "Tidak ditemukan CPP";
				} else {
					response += pals.toString();
				}
			}
		} catch (Exception e) {
			log.error("Err in getResponseCPP() : " + e.getMessage(), e);
			response = crew.getId() + " " + crew.getName() + " " + tSysError;
		} finally {
			DbUtils.closeQuietly(conn);
		}
		return response;
	}

	private boolean checkDate(String dd, String mm, String yy) {
		SimpleDateFormat sdf = new SimpleDateFormat("dd-MM-yyyy");
		boolean retval = false;
		try {
			String test = dd + "-" + mm + "-20" + yy;
			sdf.parse(test);
			retval = true;
		} catch (ParseException e) {
			log.info("Error in parsing Date : " + dd + mm + yy);
		}
		return retval;
	}

	private String getResponseCKI(Crew crew, String message) {
		Connection conn = null;
		String response = crew.getId() + " " + crew.getName() + " ";
		try {
			conn = MysqlFacade.getConnection();
			String dd = message.substring(3, 5);
			String mm = message.substring(5, 7);
			String yy = message.substring(7, 9);
			
			if (!checkDate(dd, mm, yy)) {
				response += "Salah input tanggal " + dd+mm+yy;
			} else {
				QueryRunner qr = new QueryRunner();
				String myDate = "20" + yy + "-" + mm + '-' + dd;
				String q = "SELECT id_crew FROM crew_check_in WHERE id_crew=? AND dt=?";
				Object result = qr.query(conn, q, new Object[]{crew.getId(), myDate}, new ScalarHandler("id_crew"));
				if (result != null) { // already check in
					response += "Anda sudah check in";
				} else {
					q = "SELECT * FROM schedule WHERE id_crew=? AND start_date=? AND pattern_type IN ('FP','LS') AND SUBSTRING(pid, 1, 1)='R'";
					PreparedStatement ps = conn.prepareStatement(q);
					ps.setString(1, crew.getId());
					ps.setString(2, myDate);
					ResultSet rs = ps.executeQuery();
					if (rs.next()) {
						String txt = "CHECKIN" + " " + dd + mm + yy + " " + rs.getString("pid") + " " + rs.getString("std");
						response += txt;
						q = "INSERT INTO crew_check_in (id_crew, dt) VALUES (?,?)";
						qr.update(conn, q, new Object[] {crew.getId(), myDate});
					} else {
						response += "Checkin gagal, jadwal tidak ditemukan";
					}
					rs.close();
					ps.close();
				}
			}
		} catch (Exception e) {
			log.error("Err in getResponseCKI() : " + e.getMessage(), e);
			response = crew.getId() + " " + crew.getName() + " " + tSysError;
		} finally {
			DbUtils.closeQuietly(conn);
		}
		return response;
	}

	private String getResponseSCH(Crew crew, String message) {
		Connection conn = null;
		String response = crew.getId() + " " + crew.getName() + " ";
		try {
			conn = MysqlFacade.getConnection();
			String dd = message.substring(3, 5);
			String mm = message.substring(5, 7);
			String yy = message.substring(7, 9);
			
			if (!checkDate(dd, mm, yy)) {
				response += "Salah input tanggal " + dd+mm+yy;
			} else {
				String myDate = "20" + yy + "-" + mm + '-' + dd;
				String q = "SELECT * FROM schedule WHERE id_crew=? AND (start_date BETWEEN ? AND ADDDATE(?, INTERVAL 7 DAY))";
				PreparedStatement ps = conn.prepareStatement(q);
				ps.setString(1, crew.getId());
				ps.setString(2, myDate);
				ps.setString(3, myDate);
				ResultSet rs = ps.executeQuery();
				boolean found = false;
				while (rs.next()) {
					found = true;
					response += System.getProperty("line.separator");
					if (rs.getString("pattern_type").equalsIgnoreCase("fp")) {
						response += dd + mm + yy + " " + rs.getString("pid") + " " +rs.getString("duty_length") + " "  + rs.getString("std") + " "  + rs.getString("description") + " "  + rs.getString("sta");
					} else if (rs.getString("pid").equalsIgnoreCase("sick")) {
						response += dd + mm + yy + " " + rs.getString("pid");						
					} else {
						response += dd + mm + yy + " " +rs.getString("std") + " ";
					}
				}
				if (!found) {
					response += "Schedule Tidak Ada";
				}
				rs.close();
				ps.close();
			}
		} catch (Exception e) {
			log.error("Err in getResponseSCH() : " + e.getMessage(), e);
			response = crew.getId() + " " + crew.getName() + " " + tSysError;
		} finally {
			DbUtils.closeQuietly(conn);
		}
		return response;
	}

	private String getResponsePUB(Crew crew, String message) {
		Connection conn = null;
		String response = crew.getId() + " " + crew.getName() + " ";
		try {
			conn = MysqlFacade.getConnection();
			String periodePublish = message.substring(3, 10);
			
			String q = "SELECT * FROM push_entry WHERE id_crew=? AND SUBSTRING(code_push,1,7)=? AND push_type=?";
			PreparedStatement ps = conn.prepareStatement(q);
			ps.setString(1, crew.getId());
			ps.setString(2, periodePublish);
			ps.setInt(3, PushType.PUBLISH.ordinal());
			ResultSet rs = ps.executeQuery();
			if (rs.next()) {
				response += rs.getString("message");
			} else {
				response += "Data Schedule belum di publish";
			}
			rs.close();
			ps.close();
		} catch (Exception e) {
			log.error("Err in getResponsePUB() : " + e.getMessage(), e);
			response = crew.getId() + " " + crew.getName() + " " + tSysError;
		} finally {
			DbUtils.closeQuietly(conn);
		}
		return response;
	}
}


