<%@ page import="java.sql.*"%>
<%@page import="com.telkomsel.itvas.webstarter.User"%>
<%@page import="com.telkomsel.itvas.webstarter.WebStarterProperties"%>
<%@ include file="/web-starter/taglibs.jsp"%>
<jsp:useBean id="DbCon" scope="page" class="tsel_tunai.DbCon"></jsp:useBean>
<script language="JavaScript">
<!--
function validasiForm(theForm) { // passing the form object
  var valbank_acc_no = theForm.bank_acc_no.value;
  var valbank_acc_holder = theForm.bank_acc_holder.value;
  var status = true;
  if (valbank_acc_no==null || valbank_acc_no.trim()=="") { 
    alert('Tolong lengkapi data No.Rekening Merchant');
    theForm.bank_acc_no.focus();
    status = false; // cancel submission
  }
  else if(valbank_acc_holder==null || valbank_acc_holder.trim()==""){
	alert('Tolong lengkapi data Nama No.Rekening Merchant');
    theForm.bank_acc_holder.focus();
    status = false; // cancel submission
  }
  return status; // allow submit
}

function changeText(value){
  if (value=="Mandiri"){ 
    document.getElementsByName("tsel_bank_acc")[0].value = "1240004904539";
  }
  else if(value=="BNI"){
	document.getElementsByName("tsel_bank_acc")[0].value = "0120883432";
  }
  else{
	document.getElementsByName("tsel_bank_acc")[0].value = "00";
  }
}
//-->
</script>

<%
String minfoid = request.getParameter("minfoid");
User user = (User)session.getValue("user");

