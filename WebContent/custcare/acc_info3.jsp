<%@ include file="/web-starter/taglibs.jsp" %>
<%@ page import="java.sql.*"%>
<jsp:useBean id="DbCon" scope="page" class="tsel_tunai.DbCon"></jsp:useBean>
<%@page import="com.telkomsel.itvas.webstarter.User"%>
<stripes:layout-render name="/web-starter/layout/standard.jsp" title="Edit Account">
	<stripes:layout-component name="contents">
		<link rel="stylesheet" href="my.css" type="text/css">

<%
String msisdn = (String)session.getValue("msisdn");
String acc_no = (String)session.getValue("acc_no");

Connection con = null;
PreparedStatement ps = null;
ResultSet rs = null;
String sql = "";
String cust_info_id = "";
String stat = "";
String status = "";
String status2 = "";
boolean b1 = false;

try
{
	con = DbCon.getConnection();
	sql = "select c.acc_no, c.cust_info_id, t.status from customer c, tsel_cust_account t where c.msisdn = ? and c.acc_no = t.acc_no";
	ps = con.prepareStatement(sql);
	ps.clearParameters();
	ps.setString(1, msisdn);
	rs = ps.executeQuery();	
	if(rs.next())
	{
		acc_no = rs.getString("acc_no");
		cust_info_id = rs.getString("cust_info_id");
		stat = rs.getString("status");	
		b1 = true;
	}
	else
		out.print("account_not_found");
	
	rs.close();
	ps.close();
	
	session.putValue("cust_info_id", cust_info_id);
	session.putValue("cur_status", stat);
	
	if(stat != null && stat.equals("1"))
	{
		status2 = "";
		status = "selected";
	}
	else
	{
		status = "";
		status2 = "selected";
		stat = "0";
	}
	
	if(b1)
	{
		sql = "select * from customer_info where cust_info_id = ?";
		ps = con.prepareStatement(sql);
		ps.clearParameters();
		ps.setString(1, cust_info_id);
		rs = ps.executeQuery();
		if(rs.next())
		{
%>

		<form action="acc_info4.jsp" method="post">
		<table width="48%" border="0" cellspacing="3" cellpadding="3">
			<tr>
				<td class="unnamed1" width="30%">Name</td>
				<td class="unnamed1" width="70%">: <input type="text" name="name" class="box_text" size="40" value="<%= rs.getString("name") %>"></td>
			</tr>
			<tr>
				<td class="unnamed1" width="30%">Address</td>
				<td class="unnamed1" width="70%">: <textarea name="address" class="box_text" cols="36"><%= rs.getString("address") %></textarea></td>
			</tr>
			<tr>
				<td class="unnamed1" width="30%">City</td>
				<td class="unnamed1" width="70%">: <input type="text" name="city" class="box_text" size="40" value="<%= rs.getString("city") %>"></td>
			</tr>
			<tr>
				<td class="unnamed1" width="30%">Zipcode</td>
				<td class="unnamed1" width="70%">: <input type="text" name="zipcode" class="box_text" size="40" value="<%= rs.getString("zipcode") %>"></td>
			</tr>
			<tr>
				<td class="unnamed1" width="30%">Phone number</td>
				<td class="unnamed1" width="70%">: <input type="text" name="phonenum" class="box_text" size="40" value="<%= rs.getString("phone_num") %>"></td>
			</tr>
			<tr>
				<td class="unnamed1" width="30%">Msisdn</td>
				<td class="unnamed1" width="70%">: <%= msisdn %></td>
			</tr>
			<tr>
				<td class="unnamed1" width="30%">Status</td>
				<td class="unnamed1" width="70%">:
					<select name="status" class="box_text">
						<option value="1" <%= status %>>active</option>
						<option value="0" <%= status2 %>>block</option>
					</select>
				</td>
			</tr>
			<tr>
				<td class="unnamed1" width="30%">ID number</td>
				<td class="unnamed1" width="70%">: <input type="text" name="ktpno" class="box_text" size="40" value="<%= rs.getString("ktp_no") %>"></td>
			</tr>
			<tr>
				<td class="unnamed1" width="30%">Birthdate</td>
				<td class="unnamed1" width="70%">: <%= rs.getString("birthdate") %></td>
			</tr>
			<tr>
				<td class="unnamed1" width="30%">Birthcity</td>
				<td class="unnamed1" width="70%">: <%= rs.getString("birthcity") %></td>
			</tr>
			<tr>
				<td class="unnamed1" width="30%">Mother Name</td>
				<td class="unnamed1" width="70%">: <input type="text" name="mother" class="box_text" size="40" value="<%= rs.getString("mother") %>"></td>
			</tr>
			<tr>
				<td class="unnamed1" width="30%">&nbsp;</td>
				<td class="unnamed1" width="70%">&nbsp; </td>
			</tr>
			<tr>
      	<td class="unnamed1" colspan="2">Make sure customer's Name, Birthdate, Mother's Name and Address are verified before SUBMIT INFO</td>
    	</tr>
			<tr>
				<td class="unnamed1" width="30%">&nbsp;</td>
				<td class="unnamed1" width="70%"><input type="submit" name="Submit" value="    Submit    "></td>
			</tr>
		</table>
		</form>

<%
		}
		else
			out.print("account_not_found");
		
		rs.close();
		ps.close();
	}
}
catch(Exception e)
{
	e.printStackTrace(System.out);
}
finally
{
	if(con != null)
	{
		try
		{
			con.close();
		}
		catch(Exception e2)
		{
		}
	}
}
%>

	</stripes:layout-component>
</stripes:layout-render>
