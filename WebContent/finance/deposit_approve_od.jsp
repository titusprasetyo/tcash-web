<%@ page import="java.sql.*, java.text.NumberFormat, java.text.SimpleDateFormat, java.util.Locale, java.util.Calendar, java.util.Date"%>
<%@ include file="/web-starter/taglibs.jsp"%>
<%@page import="com.telkomsel.itvas.webstarter.User"%>
<jsp:useBean id="DbCon" scope="page" class="tsel_tunai.DbCon"></jsp:useBean>
<jsp:useBean id="UTx" scope="request" class="tsel_tunai.UssdTx"></jsp:useBean>
<jsp:useBean id="reg" scope="request" class="tsel_tunai.Register2Bean"></jsp:useBean>

<script language="JavaScript">
<!--
function checkExecute(xid)
{
	with(document)
		return confirm("Do you really want to execute this deposit (id: " + xid + ")?");
}

function calendar(output)
{
	newwin = window.open('cal_tct.jsp?output=' + output + '','','top=150,left=150,width=145,height=130,resizable=no');
	if(!newwin.opener)
		newwin.opener = self;
}

function solveThis(xid, print, tdate, cur_page)
{
	window.location = "deposit_approve_od.jsp?xid=" + xid + "&print" + xid + "=" + print + "&tdate=" + tdate + "&cur_page=" + cur_page;
}
//-->
</script>
<%!
String returnFloat(String amount){
	NumberFormat nf =  NumberFormat.getInstance(Locale.ITALY);
	String [] _amount = amount.split(",");
	if(_amount.length > 1)
			amount = nf.format(Long.parseLong(_amount[0])) + "," + _amount[1];
	else
			amount = nf.format(Long.parseLong(_amount[0]));
	return amount;
}
%>

<%
User user = (User)session.getValue("user");

String encLogin = user.getUsername();
String encPass = user.getPassword();

String merchant = request.getParameter("merchant");
String xid = request.getParameter("xid");
String exec = request.getParameter("exec");
String tdate = request.getParameter("tdate");

String [] retval = {"", ""};

String query = null;
Connection conn = null;
Statement stmt = null;
PreparedStatement pstmt = null;
ResultSet rs = null;

NumberFormat nf =  NumberFormat.getInstance(Locale.ITALY);
SimpleDateFormat sdf = new SimpleDateFormat("d-M-yyyy");

if(merchant == null)
	merchant = "";

