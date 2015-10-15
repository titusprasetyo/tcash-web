<%@page import="com.telkomsel.itvas.webstarter.User"%>
<%@ page
	import="tsel_tunai.*, java.io.*, java.util.*, java.text.*, java.sql.*"%>

<jsp:useBean id="DbCon" scope="page" class="tsel_tunai.DbCon"></jsp:useBean>

<%
	User user = (User) session.getValue("user");
	Connection conn = null;
	String trxType = Util.decMy(request.getParameter("trxType")
			.replaceAll(" ", "+"));
	String bearer = Util.decMy(request.getParameter("bearer")
			.replaceAll(" ", "+"));
	String source = Util.decMy(request.getParameter("source")
			.replaceAll(" ", "+"));
	String merchantId = Util.decMy(request.getParameter("merchantId")
			.replaceAll(" ", "+"));
	if (user != null) {
		session.putValue("user", user);
		//db
		conn = DbCon.getConnection();
		try {
			String sql = "delete from fee_config where trx_type = ? and source = ? and bearer = ? and merchant_id = ?";
			PreparedStatement ps = conn.prepareStatement(sql);
			ps.setString(1, trxType);
			ps.setString(2, source);
			ps.setString(3, bearer);
			ps.setString(4, merchantId);
			ps.executeUpdate();
			ps.close();
			conn.commit();
			//HttpGet.get("http://10.2.114.121:2021/tsel_tunai2/reload_fee_configAll.jsp", 10000);
			//HttpGet.get("http://10.2.123.170:8082/tsel_tunai2/reload_fee_configAll.jsp", 10000);
			HttpGet.get("http://10.2.123.171:8081/tsel_tunai2/reload_fee_configAll.jsp", 10000);
			HttpGet.get("http://10.2.123.171:8082/tsel_tunai2/reload_fee_configAll.jsp", 10000);
			response.sendRedirect("feeConfigList.jsp?msg=FeeConfig+deleted");
		} catch (Exception e) {
			conn.rollback();
			response.sendRedirect("feeeConfigList.jsp?msg=FeeConfig+delete+failed");
		} finally {
			if (conn != null) {
				try {
					conn.setAutoCommit(true);
				} catch (Exception ee2) {
				}
				try {
					conn.close();
				} catch (Exception ee) {
				}
			}
		}
	} else {
		//response.sendRedirect("index.html");
	}
%>