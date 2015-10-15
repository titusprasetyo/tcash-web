<%@ page import="java.util.regex.*, java.util.Date, java.sql.*, tsel_tunai.*, java.text.*, java.util.*"%>
<jsp:useBean id="DbCon" scope="page" class="tsel_tunai.DbCon"></jsp:useBean><%
	String separator = ",";
	String dari = request.getParameter("dari");
	String type = request.getParameter("type");
	String ampe = request.getParameter("ampe");
	String sql = "";
	Date d = null;
	SimpleDateFormat sdf = null;
	response.setContentType ("text/csv");
	response.setHeader ("Content-Disposition", "attachment;	filename=\""+dari+"_"+ampe+".csv\"");

	
	Connection conn = null;
	try {
		if(dari == null)
		{
			d = new Date();
			sdf = new SimpleDateFormat("d-M-yyyy");
			dari = sdf.format(d);
		}
		
		if(ampe == null)
		{
			d = new Date();
			sdf = new SimpleDateFormat("d-M-yyyy");
			ampe = sdf.format(d);
		}
		conn = DbCon.getConnection();
		if(type.equals("other"))
			sql = "SELECT b.*, c.name, c.bank_acc_no FROM settlement_history b, merchant_info c, merchant d WHERE b.status = '0' AND b.merchant_id = d.merchant_id AND c.merchant_info_id = d.merchant_info_id AND b.settle_date BETWEEN TO_DATE('"+dari+" 00:00:00', 'DD-MM-YYYY HH24:MI:SS') AND TO_DATE('"+ampe+" 23:59:59', 'DD-MM-YYYY HH24:MI:SS') ORDER BY b.settle_date DESC";
		else
			sql = "SELECT b.*, c.name, c.bank_acc_no FROM merchant_" + type + " b, merchant_info c, merchant d WHERE b.merchant_id = d.merchant_id AND c.merchant_info_id = d.merchant_info_id AND b.deposit_time BETWEEN TO_DATE('"+dari+" 00:00:00', 'DD-MM-YYYY HH24:MI:SS') AND TO_DATE('"+ampe+" 23:59:59', 'DD-MM-YYYY HH24:MI:SS') ORDER BY b.deposit_time DESC";
	
		//System.out.println(sql);
		PreparedStatement pstmt = conn.prepareStatement(sql);
		ResultSet rs = pstmt.executeQuery();
		out.println(
			"ID" + separator + 
			"Settle Time" + separator + 
			"Merchant" + separator + 
			"Amount" + separator + 
			"Type" + separator + 
			"Merchant Bank" + separator + 
			"Note" + separator + 
			"Status" + separator + 
			"Print Date" + separator +
			"Completion Date"+ separator +
			"Executor");
		while (rs.next()) {
			String xid = type.equals("other") ? rs.getString("settlement_id") : rs.getString(type + "_id");
			String stime = type.equals("other") ? rs.getString("settle_date") : rs.getString("deposit_time");
			String merchant = rs.getString("name");
			String amount = rs.getString("amount");
			String stype = type.equals("other") ? (amount.startsWith("-") ? "DEP" : "COU") : (rs.getString("entry_login").equals("Daily Settlement") ? "DS" : "OD");
			String mbank = rs.getString("bank_acc_no");
			String note = type.equals("other") ? "Daily Settlement" : rs.getString("note");
			String status = type.equals("other") ? rs.getString("status") : rs.getString("is_executed");
			String print = type.equals("other") ? null : rs.getString("print_date");
			String completion = type.equals("other") ? null : rs.getString("completion_date");
			String exec = type.equals("other") ? null : rs.getString("executor");
		
			out.println(
				xid + separator + 
				stime + separator + 
				merchant + separator + 
				amount + separator + 
				stype + separator + 
				mbank + separator + 
				note + separator + 
				status + separator + 
				print + separator +
				completion + separator +
				exec);
		}
		pstmt.close();
		rs.close();
	} catch (Exception e) {
		e.printStackTrace();
	} finally {
		conn.close();
	}
%>