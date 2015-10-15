<%@ page import="java.sql.*"%>
</SCRIPT>
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
	String user = (String)session.getValue("user");
	String username = request.getParameter("username");
	if(user != null)
	{
   		session.putValue("user", user);
%>
<jsp:useBean id="DbCon" scope="page" class="tsel_tunai.DbCon"></jsp:useBean>
<html>
<head>
<title>-Telkomsel Tunai-</title>
</head>
<style>
.link {
color : #CC6633;
text-decoration : none;
}
.link1 {
color : #CC6633;
text-decoration : underline;
}
</style>
<body>
<div align="center">
  <p>&nbsp;</p>
  

  <table width="100%" border="1" cellspacing="0" cellpadding="0" bordercolor="#CC6633">
  
   <tr> 
      <td width="19%" bgcolor="#CC6633"> <div align="center"><font color="#CC6633" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong><a href="logout.jsp" class="link"><font color="#FFFFFF" size="2">MENU</font></a></strong></font></div></td>
	  <td width="81%" bgcolor="#CC6633">
	  	<div align="right"> <font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong><a href="logout.jsp" class="link">CusCus</a></strong></font><font color="#CC6633" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong><a href="logout.jsp" class="link"><font color="#FFFFFF" size="2">CUSTOMER 
          CARE ADMINISTRATOR - TELKOMSEL TUNAI</font></a></strong></font><font color="#FFFFFF" face="Verdana, Arial, Helvetica, sans-serif"><strong>:: 
          </strong></font></div>
	  </td>
    </tr>
    <tr> 
      <td><jsp:include page="left_admin.jsp" /></td>
	  <td height="110" align="center" valign="top" background="image/Liquisoft2.jpg" bgcolor="#CC6633">
        <%
	
   
	
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
	    
        <table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr> 
            <td width="7%" height="28"> <div align="right"><font color="#CC6633" size="1" face="Verdana, Arial, Helvetica, sans-serif"></font> 
              </div></td>
			  
            <td><div align="center"><font color="#CC3300" size="2" face="Verdana, Arial, Helvetica, sans-serif"> 
                <strong> </strong></font></div></td>
			<td width="7%"> <div align="right"> <font color="#CC6633" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong><img src="image/logo.JPG" width="135" height="37"></strong></font> 
              </div></td>
          </tr>
      </table>
	 
     
		
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
			  <tr> 
            <td><div align="right"><font color="#CC6633" size="4" face="Verdana, Arial, Helvetica, sans-serif"><strong></strong></font></div></td>
          </tr>	
		
		</table>
		
		
        <br>
        <font color="#CC6633" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>WELCOME, 
        <%=user%> </strong></font><br>
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
    </tr>
    <tr> 
      <td  valign="top" bgcolor="#CC6633"> <div align="right"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"></font></div></td>
		  <td  valign="top" bgcolor="#CC6633"> <div align="right"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>IT 
          VAS Development 2007</strong></font></div></td>
    </tr>
		
  
  </table>
<%	}
  	 catch(Exception  e){
			e.printStackTrace(System.out);
		} finally{
		try { conn.close(); } catch(Exception ee){}
		}
	
%>
  </div>
</body>
</html>

<%
	} else {
		response.sendRedirect("admin.html");
	}
%>
