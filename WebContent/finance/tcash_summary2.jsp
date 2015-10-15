<script language="JavaScript">
<!--
function checkDelete()
{
	with(document)
	{
		var checkStatus = confirm('Do you really want to delete this member?');
		if (checkStatus)
		{
			checkStatus = true;
		}
		return checkStatus;
	}
}
//-->

<!--
function calendar(output)
{
	newwin = window.open('cal.jsp','','top=150,left=150,width=145,height=130,resizable=no');
	if (!newwin.opener) newwin.opener = self;
}

function calendar2(output)
{
	newwin = window.open('cal2.jsp','','top=150,left=150,width=145,height=130,resizable=no');
	if (!newwin.opener) newwin.opener = self;
}
//-->
</script>


<jsp:useBean id="DbCon" scope="page" class="tsel_tunai.DbCon"></jsp:useBean>
<%@ page import="java.sql.*, java.text.*, java.util.*"%>
<%
	if(session.getValue("user") == null) {
		response.sendRedirect("index.html");	
	}
	String dari = request.getParameter("dari");
	NumberFormat nf = NumberFormat.getInstance(Locale.ITALY);
	Connection conn = DbCon.getConnection();
	SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
	
	
%>


</SCRIPT>
<%@ include file="/web-starter/taglibs.jsp"%>
<stripes:layout-render name="/web-starter/layout/standard.jsp" title="New TCash Summary">
	<stripes:layout-component name="contents">
	

	
        <div align="right"><font color="#FFFFFF" face="Verdana, Arial, Helvetica, sans-serif"></font> 
        </div>
        <div align="right"> </div>
        <div align="right"> </div>
		
		<table width="32%" border="1" cellspacing="0" cellpadding="0">
		<%
			java.util.Date skr = new java.util.Date();
			SimpleDateFormat forma = new SimpleDateFormat("d-M-yyyy");
			String tdate = forma.format(skr);
			dari = (dari != null && !dari.equals("")) ? dari : tdate;
		%>
          <form name="formini" method="get" action="tcash_summary2.jsp">
            <tr bgcolor="#CC6633"> 
              <td colspan="2"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Search Transaction date</strong></font></div></td>
            </tr>
            <tr> 
              <td colspan="2"></td>
            </tr>
            <tr> 
              <td height="15"><div align="center"><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif">From</font></div></td>
              <td><div align="left"><input type="text" name="dari" value="<%= dari%>" readonly="true"><a href="javascript:calendar('opener.document.formini.dari.value');"><img src="${pageContext.request.contextPath}/STATIC/cal.gif" alt="Calendar" border="0" align="absmiddle"></a> </div>
				<input type="hidden" name="test" value="1">
              </td>
            </tr>			
            <tr> 
              <td width="30%" height="26"><input type="submit" name="Submit" value="Search"></td>
            </tr>
          </form>
        </table>
		
		
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
			  <tr> 
            <td><div align="right"><font color="#CC6633" size="4" face="Verdana, Arial, Helvetica, sans-serif"><strong></strong></font></div></td>
          </tr>	
		<br>
        <table width="80%" border="1" cellspacing="0" cellpadding="0" bordercolor="#FFF6EF">
          <tr bgcolor="#FFF6EF"> 
            <td colspan="11"><div align="right"><font color="#CC6633" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>.:: 
                TCash Summary (<%= sdf.format(new java.util.Date())%>)</strong></font></div></td>
          </tr>
          <tr> 
            <td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Entity</strong></font></div></td>
            <td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Number</strong></font></div></td>
            <td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Cash Amount</strong></font></div></td>
          </tr>
