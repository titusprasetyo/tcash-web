package tsel_tunai;

import java.sql.*;
import java.util.regex.*;

public class MonthlyCharge
{
	private String status;
	private String amount;
	
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
		
		if(this.status.equals("1"))
			if(this.amount == null || !Pattern.compile("\\d+").matcher(this.amount).matches())
				s = "Amount must be decimal";
		
		return s;
	}
	
	public String [] insertConf()
	{
		String [] _s = {"", ""};
		
		try
		{
			String validate = this.validateInput();
			if(!validate.equals(""))
			{
				_s[0] = "0";
				_s[1] = validate;
			}
			else
			{
				this.createDbConn();
				query = "update CONFIGURATION set VALUE = ? where CONFIG = ?";
				pstmt = conn.prepareStatement(query);
				pstmt.clearParameters();
				pstmt.setString(1, this.status);
				pstmt.setString(2, "mcharge.status");
				pstmt.executeUpdate();
				
				if(this.status.equals("1"))
				{
					pstmt.clearParameters();
					pstmt.setString(1, Integer.toString(Integer.parseInt(this.amount)));
					pstmt.setString(2, "mcharge.amount");
					pstmt.executeUpdate();
				}
				
				pstmt.close();
				
				_s[0] = "1";
				_s[1] = "OK";
			}
		}
		catch(Exception e)
		{
			e.printStackTrace();
			_s[0] = "0";
			_s[1] = "Internal Error";
		}
		finally
		{
			this.closeDbConn();
		}
		
		return _s;
	}
	
	public String [] getConf()
	{
		String [] _s = {"", "", "", ""};
		
		try
		{
			this.createDbConn();
			query = "select CONFIG, VALUE from CONFIGURATION where CONFIG in (?, ?, ?, ?)";
			pstmt = conn.prepareStatement(query);
			pstmt.clearParameters();
			pstmt.setString(1, "mcharge.status");
			pstmt.setString(2, "mcharge.amount");
			pstmt.setString(3, "mcharge.date");
			pstmt.setString(4, "mcharge.maxdebt");
			rs = pstmt.executeQuery();
			while(rs.next())
			{
				String key = rs.getString(1);
				String val = rs.getString(2);
				
				if(key.equals("mcharge.status"))
					_s[0] = val;
				else if(key.equals("mcharge.amount"))
					_s[1] = val;
				else if(key.equals("mcharge.date"))
					_s[2] = val;
				else if(key.equals("mcharge.maxdebt"))
					_s[3] = val;
			}
			
			pstmt.close();
		}
		catch(Exception e)
		{
			e.printStackTrace();
			_s[0] = _s[1] = _s[2] = _s[3] = "";
		}
		finally
		{
			this.closeDbConn();
		}
		
		return _s;
	}
	
	public void setStatus(String status)
	{
		this.status = status;
	}
	
	public void setAmount(String amount)
	{
		this.amount = amount;
	}
}
