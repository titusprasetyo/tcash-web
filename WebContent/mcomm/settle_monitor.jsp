<%@ page import="java.sql.*, java.util.Date, java.util.Locale, java.text.SimpleDateFormat, java.text.NumberFormat, java.lang.Math"%>
<%@ include file="/web-starter/taglibs.jsp"%>
<%@page import="com.telkomsel.itvas.webstarter.User"%>
<jsp:useBean id="DbCon" scope="page" class="tsel_tunai.DbCon"></jsp:useBean>
<script language="JavaScript">
<!--
function calendar(output)
{
	newwin = window.open('cal.jsp','','top=150,left=150,width=145,height=130,resizable=no');
	if(!newwin.opener)
		newwin.opener = self;
}

function calendar2(output)
{
	newwin = window.open('cal2.jsp','','top=150,left=150,width=145,height=130,resizable=no');
	if(!newwin.opener)
		newwin.opener = self;
}
//-->
</script>
<%
User user = (User)session.getValue("user");
String start = request.getParameter("dari");
String end = request.getParameter("ampe");
String type = request.getParameter("type");

Date d = null;
SimpleDateFormat sdf = null;

String query = null;
Connection conn = null;
Statement stmt = null;
PreparedStatement pstmt = null;
ResultSet rs = null;

NumberFormat nf =  NumberFormat.getInstance(Locale.ITALY);

if(type == null)
	type = "deposit";

String check_c = type.equals("cashout") ? "checked" : "";
String check_d = type.equals("deposit") ? "checked" : "";
String check_o = type.equals("other") ? "checked" : "";

int role = user.getRole();

