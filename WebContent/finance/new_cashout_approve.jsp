<%@ page import="java.io.*, java.util.*,java.text.*, oracle.jdbc.driver.*, java.util.Calendar, java.sql.*, com.telkomsel.itvas.webstarter.User, java.text.SimpleDateFormat, java.util.Date" %>
<%@ include file="/web-starter/taglibs.jsp"%>
<jsp:useBean id="DbCon" scope="page" class="tsel_tunai.DbCon"></jsp:useBean>
<jsp:useBean id="reg" scope="request" class="tsel_tunai.Register2Bean"></jsp:useBean>

<script language="JavaScript">
<!--
function calendar(output)
{
	newwin = window.open('cal_tct.jsp?output=' + output + '','','top=150,left=150,width=145,height=130,resizable=no');
	if(!newwin.opener)
		newwin.opener = self;
}

function solveThis(xid, print, tdate, cur_page, check0, check1)
{
	window.location = "new_cashout_approve.jsp?xid=" + xid + "&print" + xid + "=" + print + "&tdate=" + tdate + "&cur_page=" + cur_page + "&check0=" + check0 + "&check1=" + check1;
}

function checkExecute(){
                with(document)
                        return confirm("Do you really want to execute all these cashout?");
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
String merchant = request.getParameter("merchant");
String [] view = request.getParameterValues("view");
String xid = request.getParameter("xid");
String tdate = request.getParameter("tdate");
String check0 = request.getParameter("check0");
String check1 = request.getParameter("check1");

String compare = null;

String query = null;
Connection conn = null;
Statement stmt = null;
PreparedStatement pstmt = null;
ResultSet rs = null;

NumberFormat nf =  NumberFormat.getInstance(Locale.ITALY);
SimpleDateFormat sdf = new SimpleDateFormat("d-M-yyyy");

if(merchant == null)
	merchant = "";
if(check0 == null)
	check0 = "checked";
if(check1 == null)
	check1 = "checked";

if(view != null)
{
	if(view.length == 1)
	{
		if(view[0].equals("0"))
			check1 = "";
		else
			check0 = "";
	}
}

try
{
	//Class.forName("oracle.jdbc.OracleDriver");
	//conn = DriverManager.getConnection("jdbc:oracle:thin:@10.2.114.121:1521:OPTUNAI","tunai", "b0m#RK4du21");
	conn = DbCon.getConnection();
	
	if(xid != null && !xid.equals(""))
	{
		if(tdate != null && !tdate.equals(""))
		{
			if(!tdate.equals("this"))
			{
				if(sdf.parse(tdate).before(sdf.parse(request.getParameter("print" + xid))) || sdf.parse(tdate).after(new java.util.Date())){
					out.println("<script language='javascript'>alert('Solve ticket failed, reason: date must be between " + request.getParameter("print" + xid) + " and today')</script>");
					outPUT += (xid+" Failed Completion|");
				}else
				{
					query = "UPDATE merchant_cashout SET is_executed = '2', completion_date = TO_DATE(?, 'DD-MM-YYYY'), executor = ? WHERE cashout_id = ?";
					pstmt = conn.prepareStatement(query);
					pstmt.clearParameters();
					pstmt.setString(1, tdate);
					pstmt.setString(2, "Finance");
					pstmt.setString(3, xid);
					pstmt.executeUpdate();
					pstmt.close();

					query = "UPDATE settlement_history SET status = '2' WHERE exec_id = ? AND amount > 0";
					pstmt = conn.prepareStatement(query);
					pstmt.clearParameters();
					pstmt.setString(1, xid);
					pstmt.executeUpdate();
					pstmt.close();
					
					outPUT += (xid + " completed|");
					// send SMS to Merchant ======================
						String amt = null, dnb = null, accno = null, bala = null, nmr = null, mrid = null;
						query = "select merchant_id, doc_number, amount from merchant_cashout where cashout_id='"+xid+"'";
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
						
						reg.sendSms(nmr, sdf1.format(Calendar.getInstance().getTime())+" Cashout sebesar Rp "+returnFloat(amt)+" sudah dibayarkan. No. Doc: "+dnb+". Balance anda Rp "+returnFloat(bala)+".", "2828");
						outPUT += (xid+" SMS sent|");
						// end of send sms to merchant ======================
					
					out.println("<script language='javascript'>alert('Solve ticket no " + xid + " successful')</script>");
				}
			}
		}
		else{
			out.println("<script language='javascript'>alert('Solve ticket failed, reason: date cannot null')</script>");
			outPUT += "Solve ticket failed, reason: date cannot null|";
		}
	}
%>
<stripes:layout-render name="/web-starter/layout/standard.jsp" title="Cashout Approval">
	<stripes:layout-component name="contents">
		<hr />New Feature : <br />
		<a href='bulk_payment_csv.jsp'>Bulk Payment CSV Maker</a> | <a href='new_uploadPaymentStatus.jsp?idLog1=<%=encLogin%>&idLog2=<%=encPass%>'>Upload Payment CSV</a> 
		<hr />
		<form name="form" method="post" action="new_cashout_approve.jsp">
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
		<tr>
			<td></td>
			<td>
				<input type="checkbox" name="view" value="0" <%= check0%>><font color="#CC6633" size="1" face="Verdana, Arial, Helvetica, sans-serif">Daily</font>&nbsp;
				<input type="checkbox" name="view" value="1" <%= check1%>><font color="#CC6633" size="1" face="Verdana, Arial, Helvetica, sans-serif">On Demand</font><br>
			</td>
		</tr>
		</table>
		</form>
		<br>
<%
	int jumlah = 0;
	int cur_page = 1;
	int row_per_page = 100;

	if(check0.equals("checked") && check1.equals("checked"))
		query = "SELECT COUNT(*) AS jml_mandiri FROM merchant_cashout a WHERE (a.is_executed = '1' or a.is_executed='3')";
	else
	{
		compare = check0.equals("checked") ? "=" : "!=";
		query = "SELECT COUNT(*) AS jml_mandiri FROM merchant_cashout a WHERE a.entry_login " + compare + " 'Daily Settlement' AND (a.is_executed = '1' OR a.is_executed='3')";
	}

	if(!merchant.equals(""))query += " AND a.merchant_id = ?";

	pstmt = conn.prepareStatement(query);
	pstmt.clearParameters();
	if(!merchant.equals(""))
		pstmt.setString(1, merchant);

	rs = pstmt.executeQuery();
	if(rs.next())
		jumlah = rs.getInt("jml_mandiri");

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
		out.print("<a class='link' href='?cur_page=" + (minPaging - 1) + "&merchant=" + merchant + "&check0=" + check0 + "&check1=" + check1 + "'>&lt;</a>");

	for(int i = minPaging; i <= maxPaging; i++)
	{
		if(i == cur_page)
			out.print(i + " ");
		else
			out.print("<a class='link' href='?cur_page=" + i + "&merchant=" + merchant + "&check0=" + check0 + "&check1=" + check1 + "'>" + i + " </a>");
	}

	if(maxPaging + 1 <= total_page)
		out.print("<a class='link' href='?cur_page=" + (maxPaging + 1) + "&merchant=" + merchant + "&check0=" + check0 + "&check1=" + check1 + "'>&gt;</a>");

 %>

<%
//ngecek jumlah yang bisa diapprove, kalau kosong, tombol ini tidak muncul.
int jml_mandiri = 0;
int jml_bni = 0;
int jml_oth = 0;

query = "select count(*) as jml_mandiri from merchant_cashout a, merchant_info b, merchant c where a.MERCHANT_ID = c.MERCHANT_ID and b.MERCHANT_INFO_ID = c.MERCHANT_INFO_ID and (a.is_executed=1) and a.print_date is null and a.receipt_id is null and upper(b.bank_name) = 'MANDIRI'";
pstmt = conn.prepareStatement(query);
rs = pstmt.executeQuery();
if(rs.next())jml_mandiri = rs.getInt("jml_mandiri");
pstmt.close();
rs.close();

query = "select count(*) as jml_mandiri from merchant_cashout a, merchant_info b, merchant c where a.MERCHANT_ID = c.MERCHANT_ID and b.MERCHANT_INFO_ID = c.MERCHANT_INFO_ID and (a.is_executed=1) and a.print_date is null and a.receipt_id is null and upper(b.bank_name) = 'BNI'";
pstmt = conn.prepareStatement(query);
rs = pstmt.executeQuery();
if(rs.next())jml_bni = rs.getInt("jml_mandiri");
pstmt.close();
rs.close();

query = "select count(*) as jml_mandiri from merchant_cashout a, merchant_info b, merchant c where a.MERCHANT_ID = c.MERCHANT_ID and b.MERCHANT_INFO_ID = c.MERCHANT_INFO_ID and (a.is_executed=1) and a.print_date is null and a.receipt_id is null and upper(b.bank_name) NOT IN ('BNI','MANDIRI')";
pstmt = conn.prepareStatement(query);
rs = pstmt.executeQuery();
if(rs.next())jml_oth = rs.getInt("jml_mandiri");
pstmt.close();
rs.close();


if (jml_mandiri!=0 && merchant.equals("")){
    //String [] arrayID = new String[jml_mandiri];
    //ngambil array id untuk dikirimkan ke halaman new_print_receipt
    query = "select a.* from merchant_cashout a, merchant_info b, merchant c where a.MERCHANT_ID = c.MERCHANT_ID and b.MERCHANT_INFO_ID = c.MERCHANT_INFO_ID and (a.is_executed=1) and a.print_date is null and a.receipt_id is null and upper(b.bank_name) = 'MANDIRI'";
    pstmt = conn.prepareStatement(query);
    rs = pstmt.executeQuery();
%>
<form name="frmMandiri" action="new_print_receipt.jsp" method="get">
    <input type="submit" name="method" value=" Approve All(Mandiri) " onclick="return checkExecute();">
    <input type="hidden" name="type" value="cashout">
    <%
    while(rs.next()){
        out.println("<input type='hidden' name='xID' value='"+rs.getString("cashout_id")+"'>");
        out.println("<input type='hidden' name='merchant_id' value='"+rs.getString("merchant_id")+"'>");
    }
    pstmt.close();
    rs.close(); 
    %>
</form>

<%
}
if (jml_bni!=0 && merchant.equals("")){

query = "select a.* from merchant_cashout a, merchant_info b, merchant c where a.MERCHANT_ID = c.MERCHANT_ID and b.MERCHANT_INFO_ID = c.MERCHANT_INFO_ID and (a.is_executed=1) and a.print_date is null and a.receipt_id is null and upper(b.bank_name) = 'BNI'";
pstmt = conn.prepareStatement(query);
rs = pstmt.executeQuery();
%>
<form name="frmBNI" action="new_print_receipt.jsp" method="get">
    <input type="submit" name="method" value=" Approve All(BNI) " onclick="return checkExecute();">
    <input type="hidden" name="type" value="cashout">
    <%
    //int i=0;
    while(rs.next()){
        out.println("<input type='hidden' name='xID' value='"+rs.getString("cashout_id")+"'>");
        out.println("<input type='hidden' name='merchant_id' value='"+rs.getString("merchant_id")+"'>");
    }
    pstmt.close();
    rs.close(); 
    %>
</form>
<%
}
if (jml_oth!=0 && merchant.equals("")){

query = "select a.* from merchant_cashout a, merchant_info b, merchant c where a.MERCHANT_ID = c.MERCHANT_ID and b.MERCHANT_INFO_ID = c.MERCHANT_INFO_ID and (a.is_executed=1) and a.print_date is null and a.receipt_id is null and upper(b.bank_name) not in ('BNI','MANDIRI')";
pstmt = conn.prepareStatement(query);
rs = pstmt.executeQuery();
%>
<form name="frmOTH" action="new_print_receipt_oth_bank.jsp" method="get">
    <input type="submit" name="method" value=" Approve All(OTHER) " onclick="return checkExecute();">
    <input type="hidden" name="type" value="cashout">
    <input type="hidden" name="query" value="<%=query%>">
    <%
    //int i=0;
    while(rs.next()){
        out.println("<input type='hidden' name='xID' value='"+rs.getString("cashout_id")+"'>");
        out.println("<input type='hidden' name='merchant_id' value='"+rs.getString("merchant_id")+"'>");
    }
    pstmt.close();
    rs.close(); 
    %>
</form>
<%
}
%>
		<table width="90%" border="1" cellspacing="0" cellpadding="0" bordercolor="#FFF6EF">
		<tr>
			<td colspan="11"><div align="right"><font color="#CC6633" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>.:: Cashout List</strong></font></div></td>
		</tr>
		<tr>
			<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Cashout ID</strong></font></div></td>
			<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Cashout Date</strong></font></div></td>
			<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Merchant</strong></font></div></td>
			<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Amount</strong></font></div></td>
			<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Doc Number</strong></font></div></td>
			<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Note</strong></font></div></td>
			<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Custodian Bank</strong></font></div></td>
			<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Bank Account</strong></font></div></td>
			<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Receipt</strong></font></div></td>
			<td bgcolor="#CC6633" colspan="2"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Solve Ticket</strong></font></div></td>
		</tr>
<%
	if(check0.equals("checked") && check1.equals("checked"))
		query = "SELECT b.*, c.* FROM merchant_cashout b, merchant_info c, merchant d WHERE (b.is_executed = '1' or b.is_executed='3') AND b.merchant_id = d.merchant_id AND d.merchant_info_id = c.merchant_info_id";
	else
		query = "SELECT b.*, c.* FROM merchant_cashout b, merchant_info c, merchant d WHERE b.entry_login " + compare + " 'Daily Settlement' AND (b.is_executed = '1' or b.is_executed='3') AND b.merchant_id = d.merchant_id AND d.merchant_info_id = c.merchant_info_id";

	if(!merchant.equals(""))
		query += " AND b.merchant_id = '" + merchant + "'";

	query += " ORDER BY b.deposit_time DESC, b.PRINT_DATE DESC";
	query = "SELECT * FROM (SELECT a.*, ROWNUM rnum FROM (" + query + ") a WHERE ROWNUM <= ?) WHERE rnum >= ?";
	
	pstmt = conn.prepareStatement(query);
	pstmt.clearParameters();
	pstmt.setInt(1, end_row);
	pstmt.setInt(2, start_row);
	rs = pstmt.executeQuery();
	while(rs.next())
	{
		boolean is_receipt = (rs.getString("print_date") == null || rs.getString("print_date").equals("")) && request.getParameter("print" + rs.getString("cashout_id")) == null ? true : false;
		boolean is_ticket = rs.getString("print_date") != null && !rs.getString("print_date").equals("") ? true : false;

		String amount = rs.getString("amount");
		String [] _amount = amount.split(",");
		if(_amount.length > 1)
			amount = nf.format(Long.parseLong(_amount[0])) + "," + _amount[1];
		else
			amount = nf.format(Long.parseLong(_amount[0]));
%>
		<tr>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("cashout_id")%></font></div></td>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("deposit_time")%></font></div></td>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("name")%></font></div></td>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= amount%></font></div></td>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("doc_number")%></font></div></td>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("note")%></font></div></td>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("bank_name")%></font></div></td>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("bank_acc_no")%></font></div></td>
<%
		if(is_receipt)
		{
%>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><a target="_receiptcashout" href="new_print_receipt.jsp?mid=<%= rs.getString("merchant_id")%>&type=cashout&xid=<%= rs.getString("cashout_id")%>" onclick="solveThis('<%= rs.getString("cashout_id")%>', 'this', 'this', '<%= cur_page%>', '<%= check0%>', '<%= check1%>');">print</a></font></div></td>
<%
		}
		else
		{
%>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif">print</font></div></td>
<%
		}
%>
			<td><div align="center"><input type="text" name="tdate<%= rs.getString("cashout_id")%>" id="tdate<%= rs.getString("cashout_id")%>" value="" readonly="true" width="100"><a href="javascript:calendar('tdate<%= rs.getString("cashout_id")%>');"><img src="${pageContext.request.contextPath}/STATIC/cal.gif" alt="Calendar" border="0" align="absmiddle"></a></div></td>
<%
		if(is_ticket)
		{
%>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><a href="javascript:solveThis('<%= rs.getString("cashout_id")%>', '<%= sdf.format(rs.getTimestamp("print_date"))%>', document.getElementById('tdate<%= rs.getString("cashout_id")%>').value, '', '<%= check0%>', '<%= check1%>');">OK</a></font></div></td>
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
	try{conn.rollback();} catch(Exception e2){}
	outPUT+="Exception occured. Error :"+e.getMessage();;
}
finally{
	//=====================================================================//
	if (!outPUT.equals(""))
		System.out.println("["+timeNOW+"]new_cashout_approve.jsp|"+outPUT);
	//=====================================================================//
	try{
		conn.close();
	}
	catch(Exception e){}
}
%>
