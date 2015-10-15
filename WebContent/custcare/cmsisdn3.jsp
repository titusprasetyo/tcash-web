<%@ page import="java.sql.*"%>
<%@page import="com.telkomsel.itvas.webstarter.WebStarterProperties"%>
<%@page import="org.apache.commons.dbutils.QueryRunner"%>
<%@page import="org.apache.commons.dbutils.handlers.ScalarHandler"%>
<jsp:useBean id="DbCon" scope="page" class="tsel_tunai.DbCon"></jsp:useBean>
<%@ include file="/web-starter/taglibs.jsp" %>
<%@page import="com.telkomsel.itvas.webstarter.User"%>
<stripes:layout-render name="/web-starter/layout/standard.jsp" title="Edit Account">
    <stripes:layout-component name="contents">
<jsp:useBean id="reg" scope="request" class="tsel_tunai.Register2Bean"/>
<%
String msisdn = request.getParameter("msisdn");
String prefix = WebStarterProperties.getInstance().getProperty("allowed.prefix");
String newMsisdn = request.getParameter("newMsisdn");
if (newMsisdn == null) {
	newMsisdn = "";
}
if (!msisdn.startsWith(prefix)) {
	msisdn = "dodol" + msisdn;
}

boolean exist = true;
Connection conn = null;
try {
	QueryRunner qr = new QueryRunner();
	conn = DbCon.getConnection();
	String q = "SELECT msisdn FROM customer WHERE msisdn=?";
	Object res = qr.query(conn, q, newMsisdn, new ScalarHandler("msisdn"));
	if (res == null) {
		exist = false;
	}
} catch (Exception e) {
	e.printStackTrace();
} finally {
	if (conn != null) {
		conn.close();
	}
}
User user = (User) session.getValue("user");
String Hsl = null;
System.out.println("new : " + newMsisdn);
if (!newMsisdn.startsWith(prefix)) {
	Hsl = "New MSISDN must start with "+prefix;
} else if (exist) {
	Hsl = "MSISDN already exist in T-Cash system";
} else {

	String ret [] = reg.changeMsisdn(msisdn, newMsisdn, user.getUsername());
	if (ret[0].equals("1")) {
		
		Hsl = "MSISDN successfully changed to : "+newMsisdn;
		reg.sendSms(newMsisdn, "Account T-Cash anda telah dipindahkan ke no : " + newMsisdn, "2828");
	
	} else if (ret[0].equals("2"))
	
		Hsl = "Customer not found";
	
	else
		Hsl = "Change MSISDN err:"+ret[1];
}


%>
<link rel="stylesheet" href="my.css" type="text/css">


<table width="70%" border="0" cellspacing="0" cellpadding="0" align="center">
  <tr>
    <td class="unnamed1">&nbsp;<%= Hsl %></td>
  </tr>
  <tr>
    <td class="unnamed1">&nbsp;<a href="javascript:history.go(-1)">back</a></td>
  </tr>
</table>
    </stripes:layout-component>
</stripes:layout-render>
