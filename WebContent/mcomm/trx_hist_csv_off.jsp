<%@ page import="java.util.regex.*, java.sql.*, tsel_tunai.*, java.text.*, java.util.*"%>
<jsp:useBean id="DbCon" scope="page" class="tsel_tunai.DbCon" />
<%@page import="com.telkomsel.itvas.webstarter.User"%>
<%System.out.println("DEBUG|Zone0");
	%>
<%!

public java.util.Date toDate(java.sql.Timestamp timestamp) {
    long milliseconds = timestamp.getTime() + (timestamp.getNanos() / 1000000);
    return new java.util.Date(milliseconds);
}
%>

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
	}else if(trx_type.equals("12")){
		return "Merchant Hybrid Cashout";
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
	System.out.println("DEBUG|Zone1");
	String separator = ",";
	String merchant_id = "";
	String merchant_account_id = "";
	String merchant_name = "";
		
	String dari = request.getParameter("dari");
	String merchant = request.getParameter("merchant");
	String terminal_msisdn = request.getParameter("terminal_msisdn");
	String ampe = request.getParameter("ampe");
	System.out.println("DEBUG|Zone2.1");
	User user = (User)session.getValue("user");
	System.out.println("DEBUG|Zone2.2");
	SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
	System.out.println("DEBUG|Zone2");
	
	if (merchant == null) merchant = "";
	if (terminal_msisdn == null) terminal_msisdn = "";
	response.setContentType ("text/csv");
	response.setHeader ("Content-Disposition", "attachment;	filename=\""+user.getUsername()+"_"+dari+"_"+ampe+".csv\"");
	System.out.println("DEBUG|Zone3");
	
	if(user != null)
	{
			System.out.println("DEBUG|Zone4");
	
			Connection con_tcash = null;
			Connection con_ecash = null;
			String sql = "";
			PreparedStatement pstmt = null;
			ResultSet rs = null;
			try{
				System.out.println("DEBUG|Zone5");
				Class.forName("oracle.jdbc.OracleDriver");
				con_tcash = DbCon.getConnection();
				con_ecash = DriverManager.getConnection("jdbc:oracle:thin:@//10.2.248.246:1521/orcl", "ecash", "orclecash");
				session.putValue("user", user);
			 					
				merchant_id = merchant;
				
				sql = "select name, merchant_account_id from merchant where tcash_id='"+merchant_id+"'";
				pstmt = con_ecash.prepareStatement(sql);
				rs = pstmt.executeQuery();
				if(rs.next()){
					merchant_account_id = rs.getString("merchant_account_id");
					merchant_name = rs.getString("name");
				}
				rs.close();pstmt.close();
				  
				if(terminal_msisdn.equals(""))
					sql = "select nvl(tr.fee_ecash,0) as fee_ecash, nvl(tr.fee_tcash,0) as fee_tcash, tr.last_updated as last_updated, tr.trx_time as tx_date, decode(ca.WALLET_ID, null,'ADMIN', ca.WALLET_ID) as card_id, tr.trx_type as tx_type, tr.debit as debet, tr.credit, nvl(tr.balance1,0) as balance, nvl(tr.balance2,0) as balance2, tr.id as ref_num, decode(tr.terminal_id, null, '-', tr.terminal_id) as mmsisdn, decode(te.name, null, 'Offline Reload/Settlement', te.name) as description  from transaction tr, terminal te, customer_account ca where not tr.status=5 and ca.ID(+)= tr.CUSTOMER_ID and tr.merchant_id='"+merchant_account_id+"' and tr.terminal_id=te.id (+) and ( tr.last_updated between to_date('"+dari+" 00:00:00', 'DD-MM-YYYY HH24:MI:SS') and to_date('"+ampe+" 23:59:59', 'DD-MM-YYYY HH24:MI:SS')) order by tr.last_updated asc, tr.trx_time asc"; 
				else
					sql = "select nvl(tr.fee_ecash,0) as fee_ecash, nvl(tr.fee_tcash,0) as fee_tcash, tr.last_updated as last_updated, tr.trx_time as tx_date, decode(ca.WALLET_ID, null,'ADMIN', ca.WALLET_ID) as card_id, tr.trx_type as tx_type, tr.debit as debet, tr.credit, nvl(tr.balance1,0) as balance, nvl(tr.balance2,0) as balance2, tr.id as ref_num, decode(tr.terminal_id, null, '-', tr.terminal_id) as mmsisdn, decode(te.name, null, 'Offline Reload/Settlement', te.name) as description from transaction tr, terminal te, customer_account ca where not tr.status=5 and ca.ID(+)= tr.CUSTOMER_ID and tr.merchant_id='"+merchant_account_id+"' and tr.terminal_id='"+terminal_msisdn+"' and tr.terminal_id=te.id(+) and ( tr.last_updated between to_date('"+dari+" 00:00:00', 'DD-MM-YYYY HH24:MI:SS') and to_date('"+ampe+" 23:59:59', 'DD-MM-YYYY HH24:MI:SS')) order by tr.last_updated asc, tr.trx_time asc"; 
				
				pstmt = con_ecash.prepareStatement(sql);
				rs = pstmt.executeQuery();
				out.println(
					"tx_date" + separator + 
					"last_updated" + separator + 
					"customer" + separator + 
					"tx_tipe" + separator + 
					"debet" + separator + 
					"credit" + separator + 
					"balance" + separator + 
					"ref_num" + separator + 
					"terminal_id" + separator + 
					"description");
				System.out.println("DEBUG|Zone5");
	
				String records = "";				
				while (rs.next()) {
					if((rs.getString("fee_ecash")).equals("0") || (rs.getString("fee_ecash")==null) && ((rs.getString("fee_tcash")).equals("0") || (rs.getString("fee_tcash")==null))){
						
						records = sdf.format(toDate(rs.getTimestamp("tx_date"))) + ".0" + separator + sdf.format(toDate(rs.getTimestamp("last_updated"))) + ".0" + separator + 
									rs.getString("card_id") + separator + 
									transaction_name(rs.getString("tx_type")) + separator;  
						
						if(!rs.getString("tx_type").equals("12") && !rs.getString("tx_type").equals("13") && !rs.getString("tx_type").equals("16") && !rs.getString("tx_type").equals("17")){
							records +=	rs.getString("credit") + separator;
						}
						records +=	rs.getString("debet") + separator; 
						
						if(rs.getString("tx_type").equals("12") || rs.getString("tx_type").equals("13") || rs.getString("tx_type").equals("16") || rs.getString("tx_type").equals("17")){
							records +=	rs.getString("credit") + separator;
						}
						
						if(Integer.parseInt((rs.getString("tx_type"))) <11)
							records += rs.getString("balance2") + separator; 
						else
							records += rs.getString("balance") + separator; 
						records +=	rs.getString("ref_num") + separator + 
									rs.getString("mmsisdn") + separator + 
									rs.getString("description");
						
						out.println(records);
					}else{
						double fee_ecash = rs.getDouble("fee_ecash");
						double fee_tcash = rs.getDouble("fee_tcash");
						double amount_credit = rs.getDouble("credit");
						double fee_cashin = fee_ecash + fee_tcash;
						double balance2 = 0.0;
						if(Integer.parseInt((rs.getString("tx_type"))) <11)
							balance2 = rs.getDouble("balance2") + amount_credit;
						else
							balance2 = rs.getDouble("balance") + amount_credit;
						
						out.println(
						sdf.format(toDate(rs.getTimestamp("tx_date"))) + ".0" + separator + 
						rs.getString("card_id") + separator + 
						"Cashin Fee" + separator +  
						(int)fee_cashin + separator + 
						rs.getString("debet") + separator + 
						balance2 + separator + 
						rs.getString("ref_num") + separator + 
						rs.getString("mmsisdn") + separator + 
						rs.getString("description"));
						
						
						records = sdf.format(toDate(rs.getTimestamp("tx_date"))) + ".0" + separator + 
									rs.getString("card_id") + separator + 
									transaction_name(rs.getString("tx_type")) + separator +  
									rs.getString("credit") + separator + 
									rs.getString("debet") + separator;
						if(Integer.parseInt((rs.getString("tx_type"))) <11)
							records += rs.getString("balance2") + separator;
						else
							records += rs.getString("balance") + separator;
						records += rs.getString("ref_num") + separator + 
									rs.getString("mmsisdn") + separator + 
									rs.getString("description");
						out.println(records);
	
					}
					
				}
				System.out.println("DEBUG|Zone6");
	
				pstmt.close();rs.close();
	}catch(Exception  e){
		e.printStackTrace(System.out);
	}finally{
		try { if(con_ecash!=null)con_ecash.close(); if(con_tcash!=null)con_tcash.close(); if(pstmt!=null)pstmt.close(); if(rs!=null)rs.close();} catch(Exception ee){}
	}
} else {
	response.sendRedirect("welcome.jsp");
}%>