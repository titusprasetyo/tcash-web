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
<body>
	<%
		Connection con = null;
		Statement stmt = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		String query = "";
		String content = "";

		SimpleDateFormat sdf = new SimpleDateFormat("d-M-yyyy");
		DecimalFormat formatter2 = new DecimalFormat("#,###.00");

		String token = request.getParameter("token");
		String from = request.getParameter("from");
		String to = request.getParameter("to");

		String header = "";
		// get data from db first
		if (token != null) {
			if ("md".equalsIgnoreCase(token)) {
				header = "TOTAL CASHOUT AMOUNT MATCH DETAIL FROM " + from + " TO " + to;
				query = "select " + "sum(case when bankid='bni' then amount else 0 end) bni, "
						+ "sum(case when bankid='bmr' then amount else 0 end) mandiri, " + "sum(amount) allamt "
						+ "from ag_t_bank_statement " + "where reconstatus=1 " + "and refid is not null "
						+ "and upper(txtype)='D' and to_date(TXDT) between ? and ?";
			}
			if ("bd".equalsIgnoreCase(token)) {
				header = "TOTAL CASHOUT AMOUNT BANK ONLY DETAIL FROM " + from + " TO " + to;
				query = "select " + "sum(case when bankid='bni' then amount else 0 end) bni, "
						+ "sum(case when bankid='bmr' then amount else 0 end) mandiri, " + "sum(amount) allamt "
						+ "from ag_t_bank_statement " + "where reconstatus=0 " + "and refid is null "
						+ "and upper(txtype)='D' and to_date(TXDT) between ? and ?";
			}
			if ("mc".equalsIgnoreCase(token)) {
				header = "TOTAL CASHIN AMOUNT MATCH DETAIL FROM " + from + " TO " + to;
				query = "select " + "sum(case when bankid='bni' then amount else 0 end) bni, "
						+ "sum(case when bankid='bmr' then amount else 0 end) mandiri, " + "sum(amount) allamt "
						+ "from ag_t_bank_statement " + "where reconstatus=1 " + "and refid is not null "
						+ "and upper(txtype)='C' and to_date(TXDT) between ? and ?";
			}
			if ("bc".equalsIgnoreCase(token)) {
				header = "TOTAL CASHIN AMOUNT BANK ONLY DETAIL FROM " + from + " TO " + to;
				query = "select " + "sum(case when bankid='bni' then amount else 0 end) bni, "
						+ "sum(case when bankid='bmr' then amount else 0 end) mandiri, " + "sum(amount) allamt "
						+ "from ag_t_bank_statement " + "where reconstatus=0 " + "and refid is null "
						+ "and upper(txtype)='C' and to_date(TXDT) between ? and ?";
			}
			if ("ma".equalsIgnoreCase(token)) {
				header = "TOTAL AMOUNT MATCH DETAIL FROM " + from + " TO " + to;
				query = "select " + "sum(case when bankid='bni' then amount else 0 end) bni, "
						+ "sum(case when bankid='bmr' then amount else 0 end) mandiri, " + "sum(amount) allamt "
						+ "from ag_t_bank_statement " + "where reconstatus=1 " + "and refid is not null "
						+ "and to_date(TXDT) between ? and ?";
			}
			if ("ba".equalsIgnoreCase(token)) {
				header = "TOTAL AMOUNT BANK ONLY DETAIL FROM " + from + " TO " + to;
				query = "select " + "sum(case when bankid='bni' then amount else 0 end) bni, "
						+ "sum(case when bankid='bmr' then amount else 0 end) mandiri, " + "sum(amount) allamt "
						+ "from ag_t_bank_statement " + "where reconstatus=0 " + "and refid is null "
						+ "and to_date(TXDT) between ? and ?";
			}
			out.print("<hr>");
			out.print(header);
			out.print("<hr>");
			try {
				con = DbCon.getConnection();
				pstmt = con.prepareStatement(query);
				pstmt.setDate(1, new java.sql.Date(sdf.parse(from).getTime()));
				pstmt.setDate(2, new java.sql.Date(sdf.parse(to).getTime()));
				rs = pstmt.executeQuery();
				if (rs.next()) {
					out.print("<table cellpadding='0' cellspacing='0' border='0'>");
					out.print("<tr><td width='100'>");
					out.print("BNI</td><td> : </td><td width='200' align='right'>" + formatter2.format(rs.getBigDecimal("bni")));
					out.print("</td></tr>");
					out.print("<tr><td width='100'>");
					out.print("MANDIRI</td><td> : </td><td width='200' align='right'>" + formatter2.format(rs.getBigDecimal("mandiri")));
					out.print("</td></tr>");
					out.print("<tr><td width='100'>");
					out.print("TOTAL</td><td> : </td><td width='200' align='right'>" + formatter2.format(rs.getBigDecimal("allamt")));
					out.print("</td></tr>");
					out.print("</table>");
					out.print("<hr>");
					out.print("<a href='javascript:window.print();'> Print </a>");
				}
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
	%>
</body>
</html>