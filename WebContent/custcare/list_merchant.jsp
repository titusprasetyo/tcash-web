<%@ page import="java.sql.*"%>
<%@page import="com.telkomsel.itvas.webstarter.WebStarterProperties"%>
<jsp:useBean id="DbCon" scope="page" class="tsel_tunai.DbCon"></jsp:useBean>
<%@ include file="/web-starter/taglibs.jsp" %>
<%@page import="com.telkomsel.itvas.webstarter.User"%>
<stripes:layout-render name="/web-starter/layout/standard.jsp" title="Edit Account">
    <stripes:layout-component name="contents">
<link rel="stylesheet" href="my.css" type="text/css">
<%
String merchantFilter = WebStarterProperties.getInstance().getProperty("merchant.filter");

Connection con = null;
try {
String acc_no = "";
con = DbCon.getConnection();
String sql = "";
PreparedStatement ps = null;
ResultSet rs = null;



sql = "select * from merchant_info a,merchant b where a.merchant_info_id=b.merchant_info_id AND " + merchantFilter;
ps  = con.prepareStatement(sql);
rs = ps.executeQuery();
%>
<table width="90%" border="1" cellspacing="3" cellpadding="3">
  <tr bgcolor="#CCCCCC"> 
    <td class="unnamed1" width="19%"> 
      <div align="left">&nbsp;name</div>
    </td>
    <td width="27%" class="unnamed1"> 
      <div align="left">&nbsp;address</div>
    </td>
    <td width="13%" class="unnamed1"> 
      <div align="left">&nbsp;city</div>
    </td>
    <td width="13%" class="unnamed1"> 
      <div align="left">&nbsp;zipcode</div>
    </td>
    <td width="28%" class="unnamed1"> 
      <div align="left">&nbsp;phone number</div>
    </td>
    <td width="28%" class="unnamed1"> 
      <div align="left">&nbsp;detail</div>
    </td>
  </tr>
  <%
  	while(rs.next()) {
  %>
  <tr> 
    <td class="unnamed1" width="19%">&nbsp;<%= rs.getString("name") %></td>
    <td class="unnamed1" width="27%">&nbsp;<%= rs.getString("address") %> </td>
    <td class="unnamed1" width="13%">&nbsp;<%= rs.getString("city") %></td>
    <td class="unnamed1" width="13%">&nbsp;<%= rs.getString("zipcode") %></td>
    <td class="unnamed1" width="28%">&nbsp;<%= rs.getString("phone_num") %></td>
    <td class="unnamed1" width="28%">&nbsp;<a href='merchant_detail.jsp?id=<%= rs.getString("merchant_id") %>'>detail</a></td>
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
