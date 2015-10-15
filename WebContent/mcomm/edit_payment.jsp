<%@ page import="java.sql.*"%>
<%@page import="com.telkomsel.itvas.webstarter.User"%>
<%@ include file="/web-starter/taglibs.jsp"%>
<stripes:layout-render name="/web-starter/layout/standard.jsp" title="Edit Payment Terminal">
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
	String tid = request.getParameter("tid");
	String name = request.getParameter("name");
	String msisdn = request.getParameter("msisdn");
	String desc = request.getParameter("desc");
	String address = request.getParameter("address");
	String keyterminal = request.getParameter("keyterminal");
	System.out.println("keyterminal"+keyterminal);
	
	
	String terminaltype = (request.getParameter("terminaltype")==null || request.getParameter("terminaltype").equals(""))?terminaltype="nongkios":request.getParameter("terminaltype");
	String lacci = (request.getParameter("lacci")==null || request.getParameter("lacci").equals(""))?lacci="":request.getParameter("lacci");
	String clustername = (request.getParameter("clustername")==null || request.getParameter("clustername").equals(""))?clustername="":request.getParameter("clustername");
	
	User user = (User)session.getValue("user");
	
	String no1 = "", no2 = "";
	if (msisdn.startsWith("628")) {
		no1 = msisdn.substring(0,5);
		no2 = msisdn.substring(5,msisdn.length());
	} else {
		no1 = "";
		no2 = msisdn;
	}
	
%>
<jsp:useBean id="DbCon" scope="page" class="tsel_tunai.DbCon"></jsp:useBean>
<jsp:useBean id="Util" scope="page" class="tsel_tunai.Util"></jsp:useBean>
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
		out.println( "<SCRIPT LANGUAGE=javascript> alert('Payment Data Succesfully Edited !!');</SCRIPT>" );
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
          <form name="form" method="post" action="edit_payment_eksekusi.jsp">
            <tr bgcolor="#CC6633"> 
              <td colspan="2"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>Edit 
                  Payment for<em> </em>Merchant<font color="#CCCCCC"><em> <%= name%></em></font></strong></font></div></td>
            </tr>
            <tr> 
              <td><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Msisdn</strong></font></td>
              <td width="100%"> <select name="no1">
			  	  <option value="<%= no1%>"><%= no1%></option>
                  <option value="62811">62811</option>
                  <option value="62812">62812</option>
                  <option value="62813">62813</option>
                  <option value="62852">62852</option>
                  <option value=""></option>
                </select>
                <input type="text" name="no2" width="200" value="<%= no2%>"> </td>
            </tr>
            <tr> 
              <td><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Terminal Type</strong></font></td>
              <td width="100%"> 
				<select name="terminaltype">
                  <option value="0" <%=(!terminaltype.equals("6"))?"selected":""%>>Default</option>
                  <option value="6" <%=(terminaltype.equals("6"))?"selected":""%>>Grapari Kios</option>
                </select> 
			  </td>
            </tr>
			<tr> 
              <td width="46%"><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Key Terminal</strong></font></td>
              <td width="100%"><input type="text" name="keyterminal" width="200"  value="<%= (!terminaltype.equals("6"))?keyterminal:(Util.decMy(keyterminal)).substring(2,(Util.decMy(keyterminal)).length())%>">
              </td>
            </tr>
            <tr> 
              <td width="46%"><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Description</strong></font></td>
              <td width="100%"> <textarea name="description" cols="15"><%= desc%></textarea> 
			  <input type="hidden" name="tid" value="<%= tid%>">
			  <input type="hidden" name="nama" value="<%= name%>">
			  <input type="hidden" name="msisdn" value="<%= msisdn%>">
              </td>
            </tr>
            <tr>
				<tr> 
              <td width="46%"><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Address</strong></font></td>
              <td width="100%"> <textarea name="address" cols="15"><%= address%></textarea> 
              </td>
            </tr>
            <tr> 
              <td width="46%"><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>LAC, CI (if Grapari Kios)</strong></font></td>
              <td width="100%"><input type="text" name="lacci" width="200" value="<%=lacci%>">
              </td>
            </tr>
			<tr> 
              <td><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Cluster Name (if Grapari Kios)</strong></font></td>
              <td width="100%"> 
				<select name="clustername">
                  <option value="" <%=(clustername.equals(""))?"selected":""%>> </option>
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
							<option value="<%=rs.getString("cluster_name")%>" <%=(clustername.equals(rs.getString("cluster_name")))?"selected":""%> ><%=rs.getString("cluster_name")%></option>
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
              <td><input type="submit" name="Submit" value="Edit"></td>
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
	</stripes:layout-component>
</stripes:layout-render>
