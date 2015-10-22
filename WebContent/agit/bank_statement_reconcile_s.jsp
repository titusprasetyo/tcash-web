<%@page import="java.math.BigDecimal"%>
<%@page import="java.io.*, java.util.*, java.text.*, java.sql.*"%>
<%@ include file="/web-starter/taglibs.jsp"%>
<%@page import="com.telkomsel.itvas.webstarter.User"%>

<jsp:useBean id="reg" scope="request" class="tsel_tunai.Register2Bean"></jsp:useBean>
<jsp:useBean id="DbCon" scope="page" class="tsel_tunai.DbCon"></jsp:useBean>
<script type="text/javascript">
	function validateSearch() {
		var y = document.forms["formini"]["from"].value;
		var x = document.forms["formini"]["to"].value;
		var m = "";
		var numbers = /^[0-9]+$/;
		if (y == "" || x == "") {
			m += "Fill date first\n";
		}

		if (m == "") {
			return true;
		} else {
			alert(m);
			return false;
		}
	}
	function exportcsv(prm) {
		window
				.open(
						"recon_export_csv.jsp?token=" + prm,
						"export",
						"toolbar=no, location=no, scrollbars=yes, resizable=yes, top=500, left=500, width=400, height=400")
	}
	function recondetail(prm, type) {
		window
				.open("recon_detail_popup.jsp?token=" + prm + "&type=" + type,
						"export",
						"toolbar=no, location=no, scrollbars=yes, resizable=yes, width=600, height=400")
	}
	function calendar(output) {
		newwin = window.open('cal.jsp', '',
				'top=150,left=150,width=145,height=130,resizable=no');
		if (!newwin.opener)
			newwin.opener = self;
	}

	function calendar2(output) {
		newwin = window.open('cal2.jsp', '',
				'top=150,left=150,width=145,height=130,resizable=no');
		if (!newwin.opener)
			newwin.opener = self;
	}
	function recondetail(prm, from, to) {
		window
				.open("recon_detail_popup.jsp?token=" + prm + "&from=" + from
						+ "&to=" + to, "export",
						"toolbar=no, location=no, scrollbars=yes, resizable=yes, width=700, height=200")
	}
	function printData() {
		var divToPrint = document.getElementById("printTable");
		newWin = window.open("");
		newWin.document.write(divToPrint.outerHTML);
		newWin.print();
		newWin.close();
	}
