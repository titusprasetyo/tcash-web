<%@ page import="java.util.regex.*, java.sql.*, tsel_tunai.*, java.text.*, java.util.*"%>
<jsp:useBean id="DbCon" scope="page" class="tsel_tunai.DbCon"></jsp:useBean>
<%@page import="com.telkomsel.itvas.webstarter.User"%>

<%	
	User user = (User)session.getValue("user");
	if(user == null) {
		response.sendRedirect("index.jsp");
	}
	
	NumberFormat nf =  NumberFormat.getInstance(Locale.ITALY);
	String separator = ",";
	
	String start = request.getParameter("dari");
	String end = request.getParameter("ampe");
	String type = request.getParameter("type");
	
	String check_c = type.equals("created") ? "checked" : "";
	String check_p = type.equals("pending") ? "checked" : "";
	String check_s = type.equals("solved") ? "checked" : "";
			
	response.setContentType ("text/csv");
	response.setHeader ("Content-Disposition", "attachment;	filename=\"artajasa_recon_"+start+"_"+end+".csv\"");

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
			query = "select r.RECON_ID, r.RECON_DATE, r.RECON_TYPE, r.TOTAL_DETAILS, r.DETAILS_SOLVED, r.TOTAL_AMOUNT, r.TOTAL_AMOUNT_SOLVED, r.IS_EXECUTED, r.CREATED_DATE, r.PENDING_DATE, r.SOLVED_DATE from recon r where r.merchant_id='"+AJ_merchantid+"' and r.is_executed like '%' and (recon_date between to_date('"+start+" 00:00:00','DD-MM-YYYY HH24:MI:SS') and to_date('"+end+" 23:59:59','DD-MM-YYYY HH24:MI:SS')) order by r.RECON_DATE desc";
		else{
			if(!check_c.equals("")){
				query = "select r.RECON_ID, r.RECON_DATE, r.RECON_TYPE, r.TOTAL_DETAILS, r.DETAILS_SOLVED, r.TOTAL_AMOUNT, r.TOTAL_AMOUNT_SOLVED, r.IS_EXECUTED, r.CREATED_DATE, r.PENDING_DATE, r.SOLVED_DATE from recon r where r.merchant_id='"+AJ_merchantid+"' and r.is_executed like '0%' and (recon_date between to_date('"+start+" 00:00:00','DD-MM-YYYY HH24:MI:SS') and to_date('"+end+" 23:59:59','DD-MM-YYYY HH24:MI:SS')) order by r.RECON_DATE desc";
			}else if(!check_p.equals("")){
				query = "select r.RECON_ID, r.RECON_DATE, r.RECON_TYPE, r.TOTAL_DETAILS, r.DETAILS_SOLVED, r.TOTAL_AMOUNT, r.TOTAL_AMOUNT_SOLVED, r.IS_EXECUTED, r.CREATED_DATE, r.PENDING_DATE, r.SOLVED_DATE from recon r where r.merchant_id='"+AJ_merchantid+"' and r.is_executed like '1%' and (recon_date between to_date('"+start+" 00:00:00','DD-MM-YYYY HH24:MI:SS') and to_date('"+end+" 23:59:59','DD-MM-YYYY HH24:MI:SS')) order by r.RECON_DATE desc";
			}else if(!check_s.equals("")){
				query = "select r.RECON_ID, r.RECON_DATE, r.RECON_TYPE, r.TOTAL_DETAILS, r.DETAILS_SOLVED, r.TOTAL_AMOUNT, r.TOTAL_AMOUNT_SOLVED, r.IS_EXECUTED, r.CREATED_DATE, r.PENDING_DATE, r.SOLVED_DATE from recon r where r.merchant_id='"+AJ_merchantid+"' and r.is_executed like '2%' and (recon_date between to_date('"+start+" 00:00:00','DD-MM-YYYY HH24:MI:SS') and to_date('"+end+" 23:59:59','DD-MM-YYYY HH24:MI:SS')) order by r.RECON_DATE desc";
			}
		}
		pstmt = conn.prepareStatement(query);
		rs = pstmt.executeQuery();
		
		out.println(
			"ID" + separator + 
			"Date" + separator + 
			"Type" + separator + 
			"Total Trx" + separator +
			"Trx Solved" + separator +
			"Total Amount" + separator + 
			"Amount Solved" + separator + 
			"Created" + separator + 
			"Claimed" + separator + 
			"Solved");
		while (rs.next()) {
			String outputString = (rs.getString("RECON_ID") + separator + 
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
			rs.getString("TOTAL_DETAILS") + separator + 
			rs.getString("DETAILS_SOLVED") + separator + 
			rs.getString("TOTAL_AMOUNT") + separator + 
			rs.getString("TOTAL_AMOUNT_SOLVED") + separator + 
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
