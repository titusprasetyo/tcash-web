<%@ page import = "java.io.*, java.util.*, java.text.*, java.sql.*" %>
<%@page import="com.telkomsel.itvas.webstarter.User"%>
<jsp:useBean id="DbCon" scope="page" class="tsel_tunai.DbCon"></jsp:useBean>

<%
	User user = (User)session.getValue("user");
	String tid = request.getParameter("deposit_id");
	Connection conn = null;
	if(user != null)
	{
		
		conn = DbCon.getConnection();
		try
		{
				String sql = "delete from merchant_deposit where deposit_id = ?";
				PreparedStatement ps = conn.prepareStatement(sql);
				ps.setString(1, tid);
				ps.executeUpdate();
				ps.close();
			conn.commit();
			response.sendRedirect("deposit_list.jsp?name=&msg=Deposit+deleted");
		}
		catch(Exception  e){
			e.printStackTrace(System.out);
			conn.rollback();
			response.sendRedirect("deposit_list.jsp?name=&msg=Deposit+delete+failed");
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
