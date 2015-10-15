<%@ page import="java.sql.*"%>
<jsp:useBean id="DbCon" scope="page" class="tsel_tunai.DbCon"></jsp:useBean>
<%@page import="com.telkomsel.itvas.webstarter.WebStarterProperties"%>
<%@ include file="/web-starter/taglibs.jsp" %>
<%@page import="com.telkomsel.itvas.webstarter.User"%>
<stripes:layout-render name="/web-starter/layout/standard.jsp" title="Create Ticket">
    <stripes:layout-component name="contents">
<jsp:useBean id="reg" scope="request" class="tsel_tunai.Ticket"/>
<%
User objUser =  (User)session.getValue("user");
String user = objUser.getUsername();
String msisdn = request.getParameter("msisdn");
String card_num = request.getParameter("card_num");
String problem = request.getParameter("problem");
String priority = request.getParameter("priority");
String reporter = request.getParameter("reporter");
String name = request.getParameter("name");
boolean bo = true;

//if(msisdn == null || msisdn.length() < 10) bo = false;

// Validasi MSISDN


//if(problem == null || problem.length() < 10) bo = false;


reg.setMsisdn(msisdn);
reg.setCard_num(card_num);
reg.setName(name);
reg.setProblem(problem);
reg.setPriority(priority);
reg.setReporter(user);

String ret [] = { "01", "Input Error"}; 
String Hsl = ret[1];
String prefix = WebStarterProperties.getInstance().getProperty("allowed.prefix");
if (!msisdn.startsWith(prefix)) {
	Hsl = "MSISDN must start with " + prefix;
	bo = false;
}
if(bo) {
	ret = reg.submit();
	//out.print("done. result:"+ret[0]+" note:"+ret[1]);
	
	
	if (!ret[0].equals("00"))
		Hsl = "Ticket Creation Failed :"+ret[1];
	else
		Hsl = "Ticket Creation Success";

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

