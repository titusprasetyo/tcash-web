<%@ page import="java.sql.*"%>
<%@ include file="/web-starter/taglibs.jsp"%>
<%@page import="com.telkomsel.itvas.webstarter.User"%>
<%@page import="com.telkomsel.itvas.webstarter.WebStarterProperties"%>
<jsp:useBean id="DbCon" scope="page" class="tsel_tunai.DbCon"></jsp:useBean>
<script language="JavaScript">
<!--
	function validasiForm(theForm) { // passing the form object
		var valbank_acc_no = theForm.bank_acc_no.value;
		var valbank_acc_holder = theForm.bank_acc_holder.value;
		var status = true;
		if (valbank_acc_no == null || valbank_acc_no.trim() == "") {
			alert('Tolong lengkapi data No.Rekening Merchant');
			theForm.bank_acc_no.focus();
			status = false; // cancel submission
		} else if (valbank_acc_holder == null
				|| valbank_acc_holder.trim() == "") {
			alert('Tolong lengkapi data Nama No.Rekening Merchant');
			theForm.bank_acc_holder.focus();
			status = false; // cancel submission
		}
		return status; // allow submit
	}

	function changeText(value) {
		if (value == "Mandiri") {
			document.getElementsByName("tsel_bank_acc")[0].value = "1240004904539";
		} else if (value == "BNI") {
			document.getElementsByName("tsel_bank_acc")[0].value = "0120883432";
		} else {
			document.getElementsByName("tsel_bank_acc")[0].value = "0120883432";
		}
	}
