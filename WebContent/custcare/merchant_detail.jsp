<%@ page import="java.sql.*"%>
<%@page import="com.telkomsel.itvas.webstarter.WebStarterProperties"%>
<jsp:useBean id="DbCon" scope="page" class="tsel_tunai.DbCon"></jsp:useBean>
<%@ include file="/web-starter/taglibs.jsp" %>
<%@page import="com.telkomsel.itvas.webstarter.User"%>
<stripes:layout-render name="/web-starter/layout/standard.jsp" title="Edit Account">
    <stripes:layout-component name="contents">
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


	//String id = ((User)session.getValue("user")).getUsername();
	String merchantFilter = WebStarterProperties.getInstance().getProperty("merchant.filter");
    String id = request.getParameter("id");
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


        <br>
		<%

		 	String sql = "select name,address,city,zipcode,phone_num,mi.msisdn,ktp_no from merchant_info mi,merchant m where m.merchant_info_id = mi.merchant_info_id and merchant_id = ? AND " + merchantFilter;
			//out.print(login);
			PreparedStatement pstmt = conn.prepareStatement(sql);
			pstmt.setString(1,id);
			ResultSet rs = pstmt.executeQuery();

			while (rs.next()) {
		%>

        <table width="49%" border="1" cellspacing="0" cellpadding="0" bordercolor="#FFF6EF">
          <tr bordercolor="#FFFFFF">
            <td bordercolor="#FFFFFF" bgcolor="#CC6633"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Name</strong></font></td>
            <td width="55%"><div align="center"><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong><%= rs.getString("name")%></strong></font></div></td>
          </tr>
          <tr bordercolor="#FFFFFF">
            <td bordercolor="#FFFFFF" bgcolor="#CC6633"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Address</strong></font></td>
            <td><div align="center"><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong><%= rs.getString("address")%></strong></font></div></td>
          </tr>
          <tr bordercolor="#FFFFFF">
            <td width="45%" bordercolor="#FFFFFF" bgcolor="#CC6633"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>City</strong></font></td>
            <td><div align="center"><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong><%= rs.getString("city")%></strong></font></div></td>
          </tr>
          <tr bordercolor="#FFFFFF">
            <td bordercolor="#FFFFFF" bgcolor="#CC6633"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Zip
              Code </strong></font></td>
            <td><div align="center"><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong><%= rs.getString("zipcode")%></strong></font></div></td>
          </tr>
          <tr bordercolor="#FFFFFF">
            <td width="45%" bordercolor="#FFFFFF" bgcolor="#CC6633"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Phone
              Number </strong></font></td>
            <td><div align="center"><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong><%= rs.getString("phone_num")%></strong></font></div></td>
          </tr>
          <tr bordercolor="#FFFFFF">
            <td bordercolor="#FFFFFF" bgcolor="#CC6633"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Msisdn</strong></font></td>
            <td><div align="center"><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong><%= rs.getString("msisdn")%></strong></font></div></td>
          </tr>
          <tr bordercolor="#FFFFFF">
            <td bordercolor="#FFFFFF" bgcolor="#CC6633"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>KTP
              Number </strong></font></td>
            <td><div align="center"><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong><%= rs.getString("ktp_no")%></strong></font></div></td>
          </tr>
        </table>
        <hr>
<% } %>
        <br>Merchant's Payment Terminal
        <table width="49%" border="1" cellspacing="0" cellpadding="0" bordercolor="#FFF6EF">
          <tr bordercolor="#FFFFFF">
            <td bordercolor="#FFFFFF" bgcolor="#CC6633"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>MSISDN</strong></font></td>
            <td width="75%" bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Description</strong></font></div></td>
            <td width="75%" bgcolor="#CC6633"><div align="center"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Address</strong></font></div></td>
          </tr>
		<%
			pstmt.close();
			rs.close();
			
			System.out.println("HAIYAAAAAAAAAAAAAAAAAAAAH");
			sql = "select b.msisdn, b.description, b.address from merchant a, reader_terminal b where a.merchant_id=b.merchant_id and a.merchant_id=? order by b.msisdn";
			pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, id);
			rs = pstmt.executeQuery();
			while (rs.next()) {
%>			
				<tr bordercolor="#FFFFFF">
					<td bordercolor="#FFFFFF"><font color="#000000" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong><%= rs.getString("msisdn")%></strong></font></td>
					<td><div align="left"><font color="#000000" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong><%= rs.getString("description")%></strong></font></div></td>
					<td><div align="left"><font color="#000000" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong><%= rs.getString("address")%></strong></font></div></td>
        </tr>

<%		
			}
			rs.close();
			pstmt.close();
			
		  %>
		</table>
        <br>
        <br>
<hr>
        <br>Merchant's Loading Terminal
        <table width="49%" border="1" cellspacing="0" cellpadding="0" bordercolor="#FFF6EF">
          <tr bordercolor="#FFFFFF">
            <td bordercolor="#FFFFFF" bgcolor="#CC6633"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Terminal</strong></font></td>
            <td bordercolor="#FFFFFF" bgcolor="#CC6633"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Address</strong></font></td>
          </tr>
		<%
			pstmt.close();
			rs.close();
			
			
			sql = "select b.description, b.address from merchant a, loading_terminal b where a.merchant_id=b.merchant_id and a.merchant_id=? order by b.description";
			pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, id);
			rs = pstmt.executeQuery();
			while (rs.next()) {
%>			
				<tr bordercolor="#FFFFFF">
					<td><div align="left"><font color="#000000" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong><%= rs.getString("description")%></strong></font></div></td>
					<td><div align="left"><font color="#000000" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong><%= rs.getString("address")%></strong></font></div></td>
        </tr>

<%		
			}
			rs.close();
			pstmt.close();
	} catch (Exception e) {
		e.printStackTrace();		
	} finally {
		if (conn != null) {
			try {
				conn.close();			
			} catch (Exception e) {
				
			}
		}
	}
			
		  %>
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

