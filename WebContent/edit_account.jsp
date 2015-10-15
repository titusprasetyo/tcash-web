<%@ page import="java.sql.*"%>
<%@ include file="/web-starter/taglibs.jsp" %>
<stripes:layout-render name="/web-starter/layout/standard.jsp" title="Edit Account">
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
	
   
	String stat = request.getParameter("stat");
	String username = request.getParameter("username");
	if (stat.equals("0")) {
	
	} else  if (stat.equals("1")){
		out.println( "<SCRIPT LANGUAGE=javascript> alert('username and password cannot be empty');</SCRIPT>" );
	} else if (stat.equals("2")) {
		out.println( "<SCRIPT LANGUAGE=javascript> alert('password length must be 8 characters min. ');</SCRIPT>" );
	} else if (stat.equals("3")) {
		out.println( "<SCRIPT LANGUAGE=javascript> alert('username has been used previously ');</SCRIPT>" );
		//out.println( "<SCRIPT LANGUAGE=javascript> alert('password has been used in 12 your password history , try to create another password');</SCRIPT>" );
	} else if (stat.equals("4")) {
		out.println( "<SCRIPT LANGUAGE=javascript> alert('Password Must include special character and alphanumeric (a-z, A-Z,0-9,* ! @ #.. *)');</SCRIPT>" );
	} else if (stat.equals("5")) {
			out.println( "<SCRIPT LANGUAGE=javascript> alert('User Has Been Succeccfully Edited ');</SCRIPT>" );
	}
	else if (stat.equals("6")) {
			out.println( "<SCRIPT LANGUAGE=javascript> alert('Password Has Been used on your 12 Password History!');</SCRIPT>" );
	}
	
	
	%>
        <br>
        <%
			//query data
			Connection conn = null;
			conn = DbCon.getConnection();
			try {
				String sql = "select * from admin where username = ? ";
				PreparedStatement pstmt = conn.prepareStatement(sql);
				pstmt.setString(1,username);
				ResultSet rs = pstmt.executeQuery();
				while (rs.next()) {			
		%>
        <table width="27%" border="0" cellspacing="0" cellpadding="0">
          <form name="form" method="post" action="edit_account_eksekusi.jsp">
            <tr bgcolor="#CC6633"> 
              <td colspan="2"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>Edit 
                  Account </strong></font></div></td>
            </tr>
            <tr> 
              <td width="46%"><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Username</strong></font></td>
              <td width="54%"> <input name="username" type="text" value="<%= rs.getString("username")%>"> 
			 	<input type="hidden" name="log" value="<%= rs.getString("username")%>">	
			  </td>
            </tr>
            <tr> 
              <td><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Password</strong></font></td>
              <td width="54%"><input name="password" type="password" value="<%= rs.getString("password")%>"></td>
              <td width="54%"><input type="checkbox" name="checkbox" value="checkbox"></td>
            </tr>
            <tr> 
              <td><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Akses</strong></font></td>
              <td><select name="akses">
                  <option value="admin" <%= (rs.getString("akses").equals("admin")) ? "selected" : ""%>>admin</option>
									<option value="user" <%= (rs.getString("akses").equals("user")) ? "selected" : ""%>>Customer Care</option>
                  <option value="finance" <%= (rs.getString("akses").equals("finance")) ? "selected" : ""%>>Finance</option>
                </select></td>
            </tr>
			<tr> 
              <td><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Status</strong></font></td>
              <td><select name="status">
                  <option value="ACT" <%= (rs.getString("status").equals("ACT")) ? "selected" : ""%>>ACT</option>
                  <option value="LOCKED" <%= (rs.getString("status").equals("LOCKED")) ? "selected" : ""%>>LOCKED</option>
                </select></td>
            </tr>
            <tr>
              <td>&nbsp;</td>
              <td><input type="submit" name="Submit" value="Edit"></td>
            </tr>
          </form>
        </table>
		
		<%
				}
			}
			catch(Exception  e){
				e.printStackTrace(System.out);
			} finally{
				try { conn.close(); } catch(Exception ee){}
			}
		%>
		<font color="#CC6633" size="1" face="Verdana, Arial, Helvetica, sans-serif">Password 
        Minimum 8 Characters, <em>example : username : Tetra, Password : Tsel*2007 
        </em>--&gt; <em>include special characters</em></font><br>
        <br>
        <br>
        <br>
        <table width="40%" border="0" cellspacing="0" cellpadding="0">
          <tr> 
            <td><div align="center"><font color="#CC6633" size="1" face="Verdana, Arial, Helvetica, sans-serif">Sebelum 
                anda keluar dari layanan ini pastikan anda telah logout agar login 
                anda tidak dapat dipakai oleh orang lain.</font></div></td>
          </tr>
        </table>
		 
        <br>
      </td>
    </stripes:layout-component>
</stripes:layout-render>
