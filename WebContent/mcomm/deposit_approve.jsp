<%@ page import="java.sql.*, java.text.NumberFormat, java.util.Locale"%>
<%@ include file="/web-starter/taglibs.jsp"%>
<%@page import="com.telkomsel.itvas.webstarter.User"%>
<jsp:useBean id="DbCon" scope="page" class="tsel_tunai.DbCon"></jsp:useBean>
<%
User user = (User)session.getValue("user");
String select = request.getParameter("select");
String merchant = request.getParameter("merchant");
String [] _id = request.getParameterValues("status");

String query = null;
Connection conn = null;
Statement stmt = null;
PreparedStatement pstmt = null;
ResultSet rs = null;

NumberFormat nf =  NumberFormat.getInstance(Locale.ITALY);

if(merchant == null)
	merchant = "";

try
{
	conn = DbCon.getConnection();
	
	if(select != null && select.equals("0") && _id != null)
	{
		String xid = "";
		String sid = "";
		
		for(int i = 0; i < _id.length; i++)
		{
			String [] _id1 = _id[i].split("\\|");
			xid += ", '" + _id1[0] + "'";
			sid += ", '" + _id1[1] + "'";
		}
		
		xid = xid.substring(2);
		sid = sid.substring(2);
		
		conn.setAutoCommit(false);
		query = "UPDATE merchant_deposit SET is_executed = '2', print_date = SYSDATE, completion_date = SYSDATE, executor = ?, receipt_id = settlement_doc_sequence.NEXTVAL WHERE deposit_id IN (" + xid + ")";
		pstmt = conn.prepareStatement(query);
		pstmt.clearParameters();
		pstmt.setString(1, user.getUsername());
		int q1 = pstmt.executeUpdate();
		pstmt.close();
		
		query = "UPDATE settlement_history SET status = '2' WHERE settlement_id IN (" + sid + ")";
		stmt = conn.createStatement();
		int q2 = stmt.executeUpdate(query);
		stmt.close();
		
		query = "INSERT INTO activity_log (userlogin, access_time, activity, note, ip) VALUES (?, SYSDATE, ?, ?, ?)";
		pstmt = conn.prepareStatement(query);
		pstmt.clearParameters();
		pstmt.setString(1, user.getUsername());
		pstmt.setString(2, "Approve Daily Deposit");
		pstmt.setString(3, "Success");
		pstmt.setString(4, request.getRemoteAddr());
		pstmt.executeUpdate();
		pstmt.close();
		
		if(q1 == _id.length && q2 == _id.length)
		{
			conn.commit();
			out.println("<script language='javascript'>alert('Update successful')</script>");
		}
		else
		{
			conn.rollback();
			out.println("<script language='javascript'>alert('Update failed: Internal Error')</script>");
		}
		
		conn.setAutoCommit(true);
	}
%>
<stripes:layout-render name="/web-starter/layout/standard.jsp" title="Daily Deposit Approval">
	<stripes:layout-component name="contents">
		<form name="form" method="post" action="deposit_approve.jsp">
		<input type="hidden" name="select" value="1">
		<table width="30%" border="0" cellspacing="1" cellpadding="1">
		<tr bgcolor="#CC6633">
			<td colspan="2"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>Search by Merchant</strong></font></div></td>
		</tr>
		<tr>
			<td><input type="submit" name="Submit" value="View"></td>
			<td>
				<select name="merchant">
					<option value=''></option>
<%
	query = "SELECT a.merchant_id, b.name FROM merchant a, merchant_info b, settlement_conf c WHERE a.merchant_id = c.merchant_id AND a.merchant_info_id = b.merchant_info_id ORDER BY a.merchant_id";
	stmt = conn.createStatement();
	rs = stmt.executeQuery(query);
	while(rs.next())
	{
		if(rs.getString("merchant_id").equals(merchant))
			out.println("<option value='" + rs.getString("merchant_id") + "' selected>" + rs.getString("name") + "</option>");
		else
			out.println("<option value='" + rs.getString("merchant_id") + "'>" + rs.getString("name") + "</option>");
	}

	stmt.close();
	rs.close();
%>
				</select>
			</td>
		</tr>
		</table>
		<br>
<%
	int jumlah = 0;
	int cur_page = 1;
	int row_per_page = 100;
	
	query = "SELECT COUNT(*) AS jml FROM merchant_deposit a, settlement_history b WHERE a.deposit_id = b.exec_id AND b.status = '1' AND b.amount < 0";
	if(!merchant.equals(""))
		query += " AND a.merchant_id = ?";
	
	pstmt = conn.prepareStatement(query);
	pstmt.clearParameters();
	if(!merchant.equals(""))
		pstmt.setString(1, merchant);
	
	rs = pstmt.executeQuery();
	if(rs.next())
		jumlah = rs.getInt("jml");
	
	pstmt.close();
	rs.close();
	
	if(request.getParameter("cur_page") != null)
		cur_page = Integer.parseInt(request.getParameter("cur_page"));
	
	int start_row = (cur_page - 1) * row_per_page + 1;
	int end_row = start_row + row_per_page - 1;
	int total_page = (jumlah / row_per_page) + 1;
	if(jumlah % row_per_page == 0)
		total_page--;
	
	int minPaging = cur_page - 5;
	if(minPaging < 1)
		minPaging = 1;
	
	int maxPaging = cur_page + 5;
	if(maxPaging > total_page)
		maxPaging = total_page;
	
	out.println("Page : ");
	
	if(minPaging - 1 > 0)
		out.print("<a class='link' href='?cur_page=" + (minPaging - 1) + "&merchant=" + merchant + "&select=1'>&lt;</a>");
	
	for(int i = minPaging; i <= maxPaging; i++)
	{
		if(i == cur_page)
			out.print(i + " ");
		else
			out.print("<a class='link' href='?cur_page=" + i + "&merchant=" + merchant + "&select=1'>" + i + " </a>");
	}
	
	if(maxPaging + 1 <= total_page)
		out.print("<a class='link' href='?cur_page=" + (maxPaging + 1) + "&merchant=" + merchant + "&select=1'>&gt;</a>");
%>
		<table width="90%" border="1" cellspacing="0" cellpadding="0" bordercolor="#FFF6EF">
		<tr>
			<td colspan="8"><div align="right"><font color="#CC6633" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>.:: Daily Deposit List</strong></font></div></td>
		</tr>
		<tr>
			<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Deposit ID</strong></font></div></td>
			<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Deposit Date</strong></font></div></td>
			<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Merchant</strong></font></div></td>
			<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Amount</strong></font></div></td>
			<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Doc Number</strong></font></div></td>
			<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>TSEL Bank Account</strong></font></div></td>
			<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Merchant Bank Account</strong></font></div></td>
			<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Status</strong></font></div></td>
		</tr>
<%
	if(!merchant.equals(""))
		query = "SELECT * FROM (SELECT a.*, ROWNUM rnum FROM (SELECT b.*, c.*, d.settlement_id FROM merchant_deposit b, merchant_info c, settlement_history d, merchant e WHERE b.deposit_id = d.exec_id AND d.status = '1' AND d.amount < 0 AND b.merchant_id = e.merchant_id AND e.merchant_info_id = c.merchant_info_id AND b.merchant_id = '" + merchant + "' ORDER BY b.deposit_time DESC) a WHERE ROWNUM <= ?) WHERE rnum >= ?";
	else
		query = "SELECT * FROM (SELECT a.*, ROWNUM rnum FROM (SELECT b.*, c.*, d.settlement_id FROM merchant_deposit b, merchant_info c, settlement_history d, merchant e WHERE b.deposit_id = d.exec_id AND d.status = '1' AND d.amount < 0 AND b.merchant_id = e.merchant_id AND e.merchant_info_id = c.merchant_info_id ORDER BY b.deposit_time DESC) a WHERE ROWNUM <= ?) WHERE rnum >= ?";
	
	pstmt = conn.prepareStatement(query);
	pstmt.clearParameters();
	pstmt.setInt(1, end_row);
	pstmt.setInt(2, start_row);
	rs = pstmt.executeQuery();
	while(rs.next())
	{
		String amount = rs.getString("amount");
		String [] _amount = amount.split(",");
		if(_amount.length > 1)
			amount = nf.format(Long.parseLong(_amount[0])) + "," + _amount[1];
		else
			amount = nf.format(Long.parseLong(_amount[0]));
%>
		<tr>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("deposit_id")%></font></div></td>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("deposit_time")%></font></div></td>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("name")%></font></div></td>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= amount%></font></div></td>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("doc_number")%></font></div></td>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("tsel_bank_acc")%></font></div></td>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("bank_acc_no")%></font></div></td>
			<td><div align="center"><input type="checkbox" name="status" value="<%= rs.getString("deposit_id") + "|" + rs.getString("settlement_id")%>"><font size="1" face="Verdana, Arial, Helvetica, sans-serif">OK</font></div></td>
		</tr>
<%
	}
	
	pstmt.close();
	rs.close();
%>
		<tr>
			<td colspan="8"><div align="right"><input type="submit" name="Submit2" value="Update" onclick="document.getElementById('select').value = '0';"></div></td>
		</tr>
		</table>
		</form>
	</stripes:layout-component>
</stripes:layout-render>

<%
}
catch(Exception e)
{
	e.printStackTrace(System.out);
	
	try
	{
		conn.rollback();
	}
	catch(Exception ee)
	{
	}
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