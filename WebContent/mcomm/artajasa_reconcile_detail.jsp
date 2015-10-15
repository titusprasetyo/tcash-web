<%@ page import="java.io.*, java.util.*, java.net.*,java.text.*,java.sql.*, java.util.Date, java.util.Locale, java.text.SimpleDateFormat, java.text.NumberFormat, java.lang.Math"%>
<%@ include file="/web-starter/taglibs.jsp"%>
<%@page import="com.telkomsel.itvas.webstarter.User"%>

<jsp:useBean id="DbCon" scope="page" class="tsel_tunai.DbCon"></jsp:useBean>

<%!
String trimAcctNumber(String input){
	String output = input;
	for(int j=0;j<input.length();j++){
		if(output.startsWith("0")){
			output = input.substring(j+1,input.length());
		}else{
			break;
		}
	}
	output = "62" + output;
	return output;
}
%>

<%!
String PluginRequest(String address) throws MalformedURLException, IOException, ClassCastException{
            String res = "";
            try{
				URL url = new URL(address);
				InputStream in = url.openStream();
				BufferedReader br = new BufferedReader(new InputStreamReader(in));
				String line = "";
				while((line = br.readLine()) != null){
					res = res.concat(line);
				}
				br.close();
				in.close();
            }
            catch(Exception e){
				res = "dodol";
				}
    return res;
}
%>
<script language="JavaScript">
<!--
function calendar(output)
{
	newwin = window.open('cal.jsp','','top=150,left=150,width=145,height=130,resizable=no');
	if(!newwin.opener)
		newwin.opener = self;
}

function calendar2(output)
{
	newwin = window.open('cal2.jsp','','top=150,left=150,width=145,height=130,resizable=no');
	if(!newwin.opener)
		newwin.opener = self;
}

function checkExecute(xid){
	with(document)
		return confirm("Do you really want to process this recon (id: " + xid + ")?");
}

function checkExecuteRef(xid){
	with(document)
		return confirm("Do you really want to refund this recon (id: " + xid + ")?");
}

function checkExecuteDel(xid){
	with(document)
		return confirm("Do you really want to delete this recon (id: " + xid + ")?");
}
//-->
</script>
<%
//=========================================
Calendar CAL = Calendar.getInstance();
SimpleDateFormat SDF = new SimpleDateFormat("dd-MM-yyyy HH:mm:ss");
String timeNOW=SDF.format(CAL.getTime());
String outPUT = "";
//=========================================
SimpleDateFormat sdf1 = new SimpleDateFormat("dd/MM/yy HH:mm");

User user = (User)session.getValue("user");
if(user == null) {
	response.sendRedirect("index.jsp");
}


String encLogin = user.getUsername();
String encPass = user.getPassword();

String start = request.getParameter("dari");
String end = request.getParameter("ampe");
String type = request.getParameter("type");
String command = request.getParameter("command");

String status = request.getParameter("status");
String status_detail = request.getParameter("status_detail");
String recon_id = request.getParameter("recon_id");
String recon_detail_id = request.getParameter("recon_detail_id");

Date d = null;
SimpleDateFormat sdf = null;

String query = null;
Connection conn = null;
Statement stmt = null;
PreparedStatement pstmt = null;
ResultSet rs = null;

NumberFormat nf =  NumberFormat.getInstance(Locale.ITALY);

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

boolean is_exist = false;

