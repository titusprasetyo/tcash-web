<%@ page import = "java.util.Locale, java.text.SimpleDateFormat, java.text.NumberFormat, java.sql.*" %>
<jsp:useBean id="DbCon" scope="page" class="tsel_tunai.DbCon"></jsp:useBean>
<%
String mid = request.getParameter("mid");
String type = request.getParameter("type");
String xid = request.getParameter("xid");

String name = null;
String bank_name = null;
String bank_acc = null;
String amount = null;
String print_date = null;
String executor = null;
String doc_num = null;

String doc_type = type.equals("deposit") ? "IN" : "OUT";
String s1 = type.equals("deposit") ? "diterima" : "dibayarkan";
String s2 = type.equals("deposit") ? "dari" : "kepada";

String [] _date = null;
String [] _month = {"I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI", "XII"};

SimpleDateFormat sdf = new SimpleDateFormat("dd-MM-yyyy");
NumberFormat nf =  NumberFormat.getInstance(Locale.ITALY);

String query = null;
Connection conn = null;
PreparedStatement pstmt = null;
ResultSet rs = null;

try
{
	conn = DbCon.getConnection();
	query = "SELECT * from merchant_" + type + " a, merchant b, merchant_info c WHERE a." + type + "_id = ? AND a.merchant_id = b.merchant_id AND b.merchant_info_id = c.merchant_info_id";
	pstmt = conn.prepareStatement(query);
	pstmt.clearParameters();
	pstmt.setString(1, xid);
	rs = pstmt.executeQuery();
	if(rs.next())
	{
		name = rs.getString("name");
		bank_name = type.equals("deposit") ? "" : rs.getString("bank_name");
		bank_acc = type.equals("deposit") ? rs.getString("tsel_bank_acc") : rs.getString("bank_acc_no");
		amount = rs.getString("amount");
		print_date = sdf.format(rs.getTimestamp("print_date"));
		executor = rs.getString("executor");
		doc_num = rs.getString("receipt_id");
	}
	
	rs.close();
	pstmt.close();
	
	_date = print_date.split("-");
	
	String [] _amount = amount.split(",");
	if(_amount.length > 1)
		amount = nf.format(Long.parseLong(_amount[0])) + "," + _amount[1];
	else
		amount = nf.format(Long.parseLong(_amount[0]));
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
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
	<title>T-Cash</title>
	<style type="text/css">
	<!--
	body,td,th
	 {
		font-family: Courier New, Courier, monospace;
		font-size: 12px;
	}
	-->
	</style>
</head>
<body>
	<table width="900" border="1" rules="groups" frame="hsides" align="center" cellpadding="10" cellspacing="2">
	<thead>
	<tr>
		<td width="50%"><b>TCash Settlement (<%= type%>) Solve Ticket</b></td>
		<td><div align="right">PT. TELEKOMUNIKASI SELULAR<br>Wisma Mulia<br>Jl. Gatot Subroto KAV 42 Jakarta Selatan 12710<br>NPWP/PKP: 01.718.327.8.091.00</div></td>
	</tr>
	</thead>
	<tbody>
	<tr>
		<td colspan="2">Pada tanggal <%= print_date%> telah <%= s1%> sebesar Rp.<%= amount%> <%= s2%> <%= name%> dengan tujuan <%= bank_name%> nomor rekening <%= bank_acc%> untuk settlement <%= doc_num%>/TSEL/TCASH-<%= doc_type%>/<%= _month[Integer.parseInt(_date[1]) - 1]%>/<%= _date[2]%><br><br><br></td>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<td width="20%"><div align="center">Executed by<br><br><br><br><%= executor%></div></td>
	</tr>
	</tbody>
	<tfoot>
	<tr>
		<td width="50%">TCash - Finance</td>
		<td><div align="right"><b>Telkomsel</b></div></td>
	</tr>
	</tfoot>
	</table>
</body>
</html>
