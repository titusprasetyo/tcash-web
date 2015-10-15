<%@ page import="java.io.*, java.util.*,java.text.*,java.sql.*, java.util.Date, java.util.Locale, java.text.SimpleDateFormat, java.text.NumberFormat, java.lang.Math"%>
<%@ include file="/web-starter/taglibs.jsp"%>
<%@page import="com.telkomsel.itvas.webstarter.User"%>

<jsp:useBean id="DbCon" scope="page" class="tsel_tunai.DbCon"></jsp:useBean>
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
//-->
</script>
<%
//=========================================
Calendar CAL = Calendar.getInstance();
SimpleDateFormat SDF = new SimpleDateFormat("dd-MM-yyyy HH:mm:ss");
String timeNOW=SDF.format(CAL.getTime());
String outPUT = "";
//=========================================


User user = (User)session.getValue("user");
if(user == null) {
	response.sendRedirect("index.jsp");
}

String encLogin = user.getUsername();
String encPass = user.getPassword();

String start = request.getParameter("dari");
String end = request.getParameter("ampe");
String bank_name = request.getParameter("bank_name");

Date d = null;
SimpleDateFormat sdf = null;

String query = null;
Connection conn = null;
Statement stmt = null;
PreparedStatement pstmt = null;
ResultSet rs = null;

NumberFormat nf =  NumberFormat.getInstance(Locale.ITALY);
	
if(bank_name == null)
	bank_name = "";

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
<stripes:layout-render name="/web-starter/layout/standard.jsp" title="History Hak/Kewajiban">
	<stripes:layout-component name="contents">
		<hr />Artajasa Reconcile : <br />
		1. <a href='https://10.41.71.65:7009/uploadArtajasaRPT.jsp?idLog1=<%=encLogin%>&idLog2=<%=encPass%>'>Artajasa RPT</a> | 2. <a href='https://10.41.71.65:7009/uploadArtajasaRTG.jsp?idLog1=<%=encLogin%>&idLog2=<%=encPass%>'>Artajasa RTG</a> | 3. <a href='https://10.41.71.65:7009/uploadArtajasaRTS.jsp?idLog1=<%=encLogin%>&idLog2=<%=encPass%>'>Artajasa RTS</a> | 4. <a href='https://10.41.71.65:7009/tcash-web/mcomm/artajasa_reconcile.jsp'>Artajasa Reconcile</a> | 5. <a href='https://10.41.71.65:7009/tcash-web/mcomm/history_kewajiban.jsp'>History Hak/Kewajiban</a>
		<hr />
		
		
		
		<form name="formini" method="post" action="history_kewajiban.jsp">
		<table width="30%" border="0" cellspacing="1" cellpadding="1">
		<tr bgcolor="#CC6633">
			<td colspan="2"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>Search Recon Date</strong></font></div></td>
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
			<td><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Bank Name</strong></font></td>
			<td><input type="text" name="bank_name" value="<%= bank_name%>" ></td>
		</tr>
		<tr>
			<td></td>
			<td><input type="submit" name="Submit" value=" View "></td>
		</tr>
		</form>
		</table>
		<br>
<%
	// ===================== Start of Paging
	int jumlah = 0;
	int cur_page = 1;
	int row_per_page = 100;
	
	
	query = "select count(*) as jumlah from recon_selisih rs where lower(rs.bank_name) like '%"+bank_name.toLowerCase() +"%' and to_date(rs.settle_date,'DD/MM/YYYY') between to_date('"+start+" 00:00:00','DD-MM-YYYY HH24:MI:SS') and to_date('"+end+" 23:59:59','DD-MM-YYYY HH24:MI:SS')";
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
		out.print("<a class='link' href='?cur_page=" + (minPaging - 1) + "&dari=" + start + "&ampe=" + end + "&bank_name=" + bank_name + "'>&lt;</a>");
	
	for(int i = minPaging; i <= maxPaging; i++)
	{
		if(i == cur_page)
			out.print(i + " ");
		else
			out.print("<a class='link' href='?cur_page=" + i + "&dari=" + start + "&ampe=" + end + "&bank_name=" + bank_name + "'>" + i + " </a>");
	}
	
	if(maxPaging + 1 <= total_page)
		out.print("<a class='link' href='?cur_page=" + (maxPaging + 1) + "&dari=" + start + "&ampe=" + end + "&bank_name=" + bank_name + "'>&gt;</a>");
		
	// ===================== End of Paging
