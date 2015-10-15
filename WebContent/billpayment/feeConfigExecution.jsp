<%@page import="com.telkomsel.itvas.webstarter.UserLogWriter"%>
<%@page import="com.telkomsel.itvas.webstarter.User"%>
<%@page import="org.apache.commons.lang.StringEscapeUtils"%>
<%@ page
	import="tsel_tunai.*,java.sql.*,java.lang.String.*,java.util.*,java.text.*,java.util.regex.*;"%>

<jsp:useBean id="DbCon" scope="page" class="tsel_tunai.DbCon"></jsp:useBean>

<%
	String ipaddr = request.getRemoteAddr();
	String hiddenId = StringEscapeUtils.escapeHtml(request.getParameter("hiddenId"));
	String hiddenSource = StringEscapeUtils.escapeHtml(request.getParameter("hiddenSource"));	
	String hiddenBearer = StringEscapeUtils.escapeHtml(request.getParameter("hiddenBearer"));
	String hiddenMerchant = StringEscapeUtils.escapeHtml(request.getParameter("hiddenMerchant"));
	
	String trxType = StringEscapeUtils.escapeHtml(request.getParameter("trxType"));
	String source = StringEscapeUtils.escapeHtml(request.getParameter("source"));
	String bearer = StringEscapeUtils.escapeHtml(request.getParameter("bearer"));
	String merchant = StringEscapeUtils.escapeHtml(request.getParameter("merchant"));
	String terminal = StringEscapeUtils.escapeHtml(request.getParameter("terminal"));
	String status = StringEscapeUtils.escapeHtml(request.getParameter("status"));
	String feeTiring = StringEscapeUtils.escapeHtml(request.getParameter("feeTiring"));
	String merchantFeeTiring = StringEscapeUtils.escapeHtml(request.getParameter("merchantFeeTiring"));
	String trxDescription =StringEscapeUtils.escapeHtml(request.getParameter("trxDescription"));
	
	String customerFee = "";
	String customerFeeValue = "";
	String merchantFee ="";
	String merchantFeeValue="";
	String merchantValue = "";
	if(terminal != null && !terminal.equals("")){
		merchantValue = merchant+ "|" +terminal;
	}else{
		merchantValue = merchant;
	}
	
	String textType[] = request.getParameterValues("textType");
	String textAm[] = request.getParameterValues("textAm");
	String textFloor[] = request.getParameterValues("textFloor");
	String textCeiling[] = request.getParameterValues("textCeiling");
	
	String textTypeWT = request.getParameter("textTypeWT");
	String textAmWT = request.getParameter("textAmWT");
	
	String textTypeMF[] = request.getParameterValues("textTypeMF");
	String textAmMF[] = request.getParameterValues("textAmMF");
	String textFloorMF[] = request.getParameterValues("textFloorMF");
	String textCeilingMF[] = request.getParameterValues("textCeilingMF");
	
	String textTypeMfWt = request.getParameter("textTypeMfWt");
	String textAmMfWt = request.getParameter("textAmMfWt");
	
	if(textAm != null){
		StringBuffer sb = new StringBuffer();
		for(int i = 0; i < textType.length; i++){
			Double amount = new Double(0);
			if(textType[i].equals("1")){
				amount = Double.parseDouble(textAm[i]) / 100;
				customerFee = textType[i] + "," + amount + "," + textFloor[i] + "-" + textCeiling[i];
			}else{
				customerFee = textType[i] + "," + textAm[i] + "," + textFloor[i] + "-" + textCeiling[i];
			}
			
			sb.append(customerFee);
			if(i < textType.length -1){
				sb.append(":");
			}
		}
		customerFeeValue = feeTiring+"|"+sb.toString();
	}
	
	if(feeTiring.equals("1")){
		if(textTypeWT.equals("1")){
			customerFeeValue = textTypeWT + "|" + (Double.parseDouble(textAmWT) /100);
		}else{
			customerFeeValue = textTypeWT + "|" + textAmWT;
		}
	}
	
	if(textAmMF != null){
		StringBuffer sb = new StringBuffer();
		for(int i = 0; i < textTypeMF.length; i++){
			if(textTypeMF[i].equals("1")){
				customerFee = textTypeMF[i] + "," + (Double.parseDouble(textAmMF[i])/100) + "," + textFloorMF[i] + "-" + textCeilingMF[i];
			}else{
				customerFee = textTypeMF[i] + "," + textAmMF[i] + "," + textFloorMF[i] + "-" + textCeilingMF[i];
			}		
			sb.append(customerFee);
			if(i < textTypeMF.length -1){
				sb.append(":");
			}
		}
		merchantFeeValue = merchantFeeTiring+"|"+sb.toString();
	}
	
	if(merchantFeeTiring.equals("1")){
		if(textTypeMfWt.equals("1")){
			merchantFeeValue = textTypeMfWt + "|" + (Double.parseDouble(textAmMfWt)/100);
		}else{
			merchantFeeValue = textTypeMfWt + "|" + textAmMfWt;
		}
		
	}

	

	Connection conn = null;
	conn = DbCon.getConnection();
	User user = (User) session.getValue("user");
	if ((user != null) && (request.getMethod().equals("POST"))) {
		session.putValue("user", user);
		String msg="";
		try {			
			if(hiddenId.equals("") || hiddenId == null ){
				String query = "insert into fee_config (trx_type, source, bearer, merchant_id, customer_fee, "+
						" merchant_fee, status, trx_description) values(?, ?, ?, ?, ?, ?, ?, ?)";
				PreparedStatement ps = conn.prepareStatement(query);
				ps.setString(1, trxType);
				ps.setString(2, source);
				ps.setString(3, bearer);
				ps.setString(4, merchantValue);
				ps.setString(5, customerFeeValue);
				ps.setString(6, merchantFeeValue);
				ps.setString(7, status);
				ps.setString(8, trxDescription);
				ps.executeUpdate();
				ps.close(); 
				//HttpGet.get("http://10.2.114.121:2021/tsel_tunai2/reload_fee_configAll.jsp", 10000);
				//HttpGet.get("http://10.2.123.170:8082/tsel_tunai2/reload_fee_configAll.jsp", 10000);
				HttpGet.get("http://10.2.123.171:8081/tsel_tunai2/reload_fee_configAll.jsp", 10000);
				HttpGet.get("http://10.2.123.171:8082/tsel_tunai2/reload_fee_configAll.jsp", 10000);
				msg="Fee+Config+Succesfully+Created";
				UserLogWriter.writeLog(user.getUsername(), "Fee Config Succesfully Created for IP = "+ipaddr);
			}
			 else {
				String queryUpdate = "update fee_config set trx_type = ?, source = ?, bearer = ?, merchant_id = ? "
						+", customer_fee = ?, merchant_fee = ?, status = ?, trx_description = ? where trx_type = ? "
						+"and source = ? and bearer =? and merchant_id=?";
				PreparedStatement ps = conn.prepareStatement(queryUpdate);
				ps.setString(1, trxType);
				ps.setString(2, source);
				ps.setString(3, bearer);
				ps.setString(4, merchantValue);
				ps.setString(5, customerFeeValue);
				ps.setString(6, merchantFeeValue);
				ps.setString(7, status);
				ps.setString(8, trxDescription);
				ps.setString(9, hiddenId);
				ps.setString(10, hiddenSource);
				ps.setString(11, hiddenBearer);
				ps.setString(12, hiddenMerchant);
				ps.executeUpdate();
				ps.close(); 
				
				//HttpGet.get("http://10.2.114.121:2021/tsel_tunai2/reload_fee_configAll.jsp", 10000);
				//HttpGet.get("http://10.2.123.170:8082/tsel_tunai2/reload_fee_configAll.jsp", 10000);
				HttpGet.get("http://10.2.123.171:8081/tsel_tunai2/reload_fee_configAll.jsp", 10000);
				HttpGet.get("http://10.2.123.171:8082/tsel_tunai2/reload_fee_configAll.jsp", 10000);
				msg="Fee+Config+Succesfully+Edited";
				UserLogWriter.writeLog(user.getUsername(), "Fee Config Succesfully Edited for IP = "+ipaddr);
			} 
			response.sendRedirect("feeConfigList.jsp?msg="+msg);			
		} catch (Exception e) {
			msg="Fee+Config+Unsuccessfully+create+or+update,+data+already+exist+or+error+database";
			UserLogWriter.writeLog(user.getUsername(), "Fee Config failled Edited for IP = "+ipaddr);
			response.sendRedirect("feeConfigInput.jsp?msg="+msg);
			e.printStackTrace();
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
