<jsp:useBean id="dlr" class="com.telkomsel.itvas.garudasmscrew.SmsGatewayConnector" scope="application"></jsp:useBean>
<%
	String id = request.getParameter("id");
	String mask = request.getParameter("dlr-type");
	String smsc = request.getParameter("smsc");
	dlr.handleDelivery(id, mask, smsc);
	out.println("DLR Acknowledged");
%>