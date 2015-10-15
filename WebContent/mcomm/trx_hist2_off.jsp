<%@ page language = "java" import = "java.io.*, java.util.*, java.text.*, java.sql.*, tsel_tunai.*" %>
<%@page import="com.telkomsel.itvas.webstarter.User"%>
<jsp:useBean id="DbCon" scope="page" class="tsel_tunai.DbCon" />
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
	}else if(trx_type.equals("13")){
		return "Merchant Aggre Cashout1";
	}else if(trx_type.equals("12")){
		return "Merchant Hybrid Cashout";
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
	User login = (User)session.getValue("user");
	if (login == null) {
		response.sendRedirect("welcome.jsp");
	}
	User user = (User)session.getValue("user");
	if(user != null)
	{
   		session.putValue("user", user);
%>
<%@ include file="/web-starter/taglibs.jsp"%>
<stripes:layout-render name="/web-starter/layout/standard.jsp" title="Merchant TAPizy History">
	<stripes:layout-component name="contents"> 
  
        <%
	NumberFormat nf =  NumberFormat.getInstance(Locale.ITALY);

	Calendar cal = Calendar.getInstance();
	SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
	
	String merchant_id = "";
	String merchant_account_id = "";
	String merchant_name = "";
	
	String merchant = request.getParameter("merchant");
	
	String dari = request.getParameter("dari");
	String ampe = request.getParameter("ampe");		
	String test = request.getParameter("test");
	
	String terminal_msisdn = request.getParameter("terminal_msisdn");
	
	boolean b1 = false;
	
	if (merchant == null) merchant = "";
	if (terminal_msisdn == null) terminal_msisdn = "";
	
	Connection con_tcash = null;
	Connection con_ecash = null;
	String sql = "";
	PreparedStatement pstmt = null;
	ResultSet rs = null;
	try{
		Class.forName("oracle.jdbc.OracleDriver");
		con_tcash = DbCon.getConnection();
		con_ecash = DriverManager.getConnection("jdbc:oracle:thin:@//10.2.248.246:1521/orcl", "ecash", "orclecash");
	%>
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
			ampe = (ampe != null && !ampe.equals("")) ? ampe : tdate;
		%>
          <form name="formini" method="post" action="trx_hist2_off.jsp?login=<%=login%>">
            <tr bgcolor="#CC6633"> 
              <td colspan="2"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Search 
                  Transaction (Upload) date</strong></font></div></td>
            </tr>
            <tr> 
              <td colspan="2"></td>
            </tr>
            <tr> 
              <td height="15"><div align="center"><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif">From</font></div></td>
              <td><div align="left"><input type="text" name="dari" value="<%= dari%>" readonly="true"><a href="javascript:calendar('opener.document.formini.dari.value');"><img src="${pageContext.request.contextPath}/STATIC/cal.gif" alt="Calendar" border="0" align="absmiddle"></a> 
                  
                </div>
				<input type="hidden" name="test" value="1">
              </td>
            </tr>
            <tr> 
              <td><div align="center"><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif">To</font></div></td>
              <td><div align="left"><input type="text" name="ampe" value="<%= ampe%>" readonly="true"><a href="javascript:calendar2('opener.document.formini.ampe.value');"><img src="${pageContext.request.contextPath}/STATIC/cal.gif" alt="Calendar" border="0" align="absmiddle"></a>
                  
                </div>
              </td>
            </tr>
					<tr> 
              <td><div align="center"><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif">Merchant</font></div></td>
              <td>
				<select name='merchant'>
				<%
					try {
						String q = "select a.MERCHANT_ID, b.NAME from MERCHANT a, MERCHANT_INFO b WHERE a.MERCHANT_INFO_ID=b.MERCHANT_INFO_ID and a.STATUS='A' order by b.NAME";
						pstmt = con_tcash.prepareStatement(q);
						rs = pstmt.executeQuery();
						while (rs.next()) {
							if (rs.getString("MERCHANT_ID").equals(merchant)) {
								out.println("<option value='" + merchant +"' selected>" + rs.getString("NAME") + "</option>	");
							} else {
								out.println("<option value='" + rs.getString("MERCHANT_ID") + "'>" + rs.getString("NAME") + "</option>	");
							}
						}
						rs.close();
					} catch (Exception e) {
						e.printStackTrace();
						response.sendRedirect("index.jsp?msg=Database+error");
					}
				%>
				</select>              
              </td>
            </tr>
            <tr> 
              <td width="30%" height="26"><input type="submit" name="Submit" value="Search"></td>
            </tr>
          </form>
        </table>



        <br />
		  <%	
		  
			/*
			sql = "select merchant_id from merchant where login='"+login+"'";
			pstmt = con_tcash.prepareStatement(sql);
			rs = pstmt.executeQuery();
			if(rs.next()){
				merchant_id = rs.getString("merchant_id");
			}
			pstmt.close();rs.close();
			*/
			
			merchant_id = merchant;
			
			// take merchant_account_id
			sql = "select name, merchant_account_id from merchant where tcash_id='"+merchant_id+"'";
			pstmt = con_ecash.prepareStatement(sql);
			rs = pstmt.executeQuery();
			if(rs.next()){
				merchant_account_id = rs.getString("merchant_account_id");
				merchant_name = rs.getString("name");
			}
			rs.close();pstmt.close();
		
		  if(terminal_msisdn.equals(""))
			sql = "select count(*) as jumlah from transaction tr, terminal te, customer_account ca where not tr.status=5 and ca.ID(+)= tr.CUSTOMER_ID and tr.merchant_id='"+merchant_account_id+"' and tr.terminal_id=te.id (+) and ( tr.last_updated between to_date('"+dari+" 00:00:00', 'DD-MM-YYYY HH24:MI:SS') and to_date('"+ampe+" 23:59:59', 'DD-MM-YYYY HH24:MI:SS'))";
		  else
			sql = "select count(*) as jumlah from transaction tr, terminal te, customer_account ca where not tr.status=5 and ca.ID(+)= tr.CUSTOMER_ID and tr.merchant_id='"+merchant_account_id+"' and tr.terminal_id='"+terminal_msisdn+"' and tr.terminal_id=te.id(+) and ( tr.last_updated between to_date('"+dari+" 00:00:00', 'DD-MM-YYYY HH24:MI:SS') and to_date('"+ampe+" 23:59:59', 'DD-MM-YYYY HH24:MI:SS'))";
		  
		  pstmt = con_ecash.prepareStatement(sql);
		  rs = pstmt.executeQuery();
		  int jumlah = 0;
			if (rs.next()) {
				jumlah = rs.getInt("jumlah");
			}
			rs.close();pstmt.close();			
			
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
		  int minPaging = cur_page - 5;
		  if (minPaging < 1) {
		  	minPaging = 1;
		  }
		  int maxPaging = cur_page + 5;
		  if (maxPaging > total_page) {
		  	maxPaging = total_page;
		  }
		  if (minPaging - 1 > 0) {
		  	out.print("<a class='link' href='?cur_page=" + (minPaging - 1) + "&merchant=" + merchant_id + "&dari=" + dari + "&ampe=" + ampe + "&terminal_msisdn=" + terminal_msisdn + "'>&lt;</a> ");
		  }
		  for (int i=minPaging; i<=maxPaging;i++) {
		  	if (i == cur_page) {
		  		out.print(i + " ");
		  	} else {
		  		out.print("<a class='link' href='?cur_page=" + i + "&merchant=" + merchant_id + "&dari=" + dari + "&ampe=" + ampe + "&terminal_msisdn=" + terminal_msisdn + "'>" + i + "</a> ");
		  	}
		  }
		  if (maxPaging + 1 <= total_page) {
		  	out.print("<a class='link' href='?cur_page=" + (maxPaging + 1) + "&merchant=" + merchant_id + "&dari=" + dari + "&ampe=" + ampe + "&terminal_msisdn=" + terminal_msisdn + "'>&gt;</a> ");
		  }
		  %>
		<table width="95%" border="1" cellspacing="0" cellpadding="0" bordercolor="#FFF6EF">
          <tr> 
            <td colspan="9" bgcolor="#FFF6EF"> 
              <div align="right"><font color="#CC6633" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>.:: 
                Merchant Transaction History</strong></font></div>
            </td>
          </tr>
           <tr> 
            <td bgcolor="#CC6633" width="18%"> 
              <div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Trx 
                Date </strong></font></div>
            </td>
			<td bgcolor="#CC6633" width="18%"> 
              <div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Upload 
                Date </strong></font></div>
            </td>
            <td bgcolor="#CC6633" width="12%"> 
              <div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Customer</strong></font></div>
            </td>
            <td bgcolor="#CC6633" width="6%"> 
              <div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Trx 
                Type </strong></font></div>
            </td>
            <td bgcolor="#CC6633" width="8%"> 
              <div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Debet</strong></font></div>
            </td>
            <td bgcolor="#CC6633" width="8%"> 
              <div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Credit</strong></font></div>
            </td>
            <td bgcolor="#CC6633" width="10%"> 
              <div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Balance</strong></font></div>
            </td>
            <td bgcolor="#CC6633" width="8%"> 
              <div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> 
                Trx Id</strong></font></div>
            </td>
            <td bgcolor="#CC6633" width="16%"> 
              <div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> 
                Terminal ID</strong></font></div>
            </td>
            <td bgcolor="#CC6633" width="14%"> 
              <div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Description</strong></font></div>
            </td>
          </tr>
          <%			
			if(terminal_msisdn.equals("")){
				sql = "select * FROM (select a.*, ROWNUM rnum from (" +
							"select nvl(tr.fee_ecash,0) as fee_ecash, nvl(tr.fee_tcash,0) as fee_tcash, tr.last_updated as last_updated, tr.trx_time as tx_date, decode(ca.WALLET_ID, null,'ADMIN', ca.WALLET_ID) as card_id, tr.trx_type as tx_type, tr.debit as debet, tr.credit, nvl(tr.balance1,0) as balance, nvl(tr.balance2,0) as balance2, tr.id as ref_num, decode(tr.terminal_id, null, '-', tr.terminal_id) as mmsisdn, decode(te.name, null, 'Offline Reload/Settlement', te.name) as description  from transaction tr, terminal te, customer_account ca where not tr.status=5 and ca.ID(+)= tr.CUSTOMER_ID and tr.merchant_id='"+merchant_account_id+"' and tr.terminal_id=te.id (+) and ( tr.last_updated between to_date('"+dari+" 00:00:00', 'DD-MM-YYYY HH24:MI:SS') and to_date('"+ampe+" 23:59:59', 'DD-MM-YYYY HH24:MI:SS')) order by tr.last_updated asc, tr.trx_time asc" +						
							" ) a where ROWNUM <= "+end_row+") where rnum >= "+start_row;
			}else{
				sql = "select * FROM (select a.*, ROWNUM rnum from (" +
							"select nvl(tr.fee_ecash,0) as fee_ecash, nvl(tr.fee_tcash,0) as fee_tcash, tr.last_updated as last_updated, tr.trx_time as tx_date, decode(ca.WALLET_ID, null,'ADMIN', ca.WALLET_ID) as card_id, tr.trx_type as tx_type, tr.debit as debet, tr.credit, nvl(tr.balance1,0) as balance, nvl(tr.balance2,0) as balance2, tr.id as ref_num, decode(tr.terminal_id, null, '-', tr.terminal_id) as mmsisdn, decode(te.name, null, 'Offline Reload/Settlement', te.name) as description from transaction tr, terminal te, customer_account ca where not tr.status=5 and ca.ID(+)= tr.CUSTOMER_ID and tr.merchant_id='"+merchant_account_id+"' and tr.terminal_id='"+terminal_msisdn+"' and tr.terminal_id=te.id(+) and ( tr.last_updated between to_date('"+dari+" 00:00:00', 'DD-MM-YYYY HH24:MI:SS') and to_date('"+ampe+" 23:59:59', 'DD-MM-YYYY HH24:MI:SS')) order by tr.last_updated asc, tr.trx_time asc" +						
							" ) a where ROWNUM <= "+end_row+") where rnum >= "+start_row;
			}
			System.out.println(sql);
			pstmt = con_ecash.prepareStatement(sql);
			rs = pstmt.executeQuery();
		
			while (rs.next()) {
				b1 = true;
				// check for transfer_tcash (6)
				//if(!rs.getString("tx_type").equals("6")){
					if((rs.getString("fee_ecash")).equals("0") || (rs.getString("fee_ecash")==null) && ((rs.getString("fee_tcash")).equals("0") || (rs.getString("fee_tcash")==null))){
				%> 
          <tr> 
            <td width="18%"> 
              <div align="center"><font color="#000000" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= sdf.format(toDate(rs.getTimestamp("tx_date"))) +".0"%></font></div>
            </td>
			<td width="18%"> 
              <div align="center"><font color="#000000" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= sdf.format(toDate(rs.getTimestamp("last_updated"))) +".0"%></font></div>
            </td>
            <td width="12%"> 
              <div align="center"><font color="#000000" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("card_id")%></font></div>
            </td>
            <td width="6%"> 
              <div align="center"><font color="#000000" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= transaction_name(rs.getString("tx_type"))%></font></div>
            </td>
			
			<%if(!rs.getString("tx_type").equals("12") && !rs.getString("tx_type").equals("13") && !rs.getString("tx_type").equals("16") && !rs.getString("tx_type").equals("17")){%>
            <td width="8%"> 
              <div align="center"><font color="#000000" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= nf.format(rs.getLong("credit"))%></font></div>
            </td>
            <%}%>
			
			<td width="8%"> 
              <div align="center"><font color="#000000" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= nf.format(rs.getLong("debet"))%></font></div>
            </td>
            
			<%if(rs.getString("tx_type").equals("12") || rs.getString("tx_type").equals("13") || rs.getString("tx_type").equals("16") || rs.getString("tx_type").equals("17")){%>
            <td width="8%"> 
              <div align="center"><font color="#000000" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= nf.format(rs.getLong("credit"))%></font></div>
            </td>
            <%}%>
			
			<td width="10%"> 
			<%if(Integer.parseInt((rs.getString("tx_type"))) <11){%>
              <div align="center"><font color="#000000" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= nf.format(rs.getLong("balance2"))%></font></div>
            <%}else{%>
			  <div align="center"><font color="#000000" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= nf.format(rs.getLong("balance"))%></font></div>
			<%}%>
			</td>
            <td width="8%"> 
              <div align="center"><font color="#000000" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("ref_num")%></font></div>
            </td>
            <td width="16%"> 
              <div align="center"><font color="#000000" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("mmsisdn")%></font></div>
            </td>
            <td width="14%"> 
              <div align="center"><font color="#000000" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("description")%></font></div>
            </td>
          </tr>
          <%
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
					%>
		  <tr> 
            <td width="18%"> 
              <div align="center"><font color="#000000" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= sdf.format(toDate(rs.getTimestamp("tx_date"))) + ".0"%></font></div>
            </td>
            <td width="12%"> 
              <div align="center"><font color="#000000" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("card_id")%></font></div>
            </td>
            <td width="6%"> 
              <div align="center"><font color="#000000" size="1" face="Verdana, Arial, Helvetica, sans-serif">Cashin Fee</font></div>
            </td>
            <td width="8%"> 
              <div align="center"><font color="#000000" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= nf.format(fee_cashin)%></font></div>
            </td>
            <td width="8%"> 
              <div align="center"><font color="#000000" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= nf.format(rs.getLong("debet"))%></font></div>
            </td>
            <td width="10%"> 
			  <div align="center"><font color="#000000" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= nf.format(balance2)%></font></div>
			</td>
            <td width="8%"> 
              <div align="center"><font color="#000000" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("ref_num")%></font></div>
            </td>
            <td width="16%"> 
              <div align="center"><font color="#000000" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("mmsisdn")%></font></div>
            </td>
            <td width="14%"> 
              <div align="center"><font color="#000000" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("description")%></font></div>
            </td>
          </tr>		

         <tr> 
            <td width="18%"> 
              <div align="center"><font color="#000000" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= sdf.format(toDate(rs.getTimestamp("tx_date"))) + ".0"%></font></div>
            </td>
            <td width="12%"> 
              <div align="center"><font color="#000000" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("card_id")%></font></div>
            </td>
            <td width="6%"> 
              <div align="center"><font color="#000000" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= transaction_name(rs.getString("tx_type"))%></font></div>
            </td>
            <td width="8%"> 
              <div align="center"><font color="#000000" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= nf.format(rs.getLong("credit"))%></font></div>
            </td>
            <td width="8%"> 
              <div align="center"><font color="#000000" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= nf.format(rs.getLong("debet"))%></font></div>
            </td>
            <td width="10%"> 
			<%if(Integer.parseInt((rs.getString("tx_type"))) <11){%>
              <div align="center"><font color="#000000" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= nf.format(rs.getLong("balance2"))%></font></div>
            <%}else{%>
			  <div align="center"><font color="#000000" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= nf.format(rs.getLong("balance"))%></font></div>
			<%}%>
			</td>
            <td width="8%"> 
              <div align="center"><font color="#000000" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("ref_num")%></font></div>
            </td>
            <td width="16%"> 
              <div align="center"><font color="#000000" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("mmsisdn")%></font></div>
            </td>
            <td width="14%"> 
              <div align="center"><font color="#000000" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("description")%></font></div>
            </td>
          </tr>			
					
					
					<%
				}
				//}
			}
			pstmt.close();rs.close();
		  %>
        </table>
<%
	if (b1) { %>
		 <br>
		 <%if(terminal_msisdn.equals("")){%>
			<center><a href="trx_hist_csv_off.jsp?dari=<%=dari%>&ampe=<%=ampe%>&merchant=<%=merchant_id%>">Save as CSV</a></center>
		 <%}else{%>
			<center><a href="trx_hist_csv_off.jsp?dari=<%=dari%>&ampe=<%=ampe%>&terminal_msisdn=<%=terminal_msisdn%>&merchant=<%=merchant_id%>">Save as CSV</a></center>
	<%  }} %>
		 
        <br>

<%	}catch(Exception  e){
		e.printStackTrace(System.out);
	}finally{
		try { if(con_ecash!=null)con_ecash.close(); if(con_tcash!=null)con_tcash.close(); if(pstmt!=null)pstmt.close(); if(rs!=null)rs.close();} catch(Exception ee){}
	}
	
%>

		</stripes:layout-component>
</stripes:layout-render>

<%
	} else {
		response.sendRedirect("index.html");
	}
%>
