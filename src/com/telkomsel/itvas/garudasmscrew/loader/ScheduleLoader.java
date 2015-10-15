package com.telkomsel.itvas.garudasmscrew.loader;

import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.sql.Connection;

import org.apache.commons.dbutils.DbUtils;
import org.apache.commons.dbutils.QueryRunner;
import org.apache.commons.dbutils.handlers.ScalarHandler;
import org.apache.log4j.Logger;

import com.telkomsel.itvas.database.MysqlFacade;
import com.telkomsel.itvas.garudasmscrew.PushEntry;
import com.telkomsel.itvas.garudasmscrew.PushType;
import com.telkomsel.itvas.webstarter.WebStarterProperties;

public class ScheduleLoader {
	private String filename;
	private long idFile;
	private Logger log = Logger.getLogger(ScheduleLoader.class);
	
	public ScheduleLoader(String filename, long idFile) {
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
		log.info("ScheduleLoader started");
		log.info("Processing : " + filename);
		BufferedReader reader = null;
		Connection conn = null; 
		try {
			reader = new BufferedReader(new FileReader(filename));
			String line = null;
			try {
				conn = MysqlFacade.getConnection();
				while ((line = reader.readLine()) != null) {
					String idCrew = line.substring(0, 6);
					String crewType = line.substring(6, 7);
					String fleet = line.substring(7, 8);
					String category = line.substring(8, 10);
					String startDate = formatGarudaDate(line.substring(10, 20));
					String endDate = formatGarudaDate(line.substring(20, 30));
					String patternType = line.substring(30, 32);
					String pid = line.substring(32, 37);
					String dutyLength = line.substring(37, 39);
					String std = line.substring(39, 51);
					String sta = line.substring(51, 63);
					String description = line.substring(63);
					
					QueryRunner qr = new QueryRunner();
					
					String	q = "INSERT INTO schedule (id_crew, id_file, crew_type, fleet, category, start_date, end_date, pattern_type, pid, duty_length, std, sta, description)" +
								"VALUES (?,?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
						qr.update(conn, q, new Object[] {
								idCrew, idFile, crewType, fleet, category, startDate, endDate, patternType, pid, dutyLength, std, sta, description
							});
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
}
