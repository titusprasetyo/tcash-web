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
		return confirm("Do you really want to approve this deposit (id: " + xid + ")?");
}

function checkExecute2()
{
	with(document)
		return confirm("Do you really want to approve these deposits?");
}

function calendar(output)
{
	newwin = window.open('cal_tct.jsp?output=' + output + '','','top=150,left=150,width=145,height=130,resizable=no');
	if(!newwin.opener)
		newwin.opener = self;
}

function doUpdateAmount(did, old){
	var id = prompt("Please enter a new deposit amount", old);
	window.location = "deposit_approve_od.jsp?update=amount&old="+old+"&update1="+did+"&update2="+id;
}

function doUpdateDocNum(did, old){
	var id = prompt("Please enter a new document number", old);
	window.location = "deposit_approve_od.jsp?update=doc_number&old="+old+"&update1="+did+"&update2="+id;
}

function doUpdateNote(did, old){
	var id = prompt("Please enter a new note", old);
	window.location = "deposit_approve_od.jsp?update=note&old="+old+"&update1="+did+"&update2="+id;
}

//-->
</script>
<%!
String returnFloat(String amount){
	NumberFormat nf =  NumberFormat.getInstance(Locale.ITALY);
	if(amount.contains("."))
            amount = amount.substring(0,(amount.indexOf(".")));
	String [] _amount = amount.split(",");
	if(_amount.length > 1)
			amount = nf.format(Long.parseLong(_amount[0])) + "," + _amount[1];
	else
			amount = nf.format(Long.parseLong(_amount[0]));
	return amount;
}
%>

<%
//=========================================
Calendar CAL = Calendar.getInstance();
SimpleDateFormat SDF = new SimpleDateFormat("dd-MM-yyyy HH:mm:ss");
String timeNOW=SDF.format(CAL.getTime());
String outPUT = "";
//=========================================

User user = (User)session.getValue("user");

String encLogin = user.getUsername();
String encPass = user.getPassword();
String [] depositID = request.getParameterValues("deposit_id");

String merchant = request.getParameter("merchant");
String xid = request.getParameter("xid");
String exec = request.getParameter("exec");
String tdate = request.getParameter("tdate");

String update = request.getParameter("update");
String update1 = request.getParameter("update1");
String update2 = request.getParameter("update2");
String old = request.getParameter("old");

String query = null;
Connection conn = null;
Statement stmt = null;
PreparedStatement pstmt = null;
ResultSet rs = null;

if(merchant == null)
	merchant = "";

