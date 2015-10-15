<%@page import="java.sql.*"%>
<jsp:useBean id="DbCon" scope="page" class="tsel_tunai.DbCon"></jsp:useBean>
<select name="terminal" >
<option value="">Select</option>
<%
	String merchantId = request.getParameter("count");
	String terminalIds = "";
	String merchantValue = "";
	if(merchantId.contains("|")){
		String array[] = merchantId.split("\\|");
		merchantValue = array[0];
		terminalIds = array[1];
	}else{
		merchantValue = merchantId;
	}
	Connection conRt = null;
	try {
		conRt = DbCon.getConnection();
		String q = "select terminal_id, msisdn, merchant_id from reader_terminal where merchant_id = ?";
		PreparedStatement st = conRt.prepareStatement(q);
		st.setString(1, merchantValue);
		ResultSet rs = st.executeQuery();
		while (rs.next()) {
			%>
			<option value="<%=rs.getString("terminal_id")%>" <%=(merchantValue.equals(rs.getString("merchant_id")) && terminalIds.equals(rs.getString("terminal_id"))) ? "selected" : ""%>><%=rs.getString("msisdn")%></option>
			<%
		}
		rs.close();
	} catch (Exception e) {
		//System.out.println(e);
	} finally {
		if (conRt != null) {
			conRt.close();
		}
	}
%>
</select>

