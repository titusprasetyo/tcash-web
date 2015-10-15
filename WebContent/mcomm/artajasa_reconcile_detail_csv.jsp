<%@ page import="java.util.regex.*, java.sql.*, tsel_tunai.*, java.text.*, java.util.*"%>
<jsp:useBean id="DbCon" scope="page" class="tsel_tunai.DbCon"></jsp:useBean>
<%@page import="com.telkomsel.itvas.webstarter.User"%>

<%
	
	
	User user = (User)session.getValue("user");
	if(user == null) {
		response.sendRedirect("index.jsp");
	}
	
	String separator = ",";
	
	String start = request.getParameter("dari");
	String end = request.getParameter("ampe");
	String type = request.getParameter("type");
	String command = request.getParameter("command");

	String status = request.getParameter("status");
	String status_detail = request.getParameter("status_detail");
	String recon_id = request.getParameter("recon_id");
	String recon_detail_id = request.getParameter("recon_detail_id");
	
	if(type == null)
		type = "";
		
	if(status_detail == null)
		status_detail = "";

	if(command == null)
		command = "";	
		
	if(status == null){
		status = "";
	}else if(status.equals("detail")){
		status_detail = "detail";
	}
		
	if(recon_id == null)
		recon_id = "";

	if(recon_detail_id == null)
		recon_detail_id = "";	
		
	String check_c = type.equals("created") ? "checked" : "";
	String check_p = type.equals("pending") ? "checked" : "";
	String check_s = type.equals("solved") ? "checked" : "";
	
	response.setContentType ("text/csv");
	response.setHeader ("Content-Disposition", "attachment;	filename=\"artajasa_recon_detail_"+start+"_"+end+".csv\"");

	Connection conn = null;
	String query = null;
	PreparedStatement pstmt = null;
	ResultSet rs = null;
	String AJ_merchantid = "";
	
	try {
		conn = DbCon.getConnection();
		
		// checking for AJ_merchantid
		query = "select value from configuration where config like 'ajasa.merchantid'";
		pstmt = conn.prepareStatement(query);
		rs = pstmt.executeQuery();
		if(rs.next()){
			AJ_merchantid = rs.getString("value");
		}else{
			AJ_merchantid = "1111232020565352";
		}
		rs.close();pstmt.close();
		
		if(type.equals(""))
			query = "select r.recon_id, r.recon_date, r.recon_type, rd.recon_detail_id, rd.tran_time, rd.acct_number, rd.tran_amount, rd.iso_date, rd.pan_code, rd.bank_code, rd.trace_number, rd.ref_number, rd.is_executed, rd.created_date, rd.pending_date, rd.solved_date  from recon r, recon_detail rd where r.recon_id = rd.recon_id and r.merchant_id='"+AJ_merchantid+"' and rd.is_executed like '%' and (r.recon_date between to_date('"+start+" 00:00:00','DD-MM-YYYY HH24:MI:SS') and to_date('"+end+" 23:59:59','DD-MM-YYYY HH24:MI:SS')) order by r.RECON_DATE desc";
		else{
			if(!check_c.equals("")){
				query = "select r.recon_id, r.recon_date, r.recon_type, rd.recon_detail_id, rd.tran_time, rd.acct_number, rd.tran_amount, rd.iso_date, rd.pan_code, rd.bank_code, rd.trace_number, rd.ref_number, rd.is_executed, rd.created_date, rd.pending_date, rd.solved_date  from recon r, recon_detail rd where r.recon_id = rd.recon_id and r.merchant_id='"+AJ_merchantid+"' and rd.is_executed like '0%' and (r.recon_date between to_date('"+start+" 00:00:00','DD-MM-YYYY HH24:MI:SS') and to_date('"+end+" 23:59:59','DD-MM-YYYY HH24:MI:SS')) order by r.RECON_DATE desc";
			}else if(!check_p.equals("")){
				query = "select r.recon_id, r.recon_date, r.recon_type, rd.recon_detail_id, rd.tran_time, rd.acct_number, rd.tran_amount, rd.iso_date, rd.pan_code, rd.bank_code, rd.trace_number, rd.ref_number, rd.is_executed, rd.created_date, rd.pending_date, rd.solved_date  from recon r, recon_detail rd where r.recon_id = rd.recon_id and r.merchant_id='"+AJ_merchantid+"' and rd.is_executed like '1%' and (r.recon_date between to_date('"+start+" 00:00:00','DD-MM-YYYY HH24:MI:SS') and to_date('"+end+" 23:59:59','DD-MM-YYYY HH24:MI:SS')) order by r.RECON_DATE desc";
			}else if(!check_s.equals("")){
				query = "select r.recon_id, r.recon_date, r.recon_type, rd.recon_detail_id, rd.tran_time, rd.acct_number, rd.tran_amount, rd.iso_date, rd.pan_code, rd.bank_code, rd.trace_number, rd.ref_number, rd.is_executed, rd.created_date, rd.pending_date, rd.solved_date  from recon r, recon_detail rd where r.recon_id = rd.recon_id and r.merchant_id='"+AJ_merchantid+"' and rd.is_executed like '2%' and (r.recon_date between to_date('"+start+" 00:00:00','DD-MM-YYYY HH24:MI:SS') and to_date('"+end+" 23:59:59','DD-MM-YYYY HH24:MI:SS')) order by r.RECON_DATE desc";
			}
		}
		if(status_detail.equals("detail") && !recon_id.equals(""))
			query = "select r.recon_id, r.recon_date, r.recon_type, rd.recon_detail_id, rd.tran_time, rd.acct_number, rd.tran_amount, rd.iso_date, rd.pan_code, rd.bank_code, rd.trace_number, rd.ref_number, rd.is_executed, rd.created_date, rd.pending_date, rd.solved_date  from recon r, recon_detail rd where r.recon_id='"+recon_id+"' and r.recon_id = rd.recon_id and r.merchant_id='"+AJ_merchantid+"' and rd.is_executed like '%' and (r.recon_date between to_date('"+start+" 00:00:00','DD-MM-YYYY HH24:MI:SS') and to_date('"+end+" 23:59:59','DD-MM-YYYY HH24:MI:SS')) order by r.RECON_DATE desc";
		
		//System.out.println(query);
		pstmt = conn.prepareStatement(query);
		rs = pstmt.executeQuery();
		
		out.println(
			"ID" + separator + 
			"Date" + separator + 
			"Type" + separator + 
			"Trace Number" + separator +
			"Ref Number" + separator +
			"Tran Amount" + separator + 
			"Iso Date" + separator + 
			"Created" + separator + 
			"Claimed" + separator + 
			"Solved");
		while (rs.next()) {
			String outputString = (rs.getString("RECON_detail_ID") + separator + 
			rs.getString("RECON_DATE") + separator);
			
			String recon_type = rs.getString("RECON_TYPE");
			if(recon_type.equals("cashin_suspect")){
				outputString += "Cashin - Klaim Suspect" + separator;
			}else if(recon_type.equals("cashin_rpt")){
				outputString += "Cashin - Investigasi RPT" + separator;
			}else if(recon_type.equals("cashout_rpt")){
				outputString += "Cashout - Investigasi RPT" + separator;
			}else if(recon_type.equals("cashout_suspect_gagal")){
				outputString += "Cashout - Suspect Gagal" + separator;			
			}else if(recon_type.equals("cashout_suspect_berhasil")){	
				outputString += "Cashout - Suspect Berhasil" + separator;
			}else if(recon_type.equals("cashout_suspect_suspect")){
				outputString += "Cashout - Suspect Suspect" + separator;
			}else if(recon_type.equals("cashin_db")){
				outputString += "Cashin - Investigasi DB" + separator;
			}else if(recon_type.equals("cashout_db")){
				outputString += "Cashout - Investigasi DB" + separator;
			}else if(recon_type.equals("cashin_claim_ada")){
				outputString += "Cashin - Klaim Berhasil (Reclaim)" + separator;
			}else if(recon_type.equals("cashin_claim_tidak")){
				outputString += "Cashin - Invertigasi Klaim Berhasil" + separator;
			}else{
				outputString += recon_type + separator;
			}
			
			outputString += ( 
			rs.getString("trace_number") + separator + 
			rs.getString("ref_number") + separator + 
			rs.getString("Tran_AMOUNT") + separator + 
			rs.getString("iso_date") + separator + 
			rs.getString("CREATED_DATE") + separator + 
			rs.getString("PENDING_DATE") + separator + 
			rs.getString("SOLVED_DATE")
			);
										
			out.println(outputString);
		}
		pstmt.close();
		rs.close();
	} catch (Exception e) {
		e.printStackTrace();
	} finally {
		try { if(conn!=null)conn.close(); if(pstmt!=null)pstmt.close(); if(rs!=null)rs.close();} catch(Exception ee){}
		
	}

%>
