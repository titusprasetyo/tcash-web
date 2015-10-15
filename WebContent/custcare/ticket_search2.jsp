<%@ page import="java.sql.*"%>
<%@page import="com.telkomsel.itvas.webstarter.WebStarterProperties"%>
<jsp:useBean id="DbCon" scope="page" class="tsel_tunai.DbCon"></jsp:useBean>
<%@ include file="/web-starter/taglibs.jsp" %>
<%@page import="com.telkomsel.itvas.webstarter.User"%>
<stripes:layout-render name="/web-starter/layout/standard.jsp" title="Ticket Search">
    <stripes:layout-component name="contents">
<link rel="stylesheet" href="my.css" type="text/css">
<%
User objUser =  (User)session.getValue("user");
String user = objUser.getUsername();
String msisdn = request.getParameter("msisdn");
String tipe = request.getParameter("tipe");

Connection con = null;
try {
String acc_no = "";
con = DbCon.getConnection();
String sql = "";
PreparedStatement ps = null;
ResultSet rs = null;
String prefix = WebStarterProperties.getInstance().getProperty("allowed.prefix");

if(tipe.equals("msisdn")) sql = "select * from problem_ticket where msisdn = ?  and report_by = ? AND msisdn LIKE '"+prefix+"%' and rownum < 100 order by create_time desc";
else if (tipe.equals("problem")) sql = "select * from problem_ticket where LOWER(problem) like ?  and report_by = ? AND msisdn LIKE '"+prefix+"%' and rownum < 100 order by create_time desc";
else sql = "select * from problem_ticket where card_no = ? and report_by = ? AND msisdn LIKE '"+prefix+"%' and rownum < 100 order by create_time";
ps  = con.prepareStatement(sql);

if (tipe.equals("problem")) {
	ps.setString(1, "%" + msisdn + "%");
} else {
	
	ps.setString(1, msisdn);
}
ps.setString(2, user);
rs = ps.executeQuery();
%>
<table width="90%" border="0" cellspacing="3" cellpadding="3">
  <tr bgcolor="#CCCCCC"> 
    <td class="unnamed1" width="19%"> 
      <div align="left">&nbsp;Msisdn</div>
    </td>
    <td width="18%" class="unnamed1"> 
      <div align="left">Card Number</div>
    </td>
    <td width="25%" class="unnamed1"> 
      <div align="left">&nbsp;Problem</div>
    </td>
    <td width="10%" class="unnamed1"> 
      <div align="left">&nbsp;Status</div>
    </td>
    <td width="28%" class="unnamed1"> 
      <div align="left">&nbsp;SubmitDate</div>
    </td>
  </tr>
  <%
  	while(rs.next()) {
	String status = rs.getString("status");
	if(status.equals("0")) status = "open";
  %>
  <tr> 
    <td class="unnamed1" width="19%">&nbsp;<%= rs.getString("msisdn") %></td>
    <td class="unnamed1" width="18%">&nbsp;<%= rs.getString("card_no") %> </td>
    <td class="unnamed1" width="25%">&nbsp;<%= rs.getString("problem") %></td>
    <td class="unnamed1" width="10%">&nbsp;<%= status %></td>
    <td class="unnamed1" width="28%">&nbsp;<%= rs.getString("create_time") %></td>
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
    </stripes:layout-component>
</stripes:layout-render>

