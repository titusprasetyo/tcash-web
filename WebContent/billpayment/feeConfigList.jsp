<%@page import="tsel_tunai.Util"%>
<%@ page import="java.sql.*"%>
<%@page import="org.apache.commons.lang.StringEscapeUtils"%>
<%@ include file="/web-starter/taglibs.jsp"%>
<stripes:layout-render name="/web-starter/layout/standard.jsp"
	title="Fee Config List">
	<stripes:layout-component name="contents">
		<jsp:useBean id="DbCon" scope="page" class="tsel_tunai.DbCon"></jsp:useBean>
		<%@page import="com.telkomsel.itvas.webstarter.User"%>
		<%
			User user = (User) session.getValue("user");
					String name = StringEscapeUtils.escapeHtml(request
							.getParameter("name"));
					if (name == null) {
						name = "";
					}
					session.putValue("user", user);

					Connection conn = null;
					try {
						conn = DbCon.getConnection();
		%>
		<div align="right">
			<font color="#FFFFFF" face="Verdana, Arial, Helvetica, sans-serif"></font>
		</div>
		<div align="right"></div>
		<div align="right"></div>

		<table border="0" cellpadding="0" cellspacing="0">
			<tr>
				<td><div align="right">
						<font color="#CC6633" size="4"
							face="Verdana, Arial, Helvetica, sans-serif"><strong></strong>
						</font>
					</div></td>
			</tr>

		</table>
		<form name="form" method="post" action="feeConfigList.jsp">
			<table width="21%" border="0" cellspacing="0" cellpadding="0">
				<tr bgcolor="#CC6633">
					<td colspan="2"><div align="center">
							<font color="#FFFFFF" size="1"
								face="Verdana, Arial, Helvetica, sans-serif"><strong>Search
									Merchant Name</strong> </font>
						</div></td>
				</tr>
				<tr>					
					<td><input name="name" type="text">
					</td>
					<td width="30%"><input type="submit" name="Submit"
						value="Submit"></td>
				</tr>
			</table>
		</form>

		<br>
		<%
			if (StringEscapeUtils.escapeHtml(request
								.getParameter("msg")) != null) {
							out.println("<font color='#999999' size='1' "
									+" face='Verdana, Arial, Helvetica, sans-serif'><center><strong>"
									+ request.getParameter("msg")
									+ "</center></strong></font><br><br>");
						}
		%>
		<table width="50%" border="1" cellspacing="0" cellpadding="0"
			bordercolor="#FFF6EF">
			<tr bgcolor="#FFF6EF">
				<td colspan="10">
					<div align="left">
						<input type="button" value="Add" onclick="JavaScript:window.location='feeConfigInput.jsp';">
					</div>
				</td>
			</tr>
			<tr>
				<td bgcolor="#CC6633" >
						<font color="#FFFFFF" size="1"
							face="Verdana, Arial, Helvetica, sans-serif"><strong>Transaction
											Type</strong> </font>
				</td>
				<td bgcolor="#CC6633" >
						<font color="#FFFFFF" size="1"
							face="Verdana, Arial, Helvetica, sans-serif"><strong>Source</strong>
						</font>
				</td>
				<td bgcolor="#CC6633" >
						<font color="#FFFFFF" size="1"
							face="Verdana, Arial, Helvetica, sans-serif"><strong>Bearer</strong>
						</font>
				</td>
				<td bgcolor="#CC6633" align="center">
						<font color="#FFFFFF" size="1"
							face="Verdana, Arial, Helvetica, sans-serif"><strong>Merchant|Terminal</strong>
						</font>
				</td>
				<td bgcolor="#CC6633" align="center">
						<font color="#FFFFFF" size="1"
							face="Verdana, Arial, Helvetica, sans-serif"><strong>Merchant Name</strong>
						</font>
				</td>
				<td bgcolor="#CC6633" align="center" >
						<font color="#FFFFFF" size="1"
							face="Verdana, Arial, Helvetica, sans-serif"><strong>Customer
											Fee</strong>
						</font>
				</td>
				<td bgcolor="#CC6633" style="width:10px" align="center">
						<font color="#FFFFFF" size="1"
							face="Verdana, Arial, Helvetica, sans-serif"><strong>Merchant
											Fee</strong>
						</font>
				</td>
				<td bgcolor="#CC6633" >
						<font color="#FFFFFF" size="1"
							face="Verdana, Arial, Helvetica, sans-serif"><strong>Status</strong>
						</font>
				</td>
				<td bgcolor="#CC6633" >
						<font color="#FFFFFF" size="1"
							face="Verdana, Arial, Helvetica, sans-serif"><strong>Trx
											Desc</strong>
						</font>
				</td>
				<td bgcolor="#CC6633">
						<font color="#FFFFFF" size="1"
							face="Verdana, Arial, Helvetica, sans-serif"><strong>Edit</strong>
						</font>
				</td>
			</tr>
			
			<%
							String sql = "";
							 if(!name.equals("")){
								sql = "select count(*) as jumlah from (select fg.trx_type, fg.source, fg.bearer, "
									+"fg.merchant_id, fg.customer_fee, fg.merchant_fee, fg.status, fg.trx_description, mi.name "
									+"from fee_config fg, merchant m, merchant_info mi "
									+"where m.merchant_info_id = mi.merchant_info_id "
									+"and m.merchant_id = substr(fg.merchant_id,1, decode(instr(fg.merchant_id,'|') , 0, length(fg.merchant_id), instr(fg.merchant_id,'|') - 1)) "
									+"and lower(mi.name) like ? "
									+"union "
									+"select fg.trx_type, fg.source, fg.bearer,  "
									+"fg.merchant_id, fg.customer_fee, fg.merchant_fee, fg.status, fg.trx_description, mi.name "
									+"from fee_config fg, merchant m, merchant_info mi "
									+"where m.merchant_info_id = mi.merchant_info_id(+) "
									+"and m.merchant_id(+) = fg.merchant_id "
									+"and (instr(fg.merchant_id,'|')) = 0 "
									+"and lower(mi.name) like ? "
									+ " ) ";
							}else{
								sql = "select count(*) as jumlah from fee_config fg";
							} 
							
							PreparedStatement pstmt = conn.prepareStatement(sql);
							if(!name.equals("")){
								pstmt.setString(1, name.toLowerCase() + "%");
								pstmt.setString(2, name.toLowerCase() + "%");
							}
							ResultSet rs = pstmt.executeQuery();
							int jumlah = 0;
							if (rs.next()) {
								jumlah = rs.getInt("jumlah");
							}
							rs.close();
							pstmt.close();
							sql = null;
							rs = null;
							pstmt = null;

							int cur_page = 1;
							if (request.getParameter("cur_page") != null) {
								cur_page = Integer.parseInt(request
										.getParameter("cur_page"));
							}
							int row_per_page = 50;
							int start_row = (cur_page - 1) * row_per_page + 1;
							int end_row = start_row + row_per_page - 1;
							int total_page = (jumlah / row_per_page) + 1;
							if (jumlah % row_per_page == 0) {
								total_page--;
							}
							out.println("Page : ");
							int minPaging = cur_page - 5;
							if (minPaging < 1) {
								minPaging = 1;
							}
							int maxPaging = cur_page + 5;
							if (maxPaging > total_page) {
								maxPaging = total_page;
							}
							if (minPaging - 1 > 0) {
								out.print("<a class='link' href='?cur_page="
										+ (minPaging - 1) + "&name=" + name
										+ "'>&lt;</a> ");
							}
							for (int i = minPaging; i <= maxPaging; i++) {
								if (i == cur_page) {
									out.print(i + " ");
								} else {
									out.print("<a class='link' href='?cur_page="
											+ i + "&name=" + name + "'>" + i
											+ "</a> ");
								}
							}
							if (maxPaging + 1 <= total_page) {
								out.print("<a class='link' href='?cur_page="
										+ (maxPaging + 1) + "&name=" + name
										+ "'>&gt;</a> ");
							}

							// end of paging stuff
							if(!name.equals("")){
								sql = "select * FROM (select a.*, ROWNUM rnum from (select fg.trx_type, fg.source, fg.bearer, "
									+"fg.merchant_id, fg.customer_fee, fg.merchant_fee, fg.status, fg.trx_description, mi.name "
									+"from fee_config fg, merchant m, merchant_info mi "
									+"where m.merchant_info_id = mi.merchant_info_id "
									+"and m.merchant_id = substr(fg.merchant_id,1, decode(instr(fg.merchant_id,'|') , 0, length(fg.merchant_id), instr(fg.merchant_id,'|') - 1)) "
									+"and lower(mi.name) like ? "
									+"union "
									+"select fg.trx_type, fg.source, fg.bearer,  "
									+"fg.merchant_id, fg.customer_fee, fg.merchant_fee, fg.status, fg.trx_description, mi.name "
									+"from fee_config fg, merchant m, merchant_info mi "
									+"where m.merchant_info_id = mi.merchant_info_id(+) "
									+"and m.merchant_id(+) = fg.merchant_id "
									+"and (instr(fg.merchant_id,'|')) = 0 "
									+"and lower(mi.name) like ? "
									+"order by trx_type, source, bearer, merchant_id"
									+ " ) a where ROWNUM <= ?) where rnum >= ?";
								
							}else{
								sql = "select * FROM (select a.*, ROWNUM rnum from (select fg.trx_type, fg.source, fg.bearer, "
									+"fg.merchant_id, fg.customer_fee, fg.merchant_fee, fg.status, fg.trx_description, mi.name "
									+"from fee_config fg, merchant m, merchant_info mi "
									+"where m.merchant_info_id = mi.merchant_info_id "
									+"and m.merchant_id = substr(fg.merchant_id,1, decode(instr(fg.merchant_id,'|') , 0, length(fg.merchant_id), instr(fg.merchant_id,'|') - 1)) "
									+"union "
									+"select fg.trx_type, fg.source, fg.bearer,  "
									+"fg.merchant_id, fg.customer_fee, fg.merchant_fee, fg.status, fg.trx_description, mi.name "
									+"from fee_config fg, merchant m, merchant_info mi "
									+"where m.merchant_info_id = mi.merchant_info_id(+) "
									+"and m.merchant_id(+) = fg.merchant_id "
									+"and (instr(fg.merchant_id,'|')) = 0 "
									+"order by trx_type, source, bearer, merchant_id"
									+ " ) a where ROWNUM <= ?) where rnum >= ?";
							}
							pstmt = conn.prepareStatement(sql);
							if(!name.equals("")){
								pstmt.setString(1, name.toLowerCase() + "%");
								pstmt.setString(2, name.toLowerCase() + "%");
								pstmt.setInt(3, end_row);
								pstmt.setInt(4, start_row);
								
							}else{
								pstmt.setInt(1, end_row);
								pstmt.setInt(2, start_row);
							}
							rs = pstmt.executeQuery();

							while (rs.next()) {
			%>
			<tr>
				<td bgcolor="#EEEEEE" >
						<font color="black" size="1"
							face="Verdana, Arial, Helvetica, sans-serif"><%=rs.getString("trx_type")%></font>
				</td>
				<td bgcolor="#EEEEEE" >
						<font color="black" size="1"
							face="Verdana, Arial, Helvetica, sans-serif"><%=rs.getString("source").equals("a")?"Air Time":"Emoney"%></font>
				</td>
				<td bgcolor="#EEEEEE" >
						<font color="black" size="1"
							face="Verdana, Arial, Helvetica, sans-serif"><%=rs.getString("bearer") == null ? ""
									: rs.getString("bearer")%></font>
				</td>
				<td bgcolor="#EEEEEE" >
						<font color="black" size="1"
							face="Verdana, Arial, Helvetica, sans-serif"><%=rs.getString("merchant_id") == null ? "" : rs
									.getString("merchant_id")%></font>
				</td>
				<td bgcolor="#EEEEEE" >
						<font color="black" size="1"
							face="Verdana, Arial, Helvetica, sans-serif"><%=rs.getString("name") == null ? "" : rs
									.getString("name")%></font>
				</td>
				<td bgcolor="#EEEEEE" >
						<font color="black" size="1"
							face="Verdana, Arial, Helvetica, sans-serif"><%=rs.getString("customer_fee") == null ? "" : rs
									.getString("customer_fee")%></font>
				</td>
				<td bgcolor="#EEEEEE" align="center" style="width:10px">
						<font color="black" size="1"
							face="Verdana, Arial, Helvetica, sans-serif"><%=rs.getString("merchant_fee") == null ? "" : rs
									.getString("merchant_fee")%></font>
				</td>
				<td bgcolor="#EEEEEE" >
						<font color="black" size="1"
							face="Verdana, Arial, Helvetica, sans-serif"><%=rs.getString("status") == null ? "" : rs
									.getString("status").equals("a")?"Active":"Not Active" %></font>
				</td>
				<td bgcolor="#EEEEEE">
						<font color="black" size="1"
							face="Verdana, Arial, Helvetica, sans-serif"><%=rs.getString("trx_description") == null ? "" : rs
									.getString("trx_description")%></font>
				</td>
				<td bgcolor="#EEEEEE">
						<font color="#FFFFFF" size="1"
							face="Verdana, Arial, Helvetica, sans-serif"><a
							href="feeConfigEdit.jsp?stat=0&trx_type=<%=rs.getString("trx_type")%>&trxType=<%=Util.encMy(rs.getString("trx_type"))%>&cust_fee=<%=rs.getString("CUSTOMER_FEE")%>&merc_fee=<%=rs.getString("MERCHANT_FEE")%>&source=<%=rs.getString("source")%>&merchant_id=<%=rs.getString("merchant_id")%>&bearer=<%=rs.getString("bearer")%>"
							class="link">edit</a> </font>
				</td>
			</tr>
			<%
				}
							pstmt.close();
							rs.close();
			%>
			<tr bgcolor="#FFF6EF">
				<td colspan="10">
					<div align="left">
						<input type="button" value="Add" onclick="JavaScript:window.location='feeConfigInput.jsp';">
					</div>
				</td>
			</tr>
		</table>

		<br>
		<br>
		<br>

		<table width="40%" border="0" cellspacing="0" cellpadding="0">
			<tr>
				<td><div align="center">
						<font color="#CC6633" size="1"
							face="Verdana, Arial, Helvetica, sans-serif">Sebelum anda
							keluar dari layanan ini pastikan anda telah logout agar login
							anda tidak dapat dipakai oleh orang lain.</font>
					</div></td>
			</tr>
		</table>


		<br>
		<%
			} catch (Exception e) {
					} finally {
						try {
							if(conn!=null){
								conn.close();
							}
						} catch (Exception ee) {
						}
					}
		%>
	</stripes:layout-component>
</stripes:layout-render>