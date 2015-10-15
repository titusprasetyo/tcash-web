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
	String bank_name = request.getParameter("bank_name");
	
	response.setContentType ("text/csv");
	response.setHeader ("Content-Disposition", "attachment;	filename=\"artajasa_history_"+start+"_"+end+".csv\"");

	Connection conn = null;
	String sql = "";
	PreparedStatement pstmt = null;
	ResultSet rs = null;
	
	try {
		conn = DbCon.getConnection();
		sql = "select rs.SETTLE_DATE, rs.bank_code, rs.bank_name, rs.hak as hak, rs.hak_dibayarkan as hak_dibayarkan, rs.denda_hak as denda_hak, rs.denda_hak_rpt as denda_hak_report, rs.kewajiban as kewajiban, rs.kewajiban_dibayarkan as kewajiban_dibayarkan, rs.denda_kewajiban as denda_kewajiban, rs.denda_kewajiban_rpt as denda_kewajiban_report, rs.solve_date, rs.status, rs.merchant_id, rs.keterangan from recon_selisih rs where lower(rs.bank_name) like '%"+bank_name.toLowerCase()+"%' and to_date(rs.settle_date,'DD/MM/YYYY') between to_date('"+start+" 00:00:00','DD-MM-YYYY HH24:MI:SS') and to_date('"+end+" 23:59:59','DD-MM-YYYY HH24:MI:SS') order by rs.settle_date desc, rs.bank_name asc"; 
		pstmt = conn.prepareStatement(sql);
		rs = pstmt.executeQuery();
		out.println(
			"Settle Date" + separator + 
			"Bank Code" + separator + 
			"Bank Name" + separator + 
			"Hak" + separator +
			"Hak Dibayarkan" + separator +
			"Denda Hak" + separator + 
			"Denda Hak Report" + separator + 
			"Kewajiban" + separator + 
			"Kewajiban Dibayarkan" + separator + 
			"Denda Kewajiban" + separator + 
			"Denda Kewajiban Report" + separator + 
			"Solved Date" + separator + 
			"Status" + separator + 
			"Keterangan");
		while (rs.next()) {
			int nTxTipe = -1;
			try {
				nTxTipe = Integer.parseInt(rs.getString("tx_tipe"));
			} catch (Exception e) {
			
			}	
			String outputString = (rs.getString("SETTLE_DATE") + separator + 
			rs.getString("bank_code") + separator + 
			rs.getString("bank_name") + separator + 
			rs.getString("hak") + separator + 
			rs.getString("hak_dibayarkan") + separator + 
			rs.getString("denda_hak") + separator + 
			rs.getString("denda_hak_report") + separator + 
			rs.getString("kewajiban") + separator + 
			rs.getString("kewajiban_dibayarkan") + separator + 
			rs.getString("denda_kewajiban") + separator + 
			rs.getString("denda_kewajiban_report") + separator + 
			rs.getString("solve_date") + separator + 
			rs.getString("status") + separator );
			
			String [] keteranganarray = (rs.getString("keterangan")).split("\\|");
			
			if(keteranganarray[0].equals("new") && keteranganarray.length==1){			
				outputString+= "Belum Recon";			
			}
			else if(keteranganarray[0].equals("reconed") && keteranganarray[1].equals("X")){
				outputString+= "Settlement Pas. ";
			}
			else if(keteranganarray[0].equals("reconed") && keteranganarray[1].equals("XX")){
				outputString+= "Settlement Tidak Pas. ";
			}
			else{
				outputString+= "-";
			}					
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