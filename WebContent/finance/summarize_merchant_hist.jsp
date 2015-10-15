<%@ page language = "java" import = "java.io.*, java.util.*, java.text.*, java.sql.*, tsel_tunai.*" %>
<%@page import="com.telkomsel.itvas.webstarter.User"%>
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

<%
	NumberFormat nf =  NumberFormat.getInstance(Locale.ITALY);


	User login = (User)session.getValue("user");
	String dari = request.getParameter("dari");
	String test = request.getParameter("test");
	String merchant = request.getParameter("merchant");
	String terminal_msisdn = request.getParameter("terminal_msisdn");
	if (terminal_msisdn == null) terminal_msisdn = "";
	if (merchant == null) merchant = "";
	//out.print(dari);
	String ampe = request.getParameter("ampe");
	User user = (User)session.getValue("user");
	if (login == null) {
		response.sendRedirect("welcome.jsp");
	}
	//String msisdn = request.getParameter("msisdn");
	//String variabel = request.getParameter("variabel");
	//out.print(variabel);
	if(user != null)
	{
%>
<jsp:useBean id="DbCon" scope="page" class="tsel_tunai.DbCon"></jsp:useBean>
<%@ include file="/web-starter/taglibs.jsp"%>
<stripes:layout-render name="/web-starter/layout/standard.jsp" title="Merchant Transaction History">
	<stripes:layout-component name="contents"> 
        <%
	
   
	
	Connection conn = null;
	try{
		
		//Class.forName("oracle.jdbc.driver.OracleDriver");
		//String url = "jdnc:oracle:thin:localhost:1521:ORCL";
		conn = DbCon.getConnection();
		//Statement stmt1 = conn.createStatement();
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
          <form name="formini" method="post" action="?login=<%=login%>">
            <tr bgcolor="#CC6633"> 
              <td colspan="2"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Search 
                  Transaction date</strong></font></div></td>
            </tr>
            <tr> 
              <td colspan="2"></td>
            </tr>
            <tr> 
              <td height="15"><div align="center"><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif">From</font></div></td>
              <td><div align="left"><input type="text" name="dari" value="<%= dari%>"><a href="javascript:calendar('opener.document.formini.dari.value');"><img src="${pageContext.request.contextPath}/STATIC/cal.gif" alt="Calendar" border="0" align="absmiddle"></a> 
                  
                </div>
				<input type="hidden" name="test" value="1">
              </td>
            </tr>
            <tr> 
              <td><div align="center"><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif">To</font></div></td>
              <td><div align="left"><input type="text" name="ampe" value="<%= ampe%>"><a href="javascript:calendar2('opener.document.formini.ampe.value');"><img src="${pageContext.request.contextPath}/STATIC/cal.gif" alt="Calendar" border="0" align="absmiddle"></a>
                  
                </div>
              </td>
            </tr>
					<tr> 
              <td><div align="center"><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif">Merchant</font></div></td>
              <td>
<select name='merchant'>
<%
	try {
		String q = "select a.MERCHANT_ID, b.NAME from MERCHANT a, MERCHANT_INFO b WHERE a.MERCHANT_INFO_ID=b.MERCHANT_INFO_ID order by b.NAME";
		Statement st = conn.createStatement();
		ResultSet rs = st.executeQuery(q);
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
        <br>
		<table width="95%" border="1" cellspacing="0" cellpadding="0" bordercolor="#FFF6EF">
          <tr> 
            <td colspan="11" bgcolor="#FFF6EF"> 
              <div align="right"><font color="#CC6633" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>.:: 
                Merchant Transaction History</strong></font></div>
            </td>
          </tr>
          <tr> 
            <td bgcolor="#CC6633" width="18%"> 
              <div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Trx Type</strong></font></div>
            </td>
            <td bgcolor="#CC6633" width="12%"> 
              <div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Debet</strong></font></div>
            </td>
            <td bgcolor="#CC6633" width="6%"> 
              <div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Kredit</strong></font></div>
            </td>
          </tr>
          <%
          	long saldoAwal = 0, saldoAkhir = 0;
          	System.out.println("debug01");
			// Saldo Awal          
          	String sql = "select t.ref_num, t.balance,t.debet,t.credit from merchant m,tsel_merchant_account_history t where m.acc_no = t.acc_no and m.merchant_id = ? and ( tx_date between to_date('"+dari+" 00:00:00', 'DD-MM-YYYY HH24:MI:SS') and to_date('"+ampe+" 23:59:59', 'DD-MM-YYYY HH24:MI:SS') ) order by t.tx_date ASC";
          	PreparedStatement pstmt = conn.prepareStatement(sql);
          	pstmt.setString(1,merchant);
          	ResultSet rs = pstmt.executeQuery();
          	if (rs.next()) {
          		System.out.println("debug02 : " + rs.getString("ref_num"));
				saldoAwal = rs.getLong("balance") + rs.getLong("debet") - rs.getLong("credit");           		
          	}
          	rs.close();
          	pstmt.close();
          	
         	// Saldo Akhir          
          	sql = "select t.balance from merchant m,tsel_merchant_account_history t where m.acc_no = t.acc_no and m.merchant_id = ? and ( tx_date between to_date('"+dari+" 00:00:00', 'DD-MM-YYYY HH24:MI:SS') and to_date('"+ampe+" 23:59:59', 'DD-MM-YYYY HH24:MI:SS') ) order by t.tx_date DESC";
          	pstmt = conn.prepareStatement(sql);
          	pstmt.setString(1,merchant);
          	rs = pstmt.executeQuery();
          	if (rs.next()) {
          		saldoAkhir = rs.getLong("balance");           		
          	}
          	rs.close();
          	pstmt.close();
          	System.out.println("debug03 : " + merchant);
			System.out.println("awal : " + saldoAwal);
			System.out.println("akhir: " + saldoAkhir);
          	
			sql = "select tx_tipe, sum(debet) as debet, sum(credit) as credit from merchant m,tsel_merchant_account_history t where m.acc_no = t.acc_no and m.merchant_id = ? and ( tx_date between to_date('"+dari+" 00:00:00', 'DD-MM-YYYY HH24:MI:SS') and to_date('"+ampe+" 23:59:59', 'DD-MM-YYYY HH24:MI:SS') ) group by tx_tipe order by t.tx_tipe";
			pstmt = conn.prepareStatement(sql);
			pstmt.setString(1,merchant);

			rs = pstmt.executeQuery();
			
			while (rs.next()) {
				int nTxTipe = -1;
				try {
					nTxTipe = Integer.parseInt(rs.getString("tx_tipe"));
				} catch (Exception e) {
				
				}	
				
				%>
          <tr> 
            <td width="6%"> 
              <div align="center"><font color="#000000" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= UssdTx.getTxtipe(nTxTipe)%></font></div>
            </td>
            <td width="8%"> 
              <div align="center"><font color="#000000" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= nf.format(rs.getLong("debet"))%></font></div>
            </td>
            <td width="8%"> 
              <div align="center"><font color="#000000" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= nf.format(rs.getLong("credit"))%></font></div>
            </td>
          </tr>
          <%
			}
			pstmt.close();
			rs.close();
		  %>
        </table>
        <br>
        <div align="center"><font size="2">
<%
	out.println("Saldo awal " + dari + " = Rp " + nf.format(saldoAwal));
	out.println("<br>");
	out.println("Saldo akhir " + ampe + " = Rp " + nf.format(saldoAkhir));
	if (dari != null && ampe != null && !dari.equals("") && !dari.equals("")) { %>
		 <br>
		 <br>
		 </font></div>
		 <center><a href="trx_hist_csv.jsp?dari=<%=dari%>&ampe=<%=ampe%>&terminal_msisdn=<%=terminal_msisdn%>&merchant=<%=merchant%>">Save as CSV</a></center>
<% } %>
        <br>
        <br>
        <br>
<%	}
  	 catch(Exception  e){
			e.printStackTrace(System.out);
		} finally{
		try { conn.close(); } catch(Exception ee){}
		}
	
%>
		</stripes:layout-component>
</stripes:layout-render>

<%
	} else {
		response.sendRedirect("index.html");
	}
%>
