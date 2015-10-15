<%@ page import="java.sql.*"%>
<jsp:useBean id="DbCon" scope="page" class="tsel_tunai.DbCon"></jsp:useBean>
<%@ include file="/web-starter/taglibs.jsp"%>
<stripes:layout-render name="/web-starter/layout/standard.jsp" title="Deposit List">
	<stripes:layout-component name="contents">
<%
String idTicket = request.getParameter("id");
%>
<script language="JavaScript">
<!--
function checkDelete()
{
	with(document)
	{
		var checkStatus = confirm('Do you really want to close this ticket?');
		if (checkStatus)
		{
			checkStatus = true;
		}
		return checkStatus;
	}
}
//-->
</script>
<%
Connection con = null;
try {
String acc_no = "";
con = DbCon.getConnection();
%>
<form method=POST action='open_ticket.jsp'>
<table width="90%" border="0" cellspacing="3" cellpadding="3">
  <tr bgcolor="#CCCCCC"> 
    <td class="unnamed1" width="15%"> 
      <div align="left">Enter Solution</div>
    </td>
    <td width="75%" class="unnamed1"> 
      <div align="left"><textarea rows=5 cols=40 name='solution'></textarea></div>
    </td>
  </tr>
  <tr bgcolor="#CCCCCC"> 
    <td class="unnamed1" width="15%"> 
      <input type=submit value="Enter Solution">
    </td>
    <td width="75%" class="unnamed1"> 
      &nbsp;
    </td>
  </tr>
</table>
<input type=hidden name=id value='<%=idTicket%>'>
</form>
<%
}catch(Exception e){
e.printStackTrace(System.out);
} finally {
try { con.close(); }catch(Exception e2){}
}
%>

		</stripes:layout-component>
</stripes:layout-render>