if(user != null)
{
	session.putValue("user", user);
	String stat = request.getParameter("stat");
	if(stat.equals("1"))
		out.println( "<SCRIPT LANGUAGE=javascript>alert('Any field cannot be empty');</SCRIPT>" );
	else if(stat.equals("2"))
		out.println( "<SCRIPT LANGUAGE=javascript>alert('Merchant Data Succesfully Edited');</SCRIPT>" );
	else if(stat.equals("3"))
		out.println( "<SCRIPT LANGUAGE=javascript>alert('Login already used');</SCRIPT>" );

	Connection conn = null;
	conn = DbCon.getConnection();
	try
	{
		String sql = "select name, address, city, zipcode, phone_num, m.msisdn, login, ktp_no, npwp, bank_name, bank_acc_no, bank_acc_holder, tsel_bank_acc, m.merchant_info_id from merchant m, merchant_info mi where m.merchant_info_id = mi.merchant_info_id and m.merchant_info_id = ?"; 
		PreparedStatement pstmt = conn.prepareStatement(sql);
		pstmt.setString(1, minfoid);
		ResultSet rs = pstmt.executeQuery();
		if(rs.next())
		{			
%>
<stripes:layout-render name="/web-starter/layout/standard.jsp" title="Merchant List">
	<stripes:layout-component name="contents">
		<table width="55%" border="0" cellspacing="0" cellpadding="0">
		<form name="form" method="post" onsubmit="return validasiForm(this)" action="edit_merchant_eksekusi.jsp">
			<input type="hidden" name="minfoid" value="<%= minfoid%>">
			<tr bgcolor="#CC6633">
				<td colspan="2"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>Edit Account</strong></font></div></td>
			</tr>
			<tr>
				<td><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Name</strong></font></td>
				<td><input type="text" name="name" width="200" value="<%= rs.getString("name")%>">
			</td>
			</tr>
			<tr>
				<td><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Address</strong></font></td>
				<td><textarea name="address" cols="15" ><%= rs.getString("address")%></textarea></td>
			</tr>
			<td><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>City</strong></font></td>
				<td> 
						<select name="city">			  	
                			<option value="Other" selected>Other</option>
                			<%
								String sql2 = "select distinct city  from prefix_hlr order by city asc"; 
								PreparedStatement pstmt2 = conn.prepareStatement(sql2);
								ResultSet rs2 = pstmt2.executeQuery();
								while(rs2.next()){
									if((rs.getString("city").toUpperCase()).equals(rs2.getString("city").toUpperCase())){
										//System.out.println("<option value='"+rs2.getString("city")+"' selected >"+rs2.getString("city")+"</option>");
										out.println("<option value='"+rs2.getString("city")+"' selected >"+rs2.getString("city")+"</option>");
									}
									else{
										//System.out.println("<option value='"+rs2.getString("city")+"'>"+rs2.getString("city")+"</option>");
										out.println("<option value='"+rs2.getString("city")+"'>"+rs2.getString("city")+"</option>");
									}
								}
								pstmt2.close();rs2.close();
							%>
						</select>
				</td>
			<tr>
				<td><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Zip Code</strong></font></td>
				<td><input type="text" name="zipcode" width="200" value="<%= rs.getString("zipcode")%>"></td>
			</tr>
			<tr>
				<td><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Phone Number</strong></font></td>
				<td><input type="text" name="phonenum" width="200" value="<%= rs.getString("phone_num")%>"></td>
			</tr>
			<tr>
				<td><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>MSISDN</strong></font></td>
				<td><input type="text" name="msisdn" width="200" value="<%= rs.getString("msisdn")%>"></td>
			</tr>
			<tr>
				<td><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Login</strong></font></td>
				<td><input type="text" name="login" width="200" value="<%= rs.getString("login")%>"> </td>
			</tr>
			<tr>
				<td><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>KTP Number</strong></font></td>
				<td><input name="ktpno" type="text" width="200" value="<%= rs.getString("ktp_no")%>"></td>
			</tr>
			<tr>
				<td><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>NPWP</strong></font></td>
				<td><input name="npwp" type="text" width="200" value="<%= rs.getString("npwp")%>"></td>
			</tr>
			<tr>
				<td><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Bank Name</strong></font></td>
				<td> 
						<select name="bank_name" onchange="changeText(this.value)">			  	
                			<option value="Mandiri" <%if((rs.getString("bank_name").toUpperCase()).equals("MANDIRI")) out.print("selected");%>>Mandiri</option>
                			<option value="BNI" <%if((rs.getString("bank_name").toUpperCase()).equals("BNI")) out.print("selected");%>>BNI</option>
                			<option value="BNI Syariah" <%if((rs.getString("bank_name").toUpperCase()).equals("BNI Syariah")) out.print("selected");%>>BNI Syariah</option>
							<option value="Artha Graha Internasional" <%=("Artha Graha Internasional".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>Artha Graha Internasional</option>
							<option value="Bank Aceh" <%=("Bank Aceh".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>Bank Aceh</option>
							<option value="BANK AGRIS" <%=("BANK AGRIS".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>BANK AGRIS</option>
							<option value="BANK ANDA" <%=("BANK ANDA".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>BANK ANDA</option>
							<option value="BANK ANZ" <%=("BANK ANZ".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>BANK ANZ</option>
							<option value="Bank Artos Indonesia" <%=("Bank Artos Indonesia".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>Bank Artos Indonesia</option>
							<option value="BANK BCA SYARIAH" <%=("BANK BCA SYARIAH".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>BANK BCA SYARIAH</option>
							<option value="Bank Bengkulu" <%=("Bank Bengkulu".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>Bank Bengkulu</option>
							<option value="Bank BJB" <%=("Bank BJB".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>Bank BJB</option>
							<option value="Bank BPD DIY" <%=("Bank BPD DIY".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>Bank BPD DIY</option>
							<option value="Bank BPD Kaltim" <%=("Bank BPD Kaltim".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>Bank BPD Kaltim</option>
							<option value="Bank BPD Sulteng" <%=("Bank BPD Sulteng".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>Bank BPD Sulteng</option>
							<option value="Bank BRI Agro" <%=("Bank BRI Agro".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>Bank BRI Agro</option>
							<option value="Bank BTN" <%=("Bank BTN".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>Bank BTN</option>
							<option value="Bank BTPN" <%=("Bank BTPN".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>Bank BTPN</option>
							<option value="Bank Bukopin" <%=("Bank Bukopin".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>Bank Bukopin</option>
							<option value="BANK BUMI ARTA" <%=("BANK BUMI ARTA".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>BANK BUMI ARTA</option>
							<option value="Bank Capital" <%=("Bank Capital".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>Bank Capital</option>
							<option value="BANK CENTRAL ASIA" <%=("BANK CENTRAL ASIA".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>BANK CENTRAL ASIA</option>
							<option value="BANK CHINATRUST" <%=("BANK CHINATRUST".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>BANK CHINATRUST</option>
							<option value="Bank Commonwealth" <%=("Bank Commonwealth".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>Bank Commonwealth</option>
							<option value="Bank Danamon" <%=("Bank Danamon".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>Bank Danamon</option>
							<option value="Bank DKI" <%=("Bank DKI".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>Bank DKI</option>
							<option value="Bank Ekonomi Raharja" <%=("Bank Ekonomi Raharja".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>Bank Ekonomi Raharja</option>
							<option value="Bank Ganesha" <%=("Bank Ganesha".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>Bank Ganesha</option>
							<option value="Bank ICB Bumiputera" <%=("Bank ICB Bumiputera".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>Bank ICB Bumiputera</option>
							<option value="Bank Ina Perdana" <%=("Bank Ina Perdana".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>Bank Ina Perdana</option>
							<option value="Bank Index Selindo" <%=("Bank Index Selindo".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>Bank Index Selindo</option>
							<option value="Bank Jabar Banten Syariah" <%=("Bank Jabar Banten Syariah".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>Bank Jabar Banten Syariah</option>
							<option value="Bank Jambi" <%=("Bank Jambi".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>Bank Jambi</option>
							<option value="BANK JASA JAKARTA" <%=("BANK JASA JAKARTA".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>BANK JASA JAKARTA</option>
							<option value="Bank Jateng" <%=("Bank Jateng".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>Bank Jateng</option>
							<option value="Bank Jatim" <%=("Bank Jatim".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>Bank Jatim</option>
							<option value="Bank Kalbar" <%=("Bank Kalbar".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>Bank Kalbar</option>
							<option value="Bank Kalsel" <%=("Bank Kalsel".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>Bank Kalsel</option>
							<option value="Bank Kalteng" <%=("Bank Kalteng".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>Bank Kalteng</option>
							<option value="Bank Kesejahteraan Ekonomi" <%=("Bank Kesejahteraan Ekonomi".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>Bank Kesejahteraan Ekonomi</option>
							<option value="Bank Lampung" <%=("Bank Lampung".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>Bank Lampung</option>
							<option value="Bank Maluku" <%=("Bank Maluku".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>Bank Maluku</option>
							<option value="BANK MASPION" <%=("BANK MASPION".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>BANK MASPION</option>
							<option value="Bank Mayapada Internasional" <%=("Bank Mayapada Internasional".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>Bank Mayapada Internasional</option>
							<option value="Bank Mayora" <%=("Bank Mayora".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>Bank Mayora</option>
							<option value="Bank Mega" <%=("Bank Mega".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>Bank Mega</option>
							<option value="Bank Mega Syariah" <%=("Bank Mega Syariah".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>Bank Mega Syariah</option>
							<option value="Bank Mestika Dharma" <%=("Bank Mestika Dharma".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>Bank Mestika Dharma</option>
							<option value="Bank Muamalat" <%=("Bank Muamalat".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>Bank Muamalat</option>
							<option value="Bank Muamalat Indonesia Syariah" <%=("Bank Muamalat Indonesia Syariah".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>Bank Muamalat Indonesia Syariah</option>
							<option value="BANK MUTIARA" <%=("BANK MUTIARA".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>BANK MUTIARA</option>
							<option value="Bank Nagari" <%=("Bank Nagari".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>Bank Nagari</option>
							<option value="Bank NTB" <%=("Bank NTB".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>Bank NTB</option>
							<option value="Bank NTT" <%=("Bank NTT".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>Bank NTT</option>
							<option value="Bank Nusantara Parahyangan" <%=("Bank Nusantara Parahyangan".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>Bank Nusantara Parahyangan</option>
							<option value="Bank OCBC NISP" <%=("Bank OCBC NISP".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>Bank OCBC NISP</option>
							<option value="Bank of China" <%=("Bank of China".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>Bank of China</option>
							<option value="Bank of India Indonesia" <%=("Bank of India Indonesia".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>Bank of India Indonesia</option>
							<option value="Bank Papua" <%=("Bank Papua".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>Bank Papua</option>
							<option value="BANK PUNDI INDONESIA" <%=("BANK PUNDI INDONESIA".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>BANK PUNDI INDONESIA</option>
							<option value="Bank QNB Kesawan" <%=("Bank QNB Kesawan".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>Bank QNB Kesawan</option>
							<option value="BANK RABOBANK" <%=("BANK RABOBANK".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>BANK RABOBANK</option>
							<option value="BANK RAKYAT INDONESIA" <%=("BANK RAKYAT INDONESIA".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>BANK RAKYAT INDONESIA</option>
							<option value="BANK RIAU" <%=("BANK RIAU".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>BANK RIAU</option>
							<option value="BANK ROYAL INDONESIA" <%=("BANK ROYAL INDONESIA".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>BANK ROYAL INDONESIA</option>
							<option value="BANK SAHABAT SAMPOERNA" <%=("BANK SAHABAT SAMPOERNA".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>BANK SAHABAT SAMPOERNA</option>
							<option value="Bank Saudara" <%=("Bank Saudara".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>Bank Saudara</option>
							<option value="BANK SBI INDONESIA" <%=("BANK SBI INDONESIA".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>BANK SBI INDONESIA</option>
							<option value="Bank Sinarmas" <%=("Bank Sinarmas".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>Bank Sinarmas</option>
							<option value="Bank Sulselbar" <%=("Bank Sulselbar".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>Bank Sulselbar</option>
							<option value="Bank Sultra" <%=("Bank Sultra".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>Bank Sultra</option>
							<option value="Bank Sulut" <%=("Bank Sulut".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>Bank Sulut</option>
							<option value="Bank Sumsel Babel" <%=("Bank Sumsel Babel".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>Bank Sumsel Babel</option>
							<option value="Bank Sumut" <%=("Bank Sumut".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>Bank Sumut</option>
							<option value="Bank Syariah Mandiri" <%=("Bank Syariah Mandiri".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>Bank Syariah Mandiri</option>
							<option value="BANK UOB INDONESIA" <%=("BANK UOB INDONESIA".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>BANK UOB INDONESIA</option>
							<option value="BANK VICTORIA" <%=("BANK VICTORIA".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>BANK VICTORIA</option>
							<option value="BANK WINDU KENCANA" <%=("BANK WINDU KENCANA".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>BANK WINDU KENCANA</option>
							<option value="Bank Woori Indonesia " <%=("Bank Woori Indonesia ".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>Bank Woori Indonesia </option>
							<option value="BII Maybank" <%=("BII Maybank".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>BII Maybank</option>
							<option value="BPD Bali" <%=("BPD Bali".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>BPD Bali</option>
							<option value="BPR Eka Bumi Artha" <%=("BPR Eka Bumi Artha".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>BPR Eka Bumi Artha</option>
							<option value="BPR Karyajatnika Sadaya" <%=("BPR Karyajatnika Sadaya".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>BPR Karyajatnika Sadaya</option>
							<option value="BRI Syariah" <%=("BRI Syariah".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>BRI Syariah</option>
							<option value="CIMB Niaga" <%=("CIMB Niaga".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>CIMB Niaga</option>
							<option value="Citibank" <%=("Citibank".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>Citibank</option>
							<option value="DBS INDONESIA" <%=("DBS INDONESIA".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>DBS INDONESIA</option>
							<option value="Hana Bank" <%=("Hana Bank".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>Hana Bank</option>
							<option value="Harda" <%=("Harda".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>Harda</option>
							<option value="HSBC" <%=("HSBC".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>HSBC</option>
							<option value="Nobu Bank" <%=("Nobu Bank".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>Nobu Bank</option>
							<option value="Panin Bank" <%=("Panin Bank".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>Panin Bank</option>
							<option value="Permata Bank" <%=("Permata Bank".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>Permata Bank</option>
							<option value="Standard Chartered Bank Indonesia" <%=("Standard Chartered Bank Indonesia".equalsIgnoreCase(rs.getString("bank_name"))?"selected":"")%>>Standard Chartered Bank Indonesia</option>

						</select>
				</td>
				<input type="hidden" name="tsel_bank_acc" width="200" value="<%= rs.getString("tsel_bank_acc")%>">
			</tr>
			<tr>
				<td><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Bank Account Number</strong></font></td>
				<td><input name="bank_acc_no" type="text" width="200" value="<%= rs.getString("bank_acc_no")%>"></td>
			</tr>
			<tr>
				<td><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Bank Account Holder</strong></font></td>
				<td><input name="bank_acc_holder" type="text" width="200" value="<%= rs.getString("bank_acc_holder")%>"></td>
			</tr>
			<tr>
				<td>&nbsp;</td>
				<td><input type="submit" name="Submit" value="Edit"></td>
			</tr>
		</form>
		</table>
		<br>
		<br>
		<table width="40%" border="0" cellspacing="0" cellpadding="0">
			<tr>
				<td><div align="center"><font color="#CC6633" size="1" face="Verdana, Arial, Helvetica, sans-serif">Sebelum anda keluar dari layanan ini pastikan anda telah logout agar login anda tidak dapat dipakai oleh orang lain.</font></div></td>
			</tr>
		</table>
	</stripes:layout-component>
</stripes:layout-render>
<%
		}
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
}
else
{
	response.sendRedirect("admin.html");
}
%>
