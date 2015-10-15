<%@ page import="java.util.regex.*, java.sql.*, tsel_tunai.*, java.text.*, java.util.*"%><jsp:useBean id="DbCon" scope="page" class="tsel_tunai.DbCon"></jsp:useBean><%
	String separator = ",";
	String dari = request.getParameter("dari");
	String test = request.getParameter("test");
	String terminal_msisdn = request.getParameter("terminal_msisdn");
	String merchant = request.getParameter("merchant");
	//out.print(dari);
	String ampe = request.getParameter("ampe");
	
	response.setContentType ("text/csv");
	response.setHeader ("Content-Disposition", "attachment;	filename=\""+merchant+"_"+dari+"_"+ampe+".csv\"");

	if(merchant != null)
	{
			Connection conn = null;
			try {
				conn = DbCon.getConnection();
			 	String sql = "select tx_id,t.acc_no,card_id,tx_tipe,debet,credit,balance,tx_date,loading_terminal_id,payment_terminal_id,t.description as description, ref_num, r.msisdn as mmsisdn from merchant m,tsel_merchant_account_history t, reader_terminal r where m.acc_no = t.acc_no and m.merchant_id = ? and to_char(r.terminal_id(+)) = t.payment_terminal_id and ( tx_date between to_date('"+dari+" 00:00:00', 'DD-MM-YYYY HH24:MI:SS') and to_date('"+ampe+" 23:59:59', 'DD-MM-YYYY HH24:MI:SS')) and r.msisdn like '%"+terminal_msisdn+"%'order by t.tx_date, t.ref_num, t.tx_id"; 
				PreparedStatement pstmt = conn.prepareStatement(sql);
				pstmt.setString(1,merchant);
				ResultSet rs = pstmt.executeQuery();
				out.println(
					"tx_date" + separator + 
					"customer" + separator + 
					"tx_tipe" + separator + 
					"debet" + separator + 
					"credit" + separator + 
					"balance" + separator + 
					"ref_num" + separator + 
					"terminal_id" + separator + 
					"description");
				while (rs.next()) {
					int nTxTipe = -1;
					try {
						nTxTipe = Integer.parseInt(rs.getString("tx_tipe"));
					} catch (Exception e) {
					
					}	
					out.println(
					rs.getString("tx_date") + separator + 
					rs.getString("card_id") + separator + 
					UssdTx.getTxtipe(nTxTipe) + separator + 
					rs.getString("debet") + separator + 
					rs.getString("credit") + separator + 
					rs.getString("balance") + separator + 
					rs.getString("ref_num") + separator + 
					rs.getString("mmsisdn") + separator + 
					rs.getString("description"));
				}
				pstmt.close();
				rs.close();
	} catch (Exception e) {
		e.printStackTrace();
	} finally {
		conn.close();
	}
} else {
	response.sendRedirect("welcome.jsp");
}%>