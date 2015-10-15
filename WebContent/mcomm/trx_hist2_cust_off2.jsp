<%@ page language = "java" import = "java.io.*, java.util.*, java.text.*, java.sql.*, tsel_tunai.*, oracle.jdbc.driver.*" %>
<%@page import="com.telkomsel.itvas.webstarter.User"%>
<%@page import="com.telkomsel.itvas.webstarter.WebStarterProperties"%>
<jsp:useBean id="DbCon" scope="page" class="tsel_tunai.DbCon" />

<%!
public String transaction_name(String trx_type){
	if(trx_type.equals("1")){
		return "Pembelian";
	}else if(trx_type.equals("2")){
		return "Cash out";
	}else if(trx_type.equals("3")){
		return "Cash in";
	}else if(trx_type.equals("4")){
		return "Reversal Cashin";
	}else if(trx_type.equals("6")){
		return "Transfer Tcash";
	}else if(trx_type.equals("7")){
		return "Reversal Transfer";
	}else if(trx_type.equals("8")){
		return "Update Limit_bal";
	}else if(trx_type.equals("10")){
		return "Echo Test";
	}else if(trx_type.equals("87")){
		return "Trxid Generator";
	}else if(trx_type.equals("88")){
		return "Key Terminal";
	}else if(trx_type.equals("89")){
		return "Key Load";
	}else if(trx_type.equals("86")){
		return "Key Update";
	}else if(trx_type.equals("11")){
		return "Merchant Aggre Reload";
	}else if(trx_type.equals("13")){
		return "Merchant Aggre Cashout1";
	}else if(trx_type.equals("14")){
		return "Merchant Aggre Cashout2";
	}else if(trx_type.equals("15")){
		return "Merchant Inquiry";
	}else if(trx_type.equals("16")){
		return "Contactless Reload";
	}else if(trx_type.equals("17")){
		return "Contactless Settlement";
	}else if(trx_type.equals("18")){
		return "Merchant Void";
	}else if(trx_type.equals("19")){
		return "Merchant Return";
	}else if(trx_type.equals("20")){
		return "Reversal Merchant Hybrid Reload";
	}else if(trx_type.equals("21")){
		return "Reversal Merchant Void";
	}else{
		return "Unknown Trans";
	}
}
%>