try
{
	if(start == null)
	{
		d = new Date();
		sdf = new SimpleDateFormat("d-M-yyyy");
		start = sdf.format(d);
	}
	
	if(end == null)
	{
		d = new Date();
		sdf = new SimpleDateFormat("d-M-yyyy");
		end = sdf.format(d);
	}
	
	conn = DbCon.getConnection();
%>
<stripes:layout-render name="/web-starter/layout/standard.jsp" title="Settlement Monitor">
	<stripes:layout-component name="contents">
		<form name="formini" method="post" action="settle_monitor.jsp">
		<table width="30%" border="0" cellspacing="1" cellpadding="1">
		<tr bgcolor="#CC6633">
			<td colspan="2"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>Search Settlement Date</strong></font></div></td>
		</tr>
		<tr>
			<td><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Start Date</strong></font></td>
			<td><input type="text" name="dari" value="<%= start%>" readonly="true"><a href="javascript:calendar('opener.document.formini.dari.value');"><img src="${pageContext.request.contextPath}/STATIC/cal.gif" alt="Calendar" border="0" align="absmiddle"></a></td>
		</tr>
		<tr>
			<td><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>End Date</strong></font></td>
			<td><input type="text" name="ampe" value="<%= end%>" readonly="true"><a href="javascript:calendar2('document.formini.ampe.value');"><img src="${pageContext.request.contextPath}/STATIC/cal.gif" alt="Calendar" border="0" align="absmiddle"></a></td>
		</tr>
		<tr>
			<td><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>View By</strong></font></td>
			<td>
				<input type="radio" name="type" value="deposit" <%= check_d%>><font color="#CC6633" size="1" face="Verdana, Arial, Helvetica, sans-serif">Deposit</font><br>
				<input type="radio" name="type" value="cashout" <%= check_c%>><font color="#CC6633" size="1" face="Verdana, Arial, Helvetica, sans-serif">Cashout</font><br>
<%
	if(role != 3)
	{
%>	
				<input type="radio" name="type" value="other" <%= check_o%>><font color="#CC6633" size="1" face="Verdana, Arial, Helvetica, sans-serif">Other</font><br>
<%
	}
%>
			</td>
		</tr>
		<tr>
			<td></td>
			<td><input type="submit" name="Submit" value=" View "></td>
		</tr>
		</form>
		</table>
		<br>
<%
	int jumlah = 0;
	int cur_page = 1;
	int row_per_page = 100;
	
	if(type.equals("other"))
		query = "SELECT COUNT(*) AS jml FROM settlement_history WHERE status = '0' AND settle_date BETWEEN TO_DATE(?, 'DD-MM-YYYY HH24:MI:SS') AND TO_DATE(?, 'DD-MM-YYYY HH24:MI:SS')";
	else
		query = "SELECT COUNT(*) AS jml FROM merchant_" + type + " WHERE deposit_time BETWEEN TO_DATE(?, 'DD-MM-YYYY HH24:MI:SS') AND TO_DATE(?, 'DD-MM-YYYY HH24:MI:SS')";
	
	pstmt = conn.prepareStatement(query);
	pstmt.clearParameters();
	pstmt.setString(1, start + " 00:00:00");
	pstmt.setString(2, end + " 23:59:59");
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
		out.print("<a class='link' href='?cur_page=" + (minPaging - 1) + "&dari=" + start + "&ampe=" + end + "&type=" + type + "'>&lt;</a>");
	
	for(int i = minPaging; i <= maxPaging; i++)
	{
		if(i == cur_page)
			out.print(i + " ");
		else
			out.print("<a class='link' href='?cur_page=" + i + "&dari=" + start + "&ampe=" + end + "&type=" + type + "'>" + i + " </a>");
	}
	
	if(maxPaging + 1 <= total_page)
		out.print("<a class='link' href='?cur_page=" + (maxPaging + 1) + "&dari=" + start + "&ampe=" + end + "&type=" + type + "'>&gt;</a>");
%>
		<table width="90%" border="1" cellspacing="0" cellpadding="0" bordercolor="#FFF6EF">
		<tr>
			<td colspan="<%= role != 3 ? "14" : "13"%>"><div align="right"><font color="#CC6633" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>.:: Cash Book Log</strong></font></div></td>
		</tr>
		<tr>
			<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>ID</strong></font></div></td>
			<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Settle Time</strong></font></div></td>
			<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Merchant</strong></font></div></td>
			<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Amount</strong></font></div></td>
			<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Type</strong></font></div></td>
			<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Merchant Bank</strong></font></div></td>
			<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Note</strong></font></div></td>
			<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Status</strong></font></div></td>
			<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Print Date</strong></font></div></td>
			<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Completion Date</strong></font></div></td>
			<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Executor</strong></font></div></td>
<%
	if(role != 3)
	{
%>
			<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Recon File</strong></font></div></td>
<%
	}
%>
			<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Receipt</strong></font></div></td>
			<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Solve Ticket</strong></font></div></td>
		</tr>
<%
	if(type.equals("other"))
		query = "SELECT * FROM (SELECT a.*, ROWNUM rnum FROM (SELECT b.*, c.name, c.bank_acc_no FROM settlement_history b, merchant_info c, merchant d WHERE b.status = '0' AND b.merchant_id = d.merchant_id AND c.merchant_info_id = d.merchant_info_id AND b.settle_date BETWEEN TO_DATE(?, 'DD-MM-YYYY HH24:MI:SS') AND TO_DATE(?, 'DD-MM-YYYY HH24:MI:SS') ORDER BY b.settle_date DESC) a WHERE ROWNUM <= ?) WHERE rnum >= ?";
	else
		query = "SELECT * FROM (SELECT a.*, ROWNUM rnum FROM (SELECT b.*, c.name, c.bank_acc_no FROM merchant_" + type + " b, merchant_info c, merchant d WHERE b.merchant_id = d.merchant_id AND c.merchant_info_id = d.merchant_info_id AND b.deposit_time BETWEEN TO_DATE(?, 'DD-MM-YYYY HH24:MI:SS') AND TO_DATE(?, 'DD-MM-YYYY HH24:MI:SS') ORDER BY b.deposit_time DESC) a WHERE ROWNUM <= ?) WHERE rnum >= ?";
	
	pstmt = conn.prepareStatement(query);
	pstmt.clearParameters();
	pstmt.setString(1, start + " 00:00:00");
	pstmt.setString(2, end + " 23:59:59");
	pstmt.setInt(3, end_row);
	pstmt.setInt(4, start_row);
	rs = pstmt.executeQuery();
	while(rs.next())
	{
		String xid = type.equals("other") ? rs.getString("settlement_id") : rs.getString(type + "_id");
		String stime = type.equals("other") ? rs.getString("settle_date") : rs.getString("deposit_time");
		String merchant = rs.getString("name");
		String amount = rs.getString("amount");
		String stype = type.equals("other") ? (amount.startsWith("-") ? "DEP" : "COU") : (rs.getString("entry_login").equals("Daily Settlement") ? "DS" : "OD");
		String mbank = rs.getString("bank_acc_no");
		String note = type.equals("other") ? "Daily Settlement" : rs.getString("note");
		String status = type.equals("other") ? rs.getString("status") : rs.getString("is_executed");
		String print = type.equals("other") ? null : rs.getString("print_date");
		String completion = type.equals("other") ? null : rs.getString("completion_date");
		String exec = type.equals("other") ? null : rs.getString("executor");
		
		boolean is_recon = type.equals("other") ? false : (rs.getString("entry_login").equals("Daily Settlement") ? true : false);
		boolean is_receipt = type.equals("other") ? false : (print != null && !print.equals("") ? true : false);
		boolean is_ticket = type.equals("other") ? false : (completion != null && !completion.equals("") ? true : false);
		
		String [] _amount = amount.split(",");
		if(_amount.length > 1)
			amount = nf.format(Math.abs(Long.parseLong(_amount[0]))) + "," + _amount[1];
		else
			amount = nf.format(Math.abs(Long.parseLong(_amount[0])));
%>
		<tr>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= xid%></font></div></td>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= stime%></font></div></td>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= merchant%></font></div></td>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= amount%></font></div></td>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= stype%></font></div></td>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= mbank%></font></div></td>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= note%></font></div></td>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= status%></font></div></td>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= print%></font></div></td>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= completion%></font></div></td>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= exec%></font></div></td>
<%
		if(role != 3)
		{
			if(is_recon)
			{
%>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><a href="print_recon.jsp?mid=<%= rs.getString("merchant_id")%>&date=<%= stime%>&type=<%= type%>&xid=<%= xid%>">download</a></font></div></td>
<%
			}
			else
			{
%>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif">download</font></div></td>
<%
			}
		}
		
		if(is_receipt)
		{
%>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><a target='_receipt<%= type%>' href="print_receipt.jsp?mid=<%= rs.getString("merchant_id")%>&date=<%= print%>&type=<%= type%>&xid=<%= xid%>">print</a></font></div></td>
<%
		}
		else
		{
%>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif">print</font></div></td>
<%
		}
		
		if(is_ticket)
		{
%>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><a target='_ticket<%= type%>' href="print_ticket.jsp?mid=<%= rs.getString("merchant_id")%>&type=<%= type%>&xid=<%= xid%>">print</a></font></div></td>
<%
		}
		else
		{
%>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif">print</font></div></td>
<%
		}
%>
		</tr>
<%
	}
	
	pstmt.close();
	rs.close();
%>
		</table>
		
<%	if (start != null && end != null && !start.equals("") && !end.equals("")) { %>
		 <br>
		 <center><a href="settle_monitor_csv.jsp?dari=<%=start%>&ampe=<%=end%>&type=<%=type%>">Save as CSV</a></center>
<% } %>
	</stripes:layout-component>
</stripes:layout-render>

<%
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