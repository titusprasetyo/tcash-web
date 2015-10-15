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
				String sql = "delete from loading_terminal where terminal_id = ?";
				PreparedStatement ps = conn.prepareStatement(sql);
				ps.setString(1, tid);
				ps.executeUpdate();
				ps.close();
			conn.commit();
			response.sendRedirect("list_loading.jsp?name=&msg=Loading+Terminal+deleted");
		}
		catch(Exception  e){
			e.printStackTrace(System.out);
			conn.rollback();
			response.sendRedirect("list_loading.jsp?name=&msg=Loading+Terminal+delete+failed");
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