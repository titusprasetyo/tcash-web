<%@ page import="java.sql.*, java.util.Date, java.text.SimpleDateFormat"%>
<%@ include file="/web-starter/taglibs.jsp"%>
<%@page import="com.telkomsel.itvas.webstarter.User"%>
<jsp:useBean id="DbCon" scope="page" class="tsel_tunai.DbCon"></jsp:useBean>
<jsp:useBean id="DS" scope="page" class="tsel_tunai.DailySettlement"></jsp:useBean>
<script language="JavaScript">
<!--
function calendar(output)
{
	newwin = window.open('cal.jsp','','top=150,left=150,width=145,height=130,resizable=no');
	if(!newwin.opener)
		newwin.opener = self;
}
//-->
</script>
<%
User user = (User)session.getValue("user");
String year = request.getParameter("year");
String holidate = request.getParameter("dari");
String note = request.getParameter("note");
String del = request.getParameter("del");
String select = request.getParameter("select");

Date d = null;
SimpleDateFormat sdf = null;

String query = null;
Connection conn = null;
Statement stmt = null;
PreparedStatement pstmt = null;
ResultSet rs = null;

if((select == null || select.equals("0")) && holidate != null)
{
	String [] _holidate = holidate.split("-");
	year = _holidate[2];
	
	if(del == null || del.equals(""))
	{
		DS.setYear(year);
		DS.setHolidate(holidate);
		DS.setNote(note);
		DS.resetHoliday();
		DS.insertHoliday();
		
		out.println("<script language='javascript'>alert('Configuration successful')</script>");
	}
	else
	{
		DS.setHolidate(holidate);
		DS.resetHoliday();
	}
	
	holidate = null;
}

try
{
	if(year == null || year.equals(""))
	{
		d = new Date();
		sdf = new SimpleDateFormat("yyyy");
		year = sdf.format(d);
	}
	
	if(holidate == null || holidate.equals(""))
	{
		d = new Date();
		sdf = new SimpleDateFormat("d-M-yyyy");
		holidate = sdf.format(d);
	}
	
	conn = DbCon.getConnection();
%>
<stripes:layout-render name="/web-starter/layout/standard.jsp" title="Holiday Management">
	<stripes:layout-component name="contents">
		<form name="formini" method="post" action="dsettle_holiday.jsp">
		<input type="hidden" name="select" id="select" value="0">
		<table width="30%" border="0" cellspacing="1" cellpadding="1">
		<tr bgcolor="#CC6633">
			<td colspan="2"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>Configuration</strong></font></div></td>
		</tr>
		<tr>
			<td><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Date</strong></font></td>
			<td><input type="text" name="dari" value="<%= holidate%>" readonly="true"><a href="javascript:calendar('opener.document.formini.dari.value');"><img src="${pageContext.request.contextPath}/STATIC/cal.gif" alt="Calendar" border="0" align="absmiddle"></a></td>
		</tr>
		<tr>
			<td><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Note</strong></font></td>
			<td><textarea name="note" cols="20"></textarea></td>
		</tr>
		<tr>
			<td></td>
			<td><input type="submit" name="Submit" value="Update" onclick="document.getElementById('select').value = '0';"></td>
		</tr>
		</table>
		<br>
		<table width="50%" border="1" cellspacing="0" cellpadding="0" bordercolor="#FFF6EF">
		<tr>
			<td colspan="3"><div align="right"><font color="#CC6633" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>.:: Existing Configuration</strong></font></div></td>
		</tr>
		<tr>
			<td><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Select Year</strong></font></td>
			<td>
				<select name="year" onchange="document.getElementById('select').value = '1'; this.form.submit();">
<%
	query = "SELECT DISTINCT(year) FROM holiday ORDER BY year DESC";
	stmt = conn.createStatement();
	rs = stmt.executeQuery(query);
	while(rs.next())
	{
		if(rs.getString("year").equals(year))
			out.println("<option value='" + rs.getString("year") + "' selected>" + rs.getString("year") + "</option>");
		else
			out.println("<option value='" + rs.getString("year") + "'>" + rs.getString("year") + "</option>");
	}
%>
				</select>
			</td>
			<td></td>
		</tr>
		<tr>
			<td colspan="3"></td>
		</tr>
		<tr>
			<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Date</strong></font></div></td>
			<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Note</strong></font></div></td>
			<td bgcolor="#CC6633"></td>
		</tr>
<%
	query = "SELECT holidate, note FROM holiday WHERE year = ? ORDER BY holidate ASC";
	pstmt = conn.prepareStatement(query);
	pstmt.clearParameters();
	pstmt.setString(1, year);
	rs = pstmt.executeQuery();
	while(rs.next())
	{
		String [] _tdate = rs.getString("holidate").split(" ");
		String [] _tdate1 = _tdate[0].split("-");
		String tdate = _tdate1[2] + "-" + _tdate1[1] + "-" + _tdate1[0];
%>
		<tr>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= tdate%></font></div></td>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("note")%></font></div></td>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><a href="dsettle_holiday.jsp?dari=<%= tdate%>&del=1&select=0" onclick="return checkDelete();" class="link">delete</a></font></div></td>
		</tr>
<%
	}
	
	pstmt.close();
	rs.close();
%>
		</table>
		</form>
	</stripes:layout-component>
</stripes:layout-render>

<%
}
catch(Exception e)
{
	e.printStackTrace(System.out);
}
finally
{
	try
	{
		conn.close();
	}
	catch(Exception ee)
	{
	}
}
%>