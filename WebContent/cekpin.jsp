<%@ page import="java.sql.*"%><jsp:useBean id="DbCon" scope="page" class="tsel_tunai.DbCon"></jsp:useBean>
<%
	String input1 = request.getParameter("input1"); //msisdn or login name
	String input2 = request.getParameter("input2"); //type of input1 (0:msisdn;1:login)
	String sql = "";
	
	if (input2.equals("0")) {
		String sql = "select keyterminal from reader_terminal where msisdn = ? ";
	} else  if (input2.equals("1")){
		String sql = "select password from merchant where login = ? ";
	}
	//query data
	Connection conn = null;
	conn = DbCon.getConnection();
	try {
		PreparedStatement pstmt = conn.prepareStatement(sql);
		pstmt.setString(1,username);
		ResultSet rs = pstmt.executeQuery();
		while (rs.next()) {			
			out.println(rs.getString(0));
		}
	}
	catch(Exception  e){
	e.printStackTrace(System.out);
	} finally{
		try { conn.close(); } 
		catch(Exception ee){}
		//out.println("Failed");
	}	
%>