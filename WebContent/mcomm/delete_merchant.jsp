<%@ page import = "java.io.*, java.util.*, java.text.*, java.sql.*" %>

<%@page import="com.telkomsel.itvas.webstarter.User"%>
<jsp:useBean id="DbCon" scope="page" class="tsel_tunai.DbCon"></jsp:useBean>

<%
	User user = (User)session.getValue("user");
	String mid = request.getParameter("mid");
	Connection conn = null;
	if(user != null)
	{
		conn = DbCon.getConnection();
		try
		{
			
			conn.setAutoCommit(false);
			//delete di table merchant
			String sql = "update merchant set status ='D' where merchant_id = ? ";
			PreparedStatement stmt = conn.prepareStatement(sql);
			stmt.setString(1,mid);
			stmt.executeUpdate();
			stmt.close();
			
			sql = "select acc_no from merchant where merchant_id = ?";
			PreparedStatement ps = conn.prepareStatement(sql);
			ps.setString(1, mid);
			ResultSet rs = ps.executeQuery();
			String acc_no = null;
			if(rs.next()) {
				
				acc_no = rs.getString(1);
			
			}  
			
			rs.close();
			ps.close();
			
			if(acc_no != null){
				
				sql = "update tsel_merchant_account set status = '0' where acc_no = ?";
				ps = conn.prepareStatement(sql);
				ps.setString(1, acc_no);
				ps.executeUpdate();
				ps.close();
				
				sql = "delete from reader_terminal where merchant_id = ?";
				ps = conn.prepareStatement(sql);
				ps.setString(1, mid);
				ps.executeUpdate();
				ps.close();
				
				
			}
			
			conn.commit();
			
			
		}
		catch(Exception  e){
			e.printStackTrace(System.out);
			conn.rollback();
		} finally {
		if(conn != null) {
			try { conn.setAutoCommit(true); } catch(Exception ee2){}
			try { conn.close(); } catch(Exception ee){}
		}
		}
	} else {
		response.sendRedirect("index.html");
	}
	response.sendRedirect("list_merchant.jsp?msisdn=");
%>