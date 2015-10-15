<%@ include file="/web-starter/taglibs.jsp"%>
<html>
<head>
<title>T-Cash Web</title>
<link rel="stylesheet"
      type="text/css"
      href="${pageContext.request.contextPath}/STATIC/bugzooky.css"/>
<script type="text/javascript"
        src="${pageContext.request.contextPath}/STATIC/bugzooky.js"></script>
</head>
<style>
.link {
	color: #CC6633;
	text-decoration: underline;
}

.link1 {
	color: #CC6633;
	text-decoration: none;
}
</style>
<body>
<div align="center">
<p>&nbsp;</p>
<p>&nbsp;</p>
<table width="100%" border="1" cellpadding="0" cellspacing="0"
	bordercolor="#CC6633">
	<!--DWLayoutTable-->
	<tr>
		<td bgcolor="#CC6633">
		<div align="right"><font color="#FFFFFF"
			face="Verdana, Arial, Helvetica, sans-serif"></font></div>
		</td>
	</tr>
	<tr>
		<td height="310" valign="top" background="${pageContext.request.contextPath}/STATIC/Liquisoft2.jpg">
		<table width="100%" height="100%" border="0" cellspacing="0"
			cellpadding="0">
			<tr>
				<td width="75%" valign="top">
				<div align="right">
				<table width="100%" border="0" cellspacing="0" cellpadding="0">
					<tr>
						<td width="10%">
						<div align="right"><font color="#CC6633" size="1"
							face="Verdana, Arial, Helvetica, sans-serif"><strong>
						</strong></font></div>
						</td>
					</tr>
				</table>
				<font color="#006633" size="3"
					face="Verdana, Arial, Helvetica, sans-serif"><strong>
				<br>
				<br>
				<br>
				<font color="#CC6633">T-Cash Web Interface</font></strong></font><br>
				<br>
				<font color="#CC6633" size="1"
					face="Verdana, Arial, Helvetica, sans-serif"><br>
				</font><font color="#006633" size="1"
					face="Verdana, Arial, Helvetica, sans-serif"><br>
				<br>
				<br>
				<br>
				<font color="#CC6633"><strong>Powered by IT VAS
				Development 2008</strong></font> </font></div>
				</td>

				<td align="center" valign="top">
				<div align="center"><img src="${pageContext.request.contextPath}/STATIC/tsel.JPG" width="129"
					height="36"><br>
				<br>
				<br>
				</div>
				<table width="90%" border="1" cellspacing="0" cellpadding="0"
					bordercolor="#CC6633">
					<tr>
						<td bgcolor="#CC6633" valign="top">
						<div align="center"><font color="#FFFFFF" size="2"
							face="Verdana, Arial, Helvetica, sans-serif">Login</font></div>
						</td>
					</tr>
					<tr>
						<td align="center">
						<table width="90%" border="0" cellspacing="0" cellpadding="0">
							<stripes:form action="/Login.action" focus="">
								<tr>

									<td width="40%"><font color="#CC6633" size="1"
										face="Verdana, Arial, Helvetica, sans-serif"><strong>username</strong></font></td>
									<td align="right"><stripes:text name="username" value="${user.username}"/></td>
								</tr>
								<tr>

									<td><font color="#CC6633" size="1"
										face="Verdana, Arial, Helvetica, sans-serif"><strong>password</strong></font></td>
									<td align="right"><stripes:password name="password"/></td>
								</tr>
								<tr>
									<td colspan="2">&nbsp;</td>
								</tr>								
								<tr>
									<td>&nbsp;</td>

									<td>
									<div align="right"><input type="submit" name="Submit"
										value="Submit"></div>
									</td>
								</tr>
							</stripes:form>
						</table>
						</td>
					</tr>
					<tr>

						<td>
						<div align="center"></div>
						</td>
					</tr>
				</table>
				<br>
				<font color="#CC6633" size="1"
					face="Verdana, Arial, Helvetica, sans-serif">
	<stripes:errors action="/Login.action" />
	</font></td>
			</tr>
		</table>
		</td>
	</tr>
	<tr>
		<td valign="top" bgcolor="#CC6633">
		<div align="right"><font color="#FFFFFF" size="1"
			face="Verdana, Arial, Helvetica, sans-serif"></font></div>
		</td>
	</tr>
</table>
<p>&nbsp;</p>


</div>
</body>
</html>