<%
try {

long total = 0;
// count customer
String sql = "";

if(dari.equals(tdate)) sql = "SELECT count(a.cust_id) as jumlah, sum(b.balance) as cash_amount from customer a, tsel_cust_account b where a.acc_no=b.acc_no";
else sql="select numbers as jumlah, amount as cash_amount from floating_fund_history where hist_date=to_date('"+dari+"', 'DD-MM-YYYY') and entity='Customer Online'";  	
PreparedStatement ps = conn.prepareStatement(sql);
ResultSet rs = ps.executeQuery(sql);
long cashAmount = 0, jumlah = 0, jmlTerminal = 0;
if (rs.next()) {
	cashAmount = rs.getLong("cash_amount");
	jumlah = rs.getLong("jumlah");
	total += cashAmount;
}
rs.close();
ps.close();


%>
          <tr>
					<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif">Customer Online</font></div></td>
            		<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= nf.format(jumlah)%> customer(s)</font></div></td>
            		<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif">Rp. <%= nf.format(cashAmount)%></font></div></td>
		 </tr>

<%
if(dari.equals(tdate)) sql = "SELECT count(a.cust_id) as jumlah, sum(b.balance) as cash_amount from customer a, rfid_account b where a.acc_no=b.acc_no";
else sql="select numbers as jumlah, amount as cash_amount from floating_fund_history where hist_date=to_date('"+dari+"', 'DD-MM-YYYY') and entity='Customer Offline (Kartu TCash)'";

ps = conn.prepareStatement(sql);
rs = ps.executeQuery(sql);
if (rs.next()) {
	cashAmount = rs.getLong("cash_amount");
	jumlah = rs.getLong("jumlah");
	total += cashAmount;
}
rs.close();
ps.close();
%>
          <tr>
					<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif">Customer Offline (Kartu TCash)</font></div></td>
            		<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= nf.format(jumlah)%> customer(s)</font></div></td>
            		<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif">Rp. <%= nf.format(cashAmount)%></font></div></td>
		  </tr>

				
<%
if(dari.equals(tdate)) sql = "SELECT count(*) as jumlah, sum(a.AMOUNT) as cash_amount from SUSPEND_ACCOUNT a";
else sql="select numbers as jumlah, amount as cash_amount from floating_fund_history where hist_date=to_date('"+dari+"', 'DD-MM-YYYY') and entity='Suspend Account'";

ps = conn.prepareStatement(sql);
rs = ps.executeQuery(sql);
if (rs.next()) {
	cashAmount = rs.getLong("cash_amount");
	jumlah = rs.getLong("jumlah");
	total += cashAmount;
}
rs.close();
ps.close();
%>
          <tr>
					<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif">Suspend Account</font></div></td>
            		<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= nf.format(jumlah)%> account(s)</font></div></td>
            		<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif">Rp. <%= nf.format(cashAmount)%></font></div></td>
		  </tr>

				
<%
if(dari.equals(tdate)) sql = "SELECT count(*) as jumlah, sum(a.BALANCE) as cash_amount from REMIT_ACCOUNT a";
else sql="select numbers as jumlah, amount as cash_amount from floating_fund_history where hist_date=to_date('"+dari+"', 'DD-MM-YYYY') and entity='Remittance Account'";


ps = conn.prepareStatement(sql);
rs = ps.executeQuery(sql);
if (rs.next()) {
	cashAmount = rs.getLong("cash_amount");
	jumlah = rs.getLong("jumlah");
	total += cashAmount;
}
rs.close();
ps.close();
%>
          <tr>
					<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif">Remittance Account</font></div></td>
            		<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= nf.format(jumlah)%> account(s)</font></div></td>
            		<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif">Rp. <%= nf.format(cashAmount)%></font></div></td>
		  </tr>

				
<%
// count merchant
if(dari.equals(tdate)) sql = "SELECT c.name, a.merchant_id, b.balance as cash_amount from merchant a, tsel_merchant_account b, merchant_info c where a.acc_no=b.acc_no and a.merchant_info_id=c.merchant_info_id";
else sql = "select entity as name, numbers as jumlah, amount as cash_amount from floating_fund_history where hist_date=to_date('"+dari+"', 'DD-MM-YYYY') and not entity='Customer Online' and not entity='Customer Offline (Kartu TCash)' and not entity='Suspend Account' and not entity='Remittance Account' and not entity='TOTAL'";
ps = conn.prepareStatement(sql);
rs = ps.executeQuery(sql);
String merchantName = "";
cashAmount = 0; jumlah = 0; jmlTerminal=0;

while (rs.next()) {
	merchantName = rs.getString("name");
	cashAmount = rs.getLong("cash_amount");
	if(dari.equals(tdate)){ 
		String merchantID = rs.getString("merchant_id");
		sql = "select count(*) as jumlah from reader_terminal where merchant_id=?";
		PreparedStatement ps2 = conn.prepareStatement(sql);
		ps2.setString(1, merchantID);
		ResultSet rs2 = ps2.executeQuery();
		if (rs2.next()) {
			jumlah = rs2.getLong("jumlah");
		}
		rs2.close();
		ps2.close();
	}else jumlah = rs.getLong("jumlah");
	jmlTerminal += jumlah;
	total += cashAmount;
	
%>
<tr>
		<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif">Merchant: <%= merchantName%></font></div></td>
		<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= nf.format(jumlah)%> terminal(s)</font></div></td>
		<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif">Rp. <%= nf.format(cashAmount)%></font></div></td>
</tr>
<% } 
rs.close();
ps.close();

if(!dari.equals(tdate)){
	//sql = "SELECT count(*) as jumlah, sum(a.BALANCE) as cash_amount from REMIT_ACCOUNT a";
	sql="select numbers as jmlTerminal, amount as cash_amount from floating_fund_history where hist_date=to_date('"+dari+"', 'DD-MM-YYYY') and entity='TOTAL'";

	ps = conn.prepareStatement(sql);
	rs = ps.executeQuery(sql);
	if (rs.next()) {
		cashAmount = rs.getLong("cash_amount");
		total = cashAmount;
		jmlTerminal = jmlTerminal;
	}
	rs.close();
	ps.close();	
}

%>
<tr>
		<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>TOTAL</strong></font></div></td>
		<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= nf.format(jmlTerminal)%> terminal(s)</font></div></td>
		<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif">Rp. <%= nf.format(total)%></font></div></td>
</tr>
		</table>
		
		<br>
		<center><a href="trx_summary_csv.jsp?dari=<%=dari%>">Save as CSV</a></center>
		
        <br>
        <br>
        <br>
        <br>
      </td>
    </tr>

<%
} catch (Exception e) {
	System.out.println(e.getMessage());
	e.printStackTrace();
} finally {
	try {
		conn.close();
		} catch (Exception e) {}
}

%>	
  <br><br>
		</stripes:layout-component>
</stripes:layout-render>