</script>
<%
	User user = (User) session.getValue("user");

	String encLogin = user.getUsername();
	String encPass = user.getPassword();
	SimpleDateFormat sdf = new SimpleDateFormat("d-M-yyyy");
	java.util.Date today = Calendar.getInstance().getTime();
	String from = "1" + sdf.format(today).substring(2);
	String to = sdf.format(today);
	java.util.Date dateFrom = null;
	java.util.Date dateTo = null;
	String query_rk = "";
	String query_rk2 = "";
	String query_tcash = "";

	int match_rec = 0;
	int t_rec = 0;
	int b_rec = 0;

	java.math.BigDecimal match_amt = java.math.BigDecimal.ZERO;
	java.math.BigDecimal t_amt = java.math.BigDecimal.ZERO;
	java.math.BigDecimal b_amt = java.math.BigDecimal.ZERO;

	DecimalFormat formatter = new DecimalFormat("#,###");
	DecimalFormat formatter2 = new DecimalFormat("#,###.00");

	Connection con = null;
	Statement stmt = null;
	PreparedStatement pstmt = null;
	ResultSet rs = null;
	if ("POST".equalsIgnoreCase(request.getMethod())) {
		from = request.getParameter("from");
		to = request.getParameter("to");
	}
	try {
		//check if is it filter request
		if ((from != null) && (to != null) && ("POST".equalsIgnoreCase(request.getMethod()))) {
			sdf = new SimpleDateFormat("d-M-yyyy");
			System.out.println("search : " + from);
			System.out.println("searchvalue : " + to);
			dateFrom = sdf.parse(from);
			dateTo = sdf.parse(to);
			query_rk = "SELECT COUNT(0), SUM(AMOUNT) FROM AG_T_BANK_STATEMENT WHERE RECONSTATUS=1 AND TXTYPE='D' AND TXDT BETWEEN ? AND ?";
			query_rk2 = "SELECT COUNT(0), SUM(AMOUNT) FROM AG_T_BANK_STATEMENT WHERE RECONSTATUS=0 AND TXTYPE='D' AND TXDT BETWEEN ? AND ?";
			query_tcash = "SELECT COUNT(0), SUM(AMOUNT) FROM AG_V_TCASH_RECON_SRC WHERE refid not in (select refid from ag_t_bank_statement where refid is not null and reconstatus=1) AND TRX_TYPE='D' AND DEPOSIT_TIME BETWEEN ? AND ?";
			con = DbCon.getConnection();

			pstmt = con.prepareStatement(query_rk);
			pstmt.setDate(1, new java.sql.Date(dateFrom.getTime()));
			pstmt.setDate(2, new java.sql.Date(dateTo.getTime()));
			rs = pstmt.executeQuery();
			try {
				if (rs.next()) {
					match_rec = rs.getInt(1);
					match_amt = rs.getBigDecimal(2);
				} else {
					match_rec = 0;
					match_amt = java.math.BigDecimal.ZERO;
				}
			} catch (Exception e) {
				match_rec = 0;
				match_amt = java.math.BigDecimal.ZERO;
			}

			pstmt = con.prepareStatement(query_rk2);
			pstmt.setDate(1, new java.sql.Date(dateFrom.getTime()));
			pstmt.setDate(2, new java.sql.Date(dateTo.getTime()));
			rs = pstmt.executeQuery();
			try {
				if (rs.next()) {
					b_rec = rs.getInt(1);
					b_amt = rs.getBigDecimal(2);
				} else {
					b_rec = 0;
					b_amt = java.math.BigDecimal.ZERO;
				}
			} catch (Exception e) {
				b_rec = 0;
				b_amt = java.math.BigDecimal.ZERO;
			}

			pstmt = con.prepareStatement(query_tcash);
			pstmt.setDate(1, new java.sql.Date(dateFrom.getTime()));
			pstmt.setDate(2, new java.sql.Date(dateTo.getTime()));
			rs = pstmt.executeQuery();
			try {
				if (rs.next()) {
					t_rec = rs.getInt(1);
					t_amt = rs.getBigDecimal(2);
				} else {
					t_rec = 0;
					t_amt = java.math.BigDecimal.ZERO;
				}
			} catch (Exception e) {
				t_rec = 0;
				t_amt = java.math.BigDecimal.ZERO;
			}
		}

	} catch (Exception e) {
		e.printStackTrace();
		try {
			pstmt.close();
			con.close();
		} catch (Exception ee) {
			e.printStackTrace();
		}
	}
	if (match_amt == null)
		match_amt = BigDecimal.ZERO;
	if (b_amt == null)
		b_amt = BigDecimal.ZERO;
	if (t_amt == null)
		t_amt = BigDecimal.ZERO;
%>