try
{
	conn = DbCon.getConnection();
	conn.setAutoCommit(false);
	// UPDATING 3 Parameters
	
	if(old!=null && update!=null && update1!=null && update2!=null && !update2.equals("NULL") && !update2.equals("null")){
		if(update.equals("amount"))
			query = "UPDATE merchant_deposit set "+update+"="+update2+" where deposit_id='"+update1+"'";
		else
			query = "UPDATE merchant_deposit set "+update+"='"+update2+"' where deposit_id='"+update1+"'";
		pstmt = conn.prepareStatement(query);
		pstmt.executeUpdate();
		pstmt.close();
			
		// do insert activity log
		query = "INSERT INTO activity_log (userlogin, access_time, activity, note, ip) VALUES (?, SYSDATE, ?, ?, ?)";
		pstmt = conn.prepareStatement(query);
		pstmt.clearParameters();
		pstmt.setString(1, user.getUsername());
		pstmt.setString(2, "Modify On Deposit by Admin");
		pstmt.setString(3, "Success: " + update1);
		pstmt.setString(4, request.getRemoteAddr());
		pstmt.executeUpdate();
		pstmt.close();
		
		outPUT +=(update1 + " changed successfully by "+user.getUsername()+"|Detail:"+old+update+update2+"|");
		conn.commit();
	}
	
	// UPDATING MULTI DEPOSIT
	if(depositID!=null){
		String depositIDSTR = "(";
		String depositIDSTR2 = "";
		for(int i=0;i<depositID.length;i++){
			depositIDSTR += ("'"+depositID[i]+"',");
			depositIDSTR2 += (depositID[i]+",");
		}
		depositIDSTR = depositIDSTR.substring(0,depositIDSTR.length()-1); depositIDSTR+=")";
		depositIDSTR2 = depositIDSTR2.substring(0,depositIDSTR2.length()-1);
		
		query = "UPDATE merchant_deposit set is_executed='1', exec_time=SYSDATE where deposit_id in "+depositIDSTR;
		pstmt = conn.prepareStatement(query);
		pstmt.executeUpdate();
		pstmt.close();
			
		// do insert activity log
		query = "INSERT INTO activity_log (userlogin, access_time, activity, note, ip) VALUES (?, SYSDATE, ?, ?, ?)";
		pstmt = conn.prepareStatement(query);
		pstmt.clearParameters();
		pstmt.setString(1, user.getUsername());
		pstmt.setString(2, "Approve On Deposit by Admin");
		pstmt.setString(3, "Success: " + depositIDSTR2);
		pstmt.setString(4, request.getRemoteAddr());
		pstmt.executeUpdate();
		pstmt.close();
		
		out.println("<script language='javascript'>alert('Deposit no " + depositIDSTR2 + " approved successfully')</script>");
		outPUT +=(depositIDSTR2 + " approved successfully by "+user.getUsername()+"|");
		
		conn.commit();
	}
	
	// UPDATING SINGLE DEPOSIT
	if(xid != null && !xid.equals(""))
	{
		if(exec != null && exec.equals("1"))
		{			
			// do merchant_deposit approval
			query = "UPDATE merchant_deposit set is_executed='1', exec_time=SYSDATE where deposit_id='"+xid+"'";
			pstmt = conn.prepareStatement(query);
			pstmt.executeUpdate();
			pstmt.close();
	
			// do insert activity log
			query = "INSERT INTO activity_log (userlogin, access_time, activity, note, ip) VALUES (?, SYSDATE, ?, ?, ?)";
			pstmt = conn.prepareStatement(query);
			pstmt.clearParameters();
			pstmt.setString(1, user.getUsername());
			pstmt.setString(2, "Approve On Deposit by Admin");
			pstmt.setString(3, "Success: " + xid);
			pstmt.setString(4, request.getRemoteAddr());
			pstmt.executeUpdate();
			pstmt.close();
			
			out.println("<script language='javascript'>alert('Deposit no " + xid + " approved successfully')</script>");
			outPUT +=(xid + " approved successfully by "+user.getUsername()+"|");
		}
		conn.commit();
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
	
	query = "SELECT COUNT(*) AS jml FROM merchant_deposit WHERE is_executed=0 AND exec_time is null";
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
		</tr>
<%
	if(!merchant.equals(""))
		query = "SELECT * FROM (SELECT a.*, ROWNUM rnum FROM (SELECT b.*, c.* FROM merchant_deposit b, merchant_info c, merchant d WHERE b.is_executed=0 AND exec_time is null AND b.merchant_id = d.merchant_id AND d.merchant_info_id = c.merchant_info_id AND b.merchant_id = '" + merchant + "' ORDER BY b.deposit_time DESC) a WHERE ROWNUM <= ?) WHERE rnum >= ?";
	else
		query = "SELECT * FROM (SELECT a.*, ROWNUM rnum FROM (SELECT b.*, c.* FROM merchant_deposit b, merchant_info c, merchant d WHERE b.is_executed=0 AND exec_time is null AND b.merchant_id = d.merchant_id AND d.merchant_info_id = c.merchant_info_id ORDER BY b.deposit_time DESC) a WHERE ROWNUM <= ?) WHERE rnum >= ?";
	
	pstmt = conn.prepareStatement(query);
	pstmt.clearParameters();
	pstmt.setInt(1, end_row);
	pstmt.setInt(2, start_row);
	rs = pstmt.executeQuery();
	String depositSTR = "";
	while(rs.next()){
		depositSTR += (rs.getString("deposit_id")+",");
%>
		<tr>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("deposit_id")%></font></div></td>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("deposit_time")%></font></div></td>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("name")%></font></div></td>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><a href="javascript:doUpdateAmount('<%= rs.getString("deposit_id")%>','<%=rs.getString("amount")%>');"><%= returnFloat(rs.getString("amount"))%></a></font></div></td>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><a href="javascript:doUpdateDocNum('<%= rs.getString("deposit_id")%>','<%= rs.getString("doc_number")%>');"><%= rs.getString("doc_number")%></a></font></div></td>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><a href="javascript:doUpdateNote('<%= rs.getString("deposit_id")%>','<%= rs.getString("note")%>');"><%= rs.getString("note")%></a></font></div></td>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("tsel_bank_acc")%></font></div></td>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><a href="deposit_approve_od.jsp?xid=<%= rs.getString("deposit_id")%>&exec=1&cur_page=<%= cur_page%>" onclick="return checkExecute('<%= rs.getString("deposit_id")%>');">Approve</a></font></div></td>
		</tr>
<%
	}
	if(!depositSTR.equals("")){
		String [] deposit_id = depositSTR.split(",");
		String xidSTR = "";
		for(int i=0;i<deposit_id.length;i++){
			xidSTR += ("deposit_id="+deposit_id[i]+"&");
		}
		%>
		<tr>
			<td colspan='8'><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><a href="deposit_approve_od.jsp?<%= xidSTR%>exec=1&cur_page=<%= cur_page%>" onclick="return checkExecute2();">Approve All</a></font></div></td>
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
catch(Exception e){
	e.printStackTrace(System.out);
	conn.rollback();
}
finally{
	try{
		conn.close();
		//=====================================================================//
		if (!outPUT.equals(""))
			System.out.println("["+timeNOW+"]admin_deposit_approve_od.jsp|"+outPUT);
		//=====================================================================//
	}
	catch(Exception e){}
}
%>