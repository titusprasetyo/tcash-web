<%@ page import="java.sql.*, java.text.*, java.util.*"%>
<%@page import="com.telkomsel.itvas.webstarter.User"%>

<jsp:useBean id="DbCon" scope="page" class="tsel_tunai.DbCon" />

<%
	if(session.getValue("user") == null) {
		response.sendRedirect("index.html");	
	}
	NumberFormat nf = NumberFormat.getInstance(Locale.ITALY);
	SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
	
	Connection con_tcash = null;
	Connection con_ecash = null;
	String sql = "";
	PreparedStatement pstmt = null;
	ResultSet rs = null;
	
	// parameter report
	long total_bal_tapizy = 0, 
	fee_total = 0,
	fee_ecash = 0,
	fee_tcash = 0,
	
	total_bal_customer = 0,
	total_trx_customer = 0,
	total_customer_inactive = 0,
	total_customer = 0,
	
	total_merchant = 0,
	total_merchant_inactive = 0,
	total_edc = 0,
	total_edc_inactive = 0,
	total_trx_settle_merchant = 0,
	total_trx_reload_merchant = 0,
	total_trx_purchase_merchant = 0,
	total_trx_cashin_merchant = 0,
	total_bal_pur_merchant = 0,
	total_bal_dep_merchant = 0,
	total_bal_merchant_agg = 0,
	
	ecash_balance = 0
	;
	
	String status_tapizy = "Balance",		
		ecash_merchant_id = "123456789",
		ecash_acc_no = "123456789"
		;
%>

</SCRIPT>
<%@ include file="/web-starter/taglibs.jsp"%>
<stripes:layout-render name="/web-starter/layout/standard.jsp" title="Summary TCash TAPizy">
	<stripes:layout-component name="contents">
        <div align="right"><font color="#FFFFFF" face="Verdana, Arial, Helvetica, sans-serif"></font> 
        </div>
        <div align="right"> </div>
        <div align="right"> </div>
		
		
		<table width="60%" border="0" cellpadding="0" cellspacing="0">
			<tr bgcolor="#FFF6EF"> 
				<td colspan="11"><div align="right"><font color="#CC6633" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>.:: 
					Summary TCash TAPizy (<%= sdf.format(new java.util.Date())%>)</strong></font></div></td>
			</tr>			