//-->
</script>
<%
	User user = (User) session.getValue("user");

	String stat = request.getParameter("stat");
	String msg = request.getParameter("msg");
	String suc = request.getParameter("suc");

	if (stat == null)
		stat = "0";
	if (msg == null)
		msg = "";
	if (suc == null)
		suc = "";

	if (!stat.equals("0")) {
		if (suc.equals("Merchant registration success"))
			out.println("<SCRIPT LANGUAGE=javascript> alert('Registrasi merchant berhasil');</SCRIPT>");
		else
			out.println("<SCRIPT LANGUAGE=javascript> alert('Registrasi merchant gagal, reason : " + suc
					+ "');</SCRIPT>");
	}

	Connection conn = null;
	conn = DbCon.getConnection();
	try {
		String sql = "select distinct city  from prefix_hlr order by city asc";
		PreparedStatement pstmt = conn.prepareStatement(sql);
		ResultSet rs = pstmt.executeQuery();
%>
<stripes:layout-render name="/web-starter/layout/standard.jsp"
	title="Create Merchant">
	<stripes:layout-component name="contents">
		<table width="55%" border="0" cellspacing="0" cellpadding="0">
			<form name="form" method="post" onsubmit="return validasiForm(this)"
				action="addMerchant2.jsp">
				<tr bgcolor="#CC6633">
					<td colspan="2"><div align="center">
							<font color="#FFFFFF" size="2"
								face="Verdana, Arial, Helvetica, sans-serif"><strong>Registration</strong></font>
						</div></td>
				</tr>
				<tr>
					<td><font color="#999999" size="1"
						face="Verdana, Arial, Helvetica, sans-serif"><strong>Name</strong></font></td>
					<td><input type="text" name="name" width="200"></td>
				</tr>
				<tr>
					<td><font color="#999999" size="1"
						face="Verdana, Arial, Helvetica, sans-serif"><strong>Address</strong></font></td>
					<td><textarea name="address" cols="15"></textarea></td>
				</tr>
				<tr>
					<td><font color="#999999" size="1"
						face="Verdana, Arial, Helvetica, sans-serif"><strong>City</strong></font></td>
					<td><select name="city">
							<option value="Other" selected>Other</option>
							<%
								while (rs.next()) {
												out.println("<option value='" + rs.getString("city") + "'>" + rs.getString("city")
														+ "</option>");
											}
							%>
					</select></td>
				</tr>
				<tr>
					<td><font color="#999999" size="1"
						face="Verdana, Arial, Helvetica, sans-serif"><strong>Zip
								Code</strong></font></td>
					<td><input type="text" name="zipcode" width="200"></td>
				</tr>
				<tr>
					<td><font color="#999999" size="1"
						face="Verdana, Arial, Helvetica, sans-serif"><strong>Phone
								Number</strong></font></td>
					<td><input type="text" name="phonenum" width="200"></td>
				</tr>
				<tr>
					<td><font color="#999999" size="1"
						face="Verdana, Arial, Helvetica, sans-serif"><strong>MSISDN</strong></font></td>
					<td><input type="text" name="msisdn" width="200" value="628"></td>
				</tr>
				<tr>
					<td><font color="#999999" size="1"
						face="Verdana, Arial, Helvetica, sans-serif"><strong>Login</strong></font></td>
					<td><input type="text" name="login" width="200"></td>
				</tr>
				<tr>
					<td><font color="#999999" size="1"
						face="Verdana, Arial, Helvetica, sans-serif"><strong>KTP
								Number</strong></font></td>
					<td><input type="text" name="ktpno" width="200"></td>
				</tr>
				<tr>
					<td><font color="#999999" size="1"
						face="Verdana, Arial, Helvetica, sans-serif"><strong>NPWP
								Number</strong></font></td>
					<td><input type="text" name="npwp" width="200"></td>
				</tr>
				<tr>
					<td><font color="#999999" size="1"
						face="Verdana, Arial, Helvetica, sans-serif"><strong>Bank
								Name</strong></font></td>
					<td><select name="bank_name" onchange="changeText(this.value)">
							<option value="Mandiri" selected>Mandiri</option>
							<option value="BNI">BNI</option>
							<option value="BNI Syariah">BNI Syariah</option>
							<option value="Artha Graha Internasional">Artha Graha Internasional</option>
							<option value="Bank Aceh">Bank Aceh</option>
							<option value="BANK AGRIS">BANK AGRIS</option>
							<option value="BANK ANDA">BANK ANDA</option>
							<option value="BANK ANZ">BANK ANZ</option>
							<option value="Bank Artos Indonesia">Bank Artos Indonesia</option>
							<option value="BANK BCA SYARIAH">BANK BCA SYARIAH</option>
							<option value="Bank Bengkulu">Bank Bengkulu</option>
							<option value="Bank BJB">Bank BJB</option>
							<option value="Bank BPD DIY">Bank BPD DIY</option>
							<option value="Bank BPD Kaltim">Bank BPD Kaltim</option>
							<option value="Bank BPD Sulteng">Bank BPD Sulteng</option>
							<option value="Bank BRI Agro">Bank BRI Agro</option>
							<option value="Bank BTN">Bank BTN</option>
							<option value="Bank BTPN">Bank BTPN</option>
							<option value="Bank Bukopin">Bank Bukopin</option>
							<option value="BANK BUMI ARTA">BANK BUMI ARTA</option>
							<option value="Bank Capital">Bank Capital</option>
							<option value="BANK CENTRAL ASIA">BANK CENTRAL ASIA</option>
							<option value="BANK CHINATRUST">BANK CHINATRUST</option>
							<option value="Bank Commonwealth">Bank Commonwealth</option>
							<option value="Bank Danamon">Bank Danamon</option>
							<option value="Bank DKI">Bank DKI</option>
							<option value="Bank Ekonomi Raharja">Bank Ekonomi Raharja</option>
							<option value="Bank Ganesha">Bank Ganesha</option>
							<option value="Bank ICB Bumiputera">Bank ICB Bumiputera</option>
							<option value="Bank Ina Perdana">Bank Ina Perdana</option>
							<option value="Bank Index Selindo">Bank Index Selindo</option>
							<option value="Bank Jabar Banten Syariah">Bank Jabar Banten Syariah</option>
							<option value="Bank Jambi">Bank Jambi</option>
							<option value="BANK JASA JAKARTA">BANK JASA JAKARTA</option>
							<option value="Bank Jateng">Bank Jateng</option>
							<option value="Bank Jatim">Bank Jatim</option>
							<option value="Bank Kalbar">Bank Kalbar</option>
							<option value="Bank Kalsel">Bank Kalsel</option>
							<option value="Bank Kalteng">Bank Kalteng</option>
							<option value="Bank Kesejahteraan Ekonomi">Bank Kesejahteraan Ekonomi</option>
							<option value="Bank Lampung">Bank Lampung</option>
							<option value="Bank Maluku">Bank Maluku</option>
							<option value="BANK MASPION">BANK MASPION</option>
							<option value="Bank Mayapada Internasional">Bank Mayapada Internasional</option>
							<option value="Bank Mayora">Bank Mayora</option>
							<option value="Bank Mega">Bank Mega</option>
							<option value="Bank Mega Syariah">Bank Mega Syariah</option>
							<option value="Bank Mestika Dharma">Bank Mestika Dharma</option>
							<option value="Bank Muamalat">Bank Muamalat</option>
							<option value="Bank Muamalat Indonesia Syariah">Bank Muamalat Indonesia Syariah</option>
							<option value="BANK MUTIARA">BANK MUTIARA</option>
							<option value="Bank Nagari">Bank Nagari</option>
							<option value="Bank NTB">Bank NTB</option>
							<option value="Bank NTT">Bank NTT</option>
							<option value="Bank Nusantara Parahyangan">Bank Nusantara Parahyangan</option>
							<option value="Bank OCBC NISP">Bank OCBC NISP</option>
							<option value="Bank of China">Bank of China</option>
							<option value="Bank of India Indonesia">Bank of India Indonesia</option>
							<option value="Bank Papua">Bank Papua</option>
							<option value="BANK PUNDI INDONESIA">BANK PUNDI INDONESIA</option>
							<option value="Bank QNB Kesawan">Bank QNB Kesawan</option>
							<option value="BANK RABOBANK">BANK RABOBANK</option>
							<option value="BANK RAKYAT INDONESIA">BANK RAKYAT INDONESIA</option>
							<option value="BANK RIAU">BANK RIAU</option>
							<option value="BANK ROYAL INDONESIA">BANK ROYAL INDONESIA</option>
							<option value="BANK SAHABAT SAMPOERNA">BANK SAHABAT SAMPOERNA</option>
							<option value="Bank Saudara">Bank Saudara</option>
							<option value="BANK SBI INDONESIA">BANK SBI INDONESIA</option>
							<option value="Bank Sinarmas">Bank Sinarmas</option>
							<option value="Bank Sulselbar">Bank Sulselbar</option>
							<option value="Bank Sultra">Bank Sultra</option>
							<option value="Bank Sulut">Bank Sulut</option>
							<option value="Bank Sumsel Babel">Bank Sumsel Babel</option>
							<option value="Bank Sumut">Bank Sumut</option>
							<option value="Bank Syariah Mandiri">Bank Syariah Mandiri</option>
							<option value="BANK UOB INDONESIA">BANK UOB INDONESIA</option>
							<option value="BANK VICTORIA">BANK VICTORIA</option>
							<option value="BANK WINDU KENCANA">BANK WINDU KENCANA</option>
							<option value="Bank Woori Indonesia ">Bank Woori Indonesia </option>
							<option value="BII Maybank">BII Maybank</option>
							<option value="BPD Bali">BPD Bali</option>
							<option value="BPR Eka Bumi Artha">BPR Eka Bumi Artha</option>
							<option value="BPR Karyajatnika Sadaya">BPR Karyajatnika Sadaya</option>
							<option value="BRI Syariah">BRI Syariah</option>
							<option value="CIMB Niaga">CIMB Niaga</option>
							<option value="Citibank">Citibank</option>
							<option value="DBS INDONESIA">DBS INDONESIA</option>
							<option value="Hana Bank">Hana Bank</option>
							<option value="Harda">Harda</option>
							<option value="HSBC">HSBC</option>
							<option value="Nobu Bank">Nobu Bank</option>
							<option value="Panin Bank">Panin Bank</option>
							<option value="Permata Bank">Permata Bank</option>
							<option value="Standard Chartered Bank Indonesia">Standard Chartered Bank Indonesia</option>

					</select></td>
					<input type="hidden" name="tsel_bank_acc" width="200"
						value="1240004904539">
				</tr>
				<tr>
					<td><font color="#999999" size="1"
						face="Verdana, Arial, Helvetica, sans-serif"><strong>Bank
								Account Number</strong></font></td>
					<td><input type="text" name="bank_acc_no" width="200"></td>
				</tr>
				<tr>
					<td><font color="#999999" size="1"
						face="Verdana, Arial, Helvetica, sans-serif"><strong>Bank
								Account Holder</strong></font></td>
					<td><input type="text" name="bank_acc_holder" width="200"></td>
				</tr>
				<tr>
					<td><font color="#999999" size="1"
						face="Verdana, Arial, Helvetica, sans-serif"><strong>Merchant's
								Type</strong></font></td>
					<td><select name="merchant_type">
							<option value="deposit">deposit</option>
							<option value="daily">daily</option>
					</select></td>
				</tr>
				<tr>
					<td>&nbsp;</td>
					<td><input type="submit" name="Submit" value="  Add  "></td>
				</tr>
			</form>
		</table>
		<br>
		<br>
		<table width="40%" border="0" cellspacing="0" cellpadding="0">
			<tr>
				<td>
					<div align="center">
						<font color="#CC6633" size="1"
							face="Verdana, Arial, Helvetica, sans-serif">Sebelum anda
							keluar dari layanan ini pastikan anda telah logout agar login
							anda tidak dapat dipakai oleh orang lain.</font>
					</div>
				</td>
			</tr>
		</table>
	</stripes:layout-component>
</stripes:layout-render>
<%
	} catch (Exception e) {
		e.printStackTrace(System.out);
	} finally {
		try {
			conn.close();
		} catch (Exception ee) {
		}
	}
%>
