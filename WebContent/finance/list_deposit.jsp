<%@ page import="java.sql.*,java.util.*,java.text.*"%>
<script language="JavaScript">
<!--
function checkDelete()
{
	with(document)
	{
		var checkStatus = confirm('Do you really want to delete this member?');
		if (checkStatus)
		{
			checkStatus = true;
		}
		return checkStatus;
	}
}
//-->
<!--
function calendar(output)
{
	newwin = window.open('cal.jsp','','top=150,left=150,width=145,height=130,resizable=no');
	if (!newwin.opener) newwin.opener = self;
}

function calendar2(output)
{
	newwin = window.open('cal2.jsp','','top=150,left=150,width=145,height=130,resizable=no');
	if (!newwin.opener) newwin.opener = self;
}
//-->
</script>

<%
	String merchant_name = request.getParameter("merchant_name");
	if(session.getValue("user") != null)
	{
%>
<jsp:useBean id="DbCon" scope="page" class="tsel_tunai.DbCon"></jsp:useBean>
<%@ include file="/web-starter/taglibs.jsp"%>
<stripes:layout-render name="/web-starter/layout/standard.jsp" title="Merchant List">
	<stripes:layout-component name="contents">
        <%
	
	String dari = request.getParameter("dari");
	if (merchant_name == null) {
		merchant_name = "";
	}
	String test = request.getParameter("test");
	//out.print(dari);
	String ampe = request.getParameter("ampe");
   
	NumberFormat nf =  NumberFormat.getInstance(Locale.ITALY);
	Connection conn = null;
	try{
		
		//Class.forName("oracle.jdbc.driver.OracleDriver");
		//String url = "jdnc:oracle:thin:localhost:1521:ORCL";
		conn = DbCon.getConnection();
		//Statement stmt1 = conn.createStatement();
	%>
        <div align="right"><font color="#FFFFFF" face="Verdana, Arial, Helvetica, sans-serif"></font> 
        </div>
        <div align="right"> </div>
        <div align="right"> </div>
	
	 
     
		
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
			  <tr> 
            <td><div align="right"><font color="#CC6633" size="4" face="Verdana, Arial, Helvetica, sans-serif"><strong></strong></font></div></td>
          </tr>	
		
		</table>
		
		
<table width="32%" border="1" cellspacing="0" cellpadding="0">
		<%
			java.util.Date skr = new java.util.Date();
			SimpleDateFormat forma = new SimpleDateFormat("d-M-yyyy");
			String tdate = forma.format(skr);
			dari = (dari != null && !dari.equals("")) ? dari : tdate;
			ampe = (ampe != null && !ampe.equals("")) ? ampe : tdate;
		%>
          <form name="formini" method="post">
            <tr bgcolor="#CC6633"> 
              <td colspan="2"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Search 
                  Deposit date</strong></font></div></td>
            </tr>
            <tr> 
              <td colspan="2"></td>
            </tr>
            <tr> 
              <td height="15"><div align="center"><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif">From</font></div></td>
              <td><div align="left"><input type="text" name="dari" value="<%= dari%>" readonly="true"><a href="javascript:calendar('opener.document.formini.dari.value');"><img src="${pageContext.request.contextPath}/STATIC/cal.gif" alt="Calendar" border="0" align="absmiddle"></a> 
                  
                </div>
				<input type="hidden" name="test" value="1">
              </td>
            </tr>
            <tr> 
              <td><div align="center"><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif">To</font></div></td>
              <td><div align="left"><input type="text" name="ampe" value="<%= ampe%>" readonly="true"><a href="javascript:calendar2('opener.document.formini.ampe.value');"><img src="${pageContext.request.contextPath}/STATIC/cal.gif" alt="Calendar" border="0" align="absmiddle"></a>
                  
                </div>
              </td>
            </tr>
						<tr> 
              <td><div align="center"><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif">Merchant Name</font></div></td>
              <td><div align="left"><input type="text" name="merchant_name" value="<%= merchant_name%>">
                  
                </div>
              </td>
            </tr>
            <tr> 
              <td width="30%" height="26"><input type="submit" name="Submit" value="Search"></td>
            </tr>
          </form>
        </table>
		
		<br>
		
        <table width="80%" border="1" cellspacing="0" cellpadding="0" bordercolor="#FFF6EF">
          <tr bgcolor="#FFF6EF"> 
            <td colspan="10"> 
              <div align="right"><font color="#CC6633" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>.:: 
                List Deposit</strong></font></div>
            </td>
          </tr>
          <tr> 
            <td bgcolor="#CC6633">
              <div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Deposit ID</strong></font></div>
            </td>
            <td bgcolor="#CC6633"> 
              <div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Merchant 
                Name </strong></font></div>
            </td>
            <td bgcolor="#CC6633"> 
              <div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Amount</strong></font></div>
            </td>
            <td bgcolor="#CC6633"> 
              <div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Deposit Time</strong></font></div>
            </td>
            <td bgcolor="#CC6633"> 
              <div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Doc Number</strong></font></div>
            </td>
            <td bgcolor="#CC6633"> 
              <div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Note</strong></font></div>
            </td>
            <td bgcolor="#CC6633"> 
              <div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Is Executed</strong></font></div>
            </td>
            <td bgcolor="#CC6633"> 
              <div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Print Receipt</strong></font></div>
            </td>
          </tr>
          <%

// paging stuff
String sql = "select count(*) as jumlah from merchant m,merchant_info mi,merchant_deposit mc where m.merchant_info_id = mi.merchant_info_id and m.merchant_id = mc.merchant_id and LOWER(name) like '%"+merchant_name.toLowerCase()+"%' and (deposit_time between to_date('"+dari+" 00:00:00', 'DD-MM-YYYY HH24:MI:SS') and to_date('"+ampe+" 23:59:59', 'DD-MM-YYYY HH24:MI:SS')) order by deposit_time desc";
PreparedStatement pstmt = conn.prepareStatement(sql);
ResultSet rs = pstmt.executeQuery();
int jumlah = 0;
if (rs.next()) {
	jumlah = rs.getInt("jumlah");
}
rs.close();
pstmt.close();
sql = null;
rs = null;
pstmt = null;


int cur_page = 1;
if (request.getParameter("cur_page") != null) {
	cur_page = Integer.parseInt(request.getParameter("cur_page"));
}
int row_per_page = 50;
int start_row = (cur_page-1) * row_per_page + 1;
int end_row = start_row + row_per_page - 1;
int total_page = (jumlah / row_per_page) +1;
if (jumlah % row_per_page == 0) {
	total_page--;
}
out.println("Page : ");
int minPaging = cur_page - 5;
if (minPaging < 1) {
	minPaging = 1;
}
int maxPaging = cur_page + 5;
if (maxPaging > total_page) {
	maxPaging = total_page;
}
if (minPaging - 1 > 0) {
	out.print("<a class='link' href='?cur_page=" + (minPaging - 1) + "&merchant_name="+merchant_name+"&dari="+dari+"&ampe="+ampe+"'>&lt;</a> ");
}
for (int i=minPaging; i<=maxPaging;i++) {
	if (i == cur_page) {
		out.print(i + " ");
	} else {
		out.print("<a class='link' href='?cur_page=" + i + "&merchant_name="+merchant_name+"&dari="+dari+"&ampe="+ampe+"'>" + i + "</a> ");
	}
}
if (maxPaging + 1 <= total_page) {
	out.print("<a class='link' href='?cur_page=" + (maxPaging + 1) + "&merchant_name="+merchant_name+"&dari="+dari+"&ampe="+ampe+"'>&gt;</a> ");
}

// end of paging stuff


		 	sql ="select * FROM (select a.*, ROWNUM rnum from (" +  
		 							"select deposit_time, is_executed,deposit_id,name,mc.amount,mc.doc_number,mc.note from merchant m,merchant_info mi,merchant_deposit mc where m.merchant_info_id = mi.merchant_info_id and m.merchant_id = mc.merchant_id and LOWER(name) like '%"+merchant_name.toLowerCase()+"%' and ( deposit_time between to_date('"+dari+" 00:00:00', 'DD-MM-YYYY HH24:MI:SS') and to_date('"+ampe+" 23:59:59', 'DD-MM-YYYY HH24:MI:SS')) order by deposit_time desc" +
		 							" ) a where ROWNUM <= ?) where rnum >= ?";
			//out.print(sql);
			pstmt = conn.prepareStatement(sql);
			pstmt.setInt(1,end_row);
			pstmt.setInt(2,start_row);
			rs = pstmt.executeQuery();
			
			while (rs.next()) {
				%>
          <tr> 
            <td bgcolor="#EEEEEE">
              <div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("deposit_id")%></font></div>
            </td>
            <td bgcolor="#EEEEEE"> 
              <div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("name")%></font></div>
            </td>
            <td bgcolor="#EEEEEE"> 
              <div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= nf.format(rs.getLong("amount"))%></font></div>
            </td>
            <td bgcolor="#EEEEEE"> 
              <div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("deposit_time")%></font></div>
            </td>
            <td bgcolor="#EEEEEE"> 
              <div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("doc_number")%></font></div>
            </td>
            <td bgcolor="#EEEEEE"> 
              <div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("note")%></font></div>
            </td>
            <td bgcolor="#EEEEEE"> 
              <div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= (rs.getString("is_executed").equals("1")) ? "Yes" : "No"%></font></div>
            </td>
            <td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif">&nbsp;<a target='_brandnewdeposit' href="print_deposit.jsp?id=<%= rs.getString("deposit_id")%>">print</a></font></div></td>

          </tr>
          <%
			}
			pstmt.close();
			rs.close();
		  %>
        </table>
		 
        <br>
        <br>
        <br>
		

		 
        <br>
  </table>
<%	}
  	 catch(Exception  e){
			e.printStackTrace(System.out);
		} finally{
		try { conn.close(); } catch(Exception ee){}
		}
	
%>
	</stripes:layout-component>
</stripes:layout-render>

<%
	} else {
		response.sendRedirect("admin.html");
	}
%>
