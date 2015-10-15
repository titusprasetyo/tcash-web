<%@page import="tsel_tunai.DbCon"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1"%>
<%@page import="com.telkomsel.itvas.webstarter.User"%>
<%@page import="java.io.*, java.util.*, java.text.*, java.sql.*"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Reconciliation Detail</title>
</head>
<%
	Connection con = null;
	Statement stmt = null;
	PreparedStatement pstmt = null;
	ResultSet rs = null;
	String query = "";
	String token = "";
	String content = "";
	token = request.getParameter("token");
	// get data from db first
	if (token != null) {
		try {
			System.out.println("token : " + token);
			query = "select * from merchant_cashout where cashout_id = ?";
			con = DbCon.getConnection();
			pstmt = con.prepareStatement(token);
			rs = pstmt.executeQuery();
			while (rs.next()) {
				content += rs.getString("BANKID") + ",";
				content += rs.getString("TXDT") + ",";
				content += rs.getString("JOURNALID") + ",";
				content += rs.getString("DESCRIPTION") + ",";
				content += rs.getString("TXTYPE") + ",";
				content += rs.getString("AMOUNT") + ",";
				content += rs.getString("RECONSTATUS") + ",";
				content += rs.getString("REFID") + ",";
				content += rs.getString("DTSTMP") + ",";
				content += rs.getString("ADJ_COMMENT") + "";
				content += "\n";
			}
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			try {
				pstmt.close();
				con.close();
			} catch (Exception ex) {
				ex.printStackTrace();
			}
		}
		//System.out.println("content : " + content);
		//write the data to file
		try {
			String DATE_FORMAT_NOW = "ddMMyyyy_HHmmss";
			Calendar cal = Calendar.getInstance();
			SimpleDateFormat sdf = new SimpleDateFormat(DATE_FORMAT_NOW);
			String time = sdf.format(cal.getTime());
			String fileNameExport = "REKON_MATCH_" + time + ".csv";
			String pathFileExport = application.getRealPath("/") + "CSV/" + fileNameExport;
			File f2 = new File(pathFileExport);
			if (!f2.exists()) {
				f2.createNewFile();
				//out.println("<a href='../CSV/" + fileNameExport + "' target='_blank'>" + fileNameExport + "</a> <br />");
				out.println("<a href='../finance/file_download.jsp?pathFile=" + pathFileExport + "&fileName="
						+ fileNameExport + "'>" + fileNameExport + "</a> <br />");
			} else {
				out.println("Error, file is exist <br />");
			}
			BufferedWriter output2 = new BufferedWriter(new FileWriter(pathFileExport));
			output2.write(content);
			output2.close();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
%>
<body>
	<table border="0" cellpadding="0" cellspacing="0" width="500px">
		<tr>
			<td
				style="border-left: 1px solid black; border-top: 1px solid black; border-right: 1px solid black;"
				colspan="4" align="center">Data Comparison Details</td>
		</tr>
		<tr>
			<td
				style="border-left: 1px solid black; border-bottom: 1px solid black; border-top: 1px solid black;"
				colspan="2" align="center">TCASH</td>
			<td style="border: 1px solid black;" colspan="2" align="center">RK
				BANK</td>
		</tr>
		<tr>
			<td style="border-left: 1px solid black;">Type</td>
			<td>: CASHOUT</td>
			<td style="border-left: 1px solid black;">Bank</td>
			<td style="border-right: 1px solid black;">: BNI</td>
		</tr>
		<tr>
			<td style="border-left: 1px solid black;">Merchant</td>
			<td>: 1111 - Grapari Malang</td>
			<td style="border-left: 1px solid black;">Date</td>
			<td style="border-right: 1px solid black;">: 10/10/2015</td>
		</tr>
		<tr>
			<td style="border-left: 1px solid black;">CashID</td>
			<td>: 10156</td>
			<td style="border-left: 1px solid black;">Description</td>
			<td style="border-right: 1px solid black;">: Tarik tunai</td>
		</tr>
		<tr>
			<td style="border-left: 1px solid black;">Date</td>
			<td>: 10/10/2015</td>
			<td style="border-left: 1px solid black;">Amount</td>
			<td style="border-right: 1px solid black;">: 1000000</td>
		</tr>
		<tr>
			<td style="border-left: 1px solid black;">Note</td>
			<td>: Daily settlement</td>
			<td style="border-left: 1px solid black;">&nbsp;</td>
			<td style="border-right: 1px solid black;">&nbsp;</td>
		</tr>
		<tr>
			<td
				style="border-left: 1px solid black; border-bottom: 1px solid black;">Amount</td>
			<td style="border-bottom: 1px solid black;">: 100000</td>
			<td
				style="border-left: 1px solid black; border-bottom: 1px solid black;">&nbsp;</td>
			<td
				style="border-right: 1px solid black; border-bottom: 1px solid black;">&nbsp;</td>
		</tr>
	</table>
</body>
</html>