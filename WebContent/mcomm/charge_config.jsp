<%@ include file="/web-starter/taglibs.jsp"%>
<%@page import="com.telkomsel.itvas.webstarter.User"%>
<jsp:useBean id="MC" scope="page" class="tsel_tunai.MonthlyCharge"></jsp:useBean>
<script language="JavaScript">
<!--
function checkDelete()
{
	with(document)
	{
		var checkStatus = confirm('Do you really want to delete this member?');
		if(checkStatus)
		{
			checkStatus = true;
		}
		return checkStatus;
	}
}
//-->
</script>

<%
	User user = (User)session.getValue("user");
	String result = request.getParameter("result");
	String msg = request.getParameter("msg");

	String status = "";
	String amount = "";
	String edate = "";
	String maxdebt = "";

	if(result == null)
		result = "-1";
	if(msg == null)
		msg = "null";

	if(!result.equals("-1"))
	{
		if(result.equals("1"))
			out.println("<SCRIPT LANGUAGE=javascript>alert('Configuration successful');</SCRIPT>");
		else
			out.println("<SCRIPT LANGUAGE=javascript>alert('Configuration failed: " + msg + "');</SCRIPT>");
	}

	String [] _conf = MC.getConf();
	amount = _conf[1];
	edate = _conf[2];
	maxdebt = _conf[3];

	if(_conf[0].equals("1"))
		status = "ON";
	else if(_conf[0].equals("0"))
		status = "OFF";
%>

<stripes:layout-render name="/web-starter/layout/standard.jsp" title="Monthly Charge Configuration">
	<stripes:layout-component name="contents">
		<table width="33%" border="0" cellspacing="0" cellpadding="0">
		<form name="form" method="post" action="addConfig.jsp">
		<tr bgcolor="#CC6633">
			<td colspan="2">
				<div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>Configuration</strong></font></div>
			</td>
		</tr>
		<tr>
			<td>
				<font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Service Status</strong></font>
			</td>
			<td>
				<input name="status" type="radio" value="1" checked><font color="#CC6633" size="1" face="Verdana, Arial, Helvetica, sans-serif">ON&nbsp</font>
				<input name="status" type="radio" value="0"><font color="#CC6633" size="1" face="Verdana, Arial, Helvetica, sans-serif">OFF</font>
			</td>
		</tr>
		<tr>
			<td>
				<font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Charging Amount</strong></font>
			</td>
			<td>
				<input name="amount" type="text" width="200"><font color="#CC6633" size="1" face="Verdana, Arial, Helvetica, sans-serif">&nbspIDR</font>
			</td>
		</tr>
		<tr>
			<td>&nbsp;</td>
			<td><input type="submit" name="Submit" value="Update"></td>
		</tr>
		</form>
		</table>
		<br>
		<table width="33%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td colspan="2">
				<div><font color="#CC6633" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>Current Configuration</strong></font></div>
			</td>
		</tr>
		<tr>
			<td>
				<font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Service Status</strong></font>
			</td>
			<td>
				<font color="#CC6633" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong><%=status%></strong></font>
			</td>
		</tr>
		<tr>
			<td>
				<font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Charging Amount</strong></font>
			</td>
			<td>
				<font color="#CC6633" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong><%=amount%>&nbspIDR</strong></font>
			</td>
		</tr>
		<tr>
			<td>
				<font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Execution Date</strong></font>
			</td>
			<td>
				<font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong><%=edate%></strong></font>
			</td>
		</tr>
		<tr>
			<td>
				<font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Maximum Debt</strong></font>
			</td>
			<td>
				<font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong><%=maxdebt%></strong></font>
			</td>
		</tr>
		</table>
		<br>
		<br>
		<table width="40%" border="0" cellspacing="0" cellpadding="0">
			<tr>
				<td>
					<div align="center">
						<font color="#CC6633" size="1" face="Verdana, Arial, Helvetica, sans-serif">
							Sebelum anda keluar dari layanan ini pastikan anda telah logout agar login anda tidak dapat dipakai oleh orang lain.
						</font>
					</div>
				</td>
			</tr>
		</table>
	</stripes:layout-component>
</stripes:layout-render>