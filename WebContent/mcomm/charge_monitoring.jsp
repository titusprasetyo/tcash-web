<%@ page language = "java" import = "java.io.*, java.util.*, java.text.*, java.sql.*, tsel_tunai.*" %>
<%@page import="com.telkomsel.itvas.webstarter.User"%>
<script language="JavaScript">
<!--
function calendar(output)
{
	//alert('tes');
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
	
	//String test = request.getParameter("test");
	//String merchant = request.getParameter("merchant");
	//String terminal_msisdn = request.getParameter("terminal_msisdn");
	//if (terminal_msisdn == null) terminal_msisdn = "";
	//if (merchant == null) merchant = "";
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
<stripes:layout-render name="/web-starter/layout/standard.jsp" title="Monthly Fee Monitoring">
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
          <form name="formini" method="post" action="charge_monitoring.jsp?login=<%=login%>">
            <tr bgcolor="#CC6633"> 
              <td colspan="2"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Search 
                  by date</strong></font></div></td>
            </tr>
            <tr> 
              <td colspan="2"></td>
            </tr>
            <tr> 
              <td height="15"><div align="center"><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif">Start Date</font></div></td>
              <td><div align="left"><input type="text" name="dari" value="<%= dari%>" readonly="true"><a href="javascript:calendar('opener.document.formini.dari.value');"><img src="${pageContext.request.contextPath}/STATIC/cal.gif" alt="Calendar" border="0" align="absmiddle"></a> 
                  
                </div>
				<input type="hidden" name="test" value="1">
              </td>
            </tr>
            <tr> 
              <td><div align="center"><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif">End Date</font></div></td>
              <td><div align="left"><input type="text" name="ampe" value="<%= ampe%>" readonly="true"><a href="javascript:calendar2('document.formini.ampe.value');"><img src="${pageContext.request.contextPath}/STATIC/cal.gif" alt="Calendar" border="0" align="absmiddle"></a>
                  
                </div>
              </td>
            </tr>
            <tr> 
              <td width="30%" height="26"><input type="submit" name="Submit" value="Search"></td>
            </tr>
          </form>
        </table>
        <br>
		  <%
		   String sql = "select count(*) as jumlah from MONTHLY_CHARGE_REPORT  where  ( CHARGE_DATE between to_date('"+dari+" 00:00:00', 'DD-MM-YYYY HH24:MI:SS') and to_date('"+ampe+" 23:59:59', 'DD-MM-YYYY HH24:MI:SS') )";
		  PreparedStatement pstmt = conn.prepareStatement(sql);
		  
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
		  	out.print("<a class='link' href='?cur_page=" + (minPaging - 1) + "&dari=" + dari + "&ampe=" + ampe +"'>&lt;</a> ");
		  }
		  for (int i=minPaging; i<=maxPaging;i++) {
		  	if (i == cur_page) {
		  		out.print(i + " ");
		  	} else {
		  		out.print("<a class='link' href='?cur_page=" + i + "&dari=" + dari + "&ampe=" + ampe + "'>" + i + "</a> ");
		  	}
		  }
		  if (maxPaging + 1 <= total_page) {
		  	out.print("<a class='link' href='?cur_page=" + (maxPaging + 1) + "&dari=" + dari + "&ampe=" + ampe + "'>&gt;</a> ");
		  }
		  %>
		<table width="95%" border="1" cellspacing="0" cellpadding="0" bordercolor="#FFF6EF">
          <tr> 
            <td colspan="11" bgcolor="#FFF6EF"> 
              <div align="right"><font color="#CC6633" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>.:: 
                Monthly Fee Monitoring</strong></font></div>
            </td>
          </tr>
          <tr> 
            <td bgcolor="#CC6633" width="20%"> 
              <div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Charge Date </strong></font></div>
            </td>
            <td bgcolor="#CC6633" width="10%"> 
              <div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Amount</strong></font></div>
            </td>
            <td bgcolor="#CC6633" width="10%"> 
              <div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Total Charge Current</strong></font></div>
            </td>
            <td bgcolor="#CC6633" width="10%"> 
              <div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Total Charge Debt</strong></font></div>
            </td>
            <td bgcolor="#CC6633" width="10%"> 
              <div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Current Fail Charge</strong></font></div>
            </td>
            <td bgcolor="#CC6633" width="10%"> 
              <div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Blocked Customer</strong></font></div>
            </td>
            <td bgcolor="#CC6633" width="10%"> 
              <div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Remain Debt</strong></font></div>
            </td>
            <td bgcolor="#CC6633" width="10%"> 
              <div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Charge Error</strong></font></div>
            </td>
            <td bgcolor="#CC6633" width="10%"> 
              <div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Debt Error</strong></font></div>
            </td>
          </tr>
          <%
		 	
			sql = "select * FROM (select a.*, ROWNUM rnum from (" +
						"select * from MONTHLY_CHARGE_REPORT  where  ( CHARGE_DATE between to_date('"+dari+" 00:00:00', 'DD-MM-YYYY HH24:MI:SS') and to_date('"+ampe+" 23:59:59', 'DD-MM-YYYY HH24:MI:SS') ) order by CHARGE_DATE desc" +
						" ) a where ROWNUM <= ?) where rnum >= ?";
			System.out.println("sql:"+sql+" start:"+start_row+" end_row:"+end_row);
			pstmt = conn.prepareStatement(sql);
			pstmt.setInt(1,end_row);
			pstmt.setInt(2,start_row);
			rs = pstmt.executeQuery();
			while (rs.next()) {
					
				
				%>
          <tr> 
            <td width="20%"> 
              <div align="center"><font color="#000000" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("CHARGE_DATE")%></font></div>
            </td>
            <td width="10%"> 
              <div align="center"><font color="#000000" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= nf.format(rs.getLong("AMOUNT"))%></font></div>
            </td>
            <td width="10%"> 
              <div align="center"><font color="#000000" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= nf.format(rs.getLong("TOTAL_CHARGE_CURRENT"))%></font></div>
            </td>
            <td width="10%"> 
              <div align="center"><font color="#000000" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= nf.format(rs.getLong("TOTAL_CHARGE_DEBT"))%></font></div>
            </td>
            <td width="10%"> 
              <div align="center"><font color="#000000" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= nf.format(rs.getLong("CURRENT_FAIL_CHARGE"))%></font></div>
            </td>
            <td width="10%"> 
              <div align="center"><font color="#000000" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= nf.format(rs.getLong("UNREG_CUSTOMER"))%></font></div>
            </td>
            <td width="10%"> 
              <div align="center"><font color="#000000" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= nf.format(rs.getLong("REMAIN_DEBT"))%></font></div>
            </td>
            <td width="10%"> 
              <div align="center"><font color="#000000" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= nf.format(rs.getLong("CHARGE_INT_ERROR"))%></font></div>
            </td>
            <td width="10%"> 
              <div align="center"><font color="#000000" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= nf.format(rs.getLong("DEBT_INT_ERROR"))%></font></div>
            </td>
          </tr>
          <%
			}
			pstmt.close();
			rs.close();
		  %>
        </table>

        
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
