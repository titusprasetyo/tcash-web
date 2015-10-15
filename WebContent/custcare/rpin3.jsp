<%@ page import="java.sql.*"%>
<%@page import="com.telkomsel.itvas.webstarter.WebStarterProperties"%>
<jsp:useBean id="DbCon" scope="page" class="tsel_tunai.DbCon"></jsp:useBean>
<%@ include file="/web-starter/taglibs.jsp" %>
<%@page import="com.telkomsel.itvas.webstarter.User"%>
<stripes:layout-render name="/web-starter/layout/standard.jsp" title="Edit Account">
    <stripes:layout-component name="contents">
<jsp:useBean id="reg" scope="request" class="tsel_tunai.Register2Bean"/>
<%
String msisdn = request.getParameter("msisdn");
String prefix = WebStarterProperties.getInstance().getProperty("allowed.prefix");
if (!msisdn.startsWith(prefix)) {
	msisdn = "dodol" + msisdn;
}


String ret [] = reg.resetCustPin(msisdn);
//String ret [] = { "1", "" };
//out.print("done. result:"+ret[0]+" note:"+ret[1]+"<br>");

String Hsl = null;

if (ret[0].equals("1")) {
	
	Hsl = "Reset pin success and sent to "+msisdn;
	reg.sendSms(msisdn, "PIN TCash Anda telah diubah menjadi "+ret[1]+". Rahasiakan PIN ini atau ganti segera PIN Anda dg cara ketik CPIN <PINLama> <PINBaru> kirim ke 2828", "2828");

} else if (ret[0].equals("2"))

	Hsl = "Customer not found";

else
	Hsl = "Reset pin fail err:"+ret[1];


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
