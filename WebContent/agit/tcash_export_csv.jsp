<%@page import="tsel_tunai.DbCon"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1"%>
<%@page import="com.telkomsel.itvas.webstarter.User"%>
<%@page import="java.io.*, java.util.*, java.text.*, java.sql.*"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Reconciliation CSV Export</title>
</head>
<%
	Connection con = null;
	Statement stmt = null;
	PreparedStatement pstmt = null;
	ResultSet rs = null;
	String token = "";
	String content = "";
	token = request.getParameter("token");
	// get data from db first
	if (token != null) {
		try {
			token = new String(org.apache.commons.codec.binary.Base64.decodeBase64(token.getBytes()));
			//token = token.replace("#", "\'");
			token = token.replace("WHERE rnum BETWEEN ? AND ?", "");
			System.out.println("token : " + token);
			con = DbCon.getConnection();
			pstmt = con.prepareStatement(token);
			rs = pstmt.executeQuery();
			while (rs.next()) {
				content += rs.getString("REFID") + "|";
				content += rs.getString("MERCHANT_ID") + "|";
				content += rs.getString("AMOUNT") + "|";
				content += rs.getString("DESCRIPTION") + "|";
				content += rs.getString("DEPOSIT_TIME") + "|";
				content += rs.getString("IS_EXECUTED") + "|";
				content += rs.getString("TRX_TYPE") + "";
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
			String fileNameExport = "tcash_only_" + time + ".csv";
			String pathFileExport = application.getRealPath("/") + "CSV/" + fileNameExport;
			File f2 = new File(pathFileExport);
			if (!f2.exists()) {
				f2.createNewFile();
				//out.println("<a href='../CSV/" + fileNameExport + "' target='_blank'>" + fileNameExport + "</a> <br />");
				out.println("<a href='../finance/file_download.jsp?pathFile="+pathFileExport+"&fileName="+fileNameExport+"'>"+fileNameExport+"</a> <br />");
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

</body>
</html>