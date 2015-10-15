<jsp:useBean id="pull" class="com.telkomsel.itvas.garudasmscrew.PullResponseBean"  scope="application"></jsp:useBean>
<%
String result = null;
if (request.getMethod().equals("POST")) {
	String msisdn = request.getParameter("msisdn");
	String message = request.getParameter("message");
	String myresponse = pull.pullRequest(msisdn, message);
	result = "Request SMS :<br>" + message + "<br>Response SMS :<br>" + myresponse;
}
%>
<html>
<head>
<title>Garuda SMS-Crew Test Pull Form</title>
</head>
<body>
<form method="POST" action="">
<strong><%= result %></strong>
<br>
MSISDN : <input type="text" name="msisdn" size="20"><br/>
Text : <input type="text" name="message" size="200"><br/>
<input type="submit" value="Send">
</form>
</html>