try
{
	conn = DbCon.getConnection();
	
	if(xid != null && !xid.equals(""))
	{
		if(exec != null && exec.equals("1"))
		{			
			
			boolean b_f = false;
			
			//check for concurrent request
			query = "select * from merchant_deposit where deposit_id='"+xid+"' and is_executed='0'";
			pstmt = conn.prepareStatement(query);
			rs = pstmt.executeQuery();
			if(rs.next()) b_f=true;
			pstmt.close();rs.close();
			
			if(b_f){
				retval = UTx.doMerchantDeposit(xid);
				if(retval[0].equals("00"))
				{
					query = "INSERT INTO activity_log (userlogin, access_time, activity, note, ip) VALUES (?, SYSDATE, ?, ?, ?)";
					pstmt = conn.prepareStatement(query);
					pstmt.clearParameters();
					pstmt.setString(1, user.getUsername());
					pstmt.setString(2, "Approve On Demand Deposit");
					pstmt.setString(3, "Success: " + xid);
					pstmt.setString(4, request.getRemoteAddr());
					pstmt.executeUpdate();
					pstmt.close();
					
					out.println("<script language='javascript'>alert('Deposit no " + xid + " executed successfully')</script>");
				}
				else
					out.println("<script language='javascript'>alert('Execution failed, reason: " + retval[0] + " (" + retval[1] + ")')</script>");
			}else{
				out.println("<script language='javascript'>alert('Deposit no " + xid + " has been executed before. Please refresh the page by clicking the menu on the left.')</script>");
			}
		}
		else
		{
			if(tdate != null && !tdate.equals(""))
			{
				if(!tdate.equals("this"))
				{
					if(sdf.parse(tdate).before(sdf.parse(request.getParameter("print" + xid))) || sdf.parse(tdate).after(new Date()))
						out.println("<script language='javascript'>alert('Solve ticket failed, reason: date must be between " + request.getParameter("print" + xid) + " and today')</script>");
					else
					{
						query = "UPDATE merchant_deposit SET is_executed = '2', completion_date = TO_DATE(?, 'DD-MM-YYYY'), executor = ? WHERE deposit_id = ?";
						pstmt = conn.prepareStatement(query);
						pstmt.clearParameters();
						pstmt.setString(1, tdate);
						pstmt.setString(2, user.getUsername());
						pstmt.setString(3, xid);
						pstmt.executeUpdate();
						pstmt.close();
						
						// send SMS to Merchant ======================
						String amt = null, dnb = null, accno = null, bala = null, nmr = null, mrid = null;
						query = "select merchant_id, doc_number, amount from merchant_deposit where deposit_id='"+xid+"'";
						pstmt = conn.prepareStatement(query);
						rs = pstmt.executeQuery();
						if(rs.next()){
							amt = rs.getString("amount");
							dnb = rs.getString("doc_number");
							mrid = rs.getString("merchant_id");
						}						
						pstmt.close();rs.close();	
						
						if(mrid!=null && !mrid.equals("")){
							query = "select acc_no, merchant_info_id,msisdn from merchant where merchant_id='"+mrid+"'";
							pstmt = conn.prepareStatement(query);
							rs = pstmt.executeQuery();
							if(rs.next()){
								accno = rs.getString("acc_no");
								mrid = rs.getString("merchant_info_id");
								nmr = rs.getString("msisdn");
							}						
							pstmt.close();rs.close();
						}	

						if(accno!=null && !accno.equals("")){
							query = "select balance from tsel_merchant_account where acc_no='"+accno+"'";
							pstmt = conn.prepareStatement(query);
							rs = pstmt.executeQuery();
							if(rs.next()){
								bala = rs.getString("balance");
							}						
							pstmt.close();rs.close();
						}	
						
						SimpleDateFormat sdf1 = new SimpleDateFormat("dd/MM/yy HH:mm");
						
						reg.sendSms(nmr, sdf1.format(Calendar.getInstance().getTime())+" Deposit sebesar Rp "+returnFloat(amt)+". No. Doc: "+dnb+". Balance anda Rp "+returnFloat(bala)+".", "2828");
						// end of send sms to merchant ======================
						
						out.println("<script language='javascript'>alert('Solve ticket no " + xid + " successful')</script>");
						
					}
				}
			}
			else
				out.println("<script language='javascript'>alert('Solve ticket failed, reason: date cannot null')</script>");
		}
	}
%>
<stripes:layout-render name="/web-starter/layout/standard.jsp" title="On Demand Deposit Approval">
	<stripes:layout-component name="contents">

		<form name="form" method="post" action="deposit_approve_od.jsp">
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
	query = "SELECT a.merchant_id, b.name FROM merchant a, merchant_info b WHERE a.merchant_info_id = b.merchant_info_id AND a.status = 'A' ORDER BY a.merchant_id";
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
		</form>
		<br>
<%
	int jumlah = 0;
	int cur_page = 1;
	int row_per_page = 100;
	
	query = "SELECT COUNT(*) AS jml FROM merchant_deposit WHERE entry_login != 'Daily Settlement' AND is_executed < 2";
	if(!merchant.equals(""))
		query += " AND merchant_id = ?";
	
	pstmt = conn.prepareStatement(query);
	pstmt.clearParameters();
	if(!merchant.equals(""))
		pstmt.setString(1, merchant);
	
	rs = pstmt.executeQuery();
	if(rs.next())
		jumlah = rs.getInt("jml");
	
	pstmt.close();
	rs.close();
	
	if(request.getParameter("cur_page") != null && !request.getParameter("cur_page").equals(""))
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
		out.print("<a class='link' href='?cur_page=" + (minPaging - 1) + "&merchant=" + merchant + "'>&lt;</a>");
	
	for(int i = minPaging; i <= maxPaging; i++)
	{
		if(i == cur_page)
			out.print(i + " ");
		else
			out.print("<a class='link' href='?cur_page=" + i + "&merchant=" + merchant + "'>" + i + " </a>");
	}
	
	if(maxPaging + 1 <= total_page)
		out.print("<a class='link' href='?cur_page=" + (maxPaging + 1) + "&merchant=" + merchant + "'>&gt;</a>");
%>
		<table width="90%" border="1" cellspacing="0" cellpadding="0" bordercolor="#FFF6EF">
		<tr>
			<td colspan="11"><div align="right"><font color="#CC6633" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>.:: Deposit List</strong></font></div></td>
		</tr>
		<tr>
			<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Deposit ID</strong></font></div></td>
			<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Deposit Date</strong></font></div></td>
			<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Merchant</strong></font></div></td>
			<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Amount</strong></font></div></td>
			<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Doc Number</strong></font></div></td>
			<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Note</strong></font></div></td>
			<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>TSEL Bank Account</strong></font></div></td>
			<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Execute</strong></font></div></td>
			<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Receipt</strong></font></div></td>
			<td bgcolor="#CC6633" colspan="2"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Solve Ticket</strong></font></div></td>
		</tr>
<%
	if(!merchant.equals(""))
		query = "SELECT * FROM (SELECT a.*, ROWNUM rnum FROM (SELECT b.*, c.* FROM merchant_deposit b, merchant_info c, merchant d WHERE b.entry_login != 'Daily Settlement' AND b.is_executed < 2 AND b.merchant_id = d.merchant_id AND d.merchant_info_id = c.merchant_info_id AND b.merchant_id = '" + merchant + "' ORDER BY b.deposit_time DESC) a WHERE ROWNUM <= ?) WHERE rnum >= ?";
	else
		query = "SELECT * FROM (SELECT a.*, ROWNUM rnum FROM (SELECT b.*, c.* FROM merchant_deposit b, merchant_info c, merchant d WHERE b.entry_login != 'Daily Settlement' AND b.is_executed < 2 AND b.merchant_id = d.merchant_id AND d.merchant_info_id = c.merchant_info_id ORDER BY b.deposit_time DESC) a WHERE ROWNUM <= ?) WHERE rnum >= ?";
	
	pstmt = conn.prepareStatement(query);
	pstmt.clearParameters();
	pstmt.setInt(1, end_row);
	pstmt.setInt(2, start_row);
	rs = pstmt.executeQuery();
	while(rs.next())
	{
		boolean is_execute = rs.getString("is_executed").equals("0") ? true : false;
		boolean is_receipt = rs.getString("is_executed").equals("1") && (rs.getString("print_date") == null || rs.getString("print_date").equals("")) && request.getParameter("print" + rs.getString("deposit_id")) == null ? true : false;
		boolean is_ticket = rs.getString("is_executed").equals("1") && rs.getString("print_date") != null && !rs.getString("print_date").equals("") ? true : false;
%>
		<tr>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("deposit_id")%></font></div></td>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("deposit_time")%></font></div></td>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("name")%></font></div></td>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= nf.format(rs.getLong("amount"))%></font></div></td>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("doc_number")%></font></div></td>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("note")%></font></div></td>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("tsel_bank_acc")%></font></div></td>
<%
		if(is_execute)
		{
%>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><a href="deposit_approve_od.jsp?xid=<%= rs.getString("deposit_id")%>&exec=1&cur_page=<%= cur_page%>" onclick="return checkExecute('<%= rs.getString("deposit_id")%>');">execute</a></font></div></td>
<%
		}
		else
		{
%>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif">execute</font></div></td>
<%
		}
		
		if(is_receipt)
		{
%>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><a target="_receiptdeposit" href="../mcomm/print_receipt.jsp?mid=<%= rs.getString("merchant_id")%>&type=deposit&xid=<%= rs.getString("deposit_id")%>" onclick="solveThis('<%= rs.getString("deposit_id")%>', 'this', 'this',  '<%= cur_page%>');">print</a></font></div></td>
<%
		}
		else
		{
%>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif">print</font></div></td>
<%
		}
%>
			<td><div align="center"><input type="text" name="tdate<%= rs.getString("deposit_id")%>" id="tdate<%= rs.getString("deposit_id")%>" value="" readonly="true" width="100"><a href="javascript:calendar('tdate<%= rs.getString("deposit_id")%>');"><img src="${pageContext.request.contextPath}/STATIC/cal.gif" alt="Calendar" border="0" align="absmiddle"></a></div></td>
<%
		if(is_ticket)
		{
%>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><a href="javascript:solveThis('<%= rs.getString("deposit_id")%>', '<%= sdf.format(rs.getTimestamp("print_date"))%>', document.getElementById('tdate<%= rs.getString("deposit_id")%>').value, '');">OK</a></font></div></td>
<%
		}
		else
		{
%>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif">OK</font></div></td>
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