<%@ page import="java.util.regex.*, java.sql.*, tsel_tunai.*, java.text.*, java.util.*"%>
<jsp:useBean id="DbCon" scope="page" class="tsel_tunai.DbCon"></jsp:useBean><%
	String separator = ",";
	String dari = request.getParameter("dari");
	
	response.setContentType ("text/csv");
	response.setHeader ("Content-Disposition", "attachment;	filename=\""+dari+".csv\"");
	
	java.util.Date skr = new java.util.Date();
	SimpleDateFormat forma = new SimpleDateFormat("d-M-yyyy");
	String tdate = forma.format(skr);
	dari = (dari != null && !dari.equals("")) ? dari : tdate;
		
	if(dari != null)
	{
		String sql = "";
		Connection conn = null;
		try {
			conn = DbCon.getConnection();
			out.println(
				"Entity" + separator + 
				"Number" + separator + 
				"Cash Amount");
			
			//cetak ke layar			
			long total = 0;
			// count customer			

			if(dari.equals(tdate)) sql = "SELECT count(a.cust_id) as jumlah, sum(b.balance) as cash_amount from customer a, tsel_cust_account b where a.acc_no=b.acc_no";
			else sql="select numbers as jumlah, amount as cash_amount from floating_fund_history where hist_date=to_date('"+dari+"', 'DD-MM-YYYY') and entity='Customer Online'";  	
			PreparedStatement ps = conn.prepareStatement(sql);
			ResultSet rs = ps.executeQuery(sql);
			long cashAmount = 0, jumlah = 0, jmlTerminal = 0;
			if (rs.next()) {
				cashAmount = rs.getLong("cash_amount");
				jumlah = rs.getLong("jumlah");
				total += cashAmount;				
			}
			out.println(
				"Customer Online" + separator + 
				rs.getString("jumlah") + separator +
				rs.getString("cash_amount")
			);
			rs.close();
			ps.close();
			
			if(dari.equals(tdate)) sql = "SELECT count(a.cust_id) as jumlah, sum(b.balance) as cash_amount from customer a, rfid_account b where a.acc_no=b.acc_no";
			else sql="select numbers as jumlah, amount as cash_amount from floating_fund_history where hist_date=to_date('"+dari+"', 'DD-MM-YYYY') and entity='Customer Offline (Kartu TCash)'";
			ps = conn.prepareStatement(sql);
			rs = ps.executeQuery(sql);
			if (rs.next()) {
				cashAmount = rs.getLong("cash_amount");
				jumlah = rs.getLong("jumlah");
				total += cashAmount;			
			}
			out.println(
				"Customer Offline (Kartu TCash)" + separator + 
				rs.getString("jumlah") + separator +
				rs.getString("cash_amount")
			);
			rs.close();
			ps.close();
			
			if(dari.equals(tdate)) sql = "SELECT count(*) as jumlah, sum(a.AMOUNT) as cash_amount from SUSPEND_ACCOUNT a";
			else sql="select numbers as jumlah, amount as cash_amount from floating_fund_history where hist_date=to_date('"+dari+"', 'DD-MM-YYYY') and entity='Suspend Account'";
			ps = conn.prepareStatement(sql);
			rs = ps.executeQuery(sql);
			if (rs.next()) {
				cashAmount = rs.getLong("cash_amount");
				jumlah = rs.getLong("jumlah");
				total += cashAmount;				
			}
			out.println(
				"Suspend Account" + separator + 
				rs.getString("jumlah") + separator +
				rs.getString("cash_amount")
			);
			rs.close();
			ps.close();
			
			if(dari.equals(tdate)) sql = "SELECT count(*) as jumlah, sum(a.BALANCE) as cash_amount from REMIT_ACCOUNT a";
			else sql="select numbers as jumlah, amount as cash_amount from floating_fund_history where hist_date=to_date('"+dari+"', 'DD-MM-YYYY') and entity='Remittance Account'";
			ps = conn.prepareStatement(sql);
			rs = ps.executeQuery(sql);
			if (rs.next()) {
				cashAmount = rs.getLong("cash_amount");
				jumlah = rs.getLong("jumlah");
				total += cashAmount;				
			}
			out.println(
				"Remittance Account" + separator + 
				rs.getString("jumlah") + separator +
				rs.getString("cash_amount")
			);
			rs.close();
			ps.close();
			
			if(dari.equals(tdate)) sql = "SELECT c.name, a.merchant_id, b.balance as cash_amount from merchant a, tsel_merchant_account b, merchant_info c where a.acc_no=b.acc_no and a.merchant_info_id=c.merchant_info_id";
			else sql = "select entity as name, numbers as jumlah, amount as cash_amount from floating_fund_history where hist_date=to_date('"+dari+"', 'DD-MM-YYYY') and not entity='Customer Online' and not entity='Customer Offline (Kartu TCash)' and not entity='Suspend Account' and not entity='Remittance Account' and not entity='TOTAL'";
			ps = conn.prepareStatement(sql);
			rs = ps.executeQuery(sql);
			String merchantName = "";
			cashAmount = 0; jumlah = 0; jmlTerminal=0;
			while (rs.next()) {
				merchantName = rs.getString("name");
				cashAmount = rs.getLong("cash_amount");
				if(dari.equals(tdate)){ 
					String merchantID = rs.getString("merchant_id");
					sql = "select count(*) as jumlah from reader_terminal where merchant_id=?";
					PreparedStatement ps2 = conn.prepareStatement(sql);
					ps2.setString(1, merchantID);
					ResultSet rs2 = ps2.executeQuery();
					if (rs2.next()) {
						jumlah = rs2.getLong("jumlah");
					}
					rs2.close();
					ps2.close();
				}else jumlah = rs.getLong("jumlah");
				jmlTerminal += jumlah;
				total += cashAmount;
				out.println(
					merchantName + separator + 
					jumlah + separator +
					cashAmount
				);				
			} 
			rs.close();
			ps.close();
			
			if(!dari.equals(tdate)){
				//sql = "SELECT count(*) as jumlah, sum(a.BALANCE) as cash_amount from REMIT_ACCOUNT a";
				sql="select numbers as jmlTerminal, amount as cash_amount from floating_fund_history where hist_date=to_date('"+dari+"', 'DD-MM-YYYY') and entity='TOTAL'";
				ps = conn.prepareStatement(sql);
				rs = ps.executeQuery(sql);
				if (rs.next()) {
					cashAmount = rs.getLong("cash_amount");
					total = cashAmount;
					jmlTerminal = jmlTerminal;
				}
				rs.close();
				ps.close();	
			}
			out.println(
				"TOTAL" + separator + 
				jmlTerminal + separator +
				total
			);
			
			
			
			
			
			
			
			
			
			
			
			
			
			/*if(dari.equals(tdate)) sql = "SELECT count(a.cust_id) as jumlah, sum(b.balance) as cash_amount from customer a, tsel_cust_account b where a.acc_no=b.acc_no";
			else sql = "select numbers as jumlah, amount as cash_amount from floating_fund_history where hist_date=to_date('"+dari+"', 'DD-MM-YYYY') and entity='Customer Online'"; 
			PreparedStatement pstmt = conn.prepareStatement(sql);
			ResultSet rs = pstmt.executeQuery();
				
			while (rs.next()) {					
				out.println(
					"Customer Online" + separator + 
					rs.getString("jumlah") + separator +
					rs.getString("cash_amount"));
			}
			pstmt.close();rs.close();
			
			if(dari.equals(tdate)) sql = "SELECT count(a.cust_id) as jumlah, sum(b.balance) as cash_amount from customer a, rfid_account b where a.acc_no=b.acc_no";
			else sql = "select numbers as jumlah, amount as cash_amount from floating_fund_history where hist_date=to_date('"+dari+"', 'DD-MM-YYYY') and entity='Customer Offline (Kartu TCash)'"; 
			pstmt = conn.prepareStatement(sql);
			rs = pstmt.executeQuery();
				
			while (rs.next()) {					
				out.println(
					"Customer Offline (Kartu TCash)" + separator + 
					rs.getString("jumlah") + separator +
					rs.getString("cash_amount"));
			}
			pstmt.close();rs.close();
			
			if(dari.equals(tdate)) sql = "SELECT count(*) as jumlah, sum(a.AMOUNT) as cash_amount from SUSPEND_ACCOUNT a";
			else sql = "select numbers as jumlah, amount as cash_amount from floating_fund_history where hist_date=to_date('"+dari+"', 'DD-MM-YYYY') and entity='Suspend Account'"; 
			pstmt = conn.prepareStatement(sql);
			rs = pstmt.executeQuery();
				
			while (rs.next()) {					
				out.println(
					"Suspend Account" + separator + 
					rs.getString("jumlah") + separator +
					rs.getString("cash_amount"));
			}
			pstmt.close();rs.close();
			
			if(dari.equals(tdate)) sql = "SELECT count(*) as jumlah, sum(a.BALANCE) as cash_amount from REMIT_ACCOUNT a";
			else sql = "select numbers as jumlah, amount as cash_amount from floating_fund_history where hist_date=to_date('"+dari+"', 'DD-MM-YYYY') and entity='Remittance Account'"; 
			pstmt = conn.prepareStatement(sql);
			rs = pstmt.executeQuery();
				
			while (rs.next()) {					
				out.println(
					"Remittance Account" + separator + 
					rs.getString("jumlah") + separator +
					rs.getString("cash_amount"));
			}
			pstmt.close();rs.close();
			
			if(dari.equals(tdate)) sql = "SELECT c.name, a.merchant_id, b.balance as cash_amount from merchant a, tsel_merchant_account b, merchant_info c where a.acc_no=b.acc_no and a.merchant_info_id=c.merchant_info_id";
			else sql = "select entity as name, numbers as jumlah, amount as cash_amount from floating_fund_history where hist_date=to_date('"+dari+"', 'DD-MM-YYYY') and not entity='Customer Online' and not entity='Customer Offline (Kartu TCash)' and not entity='Suspend Account' and not entity='Remittance Account' and not entity='TOTAL'"; 
			pstmt = conn.prepareStatement(sql);
			rs = pstmt.executeQuery();
				
			while (rs.next()) {					
				out.println(
					rs.getString("name") + separator + 
					rs.getString("jumlah") + separator +
					rs.getString("cash_amount"));
			}
			pstmt.close();rs.close();
			
			sql = "select numbers as jmlTerminal, amount as cash_amount from floating_fund_history where hist_date=to_date('"+dari+"', 'DD-MM-YYYY') and entity='TOTAL'"; 
			pstmt = conn.prepareStatement(sql);
			rs = pstmt.executeQuery();
				
			while (rs.next()) {					
				out.println(
					"TOTAL" + separator + 
					rs.getString("jmlTerminal") + separator +
					rs.getString("cash_amount"));
			}
			pstmt.close();rs.close();
			*/
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			if(conn!=null)conn.close();
		}
	} 
	else{
		response.sendRedirect("welcome.jsp");
	}
%>