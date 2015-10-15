<%@page import="java.io.*, java.util.*, java.text.*, java.sql.*"%>
<%@ include file="/web-starter/taglibs.jsp"%>
<%@page import="com.telkomsel.itvas.webstarter.User"%>

<jsp:useBean id="reg" scope="request" class="tsel_tunai.Register2Bean"></jsp:useBean>
<jsp:useBean id="DbCon" scope="page" class="tsel_tunai.DbCon"></jsp:useBean>
<script type="text/javascript">
	function validateSearch() {
		var y = document.forms["formini"]["search"].value;
		var x = document.forms["formini"]["searchvalue"].value;
		var m = "";
		var numbers = /^[0-9]+$/;
		if (y == "refid" || y == "amount" || y == "merchant_id") {
			if (!x.match(numbers)) {
				m += y + " must be number only\n";
			}
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
						"tcash_export_csv.jsp?token=" + prm,
						"export",
						"toolbar=no, location=no, scrollbars=yes, resizable=yes, top=500, left=500, width=400, height=400")
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
</script>
<%
	User user = (User) session.getValue("user");

	SimpleDateFormat sdf2 = new SimpleDateFormat("d-M-yyyy");
	SimpleDateFormat sdf3 = new SimpleDateFormat("yyyy-MM-dd");
	java.util.Date today = Calendar.getInstance().getTime();
	String from = "1" + sdf2.format(today).substring(2);
	String to = sdf2.format(today);
	java.util.Date dateFrom = null;
	java.util.Date dateTo = null;

	String searchBy = "";
	String searchVal = "";
	String where = "";
	String encQ = "";

	searchBy = request.getParameter("search");
	searchVal = request.getParameter("searchvalue");

	//check if is it filter request
	if ((searchBy != null) && ("POST".equalsIgnoreCase(request.getMethod()))) {
		from = request.getParameter("from");
		to = request.getParameter("to");
		System.out.println("search : " + searchBy);
		System.out.println("searchvalue : " + searchVal);
		System.out.println("from : " + from);
		System.out.println("to : " + to);
		where = " AND " + searchBy.toUpperCase()
				+ ("description".equalsIgnoreCase(searchBy) ? " LIKE '%" : " = ") + searchVal
				+ ("description".equalsIgnoreCase(searchBy) ? "%'" : "");
		System.out.println("where : " + where);
	}
	where += " AND to_date(DEPOSIT_TIME) BETWEEN to_date(\'" + sdf3.format(sdf2.parse(from))
			+ "\',\'yyyy-MM-dd\') AND to_date(\'" + sdf3.format(sdf2.parse(to)) + "\',\'yyyy-MM-dd\') ";
	String encLogin = user.getUsername();
	String encPass = user.getPassword();
	String query = "";
	int minPaging = 0;
	int maxPaging = 0;
	int cur_page = 1;
	int start_row = 0;
	int end_row = 0;
	String pageScript = "";
	int jumlah = 0;
	SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
	//Databse Access Variable
	Connection con = null;
	Statement stmt = null;
	PreparedStatement pstmt = null;
	ResultSet rs = null;
	try {
		con = DbCon.getConnection();
		query = "SELECT count(1) FROM (SELECT ROWNUM rnum,a.* FROM (SELECT * FROM AG_V_TCASH_RECON_SRC where IS_EXECUTED=3 and refid not in (select refid from ag_t_bank_statement where refid is not null and reconstatus=0) "
				+ where + " order by TRX_TYPE,REFID) a)";
		pstmt = con.prepareStatement(query);
		rs = pstmt.executeQuery();
		if (rs.next()) {
			jumlah = rs.getInt(1);
		}

		cur_page = 1;
		if (request.getParameter("cur_page") != null) {
			cur_page = Integer.parseInt(request.getParameter("cur_page"));
		}
		int row_per_page = 20;
		start_row = (cur_page - 1) * row_per_page + 1;
		end_row = start_row + row_per_page - 1;
		int total_page = (jumlah / row_per_page) + 1;
		if (jumlah % row_per_page == 0) {
			total_page--;
		}
		//out.println("Page : ");
		pageScript = "Page : ";
		minPaging = cur_page - 5;
		if (minPaging < 1) {
			minPaging = 1;
		}
		maxPaging = cur_page + 5;
		if (maxPaging > total_page) {
			maxPaging = total_page;
		}
		if (minPaging - 1 > 0) {
			//out.print("<a class='link' href='?cur_page=" + (minPaging - 1) + "'>&lt;</a> ");
			pageScript += "<a class='link' href='?cur_page=" + (minPaging - 1) + "'>&lt;</a> ";
		}
		for (int i = minPaging; i <= maxPaging; i++) {
			if (i == cur_page) {
				//out.print(i + " ");
				pageScript += "<span style='color:black;'>" + i + "</span> ";
			} else {
				//out.print("<a class='link' href='?cur_page=" + i + "'>" + i + "</a> ");
				pageScript += "<a class='link' href='?cur_page=" + i + "'>" + i + "</a> ";
			}
		}
		if (maxPaging + 1 <= total_page) {
			//out.print("<a class='link' href='?cur_page=" + (maxPaging + 1) + "'>&gt;</a> ");
			pageScript += "<a class='link' href='?cur_page=" + (maxPaging + 1) + "'>&gt;</a> ";
		}

		query = "SELECT * FROM (SELECT ROWNUM rnum,a.* FROM (SELECT * FROM AG_V_TCASH_RECON_SRC where IS_EXECUTED=3 and refid not in (select refid from ag_t_bank_statement where refid is not null and reconstatus=0) "
				+ where + " order by TRX_TYPE,REFID) a) WHERE rnum BETWEEN ? AND ?";
		pstmt = con.prepareStatement(query);
		pstmt.setInt(1, start_row);
		pstmt.setInt(2, end_row);
		rs = pstmt.executeQuery();
		encQ = new String(org.apache.commons.codec.binary.Base64.encodeBase64(query.getBytes()));
		//encQ = query.replace("\'", "#");
	} catch (Exception e) {
		e.printStackTrace();
	}
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
		<table width='70%' border='1' cellspacing='0' cellpadding='0'
			bordercolor='#FFF6EF'>
			<tr>
				<td colspan='4'><div align='left'>
						<font color='#CC6633' size='2'
							face='Verdana, Arial, Helvetica, sans-serif'><strong><%=pageScript%></strong></font>
					</div></td>
				<td colspan='3'><div align='right'>
						<font color='#CC6633' size='2'
							face='Verdana, Arial, Helvetica, sans-serif'><strong>.::
								TCash Only ::.</strong></font>
					</div></td>
			</tr>
			<form action="bank_statement_reconcile_t.jsp" method="post"
				name="formini" onsubmit="return validateSearch()">
			<tr>
				<td colspan='7'><div align='left'>

						<font color='#CC6633' size='2'
							face='Verdana, Arial, Helvetica, sans-serif'><strong>Search
								by : </strong></font> <select name="search" style="width: 100px;"><option
								value="description"
								<%="description".equalsIgnoreCase(searchBy) ? "selected='selected'" : ""%>>Description</option>
							<option value="amount"
								<%="amount".equalsIgnoreCase(searchBy) ? "selected='selected'" : ""%>>Amount</option>
							<option value="refid"
								<%="refid".equalsIgnoreCase(searchBy) ? "selected='selected'" : ""%>>CashID</option>
							<option value="merchant_id"
								<%="merchant_id".equalsIgnoreCase(searchBy) ? "selected='selected'" : ""%>>MerchantID</option>
						</select> <input type="text" name="searchvalue"
							value="<%=searchVal == null ? "" : searchVal%>" /><input
							type="submit" value="Search" /> <a href="#"
							onclick="exportcsv('<%=encQ%>')"><font size='2'>Export
								CSV</font></a>
						<!-- </form> -->

					</div></td>
			</tr>
			<tr>
				<td colspan='7'><div align='left'>
						<!-- <form action="bank_statement_reconcile_s.jsp" method="post"
							name="formini" onsubmit="return validateSearch()"> -->
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
							alt="Calendar" border="0" align="absmiddle"></a>
						<!-- <input
								type="submit" value="Search" /> -->

					</div></td>
			</tr>
			</form>
			<tr>
				<td bgcolor='#CC6633'><div align='center'>
						<font color='#FFFFFF' size='1'
							face='Verdana, Arial, Helvetica, sans-serif'><strong>ID</strong></font>
					</div></td>
				<td bgcolor='#CC6633'><div align='center'>
						<font color='#FFFFFF' size='1'
							face='Verdana, Arial, Helvetica, sans-serif'><strong>Merchant</strong></font>
					</div></td>
				<td bgcolor='#CC6633'><div align='center'>
						<font color='#FFFFFF' size='1'
							face='Verdana, Arial, Helvetica, sans-serif'><strong>Amount</strong></font>
					</div></td>
				<td bgcolor='#CC6633'><div align='center'>
						<font color='#FFFFFF' size='1'
							face='Verdana, Arial, Helvetica, sans-serif'><strong>Description</strong></font>
					</div></td>
				<td bgcolor='#CC6633'><div align='center'>
						<font color='#FFFFFF' size='1'
							face='Verdana, Arial, Helvetica, sans-serif'><strong>Date</strong></font>
					</div></td>
				<td bgcolor='#CC6633'><div align='center'>
						<font color='#FFFFFF' size='1'
							face='Verdana, Arial, Helvetica, sans-serif'><strong>Executed</strong></font>
					</div></td>
				<td bgcolor='#CC6633'><div align='center'>
						<font color='#FFFFFF' size='1'
							face='Verdana, Arial, Helvetica, sans-serif'><strong>DbCr</strong></font>
					</div></td>
			</tr>
			<%
				try {
							while (rs.next()) {
			%>
			<tr>
				<td valign="top"><div align='left'>
						<font size='1' face='Verdana, Arial, Helvetica, sans-serif'><%=rs.getString(2)%></font>
					</div></td>
				<td valign="top"><div align='left'>
						<font size='1' face='Verdana, Arial, Helvetica, sans-serif'><%=rs.getString(3)%></font>
					</div></td>
				<td valign="top"><div align='right'>
						<font size='1' face='Verdana, Arial, Helvetica, sans-serif'><%=new DecimalFormat("###,###,###").format(rs.getDouble(4))%></font>
					</div></td>
				<td valign="top"><div align='left'>
						<font size='1' face='Verdana, Arial, Helvetica, sans-serif'><%=rs.getString(5)%></font>
					</div></td>
				<td valign="top"><div align='left'>
						<font size='1' face='Verdana, Arial, Helvetica, sans-serif'><%=sdf.format(rs.getDate(6))%></font>
					</div></td>
				<td valign="top"><div align='left'>
						<font size='1' face='Verdana, Arial, Helvetica, sans-serif'><%=rs.getString(7)%></font>
					</div></td>
				<td valign="top"><div align='left'>
						<font size='1' face='Verdana, Arial, Helvetica, sans-serif'><%=rs.getString(8)%></font>
					</div></td>
			</tr>
			<%
				}
						} catch (Exception e) {

						}
						pstmt.close();
						con.close();
			%>
		</table>
	</stripes:layout-component>
</stripes:layout-render>
