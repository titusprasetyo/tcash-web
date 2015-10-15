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

public class PublishLoader {
	private String filename;
	private Logger log = Logger.getLogger(PublishLoader.class);
	private long idFile;
	
	public PublishLoader(String filename, long idFile) {
		this.filename = filename;
		this.idFile = idFile;
	}
	
	public void start() {
		log.info("PublishLoader started");
		log.info("Processing : " + filename);
		BufferedReader reader = null;
		Connection conn = null; 
		try {
			reader = new BufferedReader(new FileReader(filename));
			String line = null;
			try {
				conn = MysqlFacade.getConnection();
				while ((line = reader.readLine()) != null) {
					String idPublish = line.substring(0, 18);
					String idCrew = line.substring(11, 17);
					String message = line.substring(17);
					message = message.replaceAll(" ", System.getProperty("line.separator"));
					QueryRunner qr = new QueryRunner();
					String q = "INSERT INTO push_entry (ts, code_push, id_crew, message, push_type, id_file)" +
							" VALUES (NOW(),?,?,?,?,?)";
					qr.update(conn,q, new Object[]{
										idPublish, idCrew, message, PushType.PUBLISH.ordinal(), idFile
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
