<%@page import="com.telkomsel.itvas.webstarter.User"%>
<jsp:useBean id="DbCon" scope="page" class="tsel_tunai.DbCon"></jsp:useBean>
<jsp:useBean id="u" scope="request" class="tsel_tunai.UssdTx" />
<%@ include file="/web-starter/taglibs.jsp"%>
<stripes:layout-render name="/web-starter/layout/standard.jsp" title="Merchant List">
	<stripes:layout-component name="contents">
<%
if (request.getParameter("deposit_id") != null) {
	User user = (User)session.getValue("user");
	String deposit_id = request.getParameter("deposit_id");
	if(user != null)
	{
		Connection conn = null;
		conn = DbCon.getConnection();
		try
		{
			String q = "SELECT AMOUNT, MERCHANT_ID FROM MERCHANT_DEPOSIT WHERE DEPOSIT_ID=?";
			PreparedStatement ps = conn.prepareStatement(q);
			ps.setString(1, deposit_id);
			ResultSet rs = ps.executeQuery();
			String[] retval = new String[] {"04", "internal_problem"};
			if (rs.next()) {
				String amount = rs.getString("AMOUNT");
				String merchant_id = rs.getString("MERCHANT_ID");
				u.setAmount(amount);
				u.setMerchant_id(merchant_id);
				retval = u.doMerchantDeposit(deposit_id);
				if (retval[0].equals("00")) {
										
					PreparedStatement stmt = null;
					String sql = null;
					sql = "INSERT INTO ACTIVITY_LOG (USERLOGIN, ACCESS_TIME, ACTIVITY, NOTE, IP) values (?,sysdate, ?,?,?)";
					stmt = conn.prepareStatement(sql);
					stmt.setString(1, user.getUsername());
					stmt.setString(2, "Execute Deposit|" + deposit_id);
					stmt.setString(3, "Success");
					stmt.setString(4, request.getRemoteAddr());
					stmt.executeUpdate();
					stmt.close();
					conn.close();
					conn = null;
					
					response.sendRedirect("execute_deposit.jsp?msg=Deposit+Executed");
				} else {
					response.sendRedirect("execute_deposit.jsp?msg=" + java.net.URLEncoder.encode("Execution failed, reason : " + retval[0] + ":" + retval[1]));			
				}
			} else {
						response.sendRedirect("execute_deposit.jsp?msg=" + java.net.URLEncoder.encode("Execution failed, reason : deposit not found" ));			
			}
		}
		catch(Exception  e){
		response.sendRedirect("execute_deposit.jsp?msg=" + java.net.URLEncoder.encode("Execution failed, because of database error"));
			e.printStackTrace(System.out);
		} finally{
		try { if(conn != null) conn.close(); } catch(Exception ee){}
		}
	} else {
		response.sendRedirect("admin.html");	
	}
}
%>

<%@ page import="java.sql.*"%>
</SCRIPT>
<script language="JavaScript">
<!--
function checkExecute()
{
	with(document)
	{
		var checkStatus = confirm('Do you really want to execute this deposit?');
		if (checkStatus)
		{
			checkStatus = true;
		}
		return checkStatus;
	}
}
//-->
</script>

