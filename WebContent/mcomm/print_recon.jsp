<%@ page import="java.sql.*"%>
<jsp:useBean id="DbCon" scope="page" class="tsel_tunai.DbCon"></jsp:useBean>
<%
String mid = request.getParameter("mid");
String date = request.getParameter("date");
String type = request.getParameter("type");
String xid = request.getParameter("xid");

String start = null;
String end = null;
String acc_no = null;

String separator = ",";
String compare = type.equals("deposit") ? "<" : ">";

boolean is_first = true;

response.setContentType("text/csv");
response.setHeader("Content-Disposition", "attachment;	filename=\"tcash_" + mid + "_" + date.substring(0, date.indexOf("-")) + "_" + type + ".csv\"");

String query = null;
Connection conn = null;
Statement stmt = null;
PreparedStatement pstmt = null;
ResultSet rs = null;

try
{
	conn = DbCon.getConnection();
	query = "SELECT acc_no, trx_date FROM settlement_history WHERE merchant_id = ? AND amount " + compare + " 0 AND exec_id <= ? ORDER BY settle_date DESC";
	pstmt = conn.prepareStatement(query);
	pstmt.clearParameters();
	pstmt.setString(1, mid);
	pstmt.setString(2, xid);
	rs = pstmt.executeQuery();
	while(rs.next())
	{
		if(is_first)
		{
			acc_no = rs.getString("acc_no");
			end = rs.getString("trx_date");
			continue;
		}
		
		start = rs.getString("trx_date");
		is_first = false;
	}
	
	pstmt.close();
	rs.close();
	
	if(end != null && !end.equals(""))
	{
		out.println("trx_date" + separator + "customer" + separator + "trx_type" + separator + "debit" + separator + "credit" + separator + "balance" + separator + "trx_id" + separator + "terminal_id" + separator + "description");
		
		if(start == null || start.equals(""))	
			start = "1999-01-01 00:00:00.0";
		
		String [] _start = start.split("\\.");
		String [] _end = end.split("\\.");
		
		query = "SELECT * FROM tsel_merchant_account_history WHERE acc_no = ? AND tx_date BETWEEN TO_DATE(?, 'YYYY-MM-DD HH24-MI-SS') AND TO_DATE(?, 'YYYY-MM-DD HH24-MI-SS')";
		pstmt = conn.prepareStatement(query);
		pstmt.clearParameters();
		pstmt.setString(1, acc_no);
		pstmt.setString(2, _start[0]);
		pstmt.setString(3, _end[0]);
		rs = pstmt.executeQuery();
		while(rs.next())
			out.println(rs.getString("tx_date") + separator + rs.getString("card_id") + separator + rs.getString("tx_tipe") + separator + rs.getString("debet") + separator + rs.getString("credit") + separator + rs.getString("balance") + separator + rs.getString("tx_id") + separator + rs.getString("payment_terminal_id") + separator + rs.getString("description"));
		
		pstmt.close();
		rs.close();
	}
}
catch(Exception e)
{
	e.printStackTrace(System.out);
}
finally
{
	try
	{
		conn.close();
	}
	catch(Exception e)
	{
	}
}
%>