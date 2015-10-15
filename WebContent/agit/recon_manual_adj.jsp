
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Manual Adjustment Reconciliation Mismatch</title>
<script type="text/javascript">
	function validateForm(id) {
		var y = document.forms["myForm"]["comment"].value;
		var x = document.forms["myForm"]["cashid"].value;
		var m = "";
		var numbers = /^[0-9]+$/;
		if (x == null || x == "") {
			//alert(id + " be filled out");
			m += id + " must be filled out\n";
		}
		if (!x.match(numbers)) {
			m += id + " must be number only\n";
		}
		if (y == null || y == "") {
			//alert(id + " be filled out");
			m += "Comment must be filled out\n";
		}

		if (m == "") {
			return true;
		} else {
			alert(m);
			return false;
		}
	}
</script>
</head>
<%
	String param = request.getParameter("ref");
	String[] paramArr = null;
	String batch = "";
	String bank = "";
	String trxDt = "";
	String journal = "";
	String description = "";
	String dbcr = "";
	String amount = "";
	String txType = "";
	String txDesc = "";
	try {
		paramArr = param.split("\\|");
		batch = paramArr[0];
		bank = paramArr[1];
		trxDt = paramArr[2];
		journal = paramArr[3];
		description = paramArr[4];
		dbcr = paramArr[5];
		amount = paramArr[6];
		if ("D".equalsIgnoreCase(dbcr)) {
			txType = "CashOut_ID";
			txDesc = "CASHOUT";
		} else {
			txType = "CashIn_ID";
			txDesc = "CASHIN";
		}
	} catch (Exception e) {

	}
%>
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
							color="#FFFFFF" size="2">TCash Web Interface :: Manual
								Adjustment Reconciliation Mismatch</font></strong></font><font color="#FFFFFF"
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
								fill <%=txType%> for statement bellow.
						</b></font>
					</p>
					<form action="../adjust" method="post" name="myForm" id="myForm"
						onsubmit="return validateForm('<%=txType%>')">
						<table>
							<tr>
								<td valign="top"><div align='left'>
										<font size='1' face='Verdana, Arial, Helvetica, sans-serif'>Statement
											Batch Upload</font>
									</div></td>
								<td valign="top"><div align='left'>
										<font size='1' face='Verdana, Arial, Helvetica, sans-serif'>:
											<%=batch%></font> <input type="hidden" value="<%=batch%>" id="batch"
											name="batch" />
									</div></td>
							</tr>
							<tr>
								<td valign="top"><div align='left'>
										<font size='1' face='Verdana, Arial, Helvetica, sans-serif'>Source
											Bank</font>
									</div></td>
								<td valign="top"><div align='left'>
										<font size='1' face='Verdana, Arial, Helvetica, sans-serif'>:
											<%=bank%></font> <input type="hidden" value="<%=bank%>" id="bank"
											name="bank" />
									</div></td>
							</tr>
							<tr>
								<td valign="top"><div align='left'>
										<font size='1' face='Verdana, Arial, Helvetica, sans-serif'>Statement
											Date</font>
									</div></td>
								<td valign="top"><div align='left'>
										<font size='1' face='Verdana, Arial, Helvetica, sans-serif'>:
											<%=trxDt%></font>
									</div></td>
							</tr>
							<tr>
								<td valign="top"><div align='left'>
										<font size='1' face='Verdana, Arial, Helvetica, sans-serif'>Journal
											ID</font>
									</div></td>
								<td valign="top"><div align='left'>
										<font size='1' face='Verdana, Arial, Helvetica, sans-serif'>:
											<%=journal%></font> <input type="hidden" value="<%=journal%>"
											id="journal" name="journal" />
									</div></td>
							</tr>
							<tr>
								<td valign="top"><div align='left'>
										<font size='1' face='Verdana, Arial, Helvetica, sans-serif'>Description</font>
									</div></td>
								<td valign="top"><div align='left'>
										<font size='1' face='Verdana, Arial, Helvetica, sans-serif'>:
											<%=description%></font> <input type="hidden"
											value="<%=description%>" id="description" name="description" />
									</div></td>
							</tr>
							<tr>
								<td valign="top"><div align='left'>
										<font size='1' face='Verdana, Arial, Helvetica, sans-serif'>Transaction
											Type</font>
									</div></td>
								<td valign="top"><div align='left'>
										<font size='1' face='Verdana, Arial, Helvetica, sans-serif'>:
											<%=txDesc%></font> <input type="hidden" value="<%=dbcr%>" id="dbcr"
											name="dbcr" />
									</div></td>
							</tr>
							<tr>
								<td valign="top"><div align='left'>
										<font size='1' face='Verdana, Arial, Helvetica, sans-serif'>Amount</font>
									</div></td>
								<td valign="top"><div align='left'>
										<font size='1' face='Verdana, Arial, Helvetica, sans-serif'>:
											<%=amount%></font> <input type="hidden" value="<%=amount%>"
											id="amount" name="amount" />
									</div></td>
							</tr>
							<tr>
								<td valign="top"><div align='left'>
										<font size='1' face='Verdana, Arial, Helvetica, sans-serif'><%=txType%></font>
									</div></td>
								<td valign="top"><div align='left'>
										<font size='1' face='Verdana, Arial, Helvetica, sans-serif'>:
											<input type="text" name="cashid" id="cashid" />
										</font>
									</div></td>
							</tr>
							<tr>
								<td valign="top"><div align='left'>
										<font size='1' face='Verdana, Arial, Helvetica, sans-serif'>Comment</font>
									</div></td>
								<td valign="top"><div align='left'>
										<font size='1' face='Verdana, Arial, Helvetica, sans-serif'>:
											<input type="text" name="comment" id="comment" />
										</font>
									</div></td>
							</tr>
							<tr>
								<td valign="top"><div align='left'>
										<font size='1' face='Verdana, Arial, Helvetica, sans-serif'></font>
									</div></td>
								<td valign="top"><div align='left'>
										<font size='1' face='Verdana, Arial, Helvetica, sans-serif'>
											<input type="submit" value="Adjust" />
										</font>
									</div></td>
							</tr>
						</table>
					</form>
					<br /> <br /> <a href="./bank_statement_reconcile_b.jsp">Back
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