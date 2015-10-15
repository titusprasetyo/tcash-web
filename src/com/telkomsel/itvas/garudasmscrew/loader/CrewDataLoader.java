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
import com.telkomsel.itvas.util.Util;
import com.telkomsel.itvas.webstarter.WebStarterProperties;

public class CrewDataLoader {
	private String filename;
	private Logger log = Logger.getLogger(CrewDataLoader.class);
	private long idFile;
	
	public CrewDataLoader(String filename, long idFile) {
		this.filename = filename;
		this.idFile = idFile;
	}
	
	public void start() {
		log.info("CrewDataLoader started");
		log.info("Processing : " + filename);
		BufferedReader reader = null;
		Connection conn = null; 
		try {
			reader = new BufferedReader(new FileReader(filename));
			String line = null;
			QueryRunner qr = new QueryRunner();
			try {
				conn = MysqlFacade.getConnection();
				boolean first = true;
				while ((line = reader.readLine()) != null) {
					if (!first) {
						String properLine = line.trim().replaceAll("\\s+", " ");
						String[] p = properLine.split(" ");
						if (p.length >= 7) {
							String q = "REPLACE INTO crew (id, id_old, crew_type, fleet, category, name, msisdn, msisdn_old) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
							String msisdn_old = "";
							if (p.length == 8) {
								 msisdn_old = p[7];
							}
							try {
								qr.update(conn, q, new Object[] {
									p[0], p[1], p[2], p[3], p[4], p[5], p[6], msisdn_old
								});
							} catch (Exception e) {
								log.error("Exception : " + e.getMessage(), e);
							}
							log.info("Insert Crew ID : " + p[0]);
						}
					} else {
						first = false;
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
}
