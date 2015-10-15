<jsp:useBean id="MC" scope="request" class="tsel_tunai.MonthlyCharge"></jsp:useBean>
<%
	String status = request.getParameter("status");
	String amount = request.getParameter("amount");

	MC.setStatus(status);
	MC.setAmount(amount);

	String [] _ret = MC.insertConf();
	response.sendRedirect("charge_config.jsp?result=" + _ret[0] + "&msg=" + _ret[1]);
%>