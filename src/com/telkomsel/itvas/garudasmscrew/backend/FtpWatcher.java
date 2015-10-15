package com.telkomsel.itvas.garudasmscrew.backend;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.InputStreamReader;
import java.sql.Connection;
import java.util.ArrayList;

import org.apache.commons.dbutils.DbUtils;
import org.apache.commons.dbutils.QueryRunner;
import org.apache.commons.dbutils.handlers.ScalarHandler;
import org.apache.log4j.Logger;

import com.telkomsel.itvas.database.MysqlFacade;
import com.telkomsel.itvas.garudasmscrew.loader.CrewDataLoader;
import com.telkomsel.itvas.garudasmscrew.loader.PublishLoader;
import com.telkomsel.itvas.garudasmscrew.loader.SeparateLoader;
import com.telkomsel.itvas.garudasmscrew.loader.ScheduleLoader;
import com.telkomsel.itvas.util.Util;
import com.telkomsel.itvas.webstarter.WebStarterProperties;

public class FtpWatcher extends Thread {
	private String sourceDir;
	private String archiveDir;
	private int waitInterval = 5000;
	private Logger log = Logger.getLogger(this.getClass());
	private ArrayList<String> listExisting;
	
	public void init() {
		listExisting = new ArrayList<String>();
		listExisting.add(".bash_history");
		listExisting.add(".bash_profile");
		listExisting.add(".profile");
		listExisting.add("local.cshrc");
		listExisting.add("local.login");
		listExisting.add("local.profile");
		
		WebStarterProperties prop = WebStarterProperties.getInstance();
		sourceDir = prop.getProperty("ftpwatcher.source.path");
		archiveDir = prop.getProperty("ftpwatcher.archive.path");
		waitInterval = prop.getIntProperty("ftpwatcher.wait.interval");
		
		// Database Connecitivy
		String host = prop.getProperty("db_host");
		String username = prop.getProperty("db_username");
		String password = prop.getProperty("db_password");
		String name = prop.getProperty("db_name");
		String connectionString = "jdbc:mysql://" + host + "/" + name
				+ "?user=" + username + "&password=" + password;
		MysqlFacade.initStandalone(connectionString, username, password);
		
		Runtime.getRuntime().addShutdownHook(this);
	}
	
	public void run() { // shutdown thread
		MysqlFacade.terminateFacade();
	}
	
	public void startApp() {
		log.info("Scanning : " + sourceDir);
		while (true) {
			try {
				File f = new File(sourceDir);
				File[] files = f.listFiles();
				if (files != null && files.length > 0) {
					for (File eachFile : files) {
						if (!listExisting.contains(eachFile.getName())) {
							if (!alreadyUploadToday(eachFile)) {
								long idFile = writeFTPFileDb(eachFile);
								String filename = eachFile.getName().toLowerCase();
								if (filename.startsWith("pub")) {
									System.out.println("get id : " + idFile);	
									PublishLoader loader = new PublishLoader(eachFile.getAbsolutePath(), idFile);
									loader.start();
									moveToArchive(eachFile);
								} else if (filename.startsWith("atbl")) {
									ScheduleLoader loader = new ScheduleLoader(eachFile.getAbsolutePath(), idFile);
									loader.start();
									moveToArchive(eachFile);
								} else if (filename.startsWith("separate")) {
									SeparateLoader loader = new SeparateLoader(eachFile.getAbsolutePath(), idFile);
									loader.start();
									moveToArchive(eachFile);
								} else if (filename.startsWith("crew")) {
									CrewDataLoader loader = new CrewDataLoader(eachFile.getAbsolutePath(), idFile);
									loader.start();
									moveToArchive(eachFile);
								} else {
									log.warn("Filename not valid : " + filename);
								}
							} else {
								String event = "The samefile already being uploaded today : " + eachFile.getName();
								log.warn(event);
								Util.writeEvent(event);
								moveToArchive(eachFile);
							}
						}
					}
				}
				
				Thread.sleep(waitInterval);
			} catch (InterruptedException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
	}

	private void moveToArchive(File file) {
		try {
			String cmd = "mv " + sourceDir + "/" + file.getName() + " " + archiveDir + "/" + file.getName();
			System.out.println("exec : cmd");
			Runtime.getRuntime().exec(cmd);
			
			log.info("Moving to : " + archiveDir + "/" + file.getName());
			File archiveFile = new File(archiveDir, file.getName());
			if (archiveFile.exists()) {
				log.info("File already exists : "
						+ archiveFile.getAbsolutePath());
				log.info("overwriting...");
				archiveFile.delete();
			}
			file.renameTo(archiveFile);
		} catch (Exception e) {
			log.error("Cannot move file : " + file.getName());
		}
	}
	
	private long writeFTPFileDb(File f) {
		Connection conn = null;
		long retval = 0;
		try {
			conn = MysqlFacade.getConnection();
			QueryRunner qr = new QueryRunner();
			String q = "INSERT INTO garuda_file (ts, filename, upload_dt) VALUES (NOW(), ?, NOW())";
			qr.update(conn, q, f.getName());
			
			q = "SELECT LAST_INSERT_ID() as last";
			Object res = qr.query(conn, q, new ScalarHandler("last"));
			retval = (Long) res;
		} catch (Exception e) {
			e.printStackTrace();
			log.error("Err in writeFTPFileDb() : " + e.getMessage(), e);
		} finally {
			DbUtils.closeQuietly(conn);
		}
		return retval;
	}
	
	private boolean alreadyUploadToday(File f) {
		return false;
//		Connection conn = null;
//		boolean retval = false;
//		try {
//			conn = MysqlFacade.getConnection();
//			QueryRunner qr = new QueryRunner();
//			String q = "SELECT id FROM garuda_file WHERE upload_dt=DATE(NOW()) and filename=?";
//			Object res = qr.query(conn, q, f.getName(), new ScalarHandler("id"));
//			retval = (res != null);
//		} catch (Exception e) {
//			e.printStackTrace();
//			log.error("Err in alreadyUploadToday() : " + e.getMessage(), e);
//		} finally {
//			DbUtils.closeQuietly(conn);
//		}
//		return retval;
	}
	
	public static void main(String[] args) {
		FtpWatcher app = new FtpWatcher();
		app.init();
		app.startApp();
	}
}
