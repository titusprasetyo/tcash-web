<%@ page import="java.sql.*, java.util.Date, java.text.SimpleDateFormat"%>
<jsp:useBean id="DbCon" scope="page" class="tsel_tunai.DbCon"></jsp:useBean>
<%
String mid = request.getParameter("mid");
String separator = ",";

SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");

if(mid == null || mid.equals(""))
	mid = "ALL";

response.setContentType("text/csv");
response.setHeader("Content-Disposition", "attachment;	filename=\"tcash_" + mid + "_" + sdf.format(new Date()) + "_dailydeposit.csv\"");

String query = null;
Connection conn = null;
Statement stmt = null;
PreparedStatement pstmt = null;
ResultSet rs = null;

try
{
	out.println("deposit_id" + separator + "deposit_date" + separator + "merchant" + separator + "amount" + separator + "doc_number" + separator + "tsel_bank");
	
	conn = DbCon.getConnection();
	if(!mid.equals("ALL"))
		query = "SELECT b.*, c.* FROM merchant_deposit b, merchant_info c, settlement_history d, merchant e WHERE b.deposit_id = d.exec_id AND d.status = '1' AND d.amount < 0 AND b.merchant_id = e.merchant_id AND e.merchant_info_id = c.merchant_info_id AND b.merchant_id = '" + mid + "' ORDER BY b.deposit_time DESC";
	else
		query = "SELECT b.*, c.* FROM merchant_deposit b, merchant_info c, settlement_history d, merchant e WHERE b.deposit_id = d.exec_id AND d.status = '1' AND d.amount < 0 AND b.merchant_id = e.merchant_id AND e.merchant_info_id = c.merchant_info_id ORDER BY b.deposit_time DESC";
	
	stmt = conn.createStatement();
	rs = stmt.executeQuery(query);
	while(rs.next())
		out.println(rs.getString("deposit_id") + separator + rs.getString("deposit_time") + separator + rs.getString("name") + separator + rs.getString("amount") + separator + rs.getString("doc_number") + separator + rs.getString("tsel_bank_acc"));
	
	stmt.close();
	rs.close();
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