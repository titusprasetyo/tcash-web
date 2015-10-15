<%@ page import="java.sql.*, tsel_tunai.*"%>
<%@ include file="/web-starter/taglibs.jsp" %>
<stripes:layout-render name="/web-starter/layout/standard.jsp" title="User List">
    <stripes:layout-component name="contents">
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
</script>
<jsp:useBean id="DbCon" scope="page" class="tsel_tunai.DbCon"></jsp:useBean>
<%
Connection conn = null; try{ conn = DbCon.getConnection(); %>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td width="7%" height="28">
		<div align="right"><font color="#CC6633" size="1"
			face="Verdana, Arial, Helvetica, sans-serif"></font></div>
		</td>

		<td>
		<div align="center"><font color="#CC3300" size="2"
			face="Verdana, Arial, Helvetica, sans-serif"> <strong>
		</strong></font></div>
		</td>
		<td width="7%">
		</td>
	</tr>
</table>



<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td>
		<div align="right"><font color="#CC6633" size="4"
			face="Verdana, Arial, Helvetica, sans-serif"><strong></strong></font></div>
		</td>
	</tr>

</table>


<table width="21%" border="0" cellspacing="0" cellpadding="0">
	<form name="form" method="post" action="admin.jsp">
	<tr bgcolor="#CC6633">
		<td colspan="2">
		<div align="center"><font color="#FFFFFF" size="1"
			face="Verdana, Arial, Helvetica, sans-serif"><strong>Search
		User </strong></font></div>
		</td>
	</tr>
	<tr>
		<td width="30%"><input type="submit" name="Submit" value="Submit"></td>
		<td><input name="username" type="text"></td>
	</tr>
	</form>
</table>

<br>

<table width="80%" border="1" cellspacing="0" cellpadding="0"
	bordercolor="#FFF6EF">
	<tr bgcolor="#FFF6EF">
		<td colspan="9">
		<div align="right"><font color="#CC6633" size="2"
			face="Verdana, Arial, Helvetica, sans-serif"><strong>.::
		List Account User</strong></font></div>
		</td>
	</tr>
	<tr>
		<td bgcolor="#CC6633">
		<div align="center"><font color="#FFFFFF" size="1"
			face="Verdana, Arial, Helvetica, sans-serif"><strong>Username</strong></font></div>
		</td>
		<td bgcolor="#CC6633">
		<div align="center"><font color="#FFFFFF" size="1"
			face="Verdana, Arial, Helvetica, sans-serif"><strong>Expired
		Date </strong></font></div>
		</td>
		<td bgcolor="#CC6633">
		<div align="center"><font color="#FFFFFF" size="1"
			face="Verdana, Arial, Helvetica, sans-serif"><strong>Login
		Error </strong></font></div>
		</td>
		<td bgcolor="#CC6633">
		<div align="center"><font color="#FFFFFF" size="1"
			face="Verdana, Arial, Helvetica, sans-serif"><strong>Maximum
		Login </strong></font></div>
		</td>
		<td bgcolor="#CC6633">
		<div align="center"><font color="#FFFFFF" size="1"
			face="Verdana, Arial, Helvetica, sans-serif"><strong>Status</strong></font></div>
		</td>
		<td bgcolor="#CC6633">
		<div align="center"><font color="#FFFFFF" size="1"
			face="Verdana, Arial, Helvetica, sans-serif"><strong>Akses</strong></font></div>
		</td>
		<td bgcolor="#CC6633">
		<div align="center"><font color="#FFFFFF" size="1"
			face="Verdana, Arial, Helvetica, sans-serif"><strong>Edit</strong></font></div>
		</td>
		<td bgcolor="#CC6633">
		<div align="center"><font color="#FFFFFF" size="1"
			face="Verdana, Arial, Helvetica, sans-serif"><strong>Delete</strong></font></div>
		</td>
	</tr>
	<%
		  	String search = request.getParameter("username");
			if (search == null) {
				search = "";
			}
		 	String sql = "select *from admin where username like '%"+search+"%'"; 
			//out.print(sql);
			PreparedStatement pstmt = conn.prepareStatement(sql);
			ResultSet rs = pstmt.executeQuery();
			
			while (rs.next()) {
				%>
	<tr>
		<td bgcolor="#CCCCCC">
		<div align="center"><font color="black" size="1"
			face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("username")%></font></div>
		</td>
		<td bgcolor="#CCCCCC">
		<div align="center"><font color="black" size="1"
			face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("exp_date")%></font></div>
		</td>
		<td bgcolor="#CCCCCC">
		<div align="center"><font color="black" size="1"
			face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("login_err")%></font></div>
		</td>
		<td bgcolor="#CCCCCC">
		<div align="center"><font color="black" size="1"
			face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("max_login")%></font></div>
		</td>
		<td bgcolor="#CCCCCC">
		<div align="center"><font color="black" size="1"
			face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("status")%></font></div>
		</td>
		<td bgcolor="#CCCCCC">
		<div align="center"><font color="black" size="1"
			face="Verdana, Arial, Helvetica, sans-serif"><%= rs.getString("akses")%></font></div>
		</td>
		<td bgcolor="#CCCCCC">
		<div align="center"><font color="black" size="1"
			face="Verdana, Arial, Helvetica, sans-serif"><a
			href="edit_account.jsp?stat=0&username=<%= rs.getString("username")%>"
			class="link">edit</a></font></div>
		</td>
		<td bgcolor="#CCCCCC">
		<div align="center"><font color="black" size="1"
			face="Verdana, Arial, Helvetica, sans-serif"><a
			href="delete.jsp?username=<%= rs.getString("username")%>"
			onClick="return checkDelete();" class="link">delete</a></font></div>
		</td>
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

<table width="40%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td>
		<div align="center"><font color="#CC6633" size="1"
			face="Verdana, Arial, Helvetica, sans-serif">Sebelum anda
		keluar dari layanan ini pastikan anda telah logout agar login anda
		tidak dapat dipakai oleh orang lain.</font></div>
		</td>
	</tr>
</table>


<br>
</td>
</tr>
<tr>
	<td valign="top" bgcolor="#CC6633">
	<div align="right"><font color="#FFFFFF" size="1"
		face="Verdana, Arial, Helvetica, sans-serif"></font></div>
	</td>
	<td valign="top" bgcolor="#CC6633">
	<div align="right"><font color="#FFFFFF" size="1"
		face="Verdana, Arial, Helvetica, sans-serif"><strong>IT
	VAS Development 2007</strong></font></div>
	</td>
</tr>
<%	}
  	 catch(Exception  e){
			e.printStackTrace(System.out);
		} finally{
		try { conn.close(); } catch(Exception ee){}
		}
	
%>
    </stripes:layout-component>
</stripes:layout-render>