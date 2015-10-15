<%@page import="java.sql.Connection"%>
<%@page import="com.telkomsel.itvas.database.MysqlFacade"%>
<%@page import="org.apache.commons.dbutils.QueryRunner"%>
<%@page import="org.apache.commons.dbutils.DbUtils"%>
<jsp:useBean id="dlr" class="com.telkomsel.itvas.garudasmscrew.SmsGatewayConnector"  scope="application"></jsp:useBean>
<%
	String msisdn = request.getParameter("msisdn");
	String message= request.getParameter("message");
	Connection conn = MysqlFacade.getConnection();
	String q = "INSERT INTO sms_out_pool (single_sms_id, msisdn, message) VALUES (0, ? ,?)";
	QueryRunner qr = new QueryRunner();
	qr.update(conn, q, new Object[] {msisdn, message});
	DbUtils.closeQuietly(conn);
	out.println("selesai dikirim");
%>