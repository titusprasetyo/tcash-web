<%@ page import="java.sql.*, java.text.NumberFormat, java.util.Locale"%>
<%@ include file="/web-starter/taglibs.jsp"%>
<%@page import="com.telkomsel.itvas.webstarter.User"%>
<%@page import="com.telkomsel.itvas.webstarter.WebStarterProperties"%>
<jsp:useBean id="DbCon" scope="page" class="tsel_tunai.DbCon"></jsp:useBean>
<jsp:useBean id="DS" scope="page" class="tsel_tunai.DailySettlement"></jsp:useBean>
<script language="JavaScript">
<!--
function validate(msisdn)
{
	var s = "unknown";
	var ichar = null;
	var b = true;
	var num = "+0123456789";
	var prefix = "|62811|62812|62813|62852|62853|"
	
	for(i = 0; i < msisdn.length; i++)
	{
		ichar = msisdn.charAt(i);
		if(num.indexOf(ichar) == -1)
		{
			b = false;
			break;
		}
	}
	
	if(b)
	{
		if(msisdn.match("^\\+628") == "+628")
			msisdn = msisdn.substring(1);
		else if(msisdn.match("^08") == "08")
			msisdn = "62" + msisdn.substring(1);
		else if(msisdn.match("^8") == "8")
			msisdn = "62" + msisdn;
		else if(msisdn.match("^628") == "628")
			msisdn = msisdn;
		else
			msisdn = s;
		
		if(msisdn.length >= 11 && msisdn.length <= 13 && prefix.indexOf("|" + msisdn.substring(0, 5) + "|") != -1)
			s = msisdn;
	}
	
	return s;
}

function move(type)
{
	var dest = document.getElementById("dest");
	if(type == "all")
	{
		for(i = 0; i < dest.length; i++)
			dest.options[i].selected = true;
	}
	else if(type == "del")
	{
		for(i = 0; i < dest.length; i++)
		{
			if(dest.options[i].selected)
			{
				dest.options[i] = null;
				break;
			}
		}
	}
	else
	{
		var msisdn = document.getElementById("msisdn").value;
		msisdn = validate(msisdn);
		if(msisdn != null && msisdn != "" && msisdn != "unknown")
		{
			with(dest)
			{
				var isExist = false;
				for(i = 0; i < options.length; i++)
				{
					if(options[i] != null && options[i].value == msisdn)
					{
						isExist = true;
						break;
					}
				}
				
				if(!isExist)
					options[options.length] = new Option(msisdn, msisdn);
			}
		}
		else
			alert("Invalid MSISDN, please input correct one");
	}
}
//-->
</script>
<%
User user = (User)session.getValue("user");
String merchant = request.getParameter("merchant");
String threshold_in = request.getParameter("threshold_in");
String threshold_out = request.getParameter("threshold_out");
String fine_in = request.getParameter("fine_in");
String fine_out = request.getParameter("fine_out");
String [] _cycle = request.getParameterValues("cycle");
String [] _receiver = request.getParameterValues("dest");
String select = request.getParameter("select");
String del = request.getParameter("del");

String cycle_conf = WebStarterProperties.getInstance().getProperty("settlement.cycle");

String threshold_in_db = "";
String threshold_out_db = "";
String fine_in_db = "";
String fine_out_db = "";
String cycle_db = "";
String receiver_db = "";

String query = null;
Connection conn = null;
Statement stmt = null;
ResultSet rs = null;

NumberFormat nf =  NumberFormat.getInstance(Locale.ITALY);

if(merchant == null)
	merchant = "";
if(cycle_conf.startsWith("|"))
	cycle_conf = cycle_conf.substring(1);

