<%-- 
    Document   : auto_deposit_approve_od
    Created on : Apr 5, 2010, 12:04:39 PM
    Author     : madeady
--%>

<%@page import="java.io.*, java.util.*, java.text.*, java.sql.*, java.util.Date"%>
<%@ include file="/web-starter/taglibs.jsp"%>
<%@page import="com.telkomsel.itvas.webstarter.User"%>
<jsp:useBean id="DbCon" scope="page" class="tsel_tunai.DbCon"></jsp:useBean>
<jsp:useBean id="UTx" scope="request" class="tsel_tunai.UssdTx"></jsp:useBean>
<jsp:useBean id="reg" scope="request" class="tsel_tunai.Register2Bean"></jsp:useBean>

<script language="JavaScript">
<!--
function checkExecute(xid){
	with(document)
		return confirm("Do you really want to execute this deposit (id: " + xid + ")?");
}

function checkExecute2(){
	with(document)
		return confirm("Do you really want to bulk execute these deposits?");
}

function calendar(output){
	newwin = window.open('cal_tct.jsp?output=' + output + '','','top=150,left=150,width=145,height=130,resizable=no');
	if(!newwin.opener)
		newwin.opener = self;
}

function solveThis(xid, print, tdate, cur_page){
	window.location = "auto_deposit_approve_od.jsp?xid=" + xid + "&print" + xid + "=" + print + "&tdate=" + tdate + "&cur_page=" + cur_page;
}
//-->
</script>


<%!
String returnFloat(String amount){
	NumberFormat nf =  NumberFormat.getInstance(Locale.ITALY);
	if(amount.contains("."))
            amount = amount.substring(0,(amount.indexOf(".")));
	String [] _amount = amount.split(",");
	if(_amount.length > 1)
			amount = nf.format(Long.parseLong(_amount[0])) + "," + _amount[1];
	else
			amount = nf.format(Long.parseLong(_amount[0]));
	return amount;
}
%>

<%
//=========================================
Calendar CAL = Calendar.getInstance();
SimpleDateFormat SDF = new SimpleDateFormat("dd-MM-yyyy HH:mm:ss");
String timeNOW=SDF.format(CAL.getTime());
String outPUT = "";
//=========================================


//keperluan melakukan update tsel_merchant_account, tsel_merchant_account_history, merchant_deposit
User user = (User)session.getValue("user");

String encLogin = user.getUsername();
String encPass = user.getPassword();

String merchant = request.getParameter("merchant");
String xid = request.getParameter("xid");
String exec = request.getParameter("exec");
String tdate = request.getParameter("tdate");

String urlRedirect = "";

NumberFormat nf =  NumberFormat.getInstance(Locale.ITALY);
SimpleDateFormat sdf = new SimpleDateFormat("d-M-yyyy");

String [] retval = {"", ""};

//keperluan untuk melakukan pencocokan
String []   depositID = request.getParameterValues("deposit_id"),
            suggestedMercId = request.getParameterValues("suggestedMercId"),
            fileID1 = request.getParameterValues("file_id1"),
            fileID2 = request.getParameterValues("file_id2"),
            fileID3 = request.getParameterValues("file_id3");

String	approved = request.getParameter("approved");

//keperluan untuk akses basisdatanya
Connection con = null;
Statement stmt = null;
PreparedStatement pstmt = null;
ResultSet rs = null;
Statement stmt2 = null;
PreparedStatement pstmt2 = null;
ResultSet rs2 = null;
String sql = "";
String query = "";
String key1 = "", key2 = "", key3 = "", dID = "";

if(merchant == null) merchant = "";

