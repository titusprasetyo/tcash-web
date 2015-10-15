package com.telkomsel.itvas.garudasmscrew;

import java.sql.SQLException;

import com.telkomsel.itvas.database.MysqlFacade;

public class OutgoingSMS {
	private String msisdn;
	private String message;
	private long trxID;
	private int status;
	
	public void create() throws SQLException {
		String q = "INSERT INTO sms_out_pool (msisdn, message, trx_id)" +
				" VALUES (?,?,?)";
		MysqlFacade.update(q, new Object[] {
			msisdn,
			message,
			trxID
		});
	}
	public String getMsisdn() {
		return msisdn;
	}
	public void setMsisdn(String msisdn) {
		this.msisdn = msisdn;
	}
	public String getMessage() {
		return message;
	}
	public void setMessage(String message) {
		this.message = message;
	}
	public int getStatus() {
		return status;
	}
	public void setStatus(int status) {
		this.status = status;
	}
	public long getTrxID() {
		return trxID;
	}
	public void setTrxID(long trxID) {
		this.trxID = trxID;
	}
}
