<jsp:useBean id="DbCon" scope="page" class="tsel_tunai.DbCon" />
	<%@ page import="java.sql.*, java.text.*, java.util.*"%>
	<%@page import="com.telkomsel.itvas.webstarter.User"%>
<%
	if(session.getValue("user") == null) {
		response.sendRedirect("index.html");	
	}
	NumberFormat nf = NumberFormat.getInstance(Locale.ITALY);
	SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
	
	//Connection con_tcash = DbCon.getConnection();
	Connection con_tcash = null;
	Connection con_ecash = null;
	String sql = "";
	PreparedStatement pstmt = null;
	ResultSet rs = null;

%>


</SCRIPT>
<%@ include file="/web-starter/taglibs.jsp"%>
<stripes:layout-render name="/web-starter/layout/standard.jsp" title="Deposit List">
	<stripes:layout-component name="contents">
        <div align="right"><font color="#FFFFFF" face="Verdana, Arial, Helvetica, sans-serif"></font> 
        </div>
        <div align="right"> </div>
        <div align="right"> </div>
						
		<br />
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
	Class.forName("oracle.jdbc.OracleDriver");
	con_tcash = DbCon.getConnection();
	con_ecash = DriverManager.getConnection("jdbc:oracle:thin:@//10.2.248.246:1521/orcl", "ecash", "orclecash");

	long total = 0;
	// count customer
	sql = "SELECT count(a.cust_id) as jumlah, sum(b.balance) as cash_amount from customer a, tsel_cust_account b where a.acc_no=b.acc_no";
	pstmt = con_tcash.prepareStatement(sql);
	rs = pstmt.executeQuery(sql);
	long cashAmount = 0, jumlah = 0;
	if (rs.next()) {
		cashAmount = rs.getLong("cash_amount");
		jumlah = rs.getLong("jumlah");
		total += cashAmount;
	}
	rs.close();	pstmt.close();
%>
          <tr>
					<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif">Customer Online</font></div></td>
            		<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= nf.format(jumlah)%> customer(s)</font></div></td>
            		<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif">Rp. <%= nf.format(cashAmount)%></font></div></td>
		 </tr>

<%
	sql = "SELECT count(a.cust_id) as jumlah, sum(b.balance) as cash_amount from customer a, rfid_account b where a.acc_no=b.acc_no";
	pstmt = con_tcash.prepareStatement(sql);
	rs = pstmt.executeQuery(sql);
	if (rs.next()) {
		cashAmount = rs.getLong("cash_amount");
		jumlah = rs.getLong("jumlah");
		total += cashAmount;
	}
	rs.close();
	pstmt.close();
%>
          <tr>
					<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif">Customer Offline (Kartu TCash)</font></div></td>
            		<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= nf.format(jumlah)%> customer(s)</font></div></td>
            		<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif">Rp. <%= nf.format(cashAmount)%></font></div></td>
		  </tr>

				
<%
	sql = "SELECT count(*) as jumlah, sum(a.AMOUNT) as cash_amount from SUSPEND_ACCOUNT a";
	pstmt = con_tcash.prepareStatement(sql);
	rs = pstmt.executeQuery(sql);
	if (rs.next()) {
		cashAmount = rs.getLong("cash_amount");
		jumlah = rs.getLong("jumlah");
		total += cashAmount;
	}
	rs.close();
	pstmt.close();
%>
          <tr>
					<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif">Suspend Account</font></div></td>
            		<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= nf.format(jumlah)%> account(s)</font></div></td>
            		<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif">Rp. <%= nf.format(cashAmount)%></font></div></td>
		  </tr>

				
<%
	sql = "SELECT count(*) as jumlah, sum(a.BALANCE) as cash_amount from REMIT_ACCOUNT a";
	pstmt = con_tcash.prepareStatement(sql);
	rs = pstmt.executeQuery(sql);
	if (rs.next()) {
		cashAmount = rs.getLong("cash_amount");
		jumlah = rs.getLong("jumlah");
		total += cashAmount;
	}
	rs.close();
	pstmt.close();
%>
          <tr>
					<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif">Remittance Account</font></div></td>
            		<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= nf.format(jumlah)%> account(s)</font></div></td>
            		<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif">Rp. <%= nf.format(cashAmount)%></font></div></td>
		  </tr>

				
<%
	// count merchant
	sql = "SELECT c.name, a.merchant_id, b.balance as cash_amount from merchant a, tsel_merchant_account b, merchant_info c where a.acc_no=b.acc_no and a.merchant_info_id=c.merchant_info_id";
	pstmt = con_tcash.prepareStatement(sql);
	rs = pstmt.executeQuery(sql);
	String merchantName = "";
	cashAmount = 0; jumlah = 0;
	while (rs.next()) {
		merchantName = rs.getString("name");
		cashAmount = rs.getLong("cash_amount");
		String merchantID = rs.getString("merchant_id");
		sql = "select count(*) as jumlah from reader_terminal where merchant_id=?";
		PreparedStatement ps2 = con_tcash.prepareStatement(sql);
		ps2.setString(1, merchantID);
		ResultSet rs2 = ps2.executeQuery();
		if (rs2.next()) {
			jumlah = rs2.getLong("jumlah");
		}
		rs2.close();
		ps2.close();
		total += cashAmount;
		
%>
<tr>
		<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif">Merchant: <%= merchantName%></font></div></td>
		<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= nf.format(jumlah)%> terminal(s)</font></div></td>
		<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif">Rp. <%= nf.format(cashAmount)%></font></div></td>
</tr>
<% }
	rs.close();
	pstmt.close();


