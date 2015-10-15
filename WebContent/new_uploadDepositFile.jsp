<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page
	import="java.io.*, java.sql.*, java.util.*,java.text.*, oracle.jdbc.driver.*"%>
<%@ page import="org.apache.commons.fileupload.FileItem"%>
<%@ page import="org.apache.commons.fileupload.FileUploadException"%>
<%@ page import="org.apache.commons.fileupload.disk.DiskFileItemFactory"%>
<%@ page
	import="org.apache.commons.fileupload.servlet.ServletFileUpload"%>

<jsp:useBean id="DbCon" scope="page" class="tsel_tunai.DbCon"></jsp:useBean>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Upload Account Statement for Deposit Request</title>
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
								Deposit Account Statement</font></strong></font><font color="#FFFFFF"
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

				<center>

					<%!String[] get_records(String input) {
		String[] output = new String[6];
		try {
			// NOREK
			output[0] = (input.substring(0, 11)).trim().replaceAll("\\'", " ");
			// TANGGAL
			output[1] = (input.substring(14, 37)).trim().replaceAll("\\'", " ");
			// DESC
			output[2] = (input.substring(37, 198)).trim().replaceAll("\\'", " ");
			// AMOUNT
			output[3] = (input.substring(198, 208)).trim().replaceAll("\\'", " ");
			// TIPE
			output[4] = (input.substring(208, 210)).trim().replaceAll("\\'", " ");
			// BALANCE
			output[5] = (input.substring(210, input.length())).trim().replaceAll("\\'", " ");
		} catch (Exception e) {
			output[0] = "";
			output[1] = "";
			output[2] = "";
			output[3] = "";
			output[4] = "";
			output[5] = "";
			System.out.println(e.getMessage());
		}
		return output;
	}%>
					<%
						//=========================================
						Calendar CAL = Calendar.getInstance();
						SimpleDateFormat SDF = new SimpleDateFormat("dd-MM-yyyy HH:mm:ss");
						String timeNOW = SDF.format(CAL.getTime());
						String outPUT = "";
						//=========================================

						//PROSES UPLOAD FILE CSV MENJADI KE DATABASE
						Connection con = null;
						Statement stmt = null;
						PreparedStatement pstmt = null;
						ResultSet rs = null;
						String pathFile = "";
						String encLogP = "";
						String encPassP = "";
						String encPass = "";
						String encLog = "";
						String query = "";
						Boolean ifProceed = false;

						try {
							//Buka dulu si databasenya
							Class.forName("oracle.jdbc.OracleDriver");
							con = DbCon.getConnection();
							con.setAutoCommit(false);

							//cek untuk yang buka pertama kali	
							if (!ServletFileUpload.isMultipartContent(request)) {
								encLogP = request.getParameter("idLog1");
								encPassP = request.getParameter("idLog2");
								if (encLogP == null)
									encLogP = "";
								if (encPassP == null)
									encPassP = "";
								query = "select * from tsel_webstarter_user where username='" + encLogP + "' and password='"
										+ encPassP + "'";
								System.out.println("Qry Upload : " + query);
								stmt = con.createStatement();
								rs = stmt.executeQuery(query);
								if (!rs.next()) {
									response.sendRedirect("./web-starter/Login.jsp");
								}
								rs.close();
								stmt.close();
							}
							if (ServletFileUpload.isMultipartContent(request)) {
								System.out.println("ServletFileUpload.isMultipartContent");
								ServletFileUpload servletFileUpload = new ServletFileUpload(new DiskFileItemFactory());
								List fileItemsList = null;
								try {
									fileItemsList = servletFileUpload.parseRequest(request);
								} catch (FileUploadException e) {
									outPUT += ("File upload failed. [" + e.getMessage() + "]|");
									out.println("File upload failed. [" + e.getMessage() + "]");
								}
								System.out.println("fileItemsList size : " + fileItemsList.size());
								Iterator i = fileItemsList.iterator();
								while (i.hasNext()) {
									FileItem fi = (FileItem) i.next();
									if (!fi.isFormField()) {
										String fileName = fi.getName();
										String saveFile = fileName.substring(fileName.lastIndexOf("\\") + 1);
										String ext = saveFile.substring(saveFile.length() - 3, saveFile.length());
										if (ext.equalsIgnoreCase("txt") || ext.equalsIgnoreCase("csv")) {

											// write the file
											try {
												String pathTes = application.getRealPath("/") + "uploadedFiles";
												File fileTes = new File(pathTes);
												if (!fileTes.exists())
													fileTes.mkdirs();
												fi.write(new File(application.getRealPath("/") + "uploadedFiles", saveFile));
												pathFile = pathTes + "/" + saveFile;
												out.println(
														"<script language='javascript'>alert('File has been uploaded successfully.')</script>");
												outPUT += ("File has been uploaded successfully|");
											} catch (Exception e) {
												out.println(
														"<script language='javascript'>alert('Error inside uploadUpdateACtion while writing the uploded file Exception is ["
																+ e.getMessage() + "]|')</script>");
												outPUT += ("Error Exception is [" + e.getMessage() + "]|");
											}

										} else {
											out.println(
													"<script language='javascript'>alert('Error, File must be txt or csv.')</script>");
											outPUT += ("Error,file must be txt or csv|");
										}
									} else {
										/* Get form fields value */
										if (fi.getFieldName().equals("idLog1"))
											encLog = fi.getString();
										if (fi.getFieldName().equals("idLog2"))
											encPass = fi.getString();
									}
								}
								encLog = request.getParameter("idLog1");
								encPass = request.getParameter("idLog2");
								// checking for login and password
								if (encLog == null)
									encLog = "";
								if (encPass == null)
									encPass = "";
								//check database
								query = "select * from tsel_webstarter_user where username='" + encLog + "' and password='"
										+ encPass + "'";
								System.out.println("Query upload : " + query);
								stmt = con.createStatement();
								rs = stmt.executeQuery(query);
								if (!rs.next()) {
									response.sendRedirect("./web-starter/Login.jsp");
								}
								rs.close();
								stmt.close();
							}

							// if uploading is successful
							if (!pathFile.equals("") && !encLog.equals("") && !encPass.equals("")) {
								//UPDATE DATABASA ACC_STATEMENT DARI FILE CSV

								//SISTEMNYA YANG BAKALAN NGURUSIN, jadi ngebaca dulu, terus tentuin itu filenya Mandiri atau BNI
								//baca satu baris dulu, liat kalau kosong itu BNI, kalau Mandiri kan ga kosong dari awal
								String thisLine;
								ArrayList al = new ArrayList();
								BufferedReader fileIn = new BufferedReader(new FileReader(pathFile));
								// Mulai Baca Baris Pertama
								thisLine = fileIn.readLine();
								int rowAffected = 0;
								String bankType = "";
								int jmlInsert = 0;
								int jmlUpdate = 0;

								if (thisLine.startsWith("120883432")) {
									//ini file BNI
									bankType = "BNI";

									//simpan baris pertama yang sudah dibaca sebelumnya
									String[] records = null;
									records = get_records(thisLine);
									if (records[4].equalsIgnoreCase("CR")) {
										//cek dulu apakah data ada atau tidak. pake update
										query = "UPDATE ACC_STATEMENT SET TIPE='C' WHERE TX_DATE=TO_DATE('" + records[1]
												+ "', 'DD/MM/YYYY HH24.MI.SS') AND DESCRIPTION='" + records[2] + "' AND AMOUNT="
												+ records[3];
										pstmt = con.prepareStatement(query);
										rowAffected = pstmt.executeUpdate();
										pstmt.close();
										if (rowAffected == 0) {
											query = "INSERT INTO ACC_STATEMENT (TX_DATE, DESCRIPTION, AMOUNT, TIPE) VALUES (TO_DATE('"
													+ records[1] + "', 'DD/MM/YYYY HH24.MI.SS'), '" + records[2] + "', "
													+ records[3] + ", 'C')";
											pstmt = con.prepareStatement(query);
											pstmt.executeUpdate();
											pstmt.close();
											jmlInsert++;
										} else
											jmlUpdate++;
									}
									while ((thisLine = fileIn.readLine()) != null) {
										if (thisLine.equalsIgnoreCase("")) {
											break;
										} else {
											//simpan baris berikutnya
											records = get_records(thisLine);
											if (records[4].equalsIgnoreCase("CR")) {
												//cek dulu apakah data ada atau tidak. pake update
												query = "UPDATE ACC_STATEMENT SET TIPE='C' WHERE TX_DATE=TO_DATE('" + records[1]
														+ "', 'DD/MM/YYYY HH24.MI.SS') AND DESCRIPTION='" + records[2]
														+ "' AND AMOUNT=" + records[3];
												pstmt = con.prepareStatement(query);
												rowAffected = pstmt.executeUpdate();
												pstmt.close();
												if (rowAffected == 0) {
													query = "INSERT INTO ACC_STATEMENT (TX_DATE, DESCRIPTION, AMOUNT, TIPE) VALUES (TO_DATE('"
															+ records[1] + "', 'DD/MM/YYYY HH24.MI.SS'), '" + records[2] + "', "
															+ records[3] + ", 'C')";
													pstmt = con.prepareStatement(query);
													pstmt.executeUpdate();
													pstmt.close();
													jmlInsert++;
												} else
													jmlUpdate++;
											}
										}
									}
									ifProceed = true;
								} else if (!thisLine.startsWith("120883432")) {
									String Hasil[] = new String[6];
									//ini file Mandiri
									bankType = "Mandiri";

									//simpan baris pertama yang sudah dibaca sebelumnya
									//Hasil = thisLine.split(";", 7) ;
									Hasil = thisLine.split(";", 6);
									if (!Hasil[5].contains("DR")) {
										pstmt = con.prepareStatement("UPDATE ACC_STATEMENT SET TIPE='C' WHERE TX_DATE=TO_DATE('"
												+ Hasil[2].substring(0, 10) + "', 'DD/MM/YYYY') AND DESCRIPTION='" + Hasil[3] + " "
												+ Hasil[4] + "' AND AMOUNT=" + Hasil[5]);
										rowAffected = pstmt.executeUpdate();
										pstmt.close();
										//con.commit();
										if (rowAffected == 0) {
											pstmt = con.prepareStatement(
													"INSERT INTO ACC_STATEMENT (TX_DATE, DESCRIPTION, AMOUNT, TIPE) VALUES (TO_DATE('"
															+ Hasil[2].substring(0, 10) + "', 'DD/MM/YYYY'), '" + Hasil[3] + " "
															+ Hasil[4] + "', " + Hasil[5] + ", 'C')");
											pstmt.executeUpdate();
											pstmt.close();
											jmlInsert++;
										} else
											jmlUpdate++;
									}
									//simpan baris-baris selanjutnya
									while ((thisLine = fileIn.readLine()) != null) {
										if (thisLine.equalsIgnoreCase("")) {
											break;
										} else {
											Hasil = thisLine.split(";", 7);
											if (!Hasil[5].contains("DR")) {
												pstmt = con.prepareStatement(
														"UPDATE ACC_STATEMENT SET TIPE='C' WHERE TX_DATE=TO_DATE('"
																+ Hasil[2].substring(0, 10) + "', 'DD/MM/YYYY') AND DESCRIPTION='"
																+ Hasil[3] + " " + Hasil[4] + "' AND AMOUNT=" + Hasil[5]);
												rowAffected = pstmt.executeUpdate();
												pstmt.close();
												//con.commit();
												if (rowAffected == 0) {
													pstmt = con.prepareStatement(
															"INSERT INTO ACC_STATEMENT (TX_DATE, DESCRIPTION, AMOUNT, TIPE) VALUES (TO_DATE('"
																	+ Hasil[2].substring(0, 10) + "', 'DD/MM/YYYY'), '" + Hasil[3]
																	+ " " + Hasil[4] + "', " + Hasil[5] + ", 'C')");
													pstmt.executeUpdate();
													pstmt.close();
													jmlInsert++;
												} else
													jmlUpdate++;
											}
										}
									}
									ifProceed = true;
								} else {
									ifProceed = false;
									out.println(
											"<font size='1' face='Verdana, Arial, Helvetica, sans-serif'><b>File yang diupload tidak mempunyai format standar dari BNI atau Mandiri.</b></font>");
									outPUT += "File format is wrong|";
								}

								if (ifProceed) {
									con.commit();
									//Proses berhasil, keluarkan alert
									out.println("<script language='javascript'>alert('" + bankType
											+ " Account Statement has successfully uploaded(" + jmlInsert + ") or updated("
											+ jmlUpdate + "). ')</script>");
									outPUT += (bankType + "Account Statement,uploaded(" + jmlInsert + ")&updated(" + jmlUpdate
											+ ")|");

								}
							}
						} catch (Exception e) {
							e.printStackTrace();
							out.println("<script language='javascript'>alert('Error : " + e.getMessage() + "')</script>");
							outPUT += ("Error : " + e.getMessage() + ")|");
							try {
								con.rollback();
							} catch (Exception ee) {
							}
						} finally {
							try {
								if (!con.getAutoCommit())
									con.setAutoCommit(true);
								if (con != null)
									con.close();
								if (rs != null)
									rs.close();
								if (stmt != null)
									stmt.close();
								if (pstmt != null)
									pstmt.close();
								//=====================================================================//
								if (!outPUT.equals(""))
									System.out.println("[" + timeNOW + "]new_uploadDepositFile.jsp|" + outPUT);
								//=====================================================================//
							} catch (Exception e) {
							}
						}
					%>

					<p>
						<font size='1' face='Verdana, Arial, Helvetica, sans-serif'><b>Please
								input Mandiri and BNI account statement to proceed.</b></font>
					</p>
					<form action="new_uploadDepositFile.jsp"
						enctype="multipart/form-data" method="post">
						<input type="file" name="path"><input type="Submit"
							name="Submit" value="Upload File"> <input type="hidden"
							name="idLog1" value="<%=(encLog.equals("")) ? encLogP : encLog%>">
						<input type="hidden" name="idLog2"
							value="<%=(encPass.equals("")) ? encPassP : encPass%>">
					</form>

					<a href="./mcomm/deposit_suggest_od.jsp">Back to Deposit
						Suggestion</a>
				</center> <br /> <br /> <br />


				<table width="40%" border="0" cellspacing="0" cellpadding="0">
					<tr>
						<td><div align="center">
								<font color="#CC6633" size="1"
									face="Verdana, Arial, Helvetica, sans-serif">Sebelum
									anda keluar dari layanan ini pastikan anda telah logout agar
									login anda tidak dapat dipakai oleh orang lain.</font>
							</div></td>

					</tr>
				</table> <br>
			</td>
		</tr>
		<tr>
			<td valign="top" bgcolor="#CC6633">
				<div align="right">
					<font color="#FFFFFF" size="1"
						face="Verdana, Arial, Helvetica, sans-serif"><strong>IT
							VAS Development 2008 - Powered by Stripes Framework</strong></font>
				</div>
			</td>
		</tr>
	</table>

</body>
</html>
