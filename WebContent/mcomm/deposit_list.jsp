<%@ page import="java.sql.*,java.util.*,java.text.*"%>
<jsp:useBean id="DbCon" scope="page" class="tsel_tunai.DbCon"></jsp:useBean>
<%@ include file="/web-starter/taglibs.jsp"%>
<stripes:layout-render name="/web-starter/layout/standard.jsp" title="Deposit List">
	<stripes:layout-component name="contents">
<script language="JavaScript">
<!--
function checkDelete()
{
	with(document)
	{
		var checkStatus = confirm('Do you really want to delete this deposit?');
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
NumberFormat nf =  NumberFormat.getInstance(Locale.ITALY);
String merchant = request.getParameter("merchant");
if (merchant == null) {
	merchant = "";
}
Connection con = null;
try {
String acc_no = "";
con = DbCon.getConnection();
String sql = "";
PreparedStatement ps = null;
ResultSet rs = null;

SimpleDateFormat myforma = new SimpleDateFormat("d-M-yyyy");
String param_dari = request.getParameter("dari");
if (param_dari == null) {
	param_dari = myforma.format(new java.util.Date());
}
String param_ampe = request.getParameter("ampe");
if (param_ampe == null) {
	param_ampe = myforma.format(new java.util.Date());
}
String test = request.getParameter("test");

// Paging stuff

sql = "select count(*) as jumlah from merchant_deposit a, merchant b, merchant_info c where a.merchant_id=b.merchant_id and b.merchant_info_id=c.merchant_info_id and ( deposit_time between to_date('"+param_dari+" 00:00:00', 'DD-MM-YYYY HH24:MI:SS') and to_date('"+param_ampe+" 23:59:59', 'DD-MM-YYYY HH24:MI:SS')) and LOWER(c.name) like '%" + merchant.toLowerCase() + "%'";
PreparedStatement pstmt = con.prepareStatement(sql);
rs = pstmt.executeQuery();
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
int row_per_page = 100;
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
	out.print("<a class='link' href='?cur_page=" + (minPaging - 1) + "&merchant=" + merchant + "&dari=" + param_dari + "&ampe=" + param_ampe + "'>&lt;</a> ");
}
for (int i=minPaging; i<=maxPaging;i++) {
	if (i == cur_page) {
		out.print(i + " ");
	} else {
		out.print("<a class='link' href='?cur_page=" + i + "&merchant=" + merchant + "&dari=" + param_dari + "&ampe=" + param_ampe + "'>" + i + "</a> ");
	}
}
if (maxPaging + 1 <= total_page) {
	out.print("<a class='link' href='?cur_page=" + (maxPaging + 1) + "&merchant=" + merchant + "&dari=" + param_dari + "&ampe=" + param_ampe + "'>&gt;</a> ");
}

// End of paging stuff

sql = "select * FROM (select a.*, ROWNUM rnum from (" +
	"select a.note, a.deposit_id, c.name, a.amount, a.doc_number, a.deposit_time, a.is_executed from merchant_deposit a, merchant b, merchant_info c where a.merchant_id=b.merchant_id and b.merchant_info_id=c.merchant_info_id and ( deposit_time between to_date('"+param_dari+" 00:00:00', 'DD-MM-YYYY HH24:MI:SS') and to_date('"+param_ampe+" 23:59:59', 'DD-MM-YYYY HH24:MI:SS')) and LOWER(c.name) like '%" + merchant.toLowerCase() + "%'order by deposit_time desc" +
	" ) a where ROWNUM <= ?) where rnum >= ?";

ps  = con.prepareStatement(sql);
ps.setInt(1,end_row);
ps.setInt(2,start_row);
rs = ps.executeQuery();
%>
<%
if (request.getParameter("msg") != null) {
	out.println("<center><strong>" + request.getParameter("msg") + "</strong></center>");
}
%>
<table width="32%" border="1" cellspacing="0" cellpadding="0">
		<%
			java.util.Date skr = new java.util.Date();
			SimpleDateFormat forma = new SimpleDateFormat("d-M-yyyy");
			String tdate = forma.format(skr);
			String dari = request.getParameter("dari");
			dari = (dari != null && !dari.equals("")) ? dari : tdate;
			String ampe = request.getParameter("ampe");
			ampe = (ampe != null && !ampe.equals("")) ? ampe : tdate;
		%>
          <form name="formini" method="post" action="deposit_list.jsp">
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
              <td height="15"><div align="center"><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif">Merchant</font></div></td>
              <td><div align="left"><input type="text" name="merchant" value="<%= merchant%>"> 
                  
                </div>
              </td>
            </tr>
            <tr> 
              <td width="30%" height="26"><input type="submit" name="Submit" value="Search"></td>
            </tr>
          </form>
        </table>
        <br><br>

<table width="80%" border="1" cellspacing="0" cellpadding="0" bordercolor="#FFF6EF">
<tr bgcolor="#FFF6EF"> 
  <td colspan="10"><div align="right"><font color="#CC6633" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>.:: 
      Deposit List</strong></font></div></td>
</tr>
<tr> 
  <td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Name</strong></font></div></td>
  <td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Amount</strong></font></div></td>
  <td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Doc. Number</strong></font></div></td>
  <td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Note</strong></font></div></td>
  <td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Executed</strong></font></div></td>
  <td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Deposit Time</strong></font></div></td>
  <td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Actions</strong></font></div></td>
</tr>

  <%
  	while(rs.next()) {
  %>
  <tr> 
  <td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("name")%></font></div></td>
  <td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("amount")%></font></div></td>
  <td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("doc_number")%></font></div></td>
  <td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("note")%></font></div></td>
  <td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= (rs.getString("is_executed").equals("1")) ? "Yes" : "No" %></font></div></td>
  <td bgcolor="#EEEEEE"><div align="center"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("deposit_time") %></font></div></td>
  <% if (rs.getString("is_executed").equals("1")) { %>
	<td bgcolor="#EEEEEE"><div align="center">-
    </td>
<% } else { %>
<td bgcolor="#EEEEEE"><font color="black" size="1" face="Verdana, Arial, Helvetica, sans-serif"><div align="center"><a href='deposit_entry.jsp?deposit_id=<%=rs.getString("deposit_id")%>'>edit</a>
    	<a href='deposit_delete.jsp?deposit_id=<%= rs.getString("deposit_id") %>' onClick="return checkDelete();">delete</a>
    </font></td>
<% } %>
  
   
  </tr>
  <% } %>
</table>
<%
rs.close();
ps.close();
}catch(Exception e){
e.printStackTrace(System.out);
} finally {
try { con.close(); }catch(Exception e2){}
}
%>
</td>
	
		</stripes:layout-component>
</stripes:layout-render>
