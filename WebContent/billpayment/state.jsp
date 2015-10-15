<%@page import="java.sql.*"%>
<jsp:useBean id="DbCon" scope="page" class="tsel_tunai.DbCon"></jsp:useBean>
<select name="terminal" >
<option value="all">Select</option>
<%
	String merchantId = request.getParameter("count");
	Connection conRt = null;
	try {
		conRt = DbCon.getConnection();
		String q = "select terminal_id, msisdn from reader_terminal where merchant_id = ?";
		PreparedStatement st = conRt.prepareStatement(q);
		st.setString(1, merchantId);
		ResultSet rs = st.executeQuery();
		while (rs.next()) {
			%>
			<option value="<%=rs.getString("terminal_id")%>"><%=rs.getString("msisdn")%></option>
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