%>
<tr>
		<td bgcolor="#EEEEEE" colspan=2><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>TOTAL</strong></font></div></td>
		<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif">Rp. <%= nf.format(total)%></font></div></td>
</tr>
		 </table>
		 
		 <br />
        <table width="80%" border="1" cellspacing="0" cellpadding="0" bordercolor="#FFF6EF">
			<tr bgcolor="#FFF6EF"> 
				<td colspan="11"><div align="right"><font color="#CC6633" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>.:: 
					TAPizy Summary (<%= sdf.format(new java.util.Date())%>)</strong></font></div></td>
			</tr>
			<tr> 
				<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Entity</strong></font></div></td>
				<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Number</strong></font></div></td>
				<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Cash Amount</strong></font></div></td>
			</tr>
			<%
			// parameter
			long total_customer=0,total_bal_customer=0,total_merchant=0,total_bal_merchant=0,fee=0,sum_fee=0;
			
			// select total_customer
			//sql = "select count(*) as total_customer from customer c, customer_account ca where c.customer_account_id = ca.id and c.status=1 and ca.status=1 and c.msisdn is not null and c.activation_date is not null";
			sql = "select count(*) as total_customer from customer c, customer_account ca where c.customer_account_id = ca.id and c.status=1 and ca.status=1 and c.msisdn is not null";
			
			pstmt = con_ecash.prepareStatement(sql);
			rs = pstmt.executeQuery();
			if(rs.next()){
				total_customer = rs.getLong("total_customer");
			}
			pstmt.close(); rs.close();
			
			// select total_bal_customer
			//sql = "select sum(ca.balance) as total_bal_customer from customer c, customer_account ca where c.customer_account_id = ca.id and c.status=1 and ca.status=1 and c.msisdn is not null and c.activation_date is not null";
			sql = "select sum(ca.balance) as total_bal_customer from customer c, customer_account ca where c.customer_account_id = ca.id and c.status=1 and ca.status=1 and c.msisdn is not null";
			
			pstmt = con_ecash.prepareStatement(sql);
			rs = pstmt.executeQuery();
			if(rs.next()){
				total_bal_customer = rs.getLong("total_bal_customer");
			}
			pstmt.close(); rs.close();
			
			// select total_merchant
			sql = "select count(*) as total_merchant from merchant m, merchant_account ma where m.MERCHANT_ACCOUNT_ID = ma.ID  and m.STATUS = 1 and ma.status = 1";
			pstmt = con_ecash.prepareStatement(sql);
			rs = pstmt.executeQuery();
			if(rs.next()){
				total_merchant = rs.getLong("total_merchant");
			}
			pstmt.close(); rs.close();
			
			// select total_bal_merchant
			sql = "select sum(ma.purchase+ma.deposit) as total_bal_merchant from merchant m, merchant_account ma where m.MERCHANT_ACCOUNT_ID = ma.ID and m.STATUS = 1 and ma.status = 1";
			pstmt = con_ecash.prepareStatement(sql);
			rs = pstmt.executeQuery();
			if(rs.next()){
				total_bal_merchant = rs.getLong("total_bal_merchant");
			}
			pstmt.close(); rs.close();
			
			// select fee
			sql = "select count(*) as fee from special_account";
			pstmt = con_ecash.prepareStatement(sql);
			rs = pstmt.executeQuery();
			if(rs.next()){
				fee = rs.getLong("fee");
			}
			pstmt.close(); rs.close();
			
			// select sum_fee
			sql = "select sum(fee) as sum_fee from special_account";
			pstmt = con_ecash.prepareStatement(sql);
			rs = pstmt.executeQuery();
			if(rs.next()){
				sum_fee = rs.getLong("sum_fee");
			}
			pstmt.close(); rs.close();
			%>
			<tr>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> TAPizy Customers </font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%= nf.format((total_customer)) %> customer(s) </font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> Rp. <%= nf.format((total_bal_customer))%> </font></div></td>
			</tr>
			<tr>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> TAPizy Merchants </font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%= nf.format((total_merchant)) %> merchant(s) </font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> Rp. <%= nf.format((total_bal_merchant))%> </font></div></td>
			</tr>
			<tr>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> Fee TAPizy </font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%= nf.format((fee)) %> account(s) </font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> Rp. <%= nf.format((sum_fee))%> </font></div></td>
			</tr>
			<tr>
				<td colspan="3" bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"></font></div></td>
			</tr>
			<%
			// select merchant
			sql = "select m.name, decode(a.xx,null,'0',a.xx) count, (ma.purchase + ma.deposit) as balance  from merchant m, merchant_account ma,  (select te.merchant_id, count(te.merchant_id) as xx from terminal te group by te.merchant_id) a where m.MERCHANT_ACCOUNT_ID = ma.ID  and m.STATUS = 1 and ma.status = 1 and a.merchant_id(+) = m.id";
			pstmt = con_ecash.prepareStatement(sql);
			rs = pstmt.executeQuery();
			while(rs.next()){
			%>
			<tr>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif">Merchant: <%= rs.getString("name")%></font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= nf.format(rs.getLong("count"))%> terminal(s)</font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif">Rp. <%= nf.format(rs.getLong("balance"))%></font></div></td>
			</tr>
			<%
			}
			%>
		</table>
        
		
		<br />
        <br />
        <br />
        <br />
<%
} catch (Exception e) {
	System.out.println(e.getMessage());
	e.printStackTrace(System.out);
} finally {
	try { if(con_ecash!=null)con_ecash.close(); if(con_tcash!=null)con_tcash.close(); if(pstmt!=null)pstmt.close(); if(rs!=null)rs.close();} catch(Exception ee){}
}
%>	
  <br><br>
		</stripes:layout-component>
</stripes:layout-render>