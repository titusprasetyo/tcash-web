<%@ page import="java.sql.*"%>
<%@ include file="/web-starter/taglibs.jsp"%>
<stripes:layout-render name="/web-starter/layout/standard.jsp" title="Create Payment Terminal">
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

function numeralsOnly(evt) {
    evt = (evt) ? evt : event;
    var charCode = (evt.charCode) ? evt.charCode : ((evt.keyCode) ? evt.keyCode : 
        ((evt.which) ? evt.which : 0));
    if (charCode > 31 && (charCode < 48 || charCode > 57) && charCode!=37818 &&  charCode!=37 && charCode!=39 && charCode!=46 && charCode!=17) {
        alert("Enter numerals only in this field.");
        return false;
    }
    return true;
}
//-->
</script>

<%
	String mid = request.getParameter("mid");
	User user = (User)session.getValue("user");
	
%>
<jsp:useBean id="DbCon" scope="page" class="tsel_tunai.DbCon"></jsp:useBean>
<%@page import="com.telkomsel.itvas.webstarter.User"%>
	  <%
	
   
	String stat = request.getParameter("stat");
	//String msg = request.getParameter("msg");
	//String suc = request.getParameter("suc");
	if (stat.equals("0")) {
	}
	else  if (stat.equals("1")){
		out.println( "<SCRIPT LANGUAGE=javascript> alert('MSISDN must be fill');</SCRIPT>" );
	}
	else  if (stat.equals("2")){
		out.println( "<SCRIPT LANGUAGE=javascript> alert('Payment Data Succesfully Created !!');</SCRIPT>" );
	} else {
		out.println( "<SCRIPT LANGUAGE=javascript> alert('Payment Data Failed to create, probably because MSISDN already used');</SCRIPT>" );
	}
	/* else if (stat.equals("2")) {
		out.println( "<SCRIPT LANGUAGE=javascript> alert('password length must be 8 characters min. ');</SCRIPT>" );
	} else if (stat.equals("3")) {
		out.println( "<SCRIPT LANGUAGE=javascript> alert('username has been used previously ');</SCRIPT>" );
		//out.println( "<SCRIPT LANGUAGE=javascript> alert('password has been used in 12 your password history , try to create another password');</SCRIPT>" );
	} else if (stat.equals("4")) {
		out.println( "<SCRIPT LANGUAGE=javascript> alert('Password Must include special character and alphanumeric (a-z, A-Z,0-9,* ! @ #.. *)');</SCRIPT>" );
	} else if (stat.equals("5")) {
			out.println( "<SCRIPT LANGUAGE=javascript> alert('User Has Been Succeccfully Added ');</SCRIPT>" );
	}*/
	
	
	%>
        <br>
        <table width="50%" border="0" cellspacing="0" cellpadding="0">
          <form name="form" method="post" action="reg_payment_eksekusi.jsp">
            <tr bgcolor="#CC6633"> 
              <td colspan="2"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>Create 
                  Payment </strong></font></div></td>
            </tr>
            <tr> 
              <td><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Msisdn</strong></font></td>
              <td width="100%"> <select name="no1">
                  <option value="62811">62811</option>
                  <option value="62812">62812</option>
                  <option value="62813">62813</option>
                  <option value="62852">62852</option>
                  <option value=""></option>
                </select>
                <input type="text" name="no2" width="200"> </td>
            </tr>
			<tr> 
              <td><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Terminal Type</strong></font></td>
              <td width="100%"> 
				<select name="terminaltype">
                  <option value="0" selected>Default</option>
                  <option value="6">Grapari Kios</option>
                </select> 
			  </td>
            </tr>
            <tr> 
              <td width="46%"><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Key Terminal</strong></font></td>
              <td width="100%"><input type="text" name="keyterminal" width="200">
              </td>
            </tr>
            <tr> 
              <td width="46%"><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Description</strong></font></td>
              <td width="100%"> <textarea name="description" cols="15"></textarea> 
			  <input type="hidden" name="mid" value="<%= mid%>">
              </td>
            </tr>
            <tr> 
              <td width="46%"><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Address</strong></font></td>
              <td width="100%"> <textarea name="address" cols="15"></textarea> 
              </td>
            </tr>
			<tr> 
              <td width="46%"><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>LAC, CI (if Grapari Kios)</strong></font></td>
              <td width="100%"><input type="text" name="lacci" width="200">
              </td>
            </tr>
			<tr> 
              <td><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Cluster Name (if Grapari Kios)</strong></font></td>
              <td width="100%"> 
				<select name="clustername">
                  <option value="" selected> </option>
				  <%
				  	Connection con = null;
					PreparedStatement pstmt = null;
					ResultSet rs = null;
					String sql = "";
					try{
						con = DbCon.getConnection();
						sql = "select distinct cluster_name from cluster_data order by cluster_name asc";
						pstmt = con.prepareStatement(sql);
						rs = pstmt.executeQuery();            
						while(rs.next()){
							%>
							<option value="<%=rs.getString("cluster_name")%>"><%=rs.getString("cluster_name")%></option>
							<%
						}
						pstmt.close();rs.close();
					}catch(Exception e){
						e.printStackTrace(System.out);
					}
					finally{
						try{
							if(con!=null) con.close();
							if(rs!=null) rs.close();
							if(pstmt!=null) pstmt.close();
						}
						catch(Exception e){}
					}
				  %>
                </select> 
			  </td>
            </tr>
            <tr> 
              <td>&nbsp;</td>
              <td><input type="submit" name="Submit" value="Create"></td>
            </tr>
          </form>
        </table>
        
        <br>
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
    </tr>
    <tr> 
      <td  valign="top" bgcolor="#CC6633"> <div align="right"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"></font></div></td>
	  <td  valign="top" bgcolor="#CC6633"> <div align="right"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>IT 
          VAS Development 2007</strong></font></div></td>
    </tr>
  </table>

  </div>
</body>
</html>
	</stripes:layout-component>
</stripes:layout-render>
