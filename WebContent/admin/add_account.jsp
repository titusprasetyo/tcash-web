<%@ page import="java.sql.*"%>
<%@ include file="/web-starter/taglibs.jsp" %>
<%@page import="com.telkomsel.itvas.webstarter.User"%>
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

<%
	User user = (User)session.getValue("user");
%>
<jsp:useBean id="DbCon" scope="page" class="tsel_tunai.DbCon"></jsp:useBean>
	  <%
	
   
	String stat = request.getParameter("stat");
	if (stat == null) {
		stat = "0";
	}
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
			out.println( "<SCRIPT LANGUAGE=javascript> alert('User Has Been Succeccfully Added ');</SCRIPT>" );
	}
	
	Connection conn = null;
	try{
		
		//Class.forName("oracle.jdbc.driver.OracleDriver");
		//String url = "jdnc:oracle:thin:localhost:1521:ORCL";
		conn = DbCon.getConnection();
		//Statement stmt1 = conn.createStatement();
	%>
        <br>
        <table width="27%" border="0" cellspacing="0" cellpadding="0">
          <form name="form" method="post" action="add_account_eksekusi.jsp">
            <tr bgcolor="#CC6633"> 
              <td colspan="2"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>Add 
                  Account </strong></font></div></td>
            </tr>
            <tr> 
              <td width="46%"><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Username</strong></font></td>
              <td width="54%"> <input name="username" type="text"> </td>
            </tr>
            <tr> 
              <td><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Password</strong></font></td>
              <td width="54%"><input name="password" type="password"></td>
            </tr>
            <tr> 
              <td><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Access</strong></font></td>
              <td><select name="akses">
                  <option value="admin">admin</option>
                  <option value="user">Customer Care</option>
                  <option value="finance">Finance</option>
                </select></td>
            </tr>
            <tr>
              <td>&nbsp;</td>
              <td><input type="submit" name="Submit" value="Add"></td>
            </tr>
          </form>
        </table>
		<font color="#CC6633" size="1" face="Verdana, Arial, Helvetica, sans-serif">Password 
        Minimum 8 Characters, <em>example : username : Tetra, Password : Tsel*2007 
        </em>--&gt; <em>include special characters</em></font><br>
        <br>
        <br>
        <br>
        <br>
      </td>
<%	}
  	 catch(Exception  e){
			e.printStackTrace(System.out);
		} finally{
		try { conn.close(); } catch(Exception ee){}
		}
	
%>
    </stripes:layout-component>
</stripes:layout-render>