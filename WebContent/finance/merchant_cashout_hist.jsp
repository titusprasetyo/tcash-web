<%@ page language = "java" import = "java.io.*, java.util.*, java.text.*, java.sql.*" %>
<%@page import="com.telkomsel.itvas.webstarter.User"%>
<script language="JavaScript">
<!--
function checkDelete()
{
	with(document)
	{
		var checkStatus = confirm('Do you really want to delete this cashout?');
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
	User login = (User)session.getValue("user");
	String dari = request.getParameter("dari");
	String merchant_name = request.getParameter("merchant_name");
	if (merchant_name == null) {
		merchant_name = "";
	}
	String test = request.getParameter("test");
	//out.print(dari);
	String ampe = request.getParameter("ampe");
	if(login != null)
	{
%>
<jsp:useBean id="DbCon" scope="page" class="tsel_tunai.DbCon"></jsp:useBean>
<%@ include file="/web-starter/taglibs.jsp"%>
<stripes:layout-render name="/web-starter/layout/standard.jsp" title="Deposit List">
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
          <form name="formini" method="post">
            <tr bgcolor="#CC6633"> 
              <td colspan="2"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Search 
                  Cashout date</strong></font></div></td>
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
              <td><div align="center"><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif">Merchant Name</font></div></td>
              <td><div align="left"><input type="text" name="merchant_name" value="<%= merchant_name%>">
                  
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
		  
		  NumberFormat formatter = new DecimalFormat("###,###,###");
		   String sql = "select count(*) as jumlah from merchant_cashout a, merchant b, merchant_info c where b.merchant_info_id=c.merchant_info_id and a.merchant_id=b.merchant_id and ( deposit_time between to_date('"+dari+" 00:00:00', 'DD-MM-YYYY HH24:MI:SS') and to_date('"+ampe+" 23:59:59', 'DD-MM-YYYY HH24:MI:SS')) and LOWER(c.name) like '%"+merchant_name.toLowerCase()+"%'";
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
		  int row_per_page = 50;
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
		  	out.print("<a class='link' href='?cur_page=" + (minPaging - 1) + "&login=" + login + "&dari=" + dari + "&ampe=" + ampe + "'>&lt;</a> ");
		  }
		  for (int i=minPaging; i<=maxPaging;i++) {
		  	if (i == cur_page) {
		  		out.print(i + " ");
		  	} else {
		  		out.print("<a class='link' href='?cur_page=" + i + "&login=" + login + "&dari=" + dari + "&ampe=" + ampe + "'>" + i + "</a> ");
		  	}
		  }
		  if (maxPaging + 1 <= total_page) {
		  	out.print("<a class='link' href='?cur_page=" + (maxPaging + 1) + "&login=" + login + "&dari=" + dari + "&ampe=" + ampe + "'>&gt;</a> ");
		  }
		  %>
		<table width="80%" border="1" cellspacing="0" cellpadding="0" bordercolor="#FFF6EF">
          <tr bgcolor="#FFF6EF"> 
            <td colspan="11"><div align="right"><font color="#CC6633" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>.:: 
                Merchant Cashout History</strong></font></div></td>
          </tr>
          <tr> 
            <td bgcolor="#CC6633">
              <div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Cashout 
                ID</strong></font></div>
            </td>
            <td bgcolor="#CC6633">
              <div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Merchant</strong></font></div>
            </td>
            <td bgcolor="#CC6633">
              <div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Amount</strong></font></div>
            </td>
            <td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Doc Number</strong></font></div></td>
            <td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Note</strong></font></div></td>
			<td bgcolor="#CC6633">
              <div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Cashout 
                Time</strong></font></div>
            </td>
			<td bgcolor="#CC6633">
              <div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Approval</strong></font></div>
            </td>
            <td bgcolor="#CC6633">
              <div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Print Receipt</strong></font></div>
            </td>            
		  </tr>
			<%
		 	sql = "select * FROM (select r.*, ROWNUM as row_number from (" +
		 				"select c.name, cashout_id,amount,doc_number,note,deposit_time,is_executed from merchant_cashout a, merchant b, merchant_info c  where b.merchant_info_id=c.merchant_info_id and a.merchant_id=b.merchant_id and ( deposit_time between to_date('"+dari+" 00:00:00', 'DD-MM-YYYY HH24:MI:SS') and to_date('"+ampe+" 23:59:59', 'DD-MM-YYYY HH24:MI:SS')) and LOWER(c.name) like '%"+merchant_name.toLowerCase()+"%'" +
		 				" order by deposit_time desc) r where ROWNUM <= ? ) where row_number >= ?"; 
			System.out.println(sql);
			pstmt = conn.prepareStatement(sql);
			pstmt.setInt(1,end_row);
			pstmt.setInt(2,start_row);
			rs = pstmt.executeQuery();
			
			while (rs.next()) {
				%>
				<tr>
					<td bgcolor="#EEEEEE">
              <div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString(2)%></font></div>
            </td>
            		<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif">&nbsp;<%= rs.getString("name")%></font></div></td>
            		<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif">&nbsp;<%= formatter.format(Double.parseDouble(rs.getString("amount")))%></font></div></td>
            		<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif">&nbsp;<%= rs.getString("doc_number")%></font></div></td>
            		<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif">&nbsp;<%= rs.getString("note")%></font></div></td>
            		<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif">&nbsp;<%= rs.getString("deposit_time")%></font></div></td>		
            		<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif">&nbsp;<%= (rs.getString("is_executed").equals("1")) ? "Approved" : "Not Approved"%></font></div></td>
            		<td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif">&nbsp;<a target='_brandnew' href="print.jsp?id=<%= rs.getString("cashout_id")%>">print</a></font></div></td>		
				</tr>
				<%
			}
			pstmt.close();
			rs.close();
		  %>
		 </table>
<%
	if (dari != null && ampe != null && !dari.equals("") && !dari.equals("")) { %>
		 <br>
		 <center>
        </center>
<% } %>
        <br>
        <br>
        <br>
        <table width="40%" border="0" cellspacing="0" cellpadding="0">
          <tr> 
            <td><div align="center"><font color="#CC6633" size="1" face="Verdana, Arial, Helvetica, sans-serif">Sebelum 
                anda keluar dari layanan ini pastikan anda telah logout agar login 
                anda tidak dapat dipakai oleh orang lain.</font></div></td>
			
          </tr>
        </table>
		 
        <br>
      </td>
    </tr>
    <tr> 
      <td  valign="top" bgcolor="#CC6633"> <div align="right"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"></font></div></td>
	  <td  valign="top" bgcolor="#CC6633"> <div align="right"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>IT 
          VAS Development 2007</strong></font></div></td>
    </tr>
  </table>
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