<%
	String msisdn = request.getParameter("msisdn");
	if(session.getValue("user") != null)
	{
	
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
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
			  <tr> 
            <td><div align="right"><font color="#CC6633" size="4" face="Verdana, Arial, Helvetica, sans-serif"><strong></strong></font></div></td>
          </tr>	
		
		</table>
<%
if (request.getParameter("msg") != null) {
	out.println("<b>" + request.getParameter("msg") + "</b><br><br>");
}
%>
		
        <table width="21%" border="0" cellspacing="0" cellpadding="0">
          <form name="form" method="post" action="cashout_approval.jsp">
            <tr bgcolor="#CC6633"> 
              <td colspan="2"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Search 
                  Merchant's Deposit</strong></font></div></td>
            </tr>
            <tr> 
              <td width="30%"><input type="submit" name="Submit" value="Submit"></td>
              <td>
<select name="merchant_id">
<%
	String merchantID = request.getParameter("merchant_id");
	String q = "select MERCHANT_ID, NAME from MERCHANT a, MERCHANT_INFO b WHERE a.STATUS<>'D' AND a.MERCHANT_INFO_ID=b.MERCHANT_INFO_ID order by NAME";
	Statement st = conn.createStatement();
	ResultSet merchantRs = null;
	merchantRs = st.executeQuery(q);
	while (merchantRs.next()) {
		if (merchantID != null && merchantID.equals(merchantRs.getString("MERCHANT_ID") )) {
			out.println("<option value='" + merchantRs.getString("MERCHANT_ID") + "' selected>" + merchantRs.getString("NAME") + "</option>");
		} else {
			out.println("<option value='" + merchantRs.getString("MERCHANT_ID") + "'>" + merchantRs.getString("NAME") + "</option>");
		}
	}
	merchantRs.close();
	st.close();
%>
</select>            	
              	
              </td>
            </tr>
            <tr>
            <td><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><input type="radio" name="daily" value="1">Daily</td>
            <td><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><input type="radio" name="daily" value="2">On Demand</td> 
            </tr>
          </form>
        </table>
		
		<br>
		
        <table width="80%" border="1" cellspacing="0" cellpadding="0" bordercolor="#FFF6EF">
          <tr bgcolor="#FFF6EF"> 
            <td colspan="11"><div align="right"><font color="#CC6633" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>.:: 
                Deposit List</strong></font></div></td>
          </tr>
          <tr> 
            <td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Settle ID</strong></font></div></td>
            <td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Settle Date</strong></font></div></td>
            <td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Merchant</strong></font></div></td>
            <td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Amount(IDR)</strong></font></div></td>
            <td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Doc Number</strong></font></div></td>
            <td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Note</strong></font></div></td>
            <td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Custodian Bank</strong></font></div></td>
            <td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Merchant Bank</strong>
</font></div></td>
            <td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Pay Receipt</strong></font
></div></td>
            <td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Solve Ticket</str
ong></font></div></td> 
            </tr>
		  <%
		  
// paging stuff
String sql = null;
String merchant_id = request.getParameter("merchant_id");
if (merchant_id == null) {
	merchant_id = "";
}
if (request.getParameter("merchant_id") != null && !(request.getParameter("merchant_id").trim()).equals("")) {
	sql = "select count(*) as jumlah from MERCHANT_DEPOSIT a, MERCHANT b, MERCHANT_INFO c WHERE a.MERCHANT_ID=b.MERCHANT_ID AND b.MERCHANT_INFO_ID=c.MERCHANT_INFO_ID and a.MERCHANT_ID='"+request.getParameter("merchant_id")+"' and IS_EXECUTED='0' order by DEPOSIT_TIME DESC";
} else {
	sql = "select count(*) as jumlah from MERCHANT_DEPOSIT a, MERCHANT b, MERCHANT_INFO c WHERE a.MERCHANT_ID=b.MERCHANT_ID AND b.MERCHANT_INFO_ID=c.MERCHANT_INFO_ID  and IS_EXECUTED='0' order by DEPOSIT_TIME DESC";		 		
}
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
	out.print("<a class='link' href='?cur_page=" + (minPaging - 1) + "&merchant_id="+merchant_id+"'>&lt;</a> ");
}
for (int i=minPaging; i<=maxPaging;i++) {
	if (i == cur_page) {
		out.print(i + " ");
	} else {
		out.print("<a class='link' href='?cur_page=" + i + "&merchant_id="+merchant_id+"'>" + i + "</a> ");
	}
}
if (maxPaging + 1 <= total_page) {
	out.print("<a class='link' href='?cur_page=" + (maxPaging + 1) + "&merchant_id="+merchant_id+"'>&gt;</a> ");
}