try
{
	if(start == null)
	{
		d = new Date();
		sdf = new SimpleDateFormat("d-M-yyyy");
		start = sdf.format(d);
	}
	
	if(end == null)
	{
		d = new Date();
		sdf = new SimpleDateFormat("d-M-yyyy");
		end = sdf.format(d);
	}
	
	conn = DbCon.getConnection();
%>
<stripes:layout-render name="/web-starter/layout/standard.jsp" title="Artajasa Reconcile Details">
	<stripes:layout-component name="contents">
		<hr />Artajasa Reconcile Details : <br />
		1. <a href='https://10.41.71.65:7009/uploadArtajasaRPT.jsp?idLog1=<%=encLogin%>&idLog2=<%=encPass%>'>Artajasa RPT</a> | 2. <a href='https://10.41.71.65:7009/uploadArtajasaRTG.jsp?idLog1=<%=encLogin%>&idLog2=<%=encPass%>'>Artajasa RTG</a> | 3. <a href='https://10.41.71.65:7009/uploadArtajasaRTS.jsp?idLog1=<%=encLogin%>&idLog2=<%=encPass%>'>Artajasa RTS</a>  | 4. <a href='https://10.41.71.65:7009/tcash-web/mcomm/artajasa_reconcile.jsp?_sourcePage=%2Fmcomm%2Fartajasa_reconcile_detail.jsp'>Artajasa Reconcile</a> | 5. <a href='https://10.41.71.65:7009/tcash-web/mcomm/history_kewajiban.jsp'>History Hak/Kewajiban</a>
		<hr />
		
		
		
		<form name="formini" method="post" action="artajasa_reconcile_detail.jsp">
		<table width="30%" border="0" cellspacing="1" cellpadding="1">
		<tr bgcolor="#CC6633">
			<td colspan="2"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>Search Recon Details Date</strong></font></div></td>
		</tr>
		<tr>
			<td><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Start Date</strong></font></td>
			<td><input type="text" name="dari" value="<%= start%>" readonly="true"><a href="javascript:calendar('opener.document.formini.dari.value');"><img src="${pageContext.request.contextPath}/STATIC/cal.gif" alt="Calendar" border="0" align="absmiddle"></a></td>
		</tr>
		<tr>
			<td><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>End Date</strong></font></td>
			<td><input type="text" name="ampe" value="<%= end%>" readonly="true"><a href="javascript:calendar2('document.formini.ampe.value');"><img src="${pageContext.request.contextPath}/STATIC/cal.gif" alt="Calendar" border="0" align="absmiddle"></a></td>
		</tr>
		<tr>
			<td><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Status</strong></font></td>
			<td>
				<input type="radio" name="type" value="created" <%= check_c%>><font color="#CC6633" size="1" face="Verdana, Arial, Helvetica, sans-serif">Created</font><br>
				<input type="radio" name="type" value="pending" <%= check_p%>><font color="#CC6633" size="1" face="Verdana, Arial, Helvetica, sans-serif">Pending</font><br>
				<input type="radio" name="type" value="solved" <%= check_s%>><font color="#CC6633" size="1" face="Verdana, Arial, Helvetica, sans-serif">Solved</font><br>

			</td>
		</tr>
		<tr>
			<td></td>
			<td><input type="submit" name="Submit" value=" View "></td>
		</tr>
		</form>
		</table>
		<br>
<%
	
	conn.setAutoCommit(false);
	boolean bb =false;
	
	if(!recon_detail_id.equals("") && !recon_id.equals("") && !status.equals("") && status.equals("created")){
		if(command.equals("")){
			
			
			// update recon detail
			query = "update recon_detail set is_executed=1, pending_date=sysdate where recon_detail_id='"+recon_detail_id+"'";
			pstmt = conn.prepareStatement(query);
			pstmt.executeUpdate();
			pstmt.close();
			
			int total_details = 0;
			// ambil total_details
			query = "select total_details from recon where recon_id='"+recon_id+"'";
			//System.out.println(query);
			pstmt = conn.prepareStatement(query);
			rs = pstmt.executeQuery();
			if(rs.next()){
				total_details = rs.getInt("total_details");
			}
			pstmt.close();rs.close();
			
			int total_details_left = 0;
			query = "select count(*) as jml from recon_detail where recon_id='"+recon_id+"' and not recon_detail_id='"+recon_detail_id+"' and is_executed>=1";
			//System.out.println(query);
			pstmt = conn.prepareStatement(query);
			rs = pstmt.executeQuery();
			if(rs.next()){
				total_details_left = rs.getInt("jml");
			}
			pstmt.close();rs.close();
			
			// kalau dia adalah terakhir yang belum dicomplain
			if(total_details_left+1==total_details){
				query = "update recon set is_executed=1, pending_date=sysdate where recon_id='"+recon_id+"'";
				//System.out.println(query);
				pstmt = conn.prepareStatement(query);
				pstmt.executeUpdate();
				pstmt.close();
				bb = true;
			}
			
			conn.commit();
			if(!bb){
				out.println("<script language='javascript'>alert('Recon detail with id recon " + recon_detail_id + " claimed successfully')</script>");
				outPUT+="Recon detail with id recon " + recon_detail_id + " claimed successfully|";
			}else{
				out.println("<script language='javascript'>alert('Recon detail with id recon " + recon_detail_id + " claimed successfully. All recons were claimed')</script>");
				outPUT+="Recon detail with id recon " + recon_detail_id + " claimed successfully|All recons were claimed|";
			}
		}else if(command.equals("csgag") || command.equals("cssus2")){
			// before updating, reversal first. If all reversed then updated the recon, if not then update the details only.
			// selecting recon_detail_id from recon_id
			
			String tcash_ref = ""; 
			String acct_number = "";
			String tran_amount = "";
			
			// update recon detail
			query = "select tran_amount, acct_number, substr(result_code,3) as tcash_ref from recon_detail where recon_detail_id='"+recon_detail_id+"' and is_executed=0";
			pstmt = conn.prepareStatement(query);
			rs = pstmt.executeQuery();
			while(rs.next()){
				tcash_ref += rs.getString("tcash_ref")+",";
				acct_number += rs.getString("acct_number")+",";
				tran_amount += rs.getString("tran_amount")+",";
			}
			rs.close();pstmt.close();
			
			boolean all = true;
						
			if(!recon_detail_id.equals("") && !tcash_ref.equals("") && !acct_number.equals("")){
				String rh = "";
				// hit API
				try{		
					// throw to mo_sms.jsp
					String ul = "http://10.41.71.65:8082/tsel_tunai2/tx_be_receiver.jsp?authcode=tsel969&data=299|0|0|0|0|0|0|0|0|0|0|0|0|"+tcash_ref+"|0|0|0|0|0";
					rh = PluginRequest(ul);
					outPUT+=(ul+"|"+rh+"|");
				}catch(Exception e2){}
				
				if(rh.equals("") || (rh.substring(0,2)).equals("5A") || rh.equals("dodol")){
					all=false;
					out.println("<script language='javascript'>alert('Detail claims with id recon " + recon_id + " is failed')</script>");
					outPUT+="Detail claims with id recon " + recon_id + " is failed|";
				}else if((rh.substring(0,2)).equals("00")){
					// update recon detail
					query = "update recon_detail set is_executed=1, pending_date=sysdate where recon_id='"+recon_detail_id+"'";
					System.out.println(query);
					pstmt = conn.prepareStatement(query);
					pstmt.executeUpdate();
					pstmt.close();
					
					// check if it the last =======================
					int total_details = 0;
					// ambil total_details
					query = "select total_details from recon where recon_id='"+recon_id+"'";
					//System.out.println(query);
					pstmt = conn.prepareStatement(query);
					rs = pstmt.executeQuery();
					if(rs.next()){
						total_details = rs.getInt("total_details");
					}
					pstmt.close();rs.close();
					
					int total_details_left = 0;
					query = "select count(*) as jml from recon_detail where recon_id='"+recon_id+"' and not recon_detail_id='"+recon_detail_id+"' and is_executed>=1";
					//System.out.println(query);
					pstmt = conn.prepareStatement(query);
					rs = pstmt.executeQuery();
					if(rs.next()){
						total_details_left = rs.getInt("jml");
					}
					pstmt.close();rs.close();
					
					// kalau dia adalah terakhir yang belum dicomplain
					if(total_details_left+1==total_details){
						query = "update recon set is_executed=1, pending_date=sysdate where recon_id='"+recon_id+"'";
						//System.out.println(query);
						pstmt = conn.prepareStatement(query);
						pstmt.executeUpdate();
						pstmt.close();
						bb = true;
					}
					
					// send notification sms of success 
					
					// check balance 
					String bala = "99";
					query = "select balance from tsel_cust_account where acc_no=(select acc_no from customer where msisdn='"+trimAcctNumber(acct_number)+"')";
					pstmt = conn.prepareStatement(query);
					rs = pstmt.executeQuery();
					if(rs.next()){
						bala = rs.getString("balance");
					}
					rs.close();pstmt.close();
					
					pstmt = conn.prepareStatement("insert into notif(msisdn, msg, source, s_time) values('"+trimAcctNumber(acct_number)+"', '"+sdf1.format(Calendar.getInstance().getTime())+" Reversal Transfer sebesar Rp "+nf.format(Long.parseLong(tran_amount))+" sudah dikembalikan. Balance anda Rp "+nf.format(Long.parseLong(bala))+"."+"','2828', sysdate)");
					pstmt.executeUpdate();
					pstmt.close();
					outPUT+=("SMS sent|");
					
					conn.commit();
					if(!bb){
						out.println("<script language='javascript'>alert('Recon detail with id recon " + recon_detail_id + " refunded successfully')</script>");
						outPUT+="Recon detail with id recon " + recon_detail_id + " refunded successfully|";
					}else{
						out.println("<script language='javascript'>alert('Recon detail with id recon " + recon_detail_id + " refunded successfully. All recons with id "+recon_id+" were refunded.')</script>");
						outPUT+="Recon detail with id recon " + recon_detail_id + " claimed successfully|All recons with id "+recon_id+" were claimed|";
					}
				}
			}else{
				out.println("<script language='javascript'>alert('Detail claims with id recon " + recon_id + " is failed')</script>");
				outPUT+="Detail claims with id recon " + recon_id + " is failed|";
			}
		}else if(command.equals("csber") || command.equals("cssus1")){
			// before updating, delete first. If all deleted then updated the recon, if not then update the details only.
			// selecting recon_detail_id from recon_id
			
			String tcash_ref = ""; 
			String acct_number = "";
			
			// update recon detail
			query = "select acct_number, substr(result_code,3) as tcash_ref from recon_detail where recon_detail_id='"+recon_detail_id+"' and is_executed=0";
			pstmt = conn.prepareStatement(query);
			rs = pstmt.executeQuery();
			while(rs.next()){
				tcash_ref += rs.getString("tcash_ref")+",";
				acct_number += rs.getString("acct_number")+",";
			}
			rs.close();pstmt.close();
			
			boolean all = true;
						
			if(!recon_detail_id.equals("") && !tcash_ref.equals("") && !acct_number.equals("")){
				String rh = "";
				// hit API
				try{		
					// throw to mo_sms.jsp
					String ul = "http://10.41.71.65:8082/tsel_tunai2/tx_be_receiver.jsp?authcode=tsel969&data=14|"+tcash_ref+"|"+trimAcctNumber(acct_number);
					rh = PluginRequest(ul);
					outPUT+=(ul+"|"+rh+"|");
				}catch(Exception e2){}
				
				if(rh.equals("") || (rh.substring(0,2)).equals("5A") || rh.equals("dodol")){
					all=false;
					out.println("<script language='javascript'>alert('Detail claims with id recon " + recon_id + " is failed')</script>");
					outPUT+="Detail claims with id recon " + recon_id + " is failed|";
				}else if((rh.substring(0,2)).equals("00")){
					// update recon detail
					query = "update recon_detail set is_executed=1, pending_date=sysdate where recon_id='"+recon_detail_id+"'";
					System.out.println(query);
					pstmt = conn.prepareStatement(query);
					pstmt.executeUpdate();
					pstmt.close();
					
					// check if it the last =======================
					int total_details = 0;
					// ambil total_details
					query = "select total_details from recon where recon_id='"+recon_id+"'";
					//System.out.println(query);
					pstmt = conn.prepareStatement(query);
					rs = pstmt.executeQuery();
					if(rs.next()){
						total_details = rs.getInt("total_details");
					}
					pstmt.close();rs.close();
					
					int total_details_left = 0;
					query = "select count(*) as jml from recon_detail where recon_id='"+recon_id+"' and not recon_detail_id='"+recon_detail_id+"' and is_executed>=1";
					//System.out.println(query);
					pstmt = conn.prepareStatement(query);
					rs = pstmt.executeQuery();
					if(rs.next()){
						total_details_left = rs.getInt("jml");
					}
					pstmt.close();rs.close();
					
					// kalau dia adalah terakhir yang belum dicomplain
					if(total_details_left+1==total_details){
						query = "update recon set is_executed=1, pending_date=sysdate where recon_id='"+recon_id+"'";
						//System.out.println(query);
						pstmt = conn.prepareStatement(query);
						pstmt.executeUpdate();
						pstmt.close();
						bb = true;
					}
					
					conn.commit();
					if(!bb){
						out.println("<script language='javascript'>alert('Recon detail with id recon " + recon_detail_id + " refunded successfully')</script>");
						outPUT+="Recon detail with id recon " + recon_detail_id + " refunded successfully|";
					}else{
						out.println("<script language='javascript'>alert('Recon detail with id recon " + recon_detail_id + " refunded successfully. All recons with id "+recon_id+" were refunded.')</script>");
						outPUT+="Recon detail with id recon " + recon_detail_id + " claimed successfully|All recons with id "+recon_id+" were claimed|";
					}
				}
			}else{
				out.println("<script language='javascript'>alert('Detail claims with id recon " + recon_id + " is failed')</script>");
				outPUT+="Detail claims with id recon " + recon_id + " is failed|";
			}
		}
	}
	
	if(!recon_id.equals("") && !status.equals("") && status.equals("pending")){
		
		int tran_amount = 0;
		// ambil tran_amount
		query = "select tran_amount from recon_detail where recon_detail_id='"+recon_detail_id+"'";
		//System.out.println(query);
		pstmt = conn.prepareStatement(query);
		rs = pstmt.executeQuery();
		if(rs.next()){
			tran_amount = rs.getInt("tran_amount");
		}
		pstmt.close();rs.close();
			
		// update recon detail
		query = "update recon_detail set is_executed=2, solved_date=sysdate where recon_detail_id='"+recon_detail_id+"'";
		pstmt = conn.prepareStatement(query);
		pstmt.executeUpdate();
		pstmt.close();
		
		int total_details = 0;int details_solved = 0;int total_amount = 0;int total_amount_solved = 0;
		// ambil total_details
		query = "select total_details, details_solved, total_amount, total_amount_solved from recon where recon_id='"+recon_id+"'";
		//System.out.println(query);
		pstmt = conn.prepareStatement(query);
		rs = pstmt.executeQuery();
		if(rs.next()){
			total_details = rs.getInt("total_details");
			details_solved = rs.getInt("details_solved");
			total_amount = rs.getInt("total_amount");
			total_amount_solved = rs.getInt("total_amount_solved");
		}
		pstmt.close();rs.close();
		
		// cek apakah dia terakhir atau tidak
		if(details_solved+1==total_details){
			// kalau terakhir, set total_amount_solved dan details_solved to max
			query = "update recon set details_solved=total_details, total_amount_solved=total_amount, is_executed=2, solved_date=sysdate where recon_id='"+recon_id+"'";
			//System.out.println(query);
			pstmt = conn.prepareStatement(query);
			pstmt.executeUpdate();
			pstmt.close();
			bb = true;
		}else{
			// kalau bukan terakhir
			query = "update recon set details_solved="+(details_solved+1)+", total_amount_solved="+(total_amount_solved+tran_amount)+" where recon_id='"+recon_id+"'";
			//System.out.println(query);
			pstmt = conn.prepareStatement(query);
			pstmt.executeUpdate();
			pstmt.close();
		}
		
		conn.commit();
		if(!bb){
			out.println("<script language='javascript'>alert('Recon detail with id recon " + recon_detail_id + " solved successfully')</script>");
			outPUT+="Recon detail with id recon " + recon_detail_id + " solved successfully|Recon total_amount_solved updated|";
		}else{
			out.println("<script language='javascript'>alert('Recon detail with id recon " + recon_detail_id + " solved successfully. All recons were solved')</script>");
			outPUT+="Recon detail with id recon " + recon_detail_id + " solved successfully|All recons were solved|";
		}
	}
	
	
	// =========== Paging ==============
	int jumlah = 0;
	int cur_page = 1;
	int row_per_page = 100;
	
	String AJ_merchantid = "";
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
		query = "select count(*) as jumlah from recon r, recon_detail rd where r.recon_id = rd.recon_id and r.merchant_id='"+AJ_merchantid+"' and rd.is_executed like '%' and (r.recon_date between to_date('"+start+" 00:00:00','DD-MM-YYYY HH24:MI:SS') and to_date('"+end+" 23:59:59','DD-MM-YYYY HH24:MI:SS'))";
	else{
		if(!check_c.equals("")){
			query = "select count(*) as jumlah from recon r, recon_detail rd where r.recon_id = rd.recon_id and r.merchant_id='"+AJ_merchantid+"' and rd.is_executed like '0%' and (r.recon_date between to_date('"+start+" 00:00:00','DD-MM-YYYY HH24:MI:SS') and to_date('"+end+" 23:59:59','DD-MM-YYYY HH24:MI:SS'))";
		}else if(!check_p.equals("")){
			query = "select count(*) as jumlah from recon r, recon_detail rd where r.recon_id = rd.recon_id and r.merchant_id='"+AJ_merchantid+"' and rd.is_executed like '1%' and (r.recon_date between to_date('"+start+" 00:00:00','DD-MM-YYYY HH24:MI:SS') and to_date('"+end+" 23:59:59','DD-MM-YYYY HH24:MI:SS'))";
		}else if(!check_s.equals("")){
			query = "select count(*) as jumlah from recon r, recon_detail rd where r.recon_id = rd.recon_id and r.merchant_id='"+AJ_merchantid+"' and rd.is_executed like '2%' and (r.recon_date between to_date('"+start+" 00:00:00','DD-MM-YYYY HH24:MI:SS') and to_date('"+end+" 23:59:59','DD-MM-YYYY HH24:MI:SS'))";
		}
	}
	
	if(status_detail.equals("detail") && !recon_id.equals(""))
		query = "select count(*) as jumlah from recon r, recon_detail rd where r.recon_id='"+recon_id+"' and r.recon_id = rd.recon_id and rd.is_executed like '%' and (r.recon_date between to_date('"+start+" 00:00:00','DD-MM-YYYY HH24:MI:SS') and to_date('"+end+" 23:59:59','DD-MM-YYYY HH24:MI:SS'))";
	
	System.out.println(query);
	pstmt = conn.prepareStatement(query);
	rs = pstmt.executeQuery();
	if(rs.next())
		jumlah = rs.getInt("jumlah");
	
	pstmt.close();
	rs.close();
	
	if(request.getParameter("cur_page") != null)
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
		out.print("<a class='link' href='?cur_page=" + (minPaging - 1) + "&dari=" + start + "&ampe=" + end + "&type=" + type + "'>&lt;</a>");
	
	for(int i = minPaging; i <= maxPaging; i++)
	{
		if(i == cur_page)
			out.print(i + " ");
		else
			out.print("<a class='link' href='?cur_page=" + i + "&dari=" + start + "&ampe=" + end + "&type=" + type + "'>" + i + " </a>");
	}
	
	if(maxPaging + 1 <= total_page)
		out.print("<a class='link' href='?cur_page=" + (maxPaging + 1) + "&dari=" + start + "&ampe=" + end + "&type=" + type + "'>&gt;</a>");
%>
		<table width="90%" border="1" cellspacing="0" cellpadding="0" bordercolor="#FFF6EF">
		<tr>
			<td colspan="11"><div align="right"><font color="#CC6633" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>.:: Artajasa Recon Details Result</strong></font></div></td>
		</tr>
		<tr>
			<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>ID</strong></font></div></td>
			<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Date</strong></font></div></td>
			<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Type</strong></font></div></td>
			<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Trace Number</strong></font></div></td>
			<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Ref Number</strong></font></div></td>
			<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Tran Amount</strong></font></div></td>
			<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Iso Date</strong></font></div></td>
			<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Created</strong></font></div></td>
			<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Claimed</strong></font></div></td>
			<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Solved</strong></font></div></td>
			<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Action</strong></font></div></td>
		</tr>
<%
	if(type.equals(""))
		query = "SELECT * FROM (SELECT a.*, ROWNUM rnum FROM (select r.recon_id, r.recon_date, r.recon_type, rd.recon_detail_id, rd.tran_time, rd.acct_number, rd.tran_amount, rd.iso_date, rd.pan_code, rd.bank_code, rd.trace_number, rd.ref_number, rd.is_executed, rd.created_date, rd.pending_date, rd.solved_date  from recon r, recon_detail rd where r.recon_id = rd.recon_id and r.merchant_id='"+AJ_merchantid+"' and rd.is_executed like '%' and (r.recon_date between to_date('"+start+" 00:00:00','DD-MM-YYYY HH24:MI:SS') and to_date('"+end+" 23:59:59','DD-MM-YYYY HH24:MI:SS')) order by r.RECON_DATE desc) a WHERE ROWNUM <= "+end_row+") WHERE rnum >= "+start_row;
	else{
		if(!check_c.equals("")){
			query = "SELECT * FROM (SELECT a.*, ROWNUM rnum FROM (select r.recon_id, r.recon_date, r.recon_type, rd.recon_detail_id, rd.tran_time, rd.acct_number, rd.tran_amount, rd.iso_date, rd.pan_code, rd.bank_code, rd.trace_number, rd.ref_number, rd.is_executed, rd.created_date, rd.pending_date, rd.solved_date  from recon r, recon_detail rd where r.recon_id = rd.recon_id and r.merchant_id='"+AJ_merchantid+"' and rd.is_executed like '0%' and (r.recon_date between to_date('"+start+" 00:00:00','DD-MM-YYYY HH24:MI:SS') and to_date('"+end+" 23:59:59','DD-MM-YYYY HH24:MI:SS')) order by r.RECON_DATE desc) a WHERE ROWNUM <= "+end_row+") WHERE rnum >= "+start_row;
		}else if(!check_p.equals("")){
			query = "SELECT * FROM (SELECT a.*, ROWNUM rnum FROM (select r.recon_id, r.recon_date, r.recon_type, rd.recon_detail_id, rd.tran_time, rd.acct_number, rd.tran_amount, rd.iso_date, rd.pan_code, rd.bank_code, rd.trace_number, rd.ref_number, rd.is_executed, rd.created_date, rd.pending_date, rd.solved_date  from recon r, recon_detail rd where r.recon_id = rd.recon_id and r.merchant_id='"+AJ_merchantid+"' and rd.is_executed like '1%' and (r.recon_date between to_date('"+start+" 00:00:00','DD-MM-YYYY HH24:MI:SS') and to_date('"+end+" 23:59:59','DD-MM-YYYY HH24:MI:SS')) order by r.RECON_DATE desc) a WHERE ROWNUM <= "+end_row+") WHERE rnum >= "+start_row;
		}else if(!check_s.equals("")){
			query = "SELECT * FROM (SELECT a.*, ROWNUM rnum FROM (select r.recon_id, r.recon_date, r.recon_type, rd.recon_detail_id, rd.tran_time, rd.acct_number, rd.tran_amount, rd.iso_date, rd.pan_code, rd.bank_code, rd.trace_number, rd.ref_number, rd.is_executed, rd.created_date, rd.pending_date, rd.solved_date  from recon r, recon_detail rd where r.recon_id = rd.recon_id and r.merchant_id='"+AJ_merchantid+"' and rd.is_executed like '2%' and (r.recon_date between to_date('"+start+" 00:00:00','DD-MM-YYYY HH24:MI:SS') and to_date('"+end+" 23:59:59','DD-MM-YYYY HH24:MI:SS')) order by r.RECON_DATE desc) a WHERE ROWNUM <= "+end_row+") WHERE rnum >= "+start_row;
		}
	}
	if(status_detail.equals("detail") && !recon_id.equals(""))
		query = "SELECT * FROM (SELECT a.*, ROWNUM rnum FROM (select r.recon_id, r.recon_date, r.recon_type, rd.recon_detail_id, rd.tran_time, rd.acct_number, rd.tran_amount, rd.iso_date, rd.pan_code, rd.bank_code, rd.trace_number, rd.ref_number, rd.is_executed, rd.created_date, rd.pending_date, rd.solved_date  from recon r, recon_detail rd where r.recon_id='"+recon_id+"' and r.recon_id = rd.recon_id and r.merchant_id='"+AJ_merchantid+"' and rd.is_executed like '%' and (r.recon_date between to_date('"+start+" 00:00:00','DD-MM-YYYY HH24:MI:SS') and to_date('"+end+" 23:59:59','DD-MM-YYYY HH24:MI:SS')) order by r.RECON_DATE desc) a WHERE ROWNUM <= "+end_row+") WHERE rnum >= "+start_row;
	
	System.out.println(query);
	pstmt = conn.prepareStatement(query);
	rs = pstmt.executeQuery();
	
	while(rs.next())
	{
%>
		<tr>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("RECON_detail_ID")%></font></div></td>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("RECON_DATE")%></font></div></td>
			<%
				String recon_type = rs.getString("RECON_TYPE");
				if(recon_type.equals("cashin_suspect")){
			%>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif">Cashin - Klaim Suspect</font></div></td>
			<%
				}else if(recon_type.equals("cashin_rpt")){
			%>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif">Cashin - Investigasi RPT</font></div></td>	
			<%
				}else if(recon_type.equals("cashout_rpt")){
			%>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif">Cashout - Investigasi RPT</font></div></td>	
			<%
				}else if(recon_type.equals("cashout_suspect_gagal")){
			%>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif">Cashout - Suspect Gagal</font></div></td>
			<%
				}else if(recon_type.equals("cashout_suspect_berhasil")){
			%>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif">Cashout - Suspect Berhasil</font></div></td>
			<%
				}else if(recon_type.equals("cashout_suspect_suspect")){
			%>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif">Cashout - Suspect Suspect</font></div></td>
			<%
				}else if(recon_type.equals("cashin_db")){
			%>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif">Cashin - Investigasi DB</font></div></td>
			<%
				}else if(recon_type.equals("cashout_db")){
			%>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif">Cashout - Investigasi DB</font></div></td>
			<%
				}else if(recon_type.equals("cashin_claim_ada")){
			%>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif">Cashin - Klaim Berhasil (Reclaim)</font></div></td>
			<%
				}else if(recon_type.equals("cashin_claim_tidak")){
			%>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif">Cashin - Invertigasi Klaim Berhasil</font></div></td>
			<%
			}else{
			%>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><%=recon_type%></font></div></td>
			<%}%>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("trace_number")%></font></div></td>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("ref_number")%></font></div></td>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= nf.format(rs.getLong("Tran_AMOUNT"))%></font></div></td>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("iso_date")%></font></div></td>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("CREATED_DATE")%></font></div></td>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("PENDING_DATE")%></font></div></td>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("SOLVED_DATE")%></font></div></td>
			<%
				if(rs.getString("IS_EXECUTED").equals("0")){
					if(recon_type.equals("cashout_suspect_gagal")){
			%>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><a href="artajasa_reconcile_detail.jsp?command=csgag&dari=<%=start%>&ampe=<%=end%><%=(status_detail.equals("detail")?"&status_detail=detail":"")%>&status=created&recon_id=<%=rs.getString("RECON_ID")%>&recon_detail_id=<%=rs.getString("RECON_detail_ID")%>"  onclick="return checkExecuteRef('<%= rs.getString("recon_detail_id")%>');">Refund</a></font></div></td>				
			<%
					}else if(recon_type.equals("cashout_suspect_berhasil")){
			%>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><a href="artajasa_reconcile_detail.jsp?command=csber&dari=<%=start%>&ampe=<%=end%><%=(status_detail.equals("detail")?"&status_detail=detail":"")%>&status=created&recon_id=<%=rs.getString("RECON_ID")%>&recon_detail_id=<%=rs.getString("RECON_detail_ID")%>"  onclick="return checkExecuteDel('<%= rs.getString("recon_detail_id")%>');">Delete</a></font></div></td>				
			<%
					}else if(recon_type.equals("cashout_suspect_suspect")){
			%>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><a href="artajasa_reconcile_detail.jsp?command=cssus1&dari=<%=start%>&ampe=<%=end%><%=(status_detail.equals("detail")?"&status_detail=detail":"")%>&status=created&recon_id=<%=rs.getString("RECON_ID")%>&recon_detail_id=<%=rs.getString("RECON_detail_ID")%>"  onclick="return checkExecuteDel('<%= rs.getString("recon_detail_id")%>');">Claimed by Bank</a> | <a href="artajasa_reconcile_detail.jsp?command=cssus2&dari=<%=start%>&ampe=<%=end%><%=(status_detail.equals("detail")?"&status_detail=detail":"")%>&status=created&recon_id=<%=rs.getString("RECON_ID")%>&recon_detail_id=<%=rs.getString("RECON_detail_ID")%>"  onclick="return checkExecuteRef('<%= rs.getString("recon_detail_id")%>');">Refund</a></font></div></td>				
			<%
					}else{
			%>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><a href="artajasa_reconcile_detail.jsp?command=&dari=<%=start%>&ampe=<%=end%><%=(status_detail.equals("detail")?"&status_detail=detail":"")%>&status=created&recon_id=<%=rs.getString("RECON_ID")%>&recon_detail_id=<%=rs.getString("RECON_detail_ID")%>"  onclick="return checkExecute('<%= rs.getString("recon_detail_id")%>');">Claim</a></font></div></td>				
			<%
					}
				}else if(rs.getString("IS_EXECUTED").equals("1")){
			%>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><a href="artajasa_reconcile_detail.jsp?dari=<%=start%>&ampe=<%=end%><%=(status_detail.equals("detail")?"&status_detail=detail":"")%>&status=pending&recon_id=<%=rs.getString("RECON_ID")%>&recon_detail_id=<%=rs.getString("RECON_detail_ID")%>"  onclick="return checkExecute('<%= rs.getString("recon_detail_id")%>');">Solve</a></font></div></td>				
			<%
				}else {
			%>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"></font></div></td>				
			<%
				}
			%>
		</tr>
<%
	is_exist = true;
	}
	
	pstmt.close();
	rs.close();
%>
		</table>
		
<%	if (is_exist) { %>
		 <br>
		 <center><a href="artajasa_reconcile_detail_csv.jsp?<%=(status_detail.equals("detail") && !recon_id.equals(""))?"status=detail&recon_id="+recon_id+"&":""%>dari=<%=start%>&ampe=<%=end%>&type=<%=type%>">Save as CSV</a></center>
<% } %>
	</stripes:layout-component>
</stripes:layout-render>

<%
}
catch(Exception e)
{
	e.printStackTrace(System.out);
	conn.rollback();
}
finally
{
	//=====================================================================//
	if (!outPUT.equals(""))
		System.out.println("["+timeNOW+"]artajasa_reconcile_detail.jsp|"+outPUT);
	//=====================================================================//
	try
	{
		conn.close();
	}
	catch(Exception e)
	{
	}
}
%>