<%
User user = (User)session.getValue("user");
if(user != null){
%>
<%@ include file="/web-starter/taglibs.jsp"%>
<stripes:layout-render name="/web-starter/layout/standard.jsp" title="Customer TAPizy History">
	<stripes:layout-component name="contents"> 

<%

String msisdn = request.getParameter("msisdn");
String iccid = "";
String wallet_id = "";
String customer_account_id = "";
String balance = "";

String dari = request.getParameter("dari");
String ampe = request.getParameter("ampe");
String var1 = request.getParameter("var1");

boolean b0 = false;
boolean b1 = false;
boolean b2 = false;

if (dari == null) dari = "01-01-2005";
if (ampe == null) ampe = "01-01-2005";

Connection con_tcash = null;
Connection con_ecash = null;
String sql = "";
PreparedStatement ps = null;
ResultSet rs = null;

NumberFormat nf =  NumberFormat.getInstance(Locale.ITALY);
	
try {
	
	Class.forName("oracle.jdbc.OracleDriver");
	con_ecash = DriverManager.getConnection("jdbc:oracle:thin:@//10.2.248.246:1521/orcl", "ecash", "orclecash");
	con_tcash = DbCon.getConnection();
		
	if(var1.equals("msisdn")){
		// take wallet id from msisdn in contactless_subs in tcash
		//sql = "select iccid, walletid from contactless_subs where msisdn='"+msisdn+"'";
                sql = "select iccid, walletid from contactless_subs where msisdn='"+msisdn+"' and status='1'";
		//System.out.println(sql);
		ps  = con_tcash.prepareStatement(sql);
		rs = ps.executeQuery();
		if(rs.next()){
			iccid = rs.getString("iccid");
			wallet_id = rs.getString("walletid");
			b0 = true;
		}
		rs.close();
		ps.close();		
	}
	else{
		String msisdn_red = "";
		if(msisdn.length()>=18)
			msisdn_red = msisdn.substring(0,18);
		else
			msisdn_red = msisdn;
		// take wallet id from msisdn in contactless_subs in tcash
		sql = "select msisdn, iccid, walletid from contactless_subs where walletid='"+msisdn_red+"'";
		//System.out.println(sql);
		ps  = con_tcash.prepareStatement(sql);
		rs = ps.executeQuery();
		if(rs.next()){
			iccid = rs.getString("iccid");
			wallet_id = rs.getString("walletid");
			msisdn = rs.getString("msisdn");
			var1 = "msisdn";
			b0 = true;
		}
		rs.close();
		ps.close();		
	}
	if(b0){
		sql = "select c.msisdn, ca.wallet_id, ca.id, ca.BALANCE, ca.BALANCE_LIMIT from customer c , customer_account ca where c.customer_account_id = ca.ID  and ca.WALLET_ID like '"+wallet_id+"%' and c.msisdn='"+iccid+"'";
		//System.out.println(sql);
		ps  = con_ecash.prepareStatement(sql);
		rs = ps.executeQuery();
		if(rs.next()){
			b1 =true;
			customer_account_id = rs.getString("id");
			balance = rs.getString("balance");
		}
		rs.close();
		ps.close();
	}
	
	
	if(!b1){
	%>
	<span class="box_text">account_not_found</span> 
	<%
	}else{ 
		//Paging Stuff
		sql = "select count(*) as jumlah from transaction where not status=5 and customer_id= '"+customer_account_id+"' and trx_time between to_date('"+dari+" 23:59:59', 'DD-MM-YYYY HH24:MI:SS') and to_date('"+ampe+" 23:59:59', 'DD-MM-YYYY HH24:MI:SS')";
		System.out.println(sql);	
		ps = con_ecash.prepareStatement(sql);
		rs = ps.executeQuery();
		int jumlah = 0;
		if (rs.next()) {
			jumlah = rs.getInt("jumlah");
		}
		rs.close();
		ps.close();
					
		int cur_page = 1;
		if (request.getParameter("cur_page") != null) {
			cur_page = Integer.parseInt(request.getParameter("cur_page"));
		}
		int row_per_page = 100;
		int start_row = (cur_page-1) * row_per_page + 1;
		int end_row = start_row + row_per_page - 1;
		int total_page = (jumlah / row_per_page) +1;
		if (jumlah % row_per_page == 0) {
			total_page--;
		}
		out.println("Page : ");
		for (int i=1; i<=total_page;i++) {
			if (i == cur_page) {
				out.print(i+" ");
			} else {
				out.print("<a class='link' href='?cur_page="+i+"&ampe="+ampe+"&dari="+dari+"&var1="+var1+"&msisdn="+msisdn+"'>"+i+"</a> ");
				//System.out.print("<a class='link' href='?cur_page="+i+"&ampe="+ampe+"&dari="+dari+"&var1="+var1+"&msisdn="+msisdn+"'>"+i+"</a> ");
			}
		}
		
		//End of paging stuff		
		sql = "select * FROM (select r.*, ROWNUM as row_number from (";
		sql += "select c.msisdn, ca.wallet_id, te.name, t.customer_id, t.trx_type, t.debit, t.credit, t.trx_time, t.balance2, t.balance1, t.merchant_id, t.terminal_id from terminal te, transaction t, customer_account ca, customer c where not t.status=5 and te.id=t.terminal_id and t.customer_id='"+customer_account_id+"' and t.trx_time between to_date('"+dari+" 00:00:00', 'DD-MM-YYYY HH24:MI:SS') and to_date('"+ampe+" 23:59:59', 'DD-MM-YYYY HH24:MI:SS') and c.CUSTOMER_ACCOUNT_ID = ca.id and ca.id=t.customer_id order by t.last_updated desc, t.trx_time desc ";
		sql += ") r where ROWNUM <= "+end_row+" ) where row_number >= "+ start_row;				
		System.out.println(sql);
		ps = con_ecash.prepareStatement(sql);
		rs = ps.executeQuery();	
	%>
	<table width="100%" border="0" cellspacing="3" cellpadding="3">
	  <tr> 
		<td align='center' class="unnamed1" colspan=6><div align="center"><font color="#000000" size="1" face="Verdana, Arial, Helvetica, sans-serif">&nbsp;<%= msisdn %> Transaction history on : <%=dari%></font></div></td>
	  </tr>
	  <tr> 
		<td align='center' class="unnamed1" colspan=6><div align="center"><font color="#000000" size="1" face="Verdana, Arial, Helvetica, sans-serif">&nbsp;Current Balance: <%= "Rp " + nf.format(Long.parseLong(balance)) %></font></div></td>
	  </tr>
	  <tr> 
		<td align='center' class="unnamed1" colspan=6><div align="center"><font color="#000000" size="1" face="Verdana, Arial, Helvetica, sans-serif">&nbsp;MSISDN: <%= msisdn %></font></div></td>
	  </tr>
	  <tr> 
		<td align='center' class="unnamed1" colspan=6><div align="center"><font color="#000000" size="1" face="Verdana, Arial, Helvetica, sans-serif">&nbsp;ICCID: <%= iccid %></font></div></td>
	  </tr>
	  <tr> 
		<td align='center' class="unnamed1" colspan=6><div align="center"><font color="#000000" size="1" face="Verdana, Arial, Helvetica, sans-serif">&nbsp;Wallet ID: <%= wallet_id %></font></div></td>
	  </tr>
	  <tr>
		<td bgcolor="#CC6633" width="11%" class="unnamed1" bgcolor="#CCCCCC"> 
		  <div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>&nbsp;Type</strong></font></div>
		</td>
		<td bgcolor="#CC6633" width="13%" class="unnamed1" bgcolor="#CCCCCC"> 
		  <div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>&nbsp;Debit</strong></font></div>
		</td>
		<td bgcolor="#CC6633" width="15%" class="unnamed1" bgcolor="#CCCCCC"> 
		 <div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>&nbsp;Credit</strong></font></div>
		</td>
		<td bgcolor="#CC6633" width="15%" class="unnamed1" bgcolor="#CCCCCC"> 
		  <div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>&nbsp;Balance</strong></font></div>
		</td>
		<td bgcolor="#CC6633" width="21%" class="unnamed1" bgcolor="#CCCCCC"> 
		  <div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>&nbsp;Transaction Time</strong></font></div>
		</td>			
		<td bgcolor="#CC6633" width="31%" class="unnamed1" bgcolor="#CCCCCC"> 
		  <div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>&nbsp;Terminal Name</strong></font></div>
		</td>
	  </tr>
	  <%
		while(rs.next()) {
	  %>
	  <tr>
		<td class="unnamed1" width="11%"><div align="center"><font color="#000000" size="1" face="Verdana, Arial, Helvetica, sans-serif">&nbsp;<%= transaction_name(rs.getString("trx_type")) %> </font></div></td>
		<td class="unnamed1" width="13%"><div align="center"><font color="#000000" size="1" face="Verdana, Arial, Helvetica, sans-serif">&nbsp;<%= nf.format(rs.getLong("debit")) %></font></div></td>
		<td class="unnamed1" width="15%"><div align="center"><font color="#000000" size="1" face="Verdana, Arial, Helvetica, sans-serif">&nbsp;<%= nf.format(rs.getLong("credit")) %></font></div></td>
		
		<%if(Integer.parseInt((rs.getString("trx_type"))) <11){%>
		  <td class="unnamed1" width="15%"><div align="center"><font color="#000000" size="1" face="Verdana, Arial, Helvetica, sans-serif">&nbsp;<%= nf.format(rs.getLong("balance1")) %></font></div></td>
		<%}else{%>
		  <td class="unnamed1" width="15%"><div align="center"><font color="#000000" size="1" face="Verdana, Arial, Helvetica, sans-serif">&nbsp;<%= nf.format(rs.getLong("balance2")) %></font></div></td>
		<%}%>
		
		<td class="unnamed1" width="21%"><div align="center"><font color="#000000" size="1" face="Verdana, Arial, Helvetica, sans-serif">&nbsp;<%= rs.getString("trx_time") %></font></div></td>
		<td class="unnamed1" width="31%"><div align="center"><font color="#000000" size="1" face="Verdana, Arial, Helvetica, sans-serif">&nbsp;<%= rs.getString("name") %></font></div></td>
	  </tr>
	  <% } %>
	</table>
	<%
	}
}catch(Exception  e){
	e.printStackTrace(System.out);
}finally{
	try { if(con_ecash!=null)con_ecash.close(); if(con_tcash!=null)con_tcash.close(); if(ps!=null)ps.close(); if(rs!=null)rs.close();} catch(Exception ee){}
}
	%>
		</stripes:layout-component>
</stripes:layout-render>
	<%
} else {
	response.sendRedirect("index.html");
}
%>
