package tsel_tunai;

import java.sql.*;
import java.util.regex.*;

public class DailySettlement
{
	private String id = "";
	private String thresholdIn = "";
	private String thresholdOut = "";
	private String fineIn = "";
	private String fineOut = "";
	private String cycle = "";
	private String receiver = "";
	
	private String year = "";
	private String holidate = "";
	private String note = "";
	
	private Connection conn;
	private String query;
	private PreparedStatement pstmt;
	private ResultSet rs;
	
	public void createDbConn()
	{
		try
		{
			if(conn == null || conn.isClosed())
				conn = DbCon.getConnection();
		}
		catch(Exception e)
		{
			e.printStackTrace();
		}
	}
	
	public void closeDbConn()
	{
		try
		{
			if(conn != null)
			{
				conn.close();
				conn = null;
			}
		}
		catch(Exception e)
		{
			e.printStackTrace();
		}
	}
	
	public String validateInput()
	{
		String s = "";
		
		if(this.id == null || this.id.equals("") || this.id.equals(" "))
			s += "; Merchant cannot null";
		if(this.thresholdIn == null || this.thresholdOut == null || !Pattern.compile("\\d+").matcher(this.thresholdIn).matches() || !Pattern.compile("\\d+").matcher(this.thresholdOut).matches())
			s += "; Threshold amount must be decimal";
		if(this.cycle == null || this.cycle.equals(""))
			s += "; Settlement cycle cannot null";
		if(!s.equals(""))
			s = s.substring(2);
		
		return s;
	}
	
	public String [] getConf()
	{
		String [] _s = {"", "", "", "", "", ""};
		
		try
		{
			this.createDbConn();
			query = "SELECT threshold_in, threshold_out, fine_in, fine_out, cycle, alert_receiver FROM settlement_conf WHERE merchant_id = ?";
			pstmt = conn.prepareStatement(query);
			pstmt.clearParameters();
			pstmt.setString(1, this.id);
			rs = pstmt.executeQuery();
			if(rs.next())
			{
				_s[0] = rs.getString(1);
				_s[1] = rs.getString(2);
				_s[2] = rs.getString(3);
				_s[3] = rs.getString(4);
				_s[4] = rs.getString(5);
				_s[5] = rs.getString(6);
			}
			
			pstmt.close();
			rs.close();
		}
		catch(Exception e)
		{
			e.printStackTrace();
			_s[0] = _s[1] = _s[2] = _s[3] = _s[4] = _s[5] = "";
		}
		finally
		{
			this.closeDbConn();
		}
		
		return _s;
	}
	
	public void insertConf()
	{
		try
		{
			this.createDbConn();
			query = "INSERT INTO settlement_conf VALUES(?, ?, ?, ?, ?, ?, ?)";
			pstmt = conn.prepareStatement(query);
			pstmt.clearParameters();
			pstmt.setString(1, this.id);
			pstmt.setString(2, this.thresholdIn);
			pstmt.setString(3, this.thresholdOut);
			pstmt.setString(4, this.fineIn);
			pstmt.setString(5, this.fineOut);
			pstmt.setString(6, this.cycle);
			pstmt.setString(7, this.receiver);
			pstmt.executeUpdate();
			pstmt.close();
		}
		catch(Exception e)
		{
			e.printStackTrace();
		}
		finally
		{
			this.closeDbConn();
		}
	}
	
	public void insertHoliday()
	{
		try
		{
			this.createDbConn();
			query = "INSERT INTO holiday VALUES(?, TO_DATE(?, 'DD-MM-YYYY'), ?)";
			pstmt = conn.prepareStatement(query);
			pstmt.clearParameters();
			pstmt.setString(1, this.year);
			pstmt.setString(2, this.holidate);
			pstmt.setString(3, this.note);
			pstmt.executeUpdate();
			pstmt.close();
		}
		catch(Exception e)
		{
			e.printStackTrace();
		}
		finally
		{
			this.closeDbConn();
		}
	}
	
	public void updateType(String type)
	{
		try
		{
			this.createDbConn();
			query = "UPDATE tsel_merchant_account SET type = ? WHERE acc_no = (SELECT acc_no FROM merchant WHERE merchant_id = ?)";
			pstmt = conn.prepareStatement(query);
			pstmt.clearParameters();
			pstmt.setString(1, type);
			pstmt.setString(2, this.id);
			pstmt.executeUpdate();
			pstmt.close();
		}
		catch(Exception e)
		{
			e.printStackTrace();
		}
		finally
		{
			this.closeDbConn();
		}
	}
	
	public void resetConf()
	{
		try
		{
			this.createDbConn();
			query = "DELETE FROM settlement_conf WHERE merchant_id = ?";
			pstmt = conn.prepareStatement(query);
			pstmt.clearParameters();
			pstmt.setString(1, this.id);
			pstmt.executeUpdate();
			pstmt.close();
		}
		catch(Exception e)
		{
			e.printStackTrace();
		}
		finally
		{
			this.closeDbConn();
		}
	}
	
	public void resetHoliday()
	{
		try
		{
			this.createDbConn();
			query = "DELETE FROM holiday WHERE holidate = TO_DATE(?, 'DD-MM-YYYY')";
			pstmt = conn.prepareStatement(query);
			pstmt.clearParameters();
			pstmt.setString(1, this.holidate);
			pstmt.executeUpdate();
			pstmt.close();
		}
		catch(Exception e)
		{
			e.printStackTrace();
		}
		finally
		{
			this.closeDbConn();
		}
	}
	
	public void setId(String id)
	{
		this.id = id;
	}
	
	public void setThresholdIn(String thresholdIn)
	{
		this.thresholdIn = thresholdIn;
	}
	
	public void setThresholdOut(String thresholdOut)
	{
		this.thresholdOut = thresholdOut;
	}
	
	public void setFineIn(String fineIn)
	{
		if(fineIn != null)
			this.fineIn = fineIn;
	}
	
	public void setFineOut(String fineOut)
	{
		if(fineOut != null)
			this.fineOut = fineOut;
	}
	
	public void setCycle(String [] _cycle)
	{
		if(_cycle != null)
		{
			for(int i = 0; i < _cycle.length; i++)
				this.cycle += ";" + _cycle[i];
			
			this.cycle = this.cycle.substring(1);
		}
	}
	
	public void setReceiver(String [] _receiver)
	{
		if(_receiver != null)
		{
			for(int i = 0; i < _receiver.length; i++)
				this.receiver += ";" + _receiver[i];
			
			this.receiver = this.receiver.substring(1);
		}
	}
	
	public void setYear(String year)
	{
		this.year = year;
	}
	
	public void setHolidate(String holidate)
	{
		this.holidate = holidate;
	}
	
	public void setNote(String note)
	{
		if(note != null)
			this.note = note;
	}
}