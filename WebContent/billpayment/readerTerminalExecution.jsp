<%@page import="com.telkomsel.itvas.webstarter.UserLogWriter"%>
<%@page import="com.telkomsel.itvas.util.HexaCharUtils"%>
<%@page import="com.telkomsel.itvas.webstarter.User"%>
<%@page import="org.apache.commons.lang.StringEscapeUtils"%>
<%@ page
	import="tsel_tunai.*,java.sql.*,java.lang.String.*,java.util.*,java.text.*,java.util.regex.*;"%>

<jsp:useBean id="DbCon" scope="page" class="tsel_tunai.DbCon"></jsp:useBean>

<%
	String ipaddr = request.getRemoteAddr();
	String hiddenId = StringEscapeUtils.escapeHtml(request
			.getParameter("hiddenId"));
	String terminalId = StringEscapeUtils.escapeHtml(request
			.getParameter("terminalId"));
	String msisdn = StringEscapeUtils.escapeHtml(request
			.getParameter("msisdn").trim());
	String msisdnValue = "";
	if(msisdn.startsWith("08")){
		msisdnValue = "62" + msisdn.substring(1, msisdn.length());
	}else{
		msisdnValue = msisdn;
	}
	String merchantId = StringEscapeUtils.escapeHtml(request
			.getParameter("merchant"));
	String description = StringEscapeUtils.escapeHtml(request
			.getParameter("description"));
	String keyTerminal = StringEscapeUtils.escapeHtml(request
			.getParameter("keyTerminal").trim());
	String address = StringEscapeUtils.escapeHtml(request
			.getParameter("address").trim());
	String urlType = StringEscapeUtils.escapeHtml(request
			.getParameter("urlType"));
	String url = "";
	if(urlType.equals("x")){
		url = urlType + StringEscapeUtils.escapeHtml(request
			.getParameter("url"));
	}else{
		url = StringEscapeUtils.escapeHtml(request
				.getParameter("url"));
	}
	String terminalType = StringEscapeUtils.escapeHtml(request
			.getParameter("terminalType"));
	String chargeInfo = StringEscapeUtils.escapeHtml(request
			.getParameter("chargeInfo"));
	
	String isLocked = StringEscapeUtils.escapeHtml(request
			.getParameter("isLocked"));
	
	String alias = StringEscapeUtils.escapeHtml(request
			.getParameter("alias"));
	
	
	String encKey = "";
	if(request.getParameter("encryptionText")!=null){
		String encryption = StringEscapeUtils.escapeHtml(request.getParameter("encryptionText"));
		encKey = HexaCharUtils.CharToHexa(encryption);
	}

	Connection conn = null;
	conn = DbCon.getConnection();
	User user = (User) session.getValue("user");
	if ((user != null) && (request.getMethod().equals("POST"))) {
		session.putValue("user", user);
		String msg = "";
		try {
			
				String qCount = "select count(*) as count from merchant_rolling_key where merchant_id = ?";
				PreparedStatement psCount = conn.prepareStatement(qCount);
				psCount.setString(1, msisdnValue.toUpperCase());
				ResultSet rs = psCount.executeQuery();
				int count = 0;
				if(rs.next()){
					count = rs.getInt("count");
				}
				rs.close();
				if(hiddenId.equals("") || hiddenId == null ){
					String query = "insert into READER_TERMINAL (MERCHANT_ID, MSISDN, DESCRIPTION, KEYTERMINAL, ADDRESS, "+
							" TERMINAL_TYPE, URL, CHARGE_INFO, L_UPDATE, IS_LOCKED, ALIAS) values(?, ?, ?, ?, ?, ?, ?, ?, SYSDATE, ?, ?)";
					PreparedStatement ps = conn.prepareStatement(query);
					ps.setString(1, merchantId);
					ps.setString(2, msisdnValue);
					ps.setString(3, description);
					ps.setString(4, keyTerminal);
					ps.setString(5, address);
					ps.setString(6, terminalType);
					ps.setString(7, url);
					ps.setString(8, chargeInfo);
					ps.setString(9, isLocked);
					ps.setString(10, alias);
					ps.executeUpdate();
					ps.close();					
					
					if(count == 0 && !encKey.equals("")){
						String queryMRollingKey = "insert into merchant_rolling_key(merchant_id, enc_key, dec_key) values (?,?,?) ";
						PreparedStatement pst = conn.prepareStatement(queryMRollingKey);
						pst.setString(1, msisdnValue.toUpperCase());
						pst.setString(2, encKey);
						pst.setString(3, encKey);
						pst.executeUpdate();
						pst.close();
					}
					if(count == 0){
						msg="Reader+Terminal+Succesfully+Created";
						UserLogWriter.writeLog(user.getUsername(), "Reader Terminal Succesfully Created for IP = "+ipaddr);
					}else{
						msg="Reader+Terminal+Succesfully+Created+and+encryption+already+exist";
						UserLogWriter.writeLog(user.getUsername(), "Reader Terminal Succesfully Created and encryption already exist for IP = "+ipaddr);
					}
					
					
				}else {
					String queryUpdate = "update READER_TERMINAL set MERCHANT_ID = ?, MSISDN = ?, DESCRIPTION = ?, KEYTERMINAL = ? "
							+", ADDRESS = ?, TERMINAL_TYPE = ?, URL = ?, CHARGE_INFO = ?, L_UPDATE = SYSDATE, IS_LOCKED = ?, ALIAS = ? where TERMINAL_ID = ?";
					PreparedStatement ps = conn.prepareStatement(queryUpdate);
					ps.setString(1, merchantId);
					ps.setString(2, msisdnValue);
					ps.setString(3, description);
					ps.setString(4, keyTerminal);
					ps.setString(5, address);
					ps.setString(6, terminalType);
					ps.setString(7, url);
					ps.setString(8, chargeInfo);
					ps.setString(9, isLocked);
					ps.setString(10, alias);
					ps.setString(11, hiddenId);
					ps.executeUpdate();
					ps.close();
					
					if(count == 0 && !encKey.equals("")){
						String queryMRollingKey = "insert into merchant_rolling_key(merchant_id, enc_key, dec_key) values (?,?,?) ";
						PreparedStatement pst = conn.prepareStatement(queryMRollingKey);
						pst.setString(1, msisdnValue.toUpperCase());
						pst.setString(2, encKey);
						pst.setString(3, encKey);
						pst.executeUpdate();
						pst.close();
					}else if(count == 1 && encKey.equals("")){
						String sql = "delete from merchant_rolling_key where merchant_id = ?";
						PreparedStatement pst = conn.prepareStatement(sql);
						pst.setString(1, msisdnValue.toUpperCase());
						pst.executeUpdate();
						pst.close();
					}else{
							String queryUpdateMRollingKey = "update merchant_rolling_key set enc_key = ?, dec_key= ? where merchant_id = ? ";
							PreparedStatement pst = conn.prepareStatement(queryUpdateMRollingKey);
							pst.setString(1, encKey);
							pst.setString(2, encKey);
							pst.setString(3, msisdnValue.toUpperCase());
							pst.executeUpdate();
							pst.close();
							msg="Reader+Terminal+Succesfully+Edited";
							UserLogWriter.writeLog(user.getUsername(), "Reader Terminal Succesfully Edited for IP = "+ipaddr);
						
						}
					
					
				}			
				response.sendRedirect("readerTerminalList.jsp?msg="+msg);
		} catch (Exception e) {
			msg="Reader+Terminal+Unsuccessfully+create,+data+or+terminal+keyword+already+exist+or+error+database";
			UserLogWriter.writeLog(user.getUsername(), "Reader Terminal failed created for IP = "+ipaddr);
			response.sendRedirect("readerTerminalList.jsp?msg="+msg);
			//e.printStackTrace();
		} finally {
			try {
				if(conn!=null){
					conn.close();
				}
			} catch (Exception ee) {
			}
		}

	} else {
		response.sendRedirect("../web-starter/Login.jsp");
	}
%>
