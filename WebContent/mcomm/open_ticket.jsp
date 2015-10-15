<%@ page import="java.sql.*"%>
<jsp:useBean id="DbCon" scope="page" class="tsel_tunai.DbCon"></jsp:useBean>
<%@ include file="/web-starter/taglibs.jsp"%>
<stripes:layout-render name="/web-starter/layout/standard.jsp" title="Deposit List">
	<stripes:layout-component name="contents">
<%
String idTicket = request.getParameter("id");
if (idTicket != null) {
	String solution = request.getParameter("solution");
	if (solution == null) solution = "";
	String q = "update PROBLEM_TICKET set STATUS='1', solution=? where ID=?";
	Connection conn = null;
	try {
		conn = DbCon.getConnection();
		PreparedStatement ps = conn.prepareStatement(q);
		ps.setString(1, solution);
		ps.setString(2, idTicket);
		ps.executeUpdate();
		ps.close();
		conn.close();
		response.sendRedirect("open_ticket.jsp?msg=Ticket+closed");
	} catch (Exception e) {
		e.printStackTrace();
		System.out.println(e.getMessage());
		response.sendRedirect("open_ticket.jsp?msg=Ticket+closing+failed");
	}  finally {
		try {
			conn.close();
		} catch (Exception e) {}
	}
}

%>
<script language="JavaScript">
<!--
function checkDelete()
{
	with(document)
	{
		var checkStatus = confirm('Do you really want to close this ticket?');
		if (checkStatus)
		{
			checkStatus = true;
		}
		return checkStatus;
	}
}
//-->
</script>

		<table width="100%" border="0" cellpadding="0" cellspacing="0">
			  <tr> 
            <td><div align="right"><font color="#CC6633" size="4" face="Verdana, Arial, Helvetica, sans-serif"><strong></strong></font></div></td>
          </tr>	
		
		</table>
<link rel="stylesheet" href="my.css" type="text/css">
<%
Connection con = null;
try {
String acc_no = "";
con = DbCon.getConnection();
String sql = "";
PreparedStatement ps = null;
ResultSet rs = null;

//Paging Stuff
sql = "select count(*) as jumlah from problem_ticket where status = '0'";
PreparedStatement pstmt = con.prepareStatement(sql);
rs = pstmt.executeQuery();
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
for (int i=1; i<=total_page;i++) {
	if (i == cur_page) {
		out.print(i + " ");
	} else {
		out.print("<a class='link' href='?cur_page=" + i + "'>" + i + "</a> ");
	}
}
//End of paging stuff

sql = "select * FROM (select r.*, ROWNUM as row_number from ( " + 
			"select * from problem_ticket where status = '0' order by create_time desc" +
			") r where ROWNUM <= ? ) where row_number >= ?"; 
ps  = con.prepareStatement(sql);
ps.setInt(1,end_row);
ps.setInt(2,start_row);
rs = ps.executeQuery();

if (request.getParameter("msg") != null) {
	out.println("<center><strong>"+request.getParameter("msg")+"</strong></center><br><br>");
}

%>
<table width="90%" border="0" cellspacing="3" cellpadding="3">
  <tr bgcolor="#CCCCCC"> 
    <td class="unnamed1" width="10%"> 
      <div align="left">&nbsp;Msisdn</div>
    </td>
    <td width="15%" class="unnamed1"> 
      <div align="left">Card Number</div>
    </td>
    <td width="22%" class="unnamed1"> 
      <div align="left">&nbsp;Problem</div>
    </td>
    <td width="8%" class="unnamed1"> 
      <div align="left">&nbsp;Status</div>
    </td>
    <td width="11%" class="unnamed1">&nbsp;Severity</td>
    <td width="10%" class="unnamed1"> 
      <div align="left">&nbsp;SubmitDate</div>
    </td>
    <td width="28%" class="unnamed1"> 
      <div align="left">&nbsp;Close Ticket</div>
    </td>
  </tr>
  <%
  	while(rs.next()) {
	String status = rs.getString("status");
if(status.equals("0")) status = "open"; else status="closed";
  %>
  <tr> 
    <td class="unnamed1" width="16%">&nbsp;<%= rs.getString("msisdn") %></td>
    <td class="unnamed1" width="15%">&nbsp;<%= rs.getString("card_no") %> </td>
    <td class="unnamed1" width="22%">&nbsp;<%= rs.getString("problem") %></td>
    <td class="unnamed1" width="8%">&nbsp;<%= status %></td>
    <td class="unnamed1" width="11%"><%= rs.getString("priority").toUpperCase() %></td>
    <td class="unnamed1" width="28%">&nbsp;<%= rs.getString("create_time") %></td>
    <td class="unnamed1" width="28%">&nbsp;<%= (rs.getString("status").equals("0")) ? "<a onClick='return checkDelete();' href='open_ticket_solution.jsp?id="+rs.getString("id")+"'>close ticket</a>" : "closed" %></td>
  </tr>
  <% } %>
</table>
<%
rs.close();
ps.close();
}catch(Exception e){
e.printStackTrace(System.out);
} finally {
try { con.close(); }catch(Exception e2){}
}
%>
<br>
      </td>
    </tr>
    <tr> 
      <td  valign="top" bgcolor="#CC6633"> <div align="right"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"></font></div></td>
		  <td  valign="top" bgcolor="#CC6633"> <div align="right"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>IT 
          VAS Development 2007</strong></font></div></td>
    </tr>
		
  
  </table>
  </div>
</body>
</html>
		</stripes:layout-component>
</stripes:layout-render>