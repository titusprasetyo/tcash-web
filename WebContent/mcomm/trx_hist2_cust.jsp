<%@ page language = "java" import = "java.io.*, java.util.*, java.text.*, java.sql.*, tsel_tunai.*" %>
<%@page import="com.telkomsel.itvas.webstarter.User"%>
<%@page import="com.telkomsel.itvas.webstarter.WebStarterProperties"%>
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
	String msisdn = request.getParameter("msisdn");
	
	if ((login != null) && (login.getRole() == 4) && (msisdn != null)) {
		String prefix = WebStarterProperties.getInstance().getProperty("allowed.prefix");
		if (!msisdn.startsWith(prefix)) {
			msisdn = "dodol" + msisdn;
		}
	}
	
	String terminal_msisdn = request.getParameter("terminal_msisdn");
	if (terminal_msisdn == null) terminal_msisdn = "";
	if (msisdn == null) msisdn = "";
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
<stripes:layout-render name="/web-starter/layout/standard.jsp" title="Customer Trasaction History">
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
          <form name="formini" method="post" action="trx_hist2_cust.jsp?login=<%=login%>">
            <tr bgcolor="#CC6633"> 
              <td colspan="2"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Search 
                  Transaction date</strong></font></div></td>
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
              <td><div align="center"><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif">Customer MSISDN</font></div></td>
              <td>
<input name='msisdn' value='<%=(request.getParameter("msisdn") == null) ? "" : request.getParameter("msisdn")%>'>
              </td>
            </tr>
            <tr> 
              <td width="30%" height="26"><input type="submit" name="Submit" value="Search"></td>
            </tr>
          </form>
        </table>
        <br>
		  <%
		   String sql = "select count(*) as jumlah from customer c,tsel_cust_account_history t, reader_terminal r where c.acc_no = t.acc_no and c.msisdn = ? and to_char(r.terminal_id(+)) = t.payment_terminal_id and ( tx_date between to_date('"+dari+" 00:00:00', 'DD-MM-YYYY HH24:MI:SS') and to_date('"+ampe+" 23:59:59', 'DD-MM-YYYY HH24:MI:SS') ) order by t.tx_date";
		  PreparedStatement pstmt = conn.prepareStatement(sql);
		  pstmt.setString(1,msisdn);
		  ResultSet rs = pstmt.executeQuery();
		  int jumlah = 0;
			if (rs.next()) {
				jumlah = rs.getInt("jumlah");
			}
			rs.close();
			pstmt.close();
			sql = null;
			rs = null;
			pstmt = null;
			
			
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
		  	out.print("<a class='link' href='?cur_page=" + (minPaging - 1) + "&msisdn=" + msisdn + "&dari=" + dari + "&ampe=" + ampe + "&terminal_msisdn=" + terminal_msisdn + "'>&lt;</a> ");
		  }
		  for (int i=minPaging; i<=maxPaging;i++) {
		  	if (i == cur_page) {
		  		out.print(i + " ");
		  	} else {
		  		out.print("<a class='link' href='?cur_page=" + i + "&msisdn=" + msisdn + "&dari=" + dari + "&ampe=" + ampe + "&terminal_msisdn=" + terminal_msisdn + "'>" + i + "</a> ");
		  	}
		  }
		  if (maxPaging + 1 <= total_page) {
		  	out.print("<a class='link' href='?cur_page=" + (maxPaging + 1) + "&msisdn=" + msisdn + "&dari=" + dari + "&ampe=" + ampe + "&terminal_msisdn=" + terminal_msisdn + "'>&gt;</a> ");
		  }
		  %>
		<table width="95%" border="1" cellspacing="0" cellpadding="0" bordercolor="#FFF6EF">
          <tr> 
            <td colspan="11" bgcolor="#FFF6EF"> 
              <div align="right"><font color="#CC6633" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>.:: 
                Customer Transaction History</strong></font></div>
            </td>
          </tr>
          <tr> 
            <td bgcolor="#CC6633" width="18%"> 
              <div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Trx 
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
			
			sql = "select * FROM (select a.*, ROWNUM rnum from (" +
						"select c.msisdn as msisdn, tx_id,t.acc_no,tx_tipe,debet,credit,balance,tx_date,loading_terminal_id,payment_terminal_id,t.description as description, ref_num, r.msisdn as mmsisdn from customer c,tsel_cust_account_history t, reader_terminal r where c.acc_no = t.acc_no and c.msisdn = ? and to_char(r.terminal_id(+)) = t.payment_terminal_id and ( tx_date between to_date('"+dari+" 00:00:00', 'DD-MM-YYYY HH24:MI:SS') and to_date('"+ampe+" 23:59:59', 'DD-MM-YYYY HH24:MI:SS') ) order by t.tx_date" +
						" ) a where ROWNUM <= ?) where rnum >= ?";
			System.out.println("sql:"+sql+" start:"+start_row+" end_row:"+end_row);
			pstmt = conn.prepareStatement(sql);
			pstmt.setString(1,msisdn);
			pstmt.setInt(2,end_row);
			pstmt.setInt(3,start_row);
			rs = pstmt.executeQuery();
			
			while (rs.next()) {
				int nTxTipe = -1;
				try {
					nTxTipe = Integer.parseInt(rs.getString("tx_tipe"));
				} catch (Exception e) {
				
				}	
				
				%>
          <tr> 
            <td width="18%"> 
              <div align="center"><font color="#000000" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("tx_date")%></font></div>
            </td>
            <td width="12%"> 
              <div align="center"><font color="#000000" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("msisdn")%></font></div>
            </td>
            <td width="6%"> 
              <div align="center"><font color="#000000" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= UssdTx.getTxtipe(nTxTipe)%></font></div>
            </td>
            <td width="8%"> 
              <div align="center"><font color="#000000" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= nf.format(rs.getLong("debet"))%></font></div>
            </td>
            <td width="8%"> 
              <div align="center"><font color="#000000" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= nf.format(rs.getLong("credit"))%></font></div>
            </td>
            <td width="10%"> 
              <div align="center"><font color="#000000" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= nf.format(rs.getLong("balance"))%></font></div>
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
			pstmt.close();
			rs.close();
		  %>
        </table>
<%	if (dari != null && ampe != null && !dari.equals("") && !ampe.equals("")) { %>
		 <br>
		 <center><a href="trx_hist_csv_cust.jsp?dari=<%=dari%>&ampe=<%=ampe%>&terminal_msisdn=<%=terminal_msisdn%>&msisdn=<%=msisdn%>">Save as CSV</a></center>
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
		</td>
		</tr>
		</table>
		</stripes:layout-component>
</stripes:layout-render>

<%
	} else {
		response.sendRedirect("index.html");
	}
%>