// end of paging stuff
                                   
		        int no = 1;	
		 	sql = null;
                        String sdate = null;
		 	if (request.getParameter("merchant_id") != null && !(request.getParameter("merchant_id").trim()).equals("")) {
		 		sql = "select * FROM (select a.*, ROWNUM rnum from (" + 
		 					"select a.DEPOSIT_ID, a.IS_EXECUTED, a.DEPOSIT_TIME, c.NAME, a.DOC_NUMBER, a.NOTE, c.BANK_NAME, c.BANK_ACC_NO, d.MERCHANT_ID, d.ACC_NO, d.SETTLE_DATE, d.AMOUNT, d.STATUS from MERCHANT_DEPOSIT a, MERCHANT b, MERCHANT_INFO c, SETTLEMENT_HISTORY d where a.MERCHANT_ID=b.MERCHANT_ID and b.MERCHANT_INFO_ID=c.MERCHANT_INFO_ID and a.MERCHANT_ID='"+request.getParameter("merchant_id")+"' and IS_EXECUTED='0' and d.STATUS='1' order by DEPOSIT_TIME DESC" +
		 					" ) a where ROWNUM <= ?) where rnum >= ?";
		 	} else {
				sql = "select * FROM (select a.*, ROWNUM rnum from (" + 
							"select a.DEPOSIT_ID, a.IS_EXECUTED, a.DEPOSIT_TIME, c.NAME, a.DOC_NUMBER, a.NOTE from MERCHANT_DEPOSIT a, MERCHANT b, MERCHANT_INFO c, SETTLEMENT_HISTORY d where a.MERCHANT_ID=b.MERCHANT_ID AND b.MERCHANT_INFO_ID=c.MERCHANT_INFO_ID  and IS_EXECUTED='0' order by DEPOSIT_TIME DESC" + 
							" ) a where ROWNUM <= ?) where rnum >= ?";
		 	}
			pstmt = conn.prepareStatement(sql);
			pstmt.setInt(1,end_row);
			pstmt.setInt(2,start_row);
			rs = pstmt.executeQuery();
		        System.out.println("ca1");	
			while (rs.next()) {
                                System.out.println("no : "+no);
                                sdate = rs.getString("d.SETTLE_DATE"); sdate = sdate.substring(8); 
				%>
				<tr>
			<td bgcolor="#CCCCCC"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= Integer.toString(no++)%></font></div></td>
            		<td bgcolor="#CCCCCC"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= sdate%></font></div></td>
            		<td bgcolor="#CCCCCC"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= merchant_id%></font></div></td>
            		<td bgcolor="#CCCCCC"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("d.AMOUNT")%></font></div></td>
            		<td bgcolor="#CCCCCC"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("a.DOC_NUMBER")%></font></div></td>
            		<td bgcolor="#CCCCCC"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("a.NOTE")%></font></div></td>	
                        <td bgcolor="#CCCCCC"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("c.BANK_NAME")%></font>
</div></td>
                        <td bgcolor="#CCCCCC"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("c.BANK_ACC_NO")%></font></
div></td>
                        <td bgcolor="#CCCCCC"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif">pay_receipt</fon
t></div></td>
                        <td bgcolor="#CCCCCC"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif">solve_ticket</font></di
v></td>


	
		        <!--<td bgcolor="#CCCCCC"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><a href="execute_deposit.jsp?deposit_id=<%= rs.getString("DEPOSIT_ID")%>" onClick="return checkExecute();" class="link">execute</a></font></div></td>-->
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
		
        
		
		 
        <br>
<%	}
  	 catch(Exception  e){
			e.printStackTrace(System.out);
		} finally{
		try { conn.close(); } catch(Exception ee){}
		}
	
%>
  </div>
<%
if (request.getParameter("msg") != null) {
	out.println( "<SCRIPT LANGUAGE=javascript> alert('"+request.getParameter("msg")+"');</SCRIPT>" );
}

%>
</body>
</html>

<%
	} else {
		response.sendRedirect("admin.html");
	}
%>
	</stripes:layout-component>
</stripes:layout-render>