if(!merchant.equals(""))
{
	DS.setId(merchant);
	DS.setThresholdIn(threshold_in);
	DS.setThresholdOut(threshold_out);
	DS.setFineIn(fine_in);
	DS.setFineOut(fine_out);
	DS.setCycle(_cycle);
	DS.setReceiver(_receiver);
	
	if(del != null && del.equals("1"))
	{
		DS.resetConf();
		DS.updateType("deposit");
		merchant = "";
	}
	else
	{
		if(select != null && select.equals("1"))
		{
			String [] _conf = DS.getConf();
			threshold_in_db = _conf[0];
			threshold_out_db = _conf[1];
			fine_in_db = _conf[2];
			fine_out_db = _conf[3];
			cycle_db = _conf[4];
			receiver_db = _conf[5];
		}
		else
		{
			String validate = DS.validateInput();
			if(validate.equals(""))
			{
				DS.resetConf();
				DS.insertConf();
				DS.updateType("daily");
				out.println("<script language='javascript'>alert('Configuration successful')</script>");
			}
			else
				out.println("<script language='javascript'>alert('Configuration failed: " + validate + "')</script>");
			
			merchant = "";
		}
	}
}

try
{
	conn = DbCon.getConnection();
%>
<stripes:layout-render name="/web-starter/layout/standard.jsp" title="Daily Settlement Configuration">
	<stripes:layout-component name="contents">
		<form name="form" method="post" action="dsettle_config.jsp">
		<input type="hidden" name="select" id="select" value="0">
		<table width="40%" border="0" cellspacing="1" cellpadding="1">
		<tr bgcolor="#CC6633">
			<td colspan="2"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>Configuration</strong></font></div></td>
		</tr>
		<tr>
			<td><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Merchant</strong></font></td>
			<td>
				<select name="merchant" onchange="document.getElementById('select').value = '1'; this.form.submit()">
					<option value=''></option>
<%
	query = "SELECT a.merchant_id, b.name FROM merchant a, merchant_info b, tsel_merchant_account c WHERE a.merchant_info_id = b.merchant_info_id AND a.status= 'A' AND c.acc_no=a.acc_no AND c.type='daily' ORDER BY merchant_id";
	stmt = conn.createStatement();
	rs = stmt.executeQuery(query);
	while(rs.next())
	{
		if(rs.getString("merchant_id").equals(merchant))
			out.println("<option value='" + rs.getString("merchant_id") + "' selected>" + rs.getString("name") + "</option>");
		else
			out.println("<option value='" + rs.getString("merchant_id") + "'>" + rs.getString("name") + "</option>");
	}

	stmt.close();
	rs.close();
%>
				</select>
			</td>
		</tr>
		<tr>
			<td><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Threshold In</strong></font></td>
			<td><input type="text" name="threshold_in" width="200" value="<%= threshold_in_db%>"><font color="#CC6633" size="1" face="Verdana, Arial, Helvetica, sans-serif">&nbsp;IDR</font></td>
		</tr>
		<tr>
			<td><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Threshold Out</strong></font></td>
			<td><input type="text" name="threshold_out" width="200" value="<%= threshold_out_db%>"><font color="#CC6633" size="1" face="Verdana, Arial, Helvetica, sans-serif">&nbsp;IDR</font></td>
		</tr>
		<!--
		<tr>
			<td><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Fine In</strong></font></td>
			<td><input type="text" name="fine_in" width="200" value="<%= fine_in_db%>"></td>
		</tr>
		<tr>
			<td><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Fine Out</strong></font></td>
			<td><input type="text" name="fine_out" width="200" value="<%= fine_out_db%>"></td>
		</tr>
		-->
		<tr>
			<td><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Settlement Cycle</strong></font></td>
			<td>
<%
	String [] _cycle_conf = cycle_conf.split("\\|");
	String [] _cycle_db = cycle_db.split(";");
	for(int i = 0; i < _cycle_conf.length; i++)
	{
		String checked = "";
		for(int j = 0; j < _cycle_db.length; j++)
		{
			if(_cycle_conf[i].equals(_cycle_db[j]))
			{
				checked = "checked";
				break;
			}
		}
%>
				<input type="checkbox" name="cycle" value="<%= _cycle_conf[i]%>" <%= checked%>><font color="#CC6633" size="1" face="Verdana, Arial, Helvetica, sans-serif">SC-<%= _cycle_conf[i]%></font><br>
<%
	}
%>
			</td>
		</tr>
		<tr>
			<td colspan="2"><br><font color="#CC6633" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Alert Management</strong></font></td>
		</tr>
		<tr>
			<td><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>MSISDN</strong></font></td>
			<td><input type="text" name="msisdn" width="200" value="628"></td>
		</tr>
		<tr>
			<td></td>
			<td><input type="button" name="add" value=" Add " onclick="move('add')">&nbsp;<input type="button" name="del" value=" Del " onclick="move('del')"></td>
		</tr>
		<tr>
			<td></td>
			<td>
				<select name="dest" id="dest" size="5" multiple>
<%
	if(receiver_db != null && !receiver_db.equals(""))
	{
		String [] _receiver_db = receiver_db.split(";");
		for(int i = 0; i < _receiver_db.length; i++)
			out.println("<option value='" + _receiver_db[i] + "'>" + _receiver_db[i] + "</option>");
	}
%>
				</select>
			</td>
		</tr>
		<tr>
			<td></td>
			<td><input type="submit" name="Submit" value="Update" onclick="move('all')">&nbsp;<input type="button" name="reset" value="Reset" onclick="document.getElementById('select').value = '1'; this.form.submit()"></td>
		</tr>
		</table>
		</form>
		<br>
		<table width="90%" border="1" cellspacing="0" cellpadding="0" bordercolor="#FFF6EF">
		<tr>
			<td colspan="7"><div align="right"><font color="#CC6633" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>.:: Existing Configuration</strong></font></div></td>
		</tr>
		<tr>
			<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Name</strong></font></div></td>
            <td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Threshold In</strong></font></div></td>
            <td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Threshold Out</strong></font></div></td>
            <!--
			<td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Fine In</strong></font></div></td>
            <td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Fine Out</strong></font></div></td>
			-->
            <td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>SC</strong></font></div></td>
            <td bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Alert Receiver</strong></font></div></td>
            <td bgcolor="#CC6633" colspan="2"></td>
		</tr>
<%
	query = "SELECT a.name, b.threshold_in, b.threshold_out, b.fine_in, b.fine_out, b.cycle, b.alert_receiver, c.merchant_id FROM merchant_info a, settlement_conf b, merchant c WHERE a.merchant_info_id = c.merchant_info_id AND c.merchant_id = b.merchant_id ORDER BY merchant_id";
	stmt = conn.createStatement();
	rs = stmt.executeQuery(query);
	while(rs.next())
	{
		String shown_fine_in = rs.getString("fine_in");
		String shown_fine_out = rs.getString("fine_out");
		String shown_receiver = rs.getString("alert_receiver");
		
		/*
		if(shown_fine_in.indexOf("%") == -1)
			shown_fine_in = nf.format(Long.parseLong(shown_fine_in));
		if(shown_fine_out.indexOf("%") == -1)
			shown_fine_out = nf.format(Long.parseLong(shown_fine_out));
		*/
		
		if(shown_receiver == null)
			shown_receiver = "";
		else if(shown_receiver.length() > 30)
			shown_receiver = shown_receiver.substring(0, 30) + "...";
%>
		<tr>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("name")%></font></div></td>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= nf.format(rs.getLong("threshold_in"))%></font></div></td>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= nf.format(rs.getLong("threshold_out"))%></font></div></td>
			<!--
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= shown_fine_in%></font></div></td>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= shown_fine_out%></font></div></td>
			-->
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("cycle")%></font></div></td>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><%= shown_receiver%></font></div></td>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><a href="dsettle_config.jsp?merchant=<%= rs.getString("merchant_id")%>&select=1" class="link">edit</a></font></div></td>
			<td><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><a href="dsettle_config.jsp?merchant=<%= rs.getString("merchant_id")%>&del=1" onclick="return checkDelete();" class="link">delete</a></font></div></td>
		</tr>
<%
	}
	
	stmt.close();
	rs.close();
%>
		</table>
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
