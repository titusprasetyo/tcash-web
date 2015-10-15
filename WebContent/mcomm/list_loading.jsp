<%@ page import="java.sql.*"%>
<%@ include file="/web-starter/taglibs.jsp"%>
<%@page import="com.telkomsel.itvas.webstarter.User"%>
<stripes:layout-render name="/web-starter/layout/standard.jsp" title="Loading Terminal List">
	<stripes:layout-component name="contents">
<script language="JavaScript">
<!--
function checkDelete()
{
	with(document)
	{
		var checkStatus = confirm('Do you really want to delete this terminal?');
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
	User user = (User)session.getValue("user");
	String name = request.getParameter("name");
	if (name == null) {
		name = "";
	}
%>
<jsp:useBean id="DbCon" scope="page" class="tsel_tunai.DbCon"></jsp:useBean>

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
	    
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
			  <tr> 
            <td><div align="right"><font color="#CC6633" size="4" face="Verdana, Arial, Helvetica, sans-serif"><strong></strong></font></div></td>
          </tr>	
		
		</table>
		
		
        <table width="21%" border="0" cellspacing="0" cellpadding="0">
          <form name="form" method="post" action="list_loading.jsp">
            <tr bgcolor="#CC6633"> 
              <td colspan="2"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Search 
                  Merchant Name</strong></font></div></td>
            </tr>
            <tr> 
              <td width="30%"><input type="submit" name="Submit" value="Submit"></td>
              <td> <input name="name" type="text"> </td>
            </tr>
          </form>
        </table>
		
		<br>
<%
if (request.getParameter("msg") != null) {
	out.println("<center><strong>" + request.getParameter("msg") + "</center></strong><br><br>");
}
%>				
        <table width="80%" border="1" cellspacing="0" cellpadding="0" bordercolor="#FFF6EF">
          <tr bgcolor="#FFF6EF"> 
            <td colspan="10"> 
              <div align="right"><font color="#CC6633" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>.:: 
                List Account Merchant</strong></font></div>
            </td>
          </tr>
          <tr> 
            <td bgcolor="#CC6633">
              <div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Terminal 
                ID </strong></font></div>
            </td>
            <td bgcolor="#CC6633"> 
              <div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Merchant 
                Name </strong></font></div>
            </td>
            <td bgcolor="#CC6633"> 
              <div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Description</strong></font></div>
            </td>
            <td bgcolor="#CC6633"> 
              <div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Address</strong></font></div>
            </td>
            <td bgcolor="#CC6633"> 
              <div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Edit</strong></font></div>
            </td>
            <td bgcolor="#CC6633"> 
              <div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Delete</strong></font></div>
            </td>
          </tr>
          <%
// paging stuff
String sql = "select count(*) as jumlah from merchant m,merchant_info mi,loading_terminal lt where m.merchant_info_id = mi.merchant_info_id and m.merchant_id = lt.merchant_id and LOWER(name) like '%"+name.toLowerCase()+"%'";
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
	out.print("<a class='link' href='?cur_page=" + (minPaging - 1) + "&name="+name+"'>&lt;</a> ");
}
for (int i=minPaging; i<=maxPaging;i++) {
	if (i == cur_page) {
		out.print(i + " ");
	} else {
		out.print("<a class='link' href='?cur_page=" + i + "&name="+name+"'>" + i + "</a> ");
	}
}
if (maxPaging + 1 <= total_page) {
	out.print("<a class='link' href='?cur_page=" + (maxPaging + 1) + "&name="+name+"'>&gt;</a> ");
}

// end of paging stuff

		 	sql = "select * FROM (select a.*, ROWNUM rnum from (" +
		 				"select lt.address, name,description,terminal_id from merchant m,merchant_info mi,loading_terminal lt where m.merchant_info_id = mi.merchant_info_id and m.merchant_id = lt.merchant_id and LOWER(name) like '%"+name.toLowerCase()+"%'" +
		 				" ) a where ROWNUM <= ?) where rnum >= ?";
			//out.print(sql);
			pstmt = conn.prepareStatement(sql);
			pstmt.setInt(1,end_row);
			pstmt.setInt(2,start_row);
			rs = pstmt.executeQuery();
			
			while (rs.next()) {
				%>
          <tr> 
            <td bgcolor="#EEEEEE">
              <div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("terminal_id")%></font></div>
            </td>
            <td bgcolor="#EEEEEE"> 
              <div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("name")%></font></div>
            </td>
            <td bgcolor="#EEEEEE"> 
              <div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("description")%></font></div>
            </td>
            <td bgcolor="#EEEEEE"> 
              <div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("address")%></font></div>
            </td>
            <td bgcolor="#EEEEEE"> 
              <div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"><a href="edit_loading.jsp?stat=0&tid=<%= rs.getString("terminal_id")%>&name=<%= rs.getString("name")%>&desc=<%= rs.getString("description")%>&address=<%= rs.getString("address")%>" class="link">edit</a></font></div>
            </td>
            <td bgcolor="#EEEEEE"> 
              <div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"><a href="delete_loading_terminal.jsp?tid=<%= rs.getString("terminal_id")%>" class="link" onClick="return checkDelete();">delete</a></font></div>
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
		
        <table width="40%" border="0" cellspacing="0" cellpadding="0">
          <tr> 
            <td><div align="center"><font color="#CC6633" size="1" face="Verdana, Arial, Helvetica, sans-serif">Sebelum 
                anda keluar dari layanan ini pastikan anda telah logout agar login 
                anda tidak dapat dipakai oleh orang lain.</font></div></td>
          </tr>
        </table>
		
		 
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
 