<%
	try {
		Class.forName("oracle.jdbc.OracleDriver");
		con_tcash = DbCon.getConnection();
		con_ecash = DriverManager.getConnection("jdbc:oracle:thin:@//10.2.248.246:1521/orcl", "ecash", "orclecash");
		
		ecash_merchant_id = "1008041612301628";
		
		// take ecash_acc_no and ecash_balance
		sql = "SELECT m.acc_no, t.balance from merchant m, tsel_merchant_account t where m.merchant_id='"+ecash_merchant_id+"' and m.acc_no=t.acc_no";
		//System.out.println(sql);
		pstmt = con_tcash.prepareStatement(sql);
		rs = pstmt.executeQuery();
		if (rs.next()){
			ecash_acc_no = rs.getString("acc_no");
			ecash_balance = rs.getLong("balance");
		}
		pstmt.close();rs.close();
%>
			<tr>
				<td colspan="3" bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>ECash Merchant Information</strong></font></div></td>
			</tr>
			<tr>
				<td bgcolor="#EEEEEE"><div align="left"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> ECash Merchant ID </font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%= ecash_merchant_id %> </font></div></td>
			</tr>
			<tr>
				<td bgcolor="#EEEEEE"><div align="left"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> ECash Merchant Acc No </font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%= ecash_acc_no%> </font></div></td>
			</tr>
			<tr>
				<td bgcolor="#EEEEEE"><div align="left"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> ECash Online Balance </font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Rp. <%= nf.format((ecash_balance))%> </strong></font></div></td>
			</tr>
<%				
		// select total_merchant
		sql = "select count(*) as total_merchant from merchant m, merchant_account ma where m.MERCHANT_ACCOUNT_ID = ma.ID  and m.MERCHANT_TYPE='Hybrid' and m.STATUS = 1 and ma.status = 1";
		pstmt = con_ecash.prepareStatement(sql);
		rs = pstmt.executeQuery();
		if(rs.next()){
			total_merchant = rs.getLong("total_merchant");
		}
		pstmt.close(); rs.close();
		
		// select total_merchant_inactive
		sql = "select count(*) as total_merchant_inactive from ( select m.id as merchant_id, ma.id as acc_no, t.id as transaction_id  from merchant m, merchant_account ma, transaction t where ma.id = m.MERCHANT_ACCOUNT_ID and ma.ID = t.merchant_id(+) and m.MERCHANT_TYPE='Hybrid' and m.STATUS = 1 and ma.status = 1 ) a where a.transaction_id is null";
		pstmt = con_ecash.prepareStatement(sql);
		rs = pstmt.executeQuery();
		if(rs.next()){
			total_merchant_inactive = rs.getLong("total_merchant_inactive");
		}
		pstmt.close(); rs.close();
		
		// select total_edc_inactive
		sql = "select count(*) as total_edc_inactive from ( select distinct terminal_id from ( select m.id as merchant_id, ma.id as acc_no, t.id as transaction_id, tr.id as terminal_id from merchant m, merchant_account ma, transaction t, terminal tr where ma.id = m.MERCHANT_ACCOUNT_ID and ma.ID = t.merchant_id(+) and m.MERCHANT_TYPE='Hybrid' and m.STATUS = 1 and ma.status = 1 and tr.merchant_id=m.id ) a where a.transaction_id is null ) b ";
		pstmt = con_ecash.prepareStatement(sql);
		rs = pstmt.executeQuery();
		if(rs.next()){
			total_edc_inactive = rs.getLong("total_edc_inactive");
		}
		pstmt.close(); rs.close();
		
		// select total_edc
		sql = "select count(*) as total_edc from terminal t, merchant m where t.status=1 and t.merchant_id = m.id and m.MERCHANT_TYPE='Hybrid' and m.STATUS = 1";
		pstmt = con_ecash.prepareStatement(sql);
		rs = pstmt.executeQuery();
		if(rs.next()){
			total_edc = rs.getLong("total_edc");
		}
		pstmt.close(); rs.close();
		
		// select total_bal_dep_merchant
		sql = "select sum(ma.deposit) as total_bal_dep_merchant from merchant m, merchant_account ma where m.MERCHANT_ACCOUNT_ID = ma.ID and m.MERCHANT_TYPE='Hybrid' and m.STATUS = 1 and ma.status = 1";
		pstmt = con_ecash.prepareStatement(sql);
		rs = pstmt.executeQuery();
		if(rs.next()){
			total_bal_dep_merchant = rs.getLong("total_bal_dep_merchant");
		}
		pstmt.close(); rs.close();
		
		// select total_bal_pur_merchant
		sql = "select sum(ma.purchase) as total_bal_pur_merchant from merchant m, merchant_account ma where m.MERCHANT_ACCOUNT_ID = ma.ID and m.MERCHANT_TYPE='Hybrid' and m.STATUS = 1 and ma.status = 1";
		pstmt = con_ecash.prepareStatement(sql);
		rs = pstmt.executeQuery();
		if(rs.next()){
			total_bal_pur_merchant = rs.getLong("total_bal_pur_merchant");
		}
		pstmt.close(); rs.close();
	 
		// select total_bal_merchant_agg
		sql = "select sum(ma.purchase+ma.deposit) as total_bal_merchant_agg from merchant m, merchant_account ma where m.MERCHANT_ACCOUNT_ID = ma.ID and m.MERCHANT_TYPE='Aggregated' and m.STATUS = 1 and ma.status = 1";
		pstmt = con_ecash.prepareStatement(sql);
		rs = pstmt.executeQuery();
		if(rs.next()){
			total_bal_merchant_agg = rs.getLong("total_bal_merchant_agg");
		}
		pstmt.close(); rs.close();
		
		total_bal_merchant_agg = total_bal_dep_merchant + total_bal_pur_merchant;
%>
			<tr>
				<td colspan="3" bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>TAPizy Merchants Information</strong></font></div></td>
			</tr>
			<tr>
				<td bgcolor="#EEEEEE"><div align="left"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> Total TAPizy Merchants </font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%= nf.format((total_merchant)) %> Merchants </font></div></td>
			</tr>
			<tr>
				<td bgcolor="#EEEEEE"><div align="left"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> Total TAPizy inactive Merchants </font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%= nf.format((total_merchant_inactive)) %> Merchants </font></div></td>
			</tr>
			<tr>
				<td bgcolor="#EEEEEE"><div align="left"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> Total TAPizy EDCs </font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%= nf.format((total_edc)) %> EDCs </font></div></td>
			</tr>
			<tr>
				<td bgcolor="#EEEEEE"><div align="left"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> Total TAPizy inactive EDCs </font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%= nf.format((total_edc_inactive)) %> EDCs </font></div></td>
			</tr>			
			<tr>
				<td bgcolor="#EEEEEE"><div align="left"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> Total Deposit Balance of TAPizy Merchants </font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Rp. <%= nf.format((total_bal_dep_merchant))%> </strong></font></div></td>
			</tr>
			<tr>
				<td bgcolor="#EEEEEE"><div align="left"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> Total Purchase Balance of TAPizy Merchants </font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Rp. <%= nf.format((total_bal_pur_merchant))%> </strong></font></div></td>
			</tr>
			
			<tr>
				<td bgcolor="#EEEEEE"><div align="left"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> Total Balance of TAPizy Agg Merchants </font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Rp. <%= nf.format((total_bal_merchant_agg))%> </strong></font></div></td>
			</tr>
			<%
			// select total_customer
			//sql = "select count(*) as total_customer from customer c, customer_account ca where c.customer_account_id = ca.id and c.status=1 and ca.status=1 and c.msisdn is not null and c.activation_date is not null";
			sql = "select count(*) as total_customer from customer c, customer_account ca where c.customer_account_id = ca.id and c.status=1 and ca.status=1 and c.msisdn is not null";
			
			pstmt = con_ecash.prepareStatement(sql);
			rs = pstmt.executeQuery();
			if(rs.next()){
				total_customer = rs.getLong("total_customer");
			}
			pstmt.close(); rs.close();
			
			// select total_customer_inactive
			//sql = "select count(*) as total_customer_inactive from ( select c.id as customer_id, ca.id as customer_account_id, tr.id as transaction_id from customer c, customer_account ca, transaction tr where c.customer_account_id = ca.id and c.status=1 and ca.status=1 and c.msisdn is not null and c.activation_date is not null and ca.id = tr.customer_id(+) ) a where a.transaction_id is null";
			sql = "select count(*) as total_customer_inactive from ( select c.id as customer_id, ca.id as customer_account_id, tr.id as transaction_id from customer c, customer_account ca, transaction tr where c.customer_account_id = ca.id and c.status=1 and ca.status=1 and c.msisdn is not null and ca.id = tr.customer_id(+) ) a where a.transaction_id is null";
			
			pstmt = con_ecash.prepareStatement(sql);
			rs = pstmt.executeQuery();
			if(rs.next()){
				total_customer_inactive = rs.getLong("total_customer_inactive");
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
			%>
			<tr>
				<td colspan="3" bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>TAPizy Customers Information</strong></font></div></td>
			</tr>
			<tr>
				<td bgcolor="#EEEEEE"><div align="left"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> Total TAPizy Customers </font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%= nf.format((total_customer)) %> Customers </font></div></td>
			</tr>
			<tr>
				<td bgcolor="#EEEEEE"><div align="left"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> Total TAPizy inactive Customers </font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%= nf.format((total_customer_inactive)) %> Customers </font></div></td>
			</tr>
			<tr>
				<td bgcolor="#EEEEEE"><div align="left"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> Total Balance of TAPizy Customers </font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Rp. <%= nf.format((total_bal_customer))%> </strong></font></div></td>
			</tr>
			<%
			// select total_trx_purchase_merchant
			sql = "select count(*) as total_trx_purchase_merchant from merchant m, merchant_account ma, transaction t where ma.id = m.MERCHANT_ACCOUNT_ID and ma.ID = t.merchant_id and m.MERCHANT_TYPE='Hybrid' and m.STATUS = 1 and ma.status = 1 and t.trx_type=1";
			pstmt = con_ecash.prepareStatement(sql);
			rs = pstmt.executeQuery();
			if(rs.next()){
				total_trx_purchase_merchant = rs.getLong("total_trx_purchase_merchant");
			}
			pstmt.close(); rs.close();
			
			// select total_trx_cashin_merchant
			sql = "select count(*) as total_trx_cashin_merchant from merchant m, merchant_account ma, transaction t where ma.id = m.MERCHANT_ACCOUNT_ID and ma.ID = t.merchant_id and m.MERCHANT_TYPE='Hybrid' and m.STATUS = 1 and ma.status = 1 and t.trx_type=3";
			pstmt = con_ecash.prepareStatement(sql);
			rs = pstmt.executeQuery();
			if(rs.next()){
				total_trx_cashin_merchant = rs.getLong("total_trx_cashin_merchant");
			}
			pstmt.close(); rs.close();
			
			// select total_trx_reload_merchant
			sql = "select count(*) as total_trx_reload_merchant from merchant m, merchant_account ma, transaction t where ma.id = m.MERCHANT_ACCOUNT_ID and ma.ID = t.merchant_id and m.MERCHANT_TYPE='Hybrid' and m.STATUS = 1 and ma.status = 1 and t.trx_type=16";
			pstmt = con_ecash.prepareStatement(sql);
			rs = pstmt.executeQuery();
			if(rs.next()){
				total_trx_reload_merchant = rs.getLong("total_trx_reload_merchant");
			}
			pstmt.close(); rs.close();
			
			// select total_trx_settle_merchant
			sql = "select count(*) as total_trx_settle_merchant from merchant m, merchant_account ma, transaction t where ma.id = m.MERCHANT_ACCOUNT_ID and ma.ID = t.merchant_id and m.MERCHANT_TYPE='Hybrid' and m.STATUS = 1 and ma.status = 1 and t.trx_type=17";
			pstmt = con_ecash.prepareStatement(sql);
			rs = pstmt.executeQuery();
			if(rs.next()){
				total_trx_settle_merchant = rs.getLong("total_trx_settle_merchant");
			}
			pstmt.close(); rs.close();
			%>
			<tr>
				<td colspan="3" bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Others Information</strong></font></div></td>
			</tr>
			<tr>
				<td bgcolor="#EEEEEE"><div align="left"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> Total Transactions Reload in TAPizy  </font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%= nf.format((total_trx_reload_merchant))%> trx </font></div></td>
			</tr>
			<tr>
				<td bgcolor="#EEEEEE"><div align="left"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> Total Transactions Settle in TAPizy  </font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%= nf.format((total_trx_settle_merchant))%> trx </font></div></td>
			</tr>
			<tr>
				<td bgcolor="#EEEEEE"><div align="left"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> Total Transactions Cashin in TAPizy  </font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%= nf.format((total_trx_cashin_merchant))%> trx </font></div></td>
			</tr>
			<tr>
				<td bgcolor="#EEEEEE"><div align="left"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> Total Transactions Purchase in TAPizy  </font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> <%= nf.format((total_trx_purchase_merchant))%> trx </font></div></td>
			</tr>
			<%
			// select fee_ecash
			sql = "select balance as fee_ecash from special_account where name='ECash'";
			pstmt = con_ecash.prepareStatement(sql);
			rs = pstmt.executeQuery();
			if(rs.next()){
				fee_ecash = rs.getLong("fee_ecash");
			}
			pstmt.close(); rs.close();
			
			// select fee_tcash
			sql = "select balance as fee_tcash from special_account where name='T-Cash'";
			pstmt = con_ecash.prepareStatement(sql);
			rs = pstmt.executeQuery();
			if(rs.next()){
				fee_tcash = rs.getLong("fee_tcash");
			}
			pstmt.close(); rs.close();
			
			%>
			<tr>
				<td bgcolor="#EEEEEE"><div align="left"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> Fee TAPizy ECash </font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Rp. <%= nf.format((fee_ecash)) %> </strong></font></div></td>
			</tr>
			<tr>
				<td bgcolor="#EEEEEE"><div align="left"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> Fee TAPizy TCash </font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Rp. <%= nf.format((fee_tcash))%> </strong></font></div></td>
			</tr>
			<%
			// select total_bal_tapizy
			// total_bal_tapizy = fee_tcash + fee_ecash + total_bal_customer + total_bal_dep_merchant + total_bal_pur_merchant
			total_bal_tapizy = fee_tcash + fee_ecash + total_bal_customer + total_bal_dep_merchant + total_bal_pur_merchant;
			
			// select status_tapizy
			// compare ecash_balance dengan total_bal_tapizy
			if(total_bal_tapizy!=ecash_balance){
				if(total_bal_tapizy<ecash_balance){
					status_tapizy = "Inbalance, TCash > TAPizy";
				}else if(total_bal_tapizy>ecash_balance){
					status_tapizy = "Inbalance, TAPizy > TCash";
				}
			}
			%>
			<tr>
				<td bgcolor="#EEEEEE"><div align="left"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> Total TAPizy Balance </font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> Rp. <%= nf.format((total_bal_tapizy))%> </strong></font></div></td>
			</tr>			
			<tr>
				<td colspan="3" bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>TAPizy Status</strong></font></div></td>
			</tr>
			<tr>
				<td bgcolor="#EEEEEE"><div align="left"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> Status </font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"> : </font></div></td>
				<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> <%= status_tapizy %> </strong></font></div></td>
			</tr>
		</table>
		 
        <br />
        <br />
        <br />
        <br />
<%
	}catch(Exception  e){
		e.printStackTrace(System.out);
	}finally{
		try { if(con_ecash!=null)con_ecash.close(); if(con_tcash!=null)con_tcash.close(); if(pstmt!=null)pstmt.close(); if(rs!=null)rs.close();} catch(Exception ee){}
	}
%>
		</stripes:layout-component>
</stripes:layout-render>