<stripes:layout-render name="/web-starter/layout/standard.jsp"
	title="Bank Statement Reconcile">
	<stripes:layout-component name="contents">
		<font face="verdana" size="2"><a
			href='./bank_statement_upload.jsp?idLog1=<%=encLogin%>&idLog2=<%=encPass%>'>Upload
				Bank Statement File</a></font>
		<hr>
		<font face="verdana" size="2">|<a
			href="bank_statement_reconcile_s.jsp">Summary</a>|<a
			href="bank_statement_reconcile.jsp">Matches</a>|<a
			href="bank_statement_reconcile_t.jsp">TCash Only</a>|<a
			href="bank_statement_reconcile_b.jsp">Bank Only</a>|
		</font>
		<hr>
		<div id="printTable">
			<table width='70%' border='1' cellspacing='0' cellpadding='0'
				bordercolor='#FFF6EF'>
				<tr>
					<td colspan='9'><div align='left'>
							<form action="bank_statement_reconcile_s.jsp" method="post"
								name="formini" onsubmit="return validateSearch()">
								<font color='#CC6633' size='2'
									face='Verdana, Arial, Helvetica, sans-serif'><strong>From
										: </strong></font> <input readonly="readonly" type="text" name="from"
									value="<%=from == null ? "" : from%>" /> <a
									href="javascript:calendar('opener.document.formini.from.value');"><img
									src="${pageContext.request.contextPath}/STATIC/cal.gif"
									alt="Calendar" border="0" align="absmiddle"></a> <font
									color='#CC6633' size='2'
									face='Verdana, Arial, Helvetica, sans-serif'><strong>To
										: </strong></font> <input readonly="readonly" type="text" name="to"
									value="<%=to == null ? "" : to%>" /> <a
									href="javascript:calendar2('opener.document.formini.to.value');"><img
									src="${pageContext.request.contextPath}/STATIC/cal.gif"
									alt="Calendar" border="0" align="absmiddle"></a> <input
									type="submit" value="Search" />
							</form>
						</div></td>
				</tr>
				<tr>
					<td colspan='9'><div align='right'>
							<font color='#CC6633' size='2'
								face='Verdana, Arial, Helvetica, sans-serif'><strong>.::
									Summary Reconciliation -- CASH OUT::.</strong></font>
						</div></td>
				</tr>

				<tr>
					<td bgcolor='#CC6633'><div align='center'>
							<font color='#FFFFFF' size='1'
								face='Verdana, Arial, Helvetica, sans-serif'><strong>Total
									Row Match</strong></font>
						</div></td>
					<td bgcolor='#CC6633'><div align='center'>
							<font color='#FFFFFF' size='1'
								face='Verdana, Arial, Helvetica, sans-serif'><strong>Total
									Amount Match</strong></font>
						</div></td>
					<td bgcolor='#CC6633'><div align='center'>
							<font color='#FFFFFF' size='1'
								face='Verdana, Arial, Helvetica, sans-serif'><strong>Total
									Row TCash Only</strong></font>
						</div></td>
					<td bgcolor='#CC6633'><div align='center'>
							<font color='#FFFFFF' size='1'
								face='Verdana, Arial, Helvetica, sans-serif'><strong>Total
									Amount TCash Only</strong></font>
						</div></td>
					<td bgcolor='#CC6633'><div align='center'>
							<font color='#FFFFFF' size='1'
								face='Verdana, Arial, Helvetica, sans-serif'><strong>Total
									Row Bank Only</strong></font>
						</div></td>
					<td bgcolor='#CC6633'><div align='center'>
							<font color='#FFFFFF' size='1'
								face='Verdana, Arial, Helvetica, sans-serif'><strong>Total
									Amount Bank Only</strong></font>
						</div></td>
				</tr>

				<tr>
					<td valign="top"><div align='right'>
							<font size='1' face='Verdana, Arial, Helvetica, sans-serif'><%=formatter.format(match_rec)%></font>
						</div></td>
					<td valign="top"><div align='right'>
							<font size='1' face='Verdana, Arial, Helvetica, sans-serif'><a
								href="#" onclick="recondetail('md','<%=from%>','<%=to%>')"><%=formatter2.format(match_amt)%></a></font>
						</div></td>
					<td valign="top"><div align='right'>
							<font size='1' face='Verdana, Arial, Helvetica, sans-serif'><%=formatter.format(t_rec)%></font>
						</div></td>
					<td valign="top"><div align='right'>
							<font size='1' face='Verdana, Arial, Helvetica, sans-serif'><%=formatter2.format(t_amt)%></font>
						</div></td>
					<td valign="top"><div align='right'>
							<font size='1' face='Verdana, Arial, Helvetica, sans-serif'><%=formatter.format(b_rec)%></font>
						</div></td>
					<td valign="top"><div align='right'>
							<font size='1' face='Verdana, Arial, Helvetica, sans-serif'><a
								href="#" onclick="recondetail('bd','<%=from%>','<%=to%>')"><%=formatter2.format(b_amt)%></a></font>
						</div></td>
				</tr>
			</table>
			<br />

			<%
				int match_rec2 = 0;
						int t_rec2 = 0;
						int b_rec2 = 0;

						java.math.BigDecimal match_amt2 = java.math.BigDecimal.ZERO;
						java.math.BigDecimal t_amt2 = java.math.BigDecimal.ZERO;
						java.math.BigDecimal b_amt2 = java.math.BigDecimal.ZERO;

						if ("POST".equalsIgnoreCase(request.getMethod())) {
							from = request.getParameter("from");
							to = request.getParameter("to");
						}
						try {
							//check if is it filter request
							if ((from != null) && (to != null) && ("POST".equalsIgnoreCase(request.getMethod()))) {
								sdf = new SimpleDateFormat("d-M-yyyy");
								System.out.println("search : " + from);
								System.out.println("searchvalue : " + to);
								dateFrom = sdf.parse(from);
								dateTo = sdf.parse(to);
								query_rk = "SELECT COUNT(0), SUM(AMOUNT) FROM AG_T_BANK_STATEMENT WHERE RECONSTATUS=1 AND TXTYPE='C' AND TXDT BETWEEN ? AND ?";
								query_rk2 = "SELECT COUNT(0), SUM(AMOUNT) FROM AG_T_BANK_STATEMENT WHERE RECONSTATUS=0 AND TXTYPE='C' AND TXDT BETWEEN ? AND ?";
								query_tcash = "SELECT COUNT(0), SUM(AMOUNT) FROM AG_V_TCASH_RECON_SRC WHERE refid not in (select refid from ag_t_bank_statement where refid is not null and reconstatus=1) AND TRX_TYPE='C' AND DEPOSIT_TIME BETWEEN ? AND ?";
								con = DbCon.getConnection();

								pstmt = con.prepareStatement(query_rk);
								pstmt.setDate(1, new java.sql.Date(dateFrom.getTime()));
								pstmt.setDate(2, new java.sql.Date(dateTo.getTime()));
								rs = pstmt.executeQuery();
								try {
									if (rs.next()) {
										match_rec2 = rs.getInt(1);
										match_amt2 = rs.getBigDecimal(2);
									} else {
										match_rec2 = 0;
										match_amt2 = java.math.BigDecimal.ZERO;
									}
								} catch (Exception e) {
									match_rec2 = 0;
									match_amt2 = java.math.BigDecimal.ZERO;
								}

								pstmt = con.prepareStatement(query_rk2);
								pstmt.setDate(1, new java.sql.Date(dateFrom.getTime()));
								pstmt.setDate(2, new java.sql.Date(dateTo.getTime()));
								rs = pstmt.executeQuery();
								try {
									if (rs.next()) {
										b_rec2 = rs.getInt(1);
										b_amt2 = rs.getBigDecimal(2);
									} else {
										b_rec2 = 0;
										b_amt2 = java.math.BigDecimal.ZERO;
									}
								} catch (Exception e) {
									b_rec2 = 0;
									b_amt2 = java.math.BigDecimal.ZERO;
								}

								pstmt = con.prepareStatement(query_tcash);
								pstmt.setDate(1, new java.sql.Date(dateFrom.getTime()));
								pstmt.setDate(2, new java.sql.Date(dateTo.getTime()));
								rs = pstmt.executeQuery();
								try {
									if (rs.next()) {
										t_rec2 = rs.getInt(1);
										t_amt2 = rs.getBigDecimal(2);
									} else {
										t_rec2 = 0;
										t_amt2 = java.math.BigDecimal.ZERO;
									}
								} catch (Exception e) {
									t_rec2 = 0;
									t_amt2 = java.math.BigDecimal.ZERO;
								}
							}

						} catch (Exception e) {
							e.printStackTrace();
							try {
								pstmt.close();
								con.close();
							} catch (Exception ee) {
								e.printStackTrace();
							}
						}
						if (match_amt2 == null)
							match_amt2 = BigDecimal.ZERO;
						if (b_amt2 == null)
							b_amt2 = BigDecimal.ZERO;
						if (t_amt2 == null)
							t_amt2 = BigDecimal.ZERO;
			%>
			<table width='70%' border='1' cellspacing='0' cellpadding='0'
				bordercolor='#FFF6EF'>
				<!--<TR>
				<td colspan="9"><div align='left'>
						 <input type="submit" value="Send to OASIS" /> <input
							type="submit" value="Send to REDBRICK" />
					</div></td>
			</TR>-->
				<tr>
					<td colspan='9'><div align='right'>
							<font color='#CC6633' size='2'
								face='Verdana, Arial, Helvetica, sans-serif'><strong>.::
									Summary Reconciliation -- CASH IN::.</strong></font>
						</div></td>
				</tr>
				<!-- <tr>
				<td colspan='9'><div align='left'>
						<form action="bank_statement_reconcile_s.jsp" method="post"
							name="formini" onsubmit="return validateSearch()">
							<font color='#CC6633' size='2'
								face='Verdana, Arial, Helvetica, sans-serif'><strong>From
									: </strong></font> <input readonly="readonly" type="text" name="from"
								value="<%=from == null ? "" : from%>" /> <a
								href="javascript:calendar('opener.document.formini.from.value');"><img
								src="${pageContext.request.contextPath}/STATIC/cal.gif"
								alt="Calendar" border="0" align="absmiddle"></a> <font
								color='#CC6633' size='2'
								face='Verdana, Arial, Helvetica, sans-serif'><strong>To
									: </strong></font> <input readonly="readonly" type="text" name="to"
								value="<%=to == null ? "" : to%>" /> <a
								href="javascript:calendar2('opener.document.formini.to.value');"><img
								src="${pageContext.request.contextPath}/STATIC/cal.gif"
								alt="Calendar" border="0" align="absmiddle"></a> <input
								type="submit" value="Search" />
						</form>
					</div></td>
			</tr> -->
				<tr>
					<td bgcolor='#CC6633'><div align='center'>
							<font color='#FFFFFF' size='1'
								face='Verdana, Arial, Helvetica, sans-serif'><strong>Total
									Row Match</strong></font>
						</div></td>
					<td bgcolor='#CC6633'><div align='center'>
							<font color='#FFFFFF' size='1'
								face='Verdana, Arial, Helvetica, sans-serif'><strong>Total
									Amount Match</strong></font>
						</div></td>
					<td bgcolor='#CC6633'><div align='center'>
							<font color='#FFFFFF' size='1'
								face='Verdana, Arial, Helvetica, sans-serif'><strong>Total
									Row TCash Only</strong></font>
						</div></td>
					<td bgcolor='#CC6633'><div align='center'>
							<font color='#FFFFFF' size='1'
								face='Verdana, Arial, Helvetica, sans-serif'><strong>Total
									Amount TCash Only</strong></font>
						</div></td>
					<td bgcolor='#CC6633'><div align='center'>
							<font color='#FFFFFF' size='1'
								face='Verdana, Arial, Helvetica, sans-serif'><strong>Total
									Row Bank Only</strong></font>
						</div></td>
					<td bgcolor='#CC6633'><div align='center'>
							<font color='#FFFFFF' size='1'
								face='Verdana, Arial, Helvetica, sans-serif'><strong>Total
									Amount Bank Only</strong></font>
						</div></td>
				</tr>

				<tr>
					<td valign="top"><div align='right'>
							<font size='1' face='Verdana, Arial, Helvetica, sans-serif'><%=formatter.format(match_rec2)%></font>
						</div></td>
					<td valign="top"><div align='right'>
							<font size='1' face='Verdana, Arial, Helvetica, sans-serif'><a
								href="#" onclick="recondetail('mc','<%=from%>','<%=to%>')"><%=formatter2.format(match_amt2)%></a></font>
						</div></td>
					<td valign="top"><div align='right'>
							<font size='1' face='Verdana, Arial, Helvetica, sans-serif'><%=formatter.format(t_rec2)%></font>
						</div></td>
					<td valign="top"><div align='right'>
							<font size='1' face='Verdana, Arial, Helvetica, sans-serif'><%=formatter2.format(t_amt2)%></font>
						</div></td>
					<td valign="top"><div align='right'>
							<font size='1' face='Verdana, Arial, Helvetica, sans-serif'><%=formatter.format(b_rec2)%></font>
						</div></td>
					<td valign="top"><div align='right'>
							<font size='1' face='Verdana, Arial, Helvetica, sans-serif'><a
								href="#" onclick="recondetail('bc','<%=from%>','<%=to%>')"><%=formatter2.format(b_amt2)%></a></font>
						</div></td>
				</tr>
			</table>
			<br />
			<%
				int match_rec3 = 0;
						int t_rec3 = 0;
						int b_rec3 = 0;

						java.math.BigDecimal match_amt3 = java.math.BigDecimal.ZERO;
						java.math.BigDecimal t_amt3 = java.math.BigDecimal.ZERO;
						java.math.BigDecimal b_amt3 = java.math.BigDecimal.ZERO;

						if ("POST".equalsIgnoreCase(request.getMethod())) {
							from = request.getParameter("from");
							to = request.getParameter("to");
						}
						try {
							//check if is it filter request
							if ((from != null) && (to != null) && ("POST".equalsIgnoreCase(request.getMethod()))) {
								sdf = new SimpleDateFormat("d-M-yyyy");
								System.out.println("search : " + from);
								System.out.println("searchvalue : " + to);
								dateFrom = sdf.parse(from);
								dateTo = sdf.parse(to);
								query_rk = "SELECT COUNT(0), SUM(AMOUNT) FROM AG_T_BANK_STATEMENT WHERE RECONSTATUS=1 AND TXDT BETWEEN ? AND ?";
								query_rk2 = "SELECT COUNT(0), SUM(AMOUNT) FROM AG_T_BANK_STATEMENT WHERE RECONSTATUS=0 AND TXDT BETWEEN ? AND ?";
								query_tcash = "SELECT COUNT(0), SUM(AMOUNT) FROM AG_V_TCASH_RECON_SRC WHERE refid not in (select refid from ag_t_bank_statement where refid is not null and reconstatus=1) AND DEPOSIT_TIME BETWEEN ? AND ?";
								con = DbCon.getConnection();

								pstmt = con.prepareStatement(query_rk);
								pstmt.setDate(1, new java.sql.Date(dateFrom.getTime()));
								pstmt.setDate(2, new java.sql.Date(dateTo.getTime()));
								rs = pstmt.executeQuery();
								try {
									if (rs.next()) {
										match_rec3 = rs.getInt(1);
										match_amt3 = rs.getBigDecimal(2);
									} else {
										match_rec3 = 0;
										match_amt3 = java.math.BigDecimal.ZERO;
									}
								} catch (Exception e) {
									match_rec3 = 0;
									match_amt3 = java.math.BigDecimal.ZERO;
								}

								pstmt = con.prepareStatement(query_rk2);
								pstmt.setDate(1, new java.sql.Date(dateFrom.getTime()));
								pstmt.setDate(2, new java.sql.Date(dateTo.getTime()));
								rs = pstmt.executeQuery();
								try {
									if (rs.next()) {
										b_rec3 = rs.getInt(1);
										b_amt3 = rs.getBigDecimal(2);
									} else {
										b_rec3 = 0;
										b_amt3 = java.math.BigDecimal.ZERO;
									}
								} catch (Exception e) {
									b_rec3 = 0;
									b_amt3 = java.math.BigDecimal.ZERO;
								}

								pstmt = con.prepareStatement(query_tcash);
								pstmt.setDate(1, new java.sql.Date(dateFrom.getTime()));
								pstmt.setDate(2, new java.sql.Date(dateTo.getTime()));
								rs = pstmt.executeQuery();
								try {
									if (rs.next()) {
										t_rec3 = rs.getInt(1);
										t_amt3 = rs.getBigDecimal(2);
									} else {
										t_rec3 = 0;
										t_amt3 = java.math.BigDecimal.ZERO;
									}
								} catch (Exception e) {
									t_rec3 = 0;
									t_amt3 = java.math.BigDecimal.ZERO;
								}
							}

						} catch (Exception e) {
							e.printStackTrace();
							try {
								pstmt.close();
								con.close();
							} catch (Exception ee) {
								e.printStackTrace();
							}
						}
						if (match_amt3 == null)
							match_amt3 = BigDecimal.ZERO;
						if (b_amt3 == null)
							b_amt3 = BigDecimal.ZERO;
						if (t_amt3 == null)
							t_amt3 = BigDecimal.ZERO;
			%>
			<table width='70%' border='1' cellspacing='0' cellpadding='0'
				bordercolor='#FFF6EF'>
				<!--<TR>
				<td colspan="9"><div align='left'>
						 <input type="submit" value="Send to OASIS" /> <input
							type="submit" value="Send to REDBRICK" />
					</div></td>
			</TR>-->
				<tr>
					<td colspan='9'><div align='right'>
							<font color='#CC6633' size='2'
								face='Verdana, Arial, Helvetica, sans-serif'><strong>.::
									Summary Reconciliation -- TOTAL::.</strong></font>
						</div></td>
				</tr>
				<!-- <tr>
				<td colspan='9'><div align='left'>
						<form action="bank_statement_reconcile_s.jsp" method="post"
							name="formini" onsubmit="return validateSearch()">
							<font color='#CC6633' size='2'
								face='Verdana, Arial, Helvetica, sans-serif'><strong>From
									: </strong></font> <input readonly="readonly" type="text" name="from"
								value="<%=from == null ? "" : from%>" /> <a
								href="javascript:calendar('opener.document.formini.from.value');"><img
								src="${pageContext.request.contextPath}/STATIC/cal.gif"
								alt="Calendar" border="0" align="absmiddle"></a> <font
								color='#CC6633' size='2'
								face='Verdana, Arial, Helvetica, sans-serif'><strong>To
									: </strong></font> <input readonly="readonly" type="text" name="to"
								value="<%=to == null ? "" : to%>" /> <a
								href="javascript:calendar2('opener.document.formini.to.value');"><img
								src="${pageContext.request.contextPath}/STATIC/cal.gif"
								alt="Calendar" border="0" align="absmiddle"></a> <input
								type="submit" value="Search" />
						</form>
					</div></td>
			</tr> -->
				<tr>
					<td bgcolor='#CC6633'><div align='center'>
							<font color='#FFFFFF' size='1'
								face='Verdana, Arial, Helvetica, sans-serif'><strong>Total
									Row Match</strong></font>
						</div></td>
					<td bgcolor='#CC6633'><div align='center'>
							<font color='#FFFFFF' size='1'
								face='Verdana, Arial, Helvetica, sans-serif'><strong>Total
									Amount Match</strong></font>
						</div></td>
					<td bgcolor='#CC6633'><div align='center'>
							<font color='#FFFFFF' size='1'
								face='Verdana, Arial, Helvetica, sans-serif'><strong>Total
									Row TCash Only</strong></font>
						</div></td>
					<td bgcolor='#CC6633'><div align='center'>
							<font color='#FFFFFF' size='1'
								face='Verdana, Arial, Helvetica, sans-serif'><strong>Total
									Amount TCash Only</strong></font>
						</div></td>
					<td bgcolor='#CC6633'><div align='center'>
							<font color='#FFFFFF' size='1'
								face='Verdana, Arial, Helvetica, sans-serif'><strong>Total
									Row Bank Only</strong></font>
						</div></td>
					<td bgcolor='#CC6633'><div align='center'>
							<font color='#FFFFFF' size='1'
								face='Verdana, Arial, Helvetica, sans-serif'><strong>Total
									Amount Bank Only</strong></font>
						</div></td>
				</tr>

				<tr>
					<td valign="top"><div align='right'>
							<font size='1' face='Verdana, Arial, Helvetica, sans-serif'><%=formatter.format(match_rec3)%></font>
						</div></td>
					<td valign="top"><div align='right'>
							<font size='1' face='Verdana, Arial, Helvetica, sans-serif'><a
								href="#" onclick="recondetail('ma','<%=from%>','<%=to%>')"><%=formatter2.format(match_amt3)%></a></font>
						</div></td>
					<td valign="top"><div align='right'>
							<font size='1' face='Verdana, Arial, Helvetica, sans-serif'><%=formatter.format(t_rec3)%></font>
						</div></td>
					<td valign="top"><div align='right'>
							<font size='1' face='Verdana, Arial, Helvetica, sans-serif'><%=formatter2.format(t_amt3)%></font>
						</div></td>
					<td valign="top"><div align='right'>
							<font size='1' face='Verdana, Arial, Helvetica, sans-serif'><%=formatter.format(b_rec3)%></font>
						</div></td>
					<td valign="top"><div align='right'>
							<font size='1' face='Verdana, Arial, Helvetica, sans-serif'><a
								href="#" onclick="recondetail('ba','<%=from%>','<%=to%>')"><%=formatter2.format(b_amt3)%></a></font>
						</div></td>
				</tr>
			</table>
		</div>
		<!-- <a href="#" onclick="printData();"> Print </a> -->
		<!-- <button id="cetak" onclick="window.print();">Print</button> -->
	</stripes:layout-component>
</stripes:layout-render>
