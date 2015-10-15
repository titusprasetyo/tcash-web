package com.telkomsel.itvas.garudasmscrew.loader;

import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;

import org.apache.commons.dbutils.DbUtils;
import org.apache.commons.dbutils.QueryRunner;
import org.apache.commons.dbutils.handlers.ScalarHandler;
import org.apache.log4j.Logger;

import com.telkomsel.itvas.database.MysqlFacade;
import com.telkomsel.itvas.garudasmscrew.PushEntry;
import com.telkomsel.itvas.garudasmscrew.PushType;
import com.telkomsel.itvas.util.Util;
import com.telkomsel.itvas.webstarter.WebStarterProperties;

public class SeparateLoader {
	private String filename;
	private long idFile;
	private Logger log = Logger.getLogger(SeparateLoader.class);
	private Connection conn;

	public SeparateLoader(String filename, long idFile) {
		this.filename = filename;
		this.idFile = idFile;
	}

	private String formatGarudaDate(String date) {
		String[] p = date.split("\\.");
		if (p.length == 3) {
			return p[2] + "-" + p[1] + "-" + p[0];
		} else {
			return null;
		}
	}

	public void start() {
		log.info("ReviseLoader started");
		log.info("Processing : " + filename);
		BufferedReader reader = null;
		conn = null;
		try {
			reader = new BufferedReader(new FileReader(filename));
			String line = null;
			try {
				conn = MysqlFacade.getConnection();
				while ((line = reader.readLine()) != null) {
					String idCrew = line.substring(4, 10);
					if (line.startsWith("{REV")) {
						separateRevise(idCrew, line);
					} else if (line.startsWith("{FAM")) {
						separateFamily(idCrew, line);
					} else if (line.startsWith("{FRE")) {
						separateFreeMessage(idCrew, line);
					} else if (line.startsWith("{ETD")) {
						separateETD(idCrew, line);
					} else if (line.startsWith("{TBL")) {
						separateSchedule(idCrew, line);
					} else {
						String event = "Line unidentified : " + line
								+ ", file :" + filename;
						log.warn(event);
						Util.writeEvent(event);
					}
				}
			} catch (Exception e) {
				log.error("Exception : " + e.getMessage(), e);
			}
		} catch (FileNotFoundException e) {
			log.error("Exception : " + e.getMessage(), e);
		} finally {
			DbUtils.closeQuietly(conn);
			if (reader != null) {
				try {
					reader.close();
				} catch (IOException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
			}
			log.info("Finished Processing : " + filename);
		}
	}

	private void separateSchedule(String idCrew, String line) {
		// try {
		// String crewType = line.substring(6, 7);
		// String fleet = line.substring(7, 8);
		// String category = line.substring(8, 10);
		// String startDate = formatGarudaDate(line.substring(10, 20));
		// String endDate = formatGarudaDate(line.substring(20, 30));
		// String patternType = line.substring(30, 32);
		// String pid = line.substring(32, 37);
		// String dutyLength = line.substring(37, 39);
		// String std = line.substring(39, 51);
		// String sta = line.substring(51, 63);
		// String description = line.substring(63);
		//			
		// QueryRunner qr = new QueryRunner();
		//			
		// String q = "INSERT INTO schedule (id_crew, crew_type, fleet,
		// category, start_date, end_date, pattern_type, pid, duty_length, std,
		// sta, description)" +
		// "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
		// qr.update(conn, q, new Object[] {
		// idCrew, crewType, fleet, category, startDate, endDate, patternType,
		// pid, dutyLength, std, sta, description
		//					
		// } catch (RuntimeException e) {
		// log.error("Error reading line : " + line);
		// }
	}

	private void separateETD(String idCrew, String line) {
		try {
			String message = line.substring(10, line.indexOf("}"));
			String q = "INSERT INTO push_entry (id_crew, push_type, message, ts, id_file)"
					+ "VALUES (?,?,?, NOW(),?)";
			QueryRunner qr = new QueryRunner();
			try {
				qr.update(conn, q, new Object[] { idCrew,
						PushType.ETD.ordinal(), message, idFile });
			} catch (SQLException e) {
				log.error("Error in separateETD() : " + e.getMessage(), e);
			}

		} catch (RuntimeException e) {
			log.error("Error reading line : " + line);
		}
	}

	private void separateFreeMessage(String idCrew, String line) {
		try {
			String message = line.substring(10, line.indexOf("}"));
			String q = "INSERT INTO push_entry (id_crew, push_type, message, ts, id_file)"
					+ "VALUES (?,?,?, NOW(), ?)";
			QueryRunner qr = new QueryRunner();
			try {
				qr.update(conn, q, new Object[] { idCrew,
						PushType.FREE_MESSAGE.ordinal(), message, idFile });
			} catch (SQLException e) {
				log.error("Error in separateFreeMessage() : " + e.getMessage(),
						e);
			}

		} catch (RuntimeException e) {
			log.error("Error reading line : " + line);
		}
	}

	private void separateFamily(String idCrew, String line) {
		try {
			String message = line.substring(10, line.indexOf("}"));
			String q = "INSERT INTO push_entry (id_crew, push_type, message, id_file,ts)"
					+ "VALUES (?,?,?,?,NOW())";
			QueryRunner qr = new QueryRunner();
			try {
				qr.update(conn, q, new Object[] { idCrew,
						PushType.FAMILY_REASON.ordinal(), message, idFile });
			} catch (SQLException e) {
				log.error("Error in reviseFamily() : " + e.getMessage(), e);
			}

		} catch (RuntimeException e) {
			log.error("Error reading line : " + line);
		}
	}

	private void separateRevise(String idCrew, String line) {
		try {
			String message = line.substring(10, line.indexOf("}"));
			String q = "INSERT INTO push_entry (id_crew, push_type, message, id_file, ts)"
					+ "VALUES (?,?,?,?,NOW())";
			QueryRunner qr = new QueryRunner();
			try {
				qr.update(conn, q, new Object[] { idCrew,
						PushType.REVISE.ordinal(), message, idFile });
			} catch (SQLException e) {
				log.error("Error in reviseRevise() : " + e.getMessage(), e);
			}

		} catch (RuntimeException e) {
			log.error("Error reading line : " + line);
		}
	}
}
