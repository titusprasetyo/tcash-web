package com.telkomsel.itvas.garudasmscrew.backend;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import org.apache.commons.dbutils.DbUtils;
import org.apache.log4j.Logger;

import com.telkomsel.itvas.database.MysqlFacade;
import com.telkomsel.itvas.garudasmscrew.OutgoingSMS;
import com.telkomsel.itvas.webstarter.WebStarterProperties;

public class SendSMSDaemon extends Thread {
	PreparedStatement psGetPublishFile;

	PreparedStatement psUpdatePublishFile;

	SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

	public static Logger LOG = Logger.getLogger(SendSMSDaemon.class);

	private ArrayList<SendingThread> threadList;
	
	private RetryThread retryThread;
	
	public static int RETRY_LIMIT;
	
	public static int RETRY_INTERVAL;

	public static void main(String[] args) {
		SendSMSDaemon app = new SendSMSDaemon();
		app.runDaemon();
	}
	
	// Shutdown hook thread
	public void run() {
		if (threadList != null) {
			for (SendingThread thread : threadList) {
				thread.stopThread();
			}
		}
	}

	private void runDaemon() {
		Runtime.getRuntime().addShutdownHook(this);
		LOG.info("Application started");

		WebStarterProperties prop = WebStarterProperties.getInstance();
		
		// Set-up database connection
		String host = prop.getProperty("db_host");
		String username = prop.getProperty("db_username");
		String password = prop.getProperty("db_password");
		String name = prop.getProperty("db_name");
		String connectionString = "jdbc:mysql://" + host + "/" + name
				+ "?user=" + username + "&password=" + password;
		int nbThread = prop.getIntProperty("sms.sending.thread");
		RETRY_INTERVAL = prop.getIntProperty("sms.retry.interval");
		RETRY_LIMIT = prop.getIntProperty("sms.retry.limit");

		MysqlFacade.initStandalone(connectionString, username, password);

		threadList = new ArrayList<SendingThread>();
		for (int i=0; i < nbThread; i++) {
			SendingThread thread = new SendingThread(i + 1);
			thread.start();
			threadList.add(thread);
		}
		
		LOG.info("Starting Retry SMS");
		retryThread = new RetryThread(1);
		retryThread.start();
	}

	public int getRetryLimit() {
		return RETRY_LIMIT;
	}

	public int getRetryInterval() {
		return RETRY_INTERVAL;
	}
}

class SendingThread extends Thread {
	private Connection conn;
	private boolean isRunning = false;
	private int id;
	
	public SendingThread(int id) {
		SendSMSDaemon.LOG.info("Starting Sending Thread ID " + id);
		this.id = id;
	}
	
	public void run() {
		
		isRunning = true;
		String q = "SELECT * FROM sms_out_pool";
		String qDelete = "DELETE FROM sms_out_pool WHERE id=?";
		String qMove = "INSERT INTO sms_sent (SELECT *,'0' FROM sms_out_pool WHERE id=?)";
		try {
			conn = MysqlFacade.getConnection();
			PreparedStatement ps = conn.prepareStatement(q);
			PreparedStatement psDelete = conn.prepareStatement(qDelete);
			PreparedStatement psMove = conn.prepareStatement(qMove);
			conn.setAutoCommit(false);
			while (isRunning) {
				ResultSet rs = ps.executeQuery();
				while (rs.next()) {
					sendSMS(rs.getString("msisdn"), rs.getString("message"));
					psMove.setLong(1, rs.getLong("id"));
					psMove.executeUpdate();
					psDelete.setLong(1, rs.getLong("id"));
					psDelete.executeUpdate();
				}
				conn.commit();
				try {
					Thread.sleep(1000);
				} catch (InterruptedException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
				
			}
		} catch (SQLException e1) {
			SendSMSDaemon.LOG.fatal("Cannot get message from sms_out_pool", e1);
		} finally {
			DbUtils.closeQuietly(conn);
		}
	}
	
	private void sendSMS(String dest, String msg) {
		SendSMSDaemon.LOG.info("Send SMS|" + dest + "|" + msg);
	}

	public void stopThread() {
		SendSMSDaemon.LOG.info("Stopping Sending Thread ID " + id);
		isRunning = false;
		DbUtils.closeQuietly(conn);
	}
}

class RetryThread extends Thread {
	private Connection conn;
	private boolean isRunning = false;
	private int id;
	
	public RetryThread(int id) {
		SendSMSDaemon.LOG.info("Starting Retry Thread ID " + id);
		this.id = id;
	}
	
	public void run() {
		isRunning = true;
		String q = "SELECT * FROM push_entry WHERE delivered=0 AND next_retry_time < NOW() AND retry_count<" + SendSMSDaemon.RETRY_LIMIT;
		String qUpdate = "UPDATE push_entry SET retry_count=retry_count+1, next_retry_time=ADDDATE(NOW(), INTERVAL "+ SendSMSDaemon.RETRY_INTERVAL+ " SECOND) WHERE id=?";
		try {
			conn = MysqlFacade.getConnection();
			PreparedStatement ps = conn.prepareStatement(q);
			PreparedStatement psUpdate = conn.prepareStatement(qUpdate);
			conn.setAutoCommit(false);
			while (isRunning) {
				ResultSet rs = ps.executeQuery();
				while (rs.next()) {
					OutgoingSMS sms = new OutgoingSMS();
					sms.setMsisdn(rs.getString("msisdn"));
					sms.setMessage(rs.getString("message"));
					sms.setTrxID(rs.getLong("id"));
					sms.create();
					
					psUpdate.setLong(1, rs.getLong("id"));
					psUpdate.executeUpdate();
				}
				conn.commit();
				try {
					Thread.sleep(1000);
				} catch (InterruptedException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
				
			}
		} catch (SQLException e1) {
			SendSMSDaemon.LOG.fatal("Cannot get message from push_entry", e1);
		} finally {
			DbUtils.closeQuietly(conn);
		}
	}
	
	public void stopThread() {
		SendSMSDaemon.LOG.info("Stopping Thread ID " + id);
		isRunning = false;
		DbUtils.closeQuietly(conn);
	}
}