%>
		<table width="90%" border="1" cellspacing="0" cellpadding="0" bordercolor="#FFF6EF">
		<tr>
			<td colspan="14"><div align="right"><font color="#CC6633" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>.:: Artajasa Recon Result</strong></font></div></td>
		</tr>
		<tr>
			<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Settle Date</strong></font></div></td>
			<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Bank Code</strong></font></div></td>
			<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Bank Name</strong></font></div></td>
			<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Hak</strong></font></div></td>
			<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Hak Dibayarkan</strong></font></div></td>
			<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Denda Hak</strong></font></div></td>
			<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Denda Hak Report</strong></font></div></td>
			<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Kewajiban</strong></font></div></td>
			<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Kewajiban Dibayarkan</strong></font></div></td>
			<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Denda Kewajiban</strong></font></div></td>
			<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Denda Kewajiban Report</strong></font></div></td>
			<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Solved Date</strong></font></div></td>
			<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Status</strong></font></div></td>
			<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Keterangan</strong></font></div></td>
		</tr>
<%
	query = "SELECT * FROM (SELECT a.*, ROWNUM rnum FROM (select rs.SETTLE_DATE, rs.bank_code, rs.bank_name, rs.hak as hak, rs.hak_dibayarkan as hak_dibayarkan, rs.denda_hak as denda_hak, rs.denda_hak_rpt as denda_hak_report, rs.kewajiban as kewajiban, rs.kewajiban_dibayarkan as kewajiban_dibayarkan, rs.denda_kewajiban as denda_kewajiban, rs.denda_kewajiban_rpt as denda_kewajiban_report, rs.solve_date, rs.status, rs.merchant_id, rs.keterangan from recon_selisih rs where lower(rs.bank_name) like '%"+bank_name.toLowerCase()+"%' and to_date(rs.settle_date,'DD/MM/YYYY') between to_date('"+start+" 00:00:00','DD-MM-YYYY HH24:MI:SS') and to_date('"+end+" 23:59:59','DD-MM-YYYY HH24:MI:SS') order by rs.settle_date desc, rs.bank_name asc) a WHERE ROWNUM <= "+end_row+") WHERE rnum >= "+start_row;
	System.out.println(query);
	pstmt = conn.prepareStatement(query);
	pstmt.clearParameters();
	rs = pstmt.executeQuery();
	while(rs.next())
	{
%>
		<tr>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("SETTLE_DATE")%></font></div></td>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("bank_code")%></font></div></td>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("bank_name")%></font></div></td>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= nf.format(rs.getLong("hak"))%></font></div></td>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= nf.format(rs.getLong("hak_dibayarkan"))%></font></div></td>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= nf.format(rs.getLong("denda_hak"))%></font></div></td>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= nf.format(rs.getLong("denda_hak_report"))%></font></div></td>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= nf.format(rs.getLong("kewajiban"))%></font></div></td>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= nf.format(rs.getLong("kewajiban_dibayarkan"))%></font></div></td>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= nf.format(rs.getLong("denda_kewajiban"))%></font></div></td>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= nf.format(rs.getLong("denda_kewajiban_report"))%></font></div></td>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("solve_date")%></font></div></td>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("status")%></font></div></td>
			<%
			//System.out.println("Keterangan:"+rs.getString("keterangan"));
			String [] keteranganarray = (rs.getString("keterangan")).split("\\|");
			//System.out.println("Keterangan [0]:"+keteranganarray[0]);
			//System.out.println("Keterangan length:"+keteranganarray.length);
			
			if(keteranganarray[0].equals("new") && keteranganarray.length==1){
			%>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> Belum Recon </font></div></td>
			<%
			}
			else if(keteranganarray[0].equals("reconed") && keteranganarray[1].equals("X")){
			%>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> Settlement Pas. </font></div></td>
			<%		
			}else if(keteranganarray[0].equals("reconed") && keteranganarray[1].equals("XX")){
			%>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> Settlement Tidak Pas. </font></div></td>
			<%	
			}else{
			%>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> - </font></div></td>
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
		 <center><a href="history_kewajiban_csv.jsp?dari=<%=start%>&ampe=<%=end%>&bank_name=<%=bank_name%>">Save as CSV</a></center>
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
		System.out.println("["+timeNOW+"]history_kewajiban.jsp|"+outPUT);
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
