<%@ page import = "java.io.*, java.util.*, java.text.*, java.sql.*" %>

<%@page import="com.telkomsel.itvas.webstarter.User"%>
<jsp:useBean id="DbCon" scope="page" class="tsel_tunai.DbCon"></jsp:useBean>

<%
	User user = (User)session.getAttribute("user");
	String username = request.getParameter("username");
	if(user != null)
	{
		Connection conn = null;
		conn = DbCon.getConnection();
		try
		{
			String sql = "delete from admin where username = ? ";
			PreparedStatement stmt = conn.prepareStatement(sql);
			stmt.setString(1,username);
			stmt.executeUpdate();
			stmt.close();
			response.sendRedirect("admin.jsp?username=");
		}
		catch(Exception  e){
			e.printStackTrace(System.out);
		} finally{
		try { conn.close(); } catch(Exception ee){}
		}
	} else {
		response.sendRedirect("admin.html");
	}
%>