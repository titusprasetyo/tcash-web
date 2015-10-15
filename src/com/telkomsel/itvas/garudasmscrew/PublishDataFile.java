package com.telkomsel.itvas.garudasmscrew;

import java.sql.SQLException;

import com.telkomsel.itvas.database.MysqlFacade;

public class PublishDataFile {
	private String originalFilename;
	private String filename;
	private String operator;
	private String entryTime;
	private String executionTime;
	private String info;
	
	public void create() throws SQLException {
		String q = "INSERT INTO publish_data_file (original_filename, filename," +
				" operator, entry_ts, execution_ts, info) VALUES " +
				"(?,?,?,NOW(),null,?)";
		MysqlFacade.update(q, new Object[]{
			originalFilename,
			filename,
			operator,
			info
		});
	}

	public String getOriginalFilename() {
		return originalFilename;
	}

	public void setOriginalFilename(String originalFilename) {
		this.originalFilename = originalFilename;
	}

	public String getFilename() {
		return filename;
	}

	public void setFilename(String filename) {
		this.filename = filename;
	}

	public String getOperator() {
		return operator;
	}

	public void setOperator(String operator) {
		this.operator = operator;
	}

	public String getEntryTime() {
		return entryTime;
	}

	public void setEntryTime(String entryTime) {
		this.entryTime = entryTime;
	}

	public String getExecutionTime() {
		return executionTime;
	}

	public void setExecutionTime(String executionTime) {
		this.executionTime = executionTime;
	}

	public String getInfo() {
		return info;
	}

	public void setInfo(String info) {
		this.info = info;
	}
}