try{
    //Buka dulu si databasenya
    con = DbCon.getConnection();
	con.setAutoCommit(false);
	
	// ========================================================================== //
	// UPDATE DEPOSIT SINGLE
	// ========================================================================== //	
	if(xid != null && !xid.equals("")){
		if(exec != null && exec.equals("1")){			
			retval = UTx.doMerchantDeposit(xid);
			if(retval[0].equals("00")){
				query = "INSERT INTO activity_log (userlogin, access_time, activity, note, ip) VALUES (?, SYSDATE, ?, ?, ?)";
				pstmt = con.prepareStatement(query);
				pstmt.clearParameters();
				pstmt.setString(1, user.getUsername());
				pstmt.setString(2, "Approve On Demand Deposit");
				pstmt.setString(3, "Success: " + xid);
				pstmt.setString(4, request.getRemoteAddr());
				pstmt.executeUpdate();
				pstmt.close();
				
				out.println("<script language='javascript'>alert('Deposit no " + xid + " executed successfully')</script>");
				outPUT +="Deposit no " + xid + " executed successfully.";
				
				//langsung solve ticket
				query = "UPDATE merchant_deposit SET is_executed = '2', completion_date = SYSDATE, executor = ? WHERE deposit_id = ?";
				pstmt = con.prepareStatement(query);
				pstmt.clearParameters();
				//pstmt.setString(1, tdate);
				pstmt.setString(1, user.getUsername());
				pstmt.setString(2, xid);
				pstmt.executeUpdate();
				pstmt.close();
				
				// send SMS to Merchant ======================
				String amt = null, dnb = null, nte = null, accno = null, bala = null, nmr = null, mrid = null;
				query = "select merchant_id, doc_number, note, amount from merchant_deposit where deposit_id='"+xid+"'";
				pstmt = con.prepareStatement(query);
				rs = pstmt.executeQuery();
				if(rs.next()){
					amt = rs.getString("amount");
					dnb = rs.getString("doc_number");
					mrid = rs.getString("merchant_id");
					nte = rs.getString("note");
				}						
				pstmt.close();rs.close();	
				
				if(mrid!=null && !mrid.equals("")){
					query = "select acc_no, merchant_info_id,msisdn from merchant where merchant_id='"+mrid+"'";
					pstmt = con.prepareStatement(query);
					rs = pstmt.executeQuery();
					if(rs.next()){
						accno = rs.getString("acc_no");
						mrid = rs.getString("merchant_info_id");
						nmr = rs.getString("msisdn");
					}						
					pstmt.close();rs.close();
				}	

				if(accno!=null && !accno.equals("")){
					query = "select balance from tsel_merchant_account where acc_no='"+accno+"'";
					pstmt = con.prepareStatement(query);
					rs = pstmt.executeQuery();
					if(rs.next()){
						bala = rs.getString("balance");
					}						
					pstmt.close();rs.close();
				}	
				
				SimpleDateFormat sdf1 = new SimpleDateFormat("dd/MM/yy HH:mm");
				
				reg.sendSms(nmr, sdf1.format(Calendar.getInstance().getTime())+" Deposit sebesar Rp "+returnFloat(amt)+" "+nte+". Balance anda Rp "+returnFloat(bala)+".", "2828");
				outPUT+=(xid+" SMS sent|");
				// end of send sms to merchant ======================
				
				con.commit();
				out.println("<script language='javascript'>alert('Solve ticket no " + xid + " successful')</script>");
				outPUT+=("Solve ticket no " + xid + " successful|");
			}
			else{
				out.println("<script language='javascript'>alert('Execution failed, reason: " + retval[0] + " (" + retval[1] + ")')</script>");
				outPUT+="Execution failed, reason: " + retval[0] + " (" + retval[1] + ")";
			}
		}
	}
%>

<stripes:layout-render name="/web-starter/layout/standard.jsp" title="Approve Merchant Deposit">
	<stripes:layout-component name="contents">    
<%
    // ========================================================================== //
	// PROSES UPDATE FILE DAN RECORD YANG BERSESUAIAN
    // ========================================================================== //
	if(depositID!=null&&fileID1!=null&&fileID2!=null&&fileID3!=null&&approved.equals("approved")){
        //Validasi dulu apakah sudah pernah diupdate sebelumnya
		Boolean valUpdate = true;
		for(int i=0;i<depositID.length;i++){
			query = "select * from merchant_deposit where deposit_id='"+depositID[i]+"' and is_executed='2'";
			pstmt = con.prepareStatement(query);
			rs = pstmt.executeQuery();
			if(rs.next()){
				valUpdate &= false;
				break;
			}						
			pstmt.close();rs.close();
		}
		
		if(valUpdate){
			//UPDATING TABEL
			String [][] retvalDep = new String[depositID.length][2];
			String [][] retvalFile = new String[depositID.length][2];
			Boolean statusUpdate = true;
			
			for(int i=0;i<depositID.length;i++){
				dID = depositID[i];
				key1 = fileID1[i];
				key2 = fileID2[i];
				key3 = fileID3[i];
				
				//UPDATE DEPOSIT
				retvalDep[i]= UTx.doMerchantDeposit(depositID[i]);
				
				//UPDATE UPLOADED FILE
				// ========================================
				retvalFile[i][0] = "04";
				retvalFile[i][1] = "internal_problem";
				try {
					//Class.forName("oracle.jdbc.OracleDriver");
					//con = DbCon.getConnection();
					
					sql = "UPDATE ACC_STATEMENT SET REF='"+dID+"', STATUS='1' WHERE TX_DATE=TO_DATE('"+key1.substring(0,10)+"', 'YYYY-MM-DD') AND DESCRIPTION='"+key2+"' AND TIPE='C' AND AMOUNT="+key3;
					pstmt = con.prepareStatement(sql);
					pstmt.executeUpdate();
					pstmt.close();
					
					retvalFile[i][0] = "00"; retvalFile[i][1] = "success";
					} catch (Exception e){
					  retvalFile[i][0] = "04";
					  retvalFile[i][1] = "internal_problem";
					  e.printStackTrace(System.out);
					  try { con.rollback(); } catch(Exception e2){}
					} finally {
					  if (con != null){
						try {
						  } catch (Exception ee) {}
					  }
					}
				
				// ========================================
				if(!retvalDep[i][0].equalsIgnoreCase("00")) statusUpdate &=false;
				if(!retvalFile[i][0].equalsIgnoreCase("00")) statusUpdate &=false;
			}

			if(statusUpdate){
				// insert into activity log
				pstmt = con.prepareStatement("INSERT INTO activity_log (userlogin, access_time, activity, note, ip) VALUES (?, SYSDATE, ?, ?, ?)");
				pstmt.clearParameters();
				pstmt.setString(1, encLogin);
				pstmt.setString(2, "Approve On Demand Deposit");
				String idCollection = "Success Deposit|";
				for(int i=0;i<depositID.length;i++){
					pstmt.setString(3, idCollection = idCollection +" | "+ depositID[i]);
				}
				outPUT+=idCollection+"|";
				pstmt.setString(4, request.getRemoteAddr());
				pstmt.executeUpdate();
				pstmt.close();
				
				// update completion date
				String idCollection2 = "(";
				for(int i=0;i<depositID.length;i++){
					idCollection2 +=("'"+depositID[i]+"',");
				}
				idCollection2 = idCollection2.substring(0, idCollection2.length()-1);
				idCollection2 += ")";
				//System.out.println(idCollection2);
				outPUT+=idCollection2+" ";			            
				pstmt = con.prepareStatement("UPDATE merchant_deposit SET is_executed = '2', completion_date = SYSDATE, executor = '"+user.getUsername()+"' WHERE deposit_id in "+idCollection2);
				pstmt.executeUpdate();
				pstmt.close();
				outPUT+="Completion Date updated|";
				
				//redirect ke printreceipt
				String pmeter = "new_print_receipt.jsp?type=deposit&method=get";
				sql = "select * from merchant_deposit where is_executed=2 and print_date is null and receipt_id is null and deposit_id in "+idCollection2;
				pstmt2 = con.prepareStatement(sql);
				rs2 = pstmt2.executeQuery();
				while(rs2.next()){				
					//kirim sms ke merchant-merchant tersebut
					pmeter = pmeter + "&xID=" +rs2.getString("deposit_id") + "&merchant_id=" + rs2.getString("merchant_id");
					
					// send SMS to Merchant ======================
					String amt = null, dnb = null, accno = null, bala = null, nmr = null, mrid = null;
					query = "select merchant_id, doc_number, amount from merchant_deposit where deposit_id='"+rs2.getString("deposit_id")+"'";
					pstmt = con.prepareStatement(query);
					rs = pstmt.executeQuery();
					if(rs.next()){
						amt = rs.getString("amount");
						dnb = rs.getString("doc_number");
						mrid = rs.getString("merchant_id");
					}						
					pstmt.close();rs.close();	
					
					if(mrid!=null && !mrid.equals("")){
						query = "select acc_no, merchant_info_id,msisdn from merchant where merchant_id='"+mrid+"'";
						pstmt = con.prepareStatement(query);
						rs = pstmt.executeQuery();
						if(rs.next()){
							accno = rs.getString("acc_no");
							mrid = rs.getString("merchant_info_id");
							nmr = rs.getString("msisdn");
						}						
						pstmt.close();rs.close();
					}	

					if(accno!=null && !accno.equals("")){
						query = "select balance from tsel_merchant_account where acc_no='"+accno+"'";
						pstmt = con.prepareStatement(query);
						rs = pstmt.executeQuery();
						if(rs.next()){
							bala = rs.getString("balance");
						}						
						pstmt.close();rs.close();
					}	
					
					SimpleDateFormat sdf1 = new SimpleDateFormat("dd/MM/yy HH:mm");
					
					reg.sendSms(nmr, sdf1.format(Calendar.getInstance().getTime())+" Deposit sebesar Rp "+returnFloat(amt)+". No. Doc: "+dnb+". Balance anda Rp "+returnFloat(bala)+".", "2828");
					// end of send sms to merchant ======================
					outPUT+=(rs2.getString("deposit_id")+"SMS sent|");
					
				}
				pstmt2.close();rs2.close();
				
				con.commit();
				urlRedirect = pmeter;
				//send to NEW print receipt
				response.sendRedirect(urlRedirect);
			}
			else{
				out.println("<script language='javascript'>alert('Approve deposit unsuccessful, error.')</script>");
				outPUT+=("Approve deposit unsuccessful, error.");
			}
			approved = "unapproved";
		}
    }
	
	// ========================================================================== //
	// new deposit approve
	// ========================================================================== //
	
	//PENCOCOKAN ANTARA REQUEST DEPOSIT DAN ACCOUNT STATEMENT DIMULAI
    //untuk keperluan pencocokan
    
	String form2[][] = null;
	int jmlSugHasilInt = 0;



	// ====KELUARKAN HASIL SUGESTI DARI ADMIN JIKA ADA====
	pstmt = con.prepareStatement("SELECT COUNT(*) AS JML FROM MERCHANT_DEPOSIT A ,ACC_STATEMENT B WHERE A.DEPOSIT_ID = B.REF AND B.TIPE='C' AND B.REF IS NOT NULL AND B.STATUS='0'");
	rs = pstmt.executeQuery();
	while(rs.next()){
			jmlSugHasilInt = rs.getInt("JML");
	}
	pstmt.close();rs.close();
        
				%>
				<table width='90%' border='1' cellspacing='0' cellpadding='0' bordercolor='#FFF6EF'>
				<tr>
					<td colspan='9'><div align='right'><font color='#CC6633' size='2' face='Verdana, Arial, Helvetica, sans-serif'><strong>.:: Suggestion List by admin</strong></font></div></td>
				</tr>
				<tr>
					<td bgcolor='#CC6633'><div align='center'><font color='#FFFFFF' size='1' face='Verdana, Arial, Helvetica, sans-serif'><strong>Deposit ID</strong></font></div></td>
					<td bgcolor='#CC6633'><div align='center'><font color='#FFFFFF' size='1' face='Verdana, Arial, Helvetica, sans-serif'><strong>Deposit Date</strong></font></div></td>
					<td bgcolor='#CC6633'><div align='center'><font color='#FFFFFF' size='1' face='Verdana, Arial, Helvetica, sans-serif'><strong>Merchant ID</strong></font></div></td>
					<td bgcolor='#CC6633'><div align='center'><font color='#FFFFFF' size='1' face='Verdana, Arial, Helvetica, sans-serif'><strong>Deposit Amount</strong></font></div></td>
					<td bgcolor='#CC6633'><div align='center'><font color='#FFFFFF' size='1' face='Verdana, Arial, Helvetica, sans-serif'><strong>Transaction Date</strong></font></div></td>
					<td bgcolor='#CC6633'><div align='center'><font color='#FFFFFF' size='1' face='Verdana, Arial, Helvetica, sans-serif'><strong>Description</strong></font></div></td>
					<td bgcolor='#CC6633'><div align='center'><font color='#FFFFFF' size='1' face='Verdana, Arial, Helvetica, sans-serif'><strong>Amount</strong></font></div></td>
				</tr>
				<%
		if (jmlSugHasilInt!=0){
            //out.println("<hr /> Untuk sugesti pasangan deposit dan account statement dari admin adalah : ");
            ArrayList<String> sugHasil = new ArrayList<String>();
            pstmt = con.prepareStatement("SELECT B.TX_DATE, B.DESCRIPTION, B.AMOUNT, A.DEPOSIT_TIME, A.MERCHANT_ID, A.AMOUNT, A.DEPOSIT_ID FROM MERCHANT_DEPOSIT A ,ACC_STATEMENT B WHERE A.DEPOSIT_ID = B.REF AND B.TIPE='C' AND B.REF IS NOT NULL AND B.STATUS='0' AND A.IS_EXECUTED='1'");
            rs = pstmt.executeQuery();
            while(rs.next()){
                    sugHasil.add((rs.getTimestamp(1)).toString()+","+rs.getString(2)+","+rs.getString(3)+","+(rs.getTimestamp(4)).toString()+","+rs.getString(5)+","+rs.getString(6)+","+rs.getString(7));
            }
            pstmt.close();rs.close();
            String [][] matriksSugHasil = new String [jmlSugHasilInt][7];
            for(int i=0;i<jmlSugHasilInt;i++){
                matriksSugHasil [i] = sugHasil.get(i).split(",");
            }

            for(int i=0;i<jmlSugHasilInt;i++){
				%>
				<tr>
					<td><div align='center'><font size='1' face='Verdana, Arial, Helvetica, sans-serif'><u><%= matriksSugHasil[i][6] %></u></font></div></td>
					<td><div align='center'><font size='1' face='Verdana, Arial, Helvetica, sans-serif'><u><%= matriksSugHasil[i][3] %></u></font></div></td>
					<td><div align='center'><font size='1' face='Verdana, Arial, Helvetica, sans-serif'><u><%= matriksSugHasil[i][4] %></u></font></div></td>
					<td><div align='center'><font size='1' face='Verdana, Arial, Helvetica, sans-serif'><u><%= matriksSugHasil[i][5] %></u></font></div></td>
					<td><div align='center'><font size='1' face='Verdana, Arial, Helvetica, sans-serif'><u><%= matriksSugHasil[i][0] %></u></font></div></td>
					<td><div align='center'><font size='1' face='Verdana, Arial, Helvetica, sans-serif'><u><%= matriksSugHasil[i][1] %></u></font></div></td>
					<td><div align='center'><font size='1' face='Verdana, Arial, Helvetica, sans-serif'><u><%= matriksSugHasil[i][2] %></u></font></div></td>
				</tr>
				<%
            }
            form2 = new String[jmlSugHasilInt][4];            		
			for(int i=0;i<jmlSugHasilInt;i++){
				form2[i][0] = matriksSugHasil[i][6];
				form2[i][1] = matriksSugHasil[i][0];
				form2[i][2] = matriksSugHasil[i][1];
				form2[i][3] = matriksSugHasil[i][2];                
            }            			
     
			// tampilkan form untuk melakukan approval
			%>
			<tr><td colspan='7'><div align='center'><form action='auto_deposit_approve_od.jsp' method='get'>
			<%
			for(int i=0;i<jmlSugHasilInt;i++){	
				%>
				<input type='hidden' name='deposit_id' value='<%=form2[i][0]%>'>
				<input type='hidden' name='file_id1' value='<%=form2[i][1]%>'>
				<input type='hidden' name='file_id2' value='<%=form2[i][2]%>'>
				<input type='hidden' name='file_id3' value='<%=form2[i][3]%>'>
				<%
			}
			if(approved==null){
				approved = "approved";
			}
			%>
			<input type='hidden' name='approved' value='<%=approved%>'>
			<input type='submit' value='Approve' onclick='return checkExecute2();'>
			
			</form></div></td></tr>
		<%
		}
		%>
		</table>

		<hr />
		<form name="form" method="post" action="auto_deposit_approve_od.jsp">
		<table width="30%" border="0" cellspacing="1" cellpadding="1">
		<tr bgcolor="#CC6633">
			<td colspan="2"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>Search by Merchant</strong></font></div></td>
		</tr>
		<tr>
			<td><input type="submit" name="Submit" value="View"></td>
			<td>
				<select name="merchant">
					<option value=''></option>
<%
	query = "SELECT a.merchant_id, b.name FROM merchant a, merchant_info b WHERE a.merchant_info_id = b.merchant_info_id AND a.status = 'A' ORDER BY a.merchant_id";
	stmt = con.createStatement();
	rs = stmt.executeQuery(query);
	while(rs.next()){
		if(rs.getString("merchant_id").equals(merchant))
			out.println("<option value='" + rs.getString("merchant_id") + "' selected>" + rs.getString("name") + "</option>");
		else
			out.println("<option value='" + rs.getString("merchant_id") + "'>" + rs.getString("name") + "</option>");
	}
	stmt.close();rs.close();
%>
				</select>
			</td>
		</tr>
		</table>
		</form>
		<br>

<%
	int jumlah = 0;
	int cur_page = 1;
	int row_per_page = 100;
	
	query = "SELECT COUNT(*) AS jml FROM merchant_deposit WHERE is_executed <= 2 and print_date is  null and receipt_id is  null";
	if(!merchant.equals(""))
		query += " AND merchant_id = ?";
	
	pstmt = con.prepareStatement(query);
	pstmt.clearParameters();
	if(!merchant.equals(""))
		pstmt.setString(1, merchant);
	
	rs = pstmt.executeQuery();
	if(rs.next())
		jumlah = rs.getInt("jml");
	
	pstmt.close();
	rs.close();
	
	if(request.getParameter("cur_page") != null && !request.getParameter("cur_page").equals(""))
		cur_page = Integer.parseInt(request.getParameter("cur_page"));
	
	int start_row = (cur_page - 1) * row_per_page + 1;
	int end_row = start_row + row_per_page - 1;
	int total_page = (jumlah / row_per_page) + 1;
	if(jumlah % row_per_page == 0)
		total_page--;
	
	int minPaging = cur_page - 5;
	if(minPaging < 1)
		minPaging = 1;
	
	int maxPaging = cur_page + 5;
	if(maxPaging > total_page)
		maxPaging = total_page;
	
	out.println("Page : ");
	
	if(minPaging - 1 > 0)
		out.print("<a class='link' href='?cur_page=" + (minPaging - 1) + "&merchant=" + merchant + "'>&lt;</a>");
	
	for(int i = minPaging; i <= maxPaging; i++)
	{
		if(i == cur_page)
			out.print(i + " ");
		else
			out.print("<a class='link' href='?cur_page=" + i + "&merchant=" + merchant + "'>" + i + " </a>");
	}
	
	if(maxPaging + 1 <= total_page)
		out.print("<a class='link' href='?cur_page=" + (maxPaging + 1) + "&merchant=" + merchant + "'>&gt;</a>");
%>
		<table width="90%" border="1" cellspacing="0" cellpadding="0" bordercolor="#FFF6EF">
		<tr>
			<td colspan="11"><div align="right"><font color="#CC6633" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>.:: Deposit List</strong></font></div></td>
		</tr>
		<tr>
			<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Deposit ID</strong></font></div></td>
			<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Deposit Date</strong></font></div></td>
			<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Merchant</strong></font></div></td>
			<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Amount</strong></font></div></td>
			<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Doc Number</strong></font></div></td>
			<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Note</strong></font></div></td>
			<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>TSEL Bank Account</strong></font></div></td>
			<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Execute</strong></font></div></td>
			<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Receipt</strong></font></div></td>
		</tr>
<%
	if(!merchant.equals(""))
		query = "SELECT * FROM (SELECT a.*, ROWNUM rnum FROM (SELECT b.*, c.* FROM merchant_deposit b, merchant_info c, merchant d WHERE b.is_executed <= 2 and exec_time is not null and print_date is  null and receipt_id is  null AND b.merchant_id = d.merchant_id AND d.merchant_info_id = c.merchant_info_id AND b.merchant_id = '" + merchant + "' ORDER BY b.deposit_time DESC) a WHERE ROWNUM <= ?) WHERE rnum >= ?";
	else
		query = "SELECT * FROM (SELECT a.*, ROWNUM rnum FROM (SELECT b.*, c.* FROM merchant_deposit b, merchant_info c, merchant d WHERE b.is_executed <= 2 and exec_time is not null and print_date is  null and receipt_id is null AND b.merchant_id = d.merchant_id AND d.merchant_info_id = c.merchant_info_id ORDER BY b.deposit_time DESC) a WHERE ROWNUM <= ?) WHERE rnum >= ?";
	
	pstmt = con.prepareStatement(query);
	pstmt.clearParameters();
	pstmt.setInt(1, end_row);
	pstmt.setInt(2, start_row);
	rs = pstmt.executeQuery();
	while(rs.next())
	{
		boolean is_execute = (rs.getString("is_executed").equals("1") || rs.getString("is_executed").equals("0")) ? true : false;
		boolean is_receipt = rs.getString("is_executed").equals("2") && (rs.getString("print_date") == null || rs.getString("print_date").equals("")) && request.getParameter("print" + rs.getString("deposit_id")) == null ? true : false;
		%>
		<tr>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("deposit_id")%></font></div></td>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("deposit_time")%></font></div></td>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("name")%></font></div></td>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= nf.format(rs.getLong("amount"))%></font></div></td>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("doc_number")%></font></div></td>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("note")%></font></div></td>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("tsel_bank_acc")%></font></div></td>
		<%
		if(is_execute){
			%>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><a href="auto_deposit_approve_od.jsp?xid=<%= rs.getString("deposit_id")%>&exec=1&cur_page=<%= cur_page%>" onclick="return checkExecute('<%= rs.getString("deposit_id")%>');">execute</a></font></div></td>
			<%
		}else{
			%>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif">execute</font></div></td>
			<%
		}
		
		if(is_receipt){
			%>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><a target="_receiptdeposit" href="new_print_receipt.jsp?mid=<%= rs.getString("merchant_id")%>&type=deposit&xid=<%= rs.getString("deposit_id")%>" onclick="solveThis('<%= rs.getString("deposit_id")%>', 'this', 'this',  '<%= cur_page%>');">print</a></font></div></td>
			<%
		}else{
			%>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif">print</font></div></td>
			<%
		}
%>
		</tr>
<%
	}	
	pstmt.close();
	rs.close();
%>
		</table>		
		
		</stripes:layout-component>
</stripes:layout-render>
<%  
}
catch(Exception e){
    e.printStackTrace();
    out.println("<br/ > <b>Basis data error.</b>");
	outPUT+=("Error : "+e.getMessage()+"|");
    try{con.rollback();}catch(Exception ee){}
}
finally{
    try{
        if(con!=null) con.close();
        if(rs!=null) rs.close();
        if(stmt!=null) stmt.close();
        if(pstmt!=null) pstmt.close();
		//=====================================================================//
		if (!outPUT.equals(""))
			System.out.println("["+timeNOW+"]auto_deposit_approve_od.jsp|"+outPUT);
		//=====================================================================//
    }
    catch(Exception e){}
}

%>



