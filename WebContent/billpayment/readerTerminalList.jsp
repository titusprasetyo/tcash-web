<%@ page import="java.sql.*"%>
<%@page import="org.apache.commons.lang.StringEscapeUtils"%>
<%@ include file="/web-starter/taglibs.jsp"%>
<stripes:layout-render name="/web-starter/layout/standard.jsp"
	title="Reader Terminal List">
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

		<table width="100%" border="0" cellpadding="0" cellspacing="0">
			<tr>
				<td><div align="right">
						<font color="#CC6633" size="4"
							face="Verdana, Arial, Helvetica, sans-serif"><strong></strong>
						</font>
					</div></td>
			</tr>

		</table>
		<form name="form" method="post" action="readerTerminalList.jsp">
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
		<table width="80%" border="1" cellspacing="0" cellpadding="0"
			bordercolor="#FFF6EF">
			<tr bgcolor="#FFF6EF">
				<td colspan="7">
					<div align="left">
						<input type="button" value="Add" onclick="JavaScript:window.location='readerTerminalInput.jsp';">
					</div>
				</td>
			</tr>
			<tr>
				<td bgcolor="#CC6633">
					<div align="center">
						<font color="#FFFFFF" size="1"
							face="Verdana, Arial, Helvetica, sans-serif"><strong>Merchant</strong> </font>
					</div>
				</td>
				<td bgcolor="#CC6633">
					<div align="center">
						<font color="#FFFFFF" size="1"
							face="Verdana, Arial, Helvetica, sans-serif"><strong>Terminal/Keyword</strong>
						</font>
					</div>
				</td>
				<td bgcolor="#CC6633">
					<div align="center">
						<font color="#FFFFFF" size="1"
							face="Verdana, Arial, Helvetica, sans-serif"><strong>Description</strong>
						</font>
					</div>
				</td>
				<td bgcolor="#CC6633">
					<div align="center">
						<font color="#FFFFFF" size="1"
							face="Verdana, Arial, Helvetica, sans-serif"><strong>Address</strong>
						</font>
					</div>
				</td>
				<td bgcolor="#CC6633">
					<div align="center">
						<font color="#FFFFFF" size="1"
							face="Verdana, Arial, Helvetica, sans-serif"><strong>URL</strong>
						</font>
					</div>
				</td>
				<td bgcolor="#CC6633">
					<div align="center">
						<font color="#FFFFFF" size="1"
							face="Verdana, Arial, Helvetica, sans-serif"><strong>Charge Info</strong>
						</font>
					</div>
				</td>
				<td bgcolor="#CC6633" width="10">
					<div align="center">
						<font color="#FFFFFF" size="1"
							face="Verdana, Arial, Helvetica, sans-serif"><strong>Edit</strong>
						</font>
					</div>
				</td>
			</tr>
			
			<%
				String sql = "select count(*) as jumlah from merchant m, merchant_info mi, reader_terminal rt where m.merchant_info_id = mi.merchant_info_id and m.merchant_id = rt.merchant_id and LOWER(name) like ?";
							PreparedStatement pstmt = conn.prepareStatement(sql);
							pstmt.setString(1, "%" + name.toLowerCase() + "%");
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

							sql = "select * FROM (select a.*, ROWNUM rnum from ("
									+ "select KEYTERMINAL, name, rt.MSISDN, rt.DESCRIPTION, TERMINAL_ID, rt.ADDRESS, rt.TERMINAL_TYPE, rt.URL, "
									+ " rt.CHARGE_INFO, m.merchant_id from merchant m, merchant_info mi, reader_terminal rt where m.merchant_info_id = mi.merchant_info_id "
									+ " and m.merchant_id = rt.merchant_id and LOWER(name) like '%"
									+ name.toLowerCase() + "%'"
									+ " order by rt.terminal_id desc) a where ROWNUM <= ?) where rnum >= ?";
							pstmt = conn.prepareStatement(sql);
							pstmt.setInt(1, end_row);
							pstmt.setInt(2, start_row);
							rs = pstmt.executeQuery();

							while (rs.next()) {
			%>
			<tr>
				<td bgcolor="#EEEEEE">
					<div align="center">
						<font color="black" size="1"
							face="Verdana, Arial, Helvetica, sans-serif"><%=rs.getString("name")%></font>
					</div>
				</td>
				<td bgcolor="#EEEEEE">
					<div align="center">
						<font color="black" size="1"
							face="Verdana, Arial, Helvetica, sans-serif"><%=rs.getString("msisdn")%></font>
					</div>
				</td>
				<td bgcolor="#EEEEEE">
					<div align="center">
						<font color="black" size="1"
							face="Verdana, Arial, Helvetica, sans-serif"><%=rs.getString("description") == null ? ""
									: rs.getString("description")%></font>
					</div>
				</td>
				<td bgcolor="#EEEEEE">
					<div align="center">
						<font color="black" size="1"
							face="Verdana, Arial, Helvetica, sans-serif"><%=rs.getString("address") == null ? "" : rs
									.getString("address")%></font>
					</div>
				</td>
				<td bgcolor="#EEEEEE">
					<div align="center">
						<font color="black" size="1"
							face="Verdana, Arial, Helvetica, sans-serif"><%=rs.getString("url") == null ? "" : rs
									.getString("url")%></font>
					</div>
				</td>
				<td bgcolor="#EEEEEE">
					<div align="center">
						<font color="black" size="1"
							face="Verdana, Arial, Helvetica, sans-serif"><%=rs.getString("charge_info") == null ? "" : rs
									.getString("charge_info")%></font>
					</div>
				</td>
				<td bgcolor="#EEEEEE">
					<div align="center">
						<font color="black" size="1"
							face="Verdana, Arial, Helvetica, sans-serif"><a
							href="readerTerminalInput.jsp?rtId=<%=rs.getString("terminal_id")%>&merchantId=<%=rs.getString("msisdn").toUpperCase()%>"
							class="link">edit</a> </font>
					</div>
				</td>
			</tr>
			<%
				}
							pstmt.close();
							rs.close();
			%>
			<tr bgcolor="#FFF6EF">
				<td colspan="7">
					<div align="left">
						<input type="button" value="Add" onclick="JavaScript:window.location='readerTerminalInput.jsp';">
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
						e.printStackTrace(System.out);
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