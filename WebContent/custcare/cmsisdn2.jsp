<%@ page import="java.sql.*"%>
<%@page import="com.telkomsel.itvas.webstarter.WebStarterProperties"%>
<jsp:useBean id="DbCon" scope="page" class="tsel_tunai.DbCon"></jsp:useBean>
<%@ include file="/web-starter/taglibs.jsp" %>
<%@page import="com.telkomsel.itvas.webstarter.User"%>
<stripes:layout-render name="/web-starter/layout/standard.jsp" title="Reset PIN">
    <stripes:layout-component name="contents">
<link rel="stylesheet" href="my.css" type="text/css">
<%
String msisdn = request.getParameter("msisdn");
String prefix = WebStarterProperties.getInstance().getProperty("allowed.prefix");
if (!msisdn.startsWith(prefix)) {
	msisdn = "dodol" + msisdn;
}
session.putValue("msisdn", msisdn);
Connection con = null;
try {
String cust_info_id = "";
String acc_no = "";
String status = "not active";

con = DbCon.getConnection();
String sql = "select c.acc_no, c.cust_info_id, t.status from customer c, tsel_cust_account t where msisdn = ? and c.acc_no = t.acc_no";
PreparedStatement ps = con.prepareStatement(sql);
ps.setString(1, msisdn);
ResultSet rs = ps.executeQuery();
boolean b1 = false;

if(!rs.next()) {
	
	out.print("account_not_found");

} else {
	b1 = true;
	acc_no = rs.getString("acc_no");
	session.putValue("acc_no", acc_no);
	cust_info_id = rs.getString("cust_info_id");
	status = rs.getString("status");	
}
rs.close();
ps.close();

if(status != null && status.equals("1")) status = "active";
else status = "not active";

if(b1){
	sql = "select * from customer_info where cust_info_id = ?";
	ps = con.prepareStatement(sql);
	ps.setString(1, cust_info_id);
	rs = ps.executeQuery();
	if(rs.next()) {

%>
<form action="cmsisdn3.jsp" method="post">
  <table width="48%" border="0" cellspacing="3" cellpadding="3">
    <tr>
      <td class="unnamed1" width="30%"> 
        <div align="left">Name </div>
      </td>
      <td class="unnamed1" width="70%"> : <%= rs.getString("name") %></td>
    </tr>
    <tr>
      <td class="unnamed1" width="30%"> 
        <div align="left">Address </div>
      </td>
      <td class="unnamed1" width="70%"> : <%= rs.getString("address") %></td>
    </tr>
    <tr>
      <td class="unnamed1" width="30%"> 
        <div align="left">City </div>
      </td>
      <td class="unnamed1" width="70%"> : <%= rs.getString("city") %></td>
    </tr>
    <tr>
      <td class="unnamed1" width="30%"> 
        <div align="left">zipcode </div>
      </td>
      <td class="unnamed1" width="70%"> : <%= rs.getString("zipcode") %></td>
    </tr>
    <tr>
      <td class="unnamed1" width="30%"> 
        <div align="left">Phone number </div>
      </td>
      <td class="unnamed1" width="70%"> : <%= rs.getString("phone_num") %></td>
    </tr>
    <tr>
      <td class="unnamed1" width="30%">Msisdn</td>
      <td class="unnamed1" width="70%"> : <%= msisdn %></td>
    </tr>
    <tr>
      <td class="unnamed1" width="30%">Status</td>
      <td class="unnamed1" width="70%"> : <%= status %></td>
    </tr>
    <tr>
      <td class="unnamed1" width="30%">ID number</td>
      <td class="unnamed1" width="70%"> : <%= rs.getString("ktp_no") %></td>
    </tr>
    <tr>
      <td class="unnamed1" width="30%">Birthdate</td>
      <td class="unnamed1" width="70%"> : <%= rs.getString("birthdate") %></td>
    </tr>
    <tr>
      <td class="unnamed1" width="30%">Birthcity</td>
      <td class="unnamed1" width="70%"> : <%= rs.getString("birthcity") %></td>
    </tr>
    <tr>
      <td class="unnamed1" width="30%">Mother Name</td>
      <td class="unnamed1" width="70%"> : <%= rs.getString("mother") %></td>
    </tr>
    <tr>
      <td class="unnamed1" width="30%">&nbsp;</td>
      <td class="unnamed1" width="70%">&nbsp; </td>
    </tr>
    <tr>
      <td class="unnamed1" colspan="2">Make sure customer's Name, Birthdate, Mother's Name and Address are verified before RESET PIN</td>
    </tr>
    
    <tr>
      <td class="unnamed1" width="30%">New MSISDN : </td>
      <td class="unnamed1" width="70%">&nbsp; 
        <input type="text" name="newMsisdn" value="85" class="unnamed1">
      </td>
    </tr>
    <tr>
      <td class="unnamed1" width="30%">&nbsp;</td>
      <td class="unnamed1" width="70%">&nbsp; 
        <input type="submit" name="Submit" value="    Change MSISDN    " class="unnamed1">
      </td>
    </tr>
  </table>
  <input type=hidden name=msisdn value='<%=msisdn%>'>
</form>
<%
} else out.print("account_not_found");
rs.close();
ps.close();
}
} catch(Exception e){
	e.printStackTrace(System.out);
} finally {
	if(con != null) {
		try {
			con.close();
		}catch(Exception e2){}
	
	}
}
%>
    </stripes:layout-component>
</stripes:layout-render>
