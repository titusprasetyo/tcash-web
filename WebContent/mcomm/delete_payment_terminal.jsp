<%@ page import = "java.io.*, java.util.*, java.text.*, java.sql.*" %>
<%@page import="com.telkomsel.itvas.webstarter.User"%>
<jsp:useBean id="DbCon" scope="page" class="tsel_tunai.DbCon"></jsp:useBean>

<%
	User user = (User)session.getValue("user");
	String tid = request.getParameter("tid");
	Connection conn = null;
	if(user != null)
	{
		
		conn = DbCon.getConnection();
		try
		{	
			boolean b1 = false;
			
			String sql = "select ref_num from tsel_merchant_account_history where payment_terminal_id = ?";
			PreparedStatement ps = conn.prepareStatement(sql);
			ps.setString(1, tid);
			ResultSet rs;
			rs = ps.executeQuery();
			if (rs.next()) b1=true;
			rs.close();
			ps.close();	
			
			if (b1) { sql = "update reader_terminal set msisdn='x'||msisdn where terminal_id = ?";
			} else {
				sql = "delete from reader_terminal where terminal_id = ?";
			}
			ps = conn.prepareStatement(sql);
			ps.setString(1, tid);
			ps.executeUpdate();
			ps.close();
			conn.commit();
			response.sendRedirect("list_payment.jsp?name=&msg=Payment+Terminal+deleted");		
		}
		catch(Exception  e){
			e.printStackTrace(System.out);
			conn.rollback();
			response.sendRedirect("list_payment.jsp?name=&msg=Payment+Terminal+delete+failed");
		} finally {
		if(conn != null) {
			try { conn.setAutoCommit(true); } catch(Exception ee2){}
			try { conn.close(); } catch(Exception ee){}
		}
		}
	} else {
		response.sendRedirect("index.html");
	}
%>