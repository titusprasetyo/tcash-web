
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Bank Statement Upload</title>
<script type="text/javascript">
	function Checkfiles(f) {
		var alerts = "";
		var filename = f['file'].value.replace(/^.*[\\\/]/, '')
		f = f.elements;
		if (/.*\.(txt)|(csv)$/.test(f['file'].value.toLowerCase()))
			alerts = "";
		else
			alerts += "Please Upload txt/csv Files Only.\n";
		if ((filename.toLowerCase().indexOf('bni_rk_') == 0)
				|| (filename.toLowerCase().indexOf('bmr_rk_') == 0))
			alerts = "";
		else
			alerts += "Filename must start with bni_rk_ for BNI dan bmr_rk_ for Mandiri ";
		if (alerts == "")
			return true;
		alert(alerts);
		f['file'].focus();
		return false;
	};
</script>
</head>
<style>
.link {
	color: #CC6633;
	text-decoration: none;
}

.link1 {
	color: #CC6633;
	text-decoration: underline;
}
</style>
<body>
	<table width="100%" border="1" cellspacing="0" cellpadding="0"
		bordercolor="#CC6633">
		<tr>
			<td width="81%" bgcolor="#CC6633">
				<div align="right">
					<font color="#CC6633" size="1"
						face="Verdana, Arial, Helvetica, sans-serif"><strong><font
							color="#FFFFFF" size="2">TCash Web Interface :: Upload
								Bank Statement File</font></strong></font><font color="#FFFFFF"
						face="Verdana, Arial, Helvetica, sans-serif"><strong>
					</strong></font>
				</div>
			</td>
		</tr>
		<tr valign='top'>
			<td height="110" align="center" valign="top"
				background="${pageContext.request.contextPath}/image/Liquisoft2.jpg"
				bgcolor="#999999">
				<div align="right">
					<font color="black" face="Verdana, Arial, Helvetica, sans-serif"></font>
				</div>
				<div align="right"></div>
				<div align="right"></div>
				<table width="100%" border="0" cellspacing="0" cellpadding="0">
					<tr>
						<td width="7%" height="28">
							<div align="right">
								<font color="#CC6633" size="1"
									face="Verdana, Arial, Helvetica, sans-serif"><strong><img
										src="${pageContext.request.contextPath}/STATIC/tsel.JPG"
										width="135" height="37"></strong></font>
							</div>
						</td>
					</tr>
				</table> <br />
				<div>
					<p>
						<font size='1' face='Verdana, Arial, Helvetica, sans-serif'><b>Please
								input Bank Statement file to proceed.</b></font>
					</p>
					<form action="../upload" method="post"
						enctype="multipart/form-data" onsubmit="return Checkfiles(this);">
						<input type="file" name="file" id="file" /> <input type="submit"
							value="upload" />
					</form>
					<br /> <br /> <a href="./bank_statement_reconcile.jsp">Back
						to Bank Statement Reconcile</a>
				</div> <br /> <br />
				<table width="40%" border="0" cellspacing="0" cellpadding="0">
					<tr>
						<td><div align="center">
								<font color="#CC6633" size="1"
									face="Verdana, Arial, Helvetica, sans-serif">Sebelum
									anda keluar dari layanan ini pastikan anda telah logout agar
									login anda tidak dapat dipakai oleh orang lain.</font>
							</div></td>

					</tr>
				</table>
		<tr>
			<td valign="top" bgcolor="#CC6633">
				<div align="right">
					<font color="#FFFFFF" size="1"
						face="Verdana, Arial, Helvetica, sans-serif"><strong>IT
							VAS Development 2015 - Powered by Stripes Framework and AGIT ESD
							Telkomsel</strong></font>
				</div>
			</td>
		</tr>
	</table>
</body>
</html>