<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page
	import="java.io.*, jxl.*, java.sql.*, java.util.*,java.text.*, oracle.jdbc.driver.*"%>
<%@ page import="org.apache.commons.fileupload.FileItem"%>
<%@ page import="org.apache.commons.fileupload.FileUploadException"%>
<%@ page import="org.apache.commons.fileupload.disk.DiskFileItemFactory"%>
<%@ page
	import="org.apache.commons.fileupload.servlet.ServletFileUpload"%>
<jsp:useBean id="DbCon" scope="page" class="tsel_tunai.DbCon" />
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Upload Account Statement for Payment</title>
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
								Payment Status</font></strong></font><font color="#FFFFFF"
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
										src="${pageContext.request.contextPath}/image/logo.JPG"
										width="135" height="37"></strong></font>
							</div>
						</td>
					</tr>
				</table> <br />

				<center>
					<%!String returnFloat(String amount) {
		NumberFormat nf = NumberFormat.getInstance(Locale.ITALY);
		if (amount.contains("."))
			amount = amount.substring(0, (amount.indexOf(".")));
		String[] _amount = amount.split(",");
		if (_amount.length > 1)
			amount = nf.format(Long.parseLong(_amount[0])) + "," + _amount[1];
		else
			amount = nf.format(Long.parseLong(_amount[0]));
		return amount;
	}%>
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
					<%!String convertMandiri(String inputs) {
		String inPut = inputs;
		String outPut = "";
		boolean locked = false;
		//boolean lockedNull = false;

		char arrayTes[] = inPut.toCharArray();
		String arrayVariabel[] = new String[9];
		for (int i = 0; i < arrayVariabel.length; i++) {
			arrayVariabel[i] = "";
		}

		int variabelCounter = 0;
		for (int i = 0; i < arrayTes.length; i++) {
			if (arrayTes[i] == '"' && !locked)
				locked = true;
			else if (arrayTes[i] == '"' && locked) {
				locked = false;
				//lockedNull = false;
			} else {
				//ambil dan tambahkan ke array of String
				if (arrayTes[i] == ',' && !locked)
					variabelCounter++;
				else if (arrayTes[i] != ',') {
					/*if(arrayTes[i]=='.' && !lockedNull)
					lockedNull = true;
					else if(arrayTes[i]=='.' && lockedNull)
					lockedNull = false;
					else if(!lockedNull)*/
					arrayVariabel[variabelCounter] += arrayTes[i];

				}
			}
		}

		for (int i = 0; i < arrayVariabel.length; i++) {
			outPut += arrayVariabel[i] + ",";
		}

		return outPut;
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
						String query = "";

						String pathFile = "";
						String encLogP = "";
						String encPassP = "";
						String encPass = "";
						String encLog = "";
						String days = "H";

						String ext = "";

						Boolean ifToday = false;
						Boolean ifInq = false;
						Boolean ifProceed = false;

						String bankType = "";
						int jmlInsert = 0;
						int jmlUpdate = 0;

						try {
							// Buka dulu si databasenya
							Class.forName("oracle.jdbc.OracleDriver");
							con = DbCon.getConnection();
							con.setAutoCommit(false);

							// cek untuk yang buka pertama kali	
							if (!ServletFileUpload.isMultipartContent(request)) {
								encLogP = request.getParameter("idLog1");
								encPassP = request.getParameter("idLog2");
								if (encLogP == null)
									encLogP = "";
								if (encPassP == null)
									encPassP = "";
								query = "select * from tsel_webstarter_user where username='" + encLogP + "' and password='"
										+ encPassP + "'";
								stmt = con.createStatement();
								rs = stmt.executeQuery(query);
								if (!rs.next()) {
									response.sendRedirect("https://10.2.114.121:9082/tcash-web/web-starter/Login.jsp");
								}
								rs.close();
								stmt.close();
							}
							//==cek untuk yang buka kedua kali
							if (ServletFileUpload.isMultipartContent(request)) {
								ServletFileUpload servletFileUpload = new ServletFileUpload(new DiskFileItemFactory());
								List fileItemsList = null;
								try {
									fileItemsList = servletFileUpload.parseRequest(request);
								} catch (FileUploadException e) {
									out.println("File upload failed. [" + e.getMessage() + "]");
									outPUT += ("File upload failed. [" + e.getMessage() + "]");
								}
								Iterator i = fileItemsList.iterator();
								while (i.hasNext()) {
									FileItem fi = (FileItem) i.next();
									if (!fi.isFormField()) {
										String fileName = fi.getName();
										String saveFile = fileName.substring(fileName.lastIndexOf("\\") + 1);
										if (!fileName.equals("") && !saveFile.equals("")) {
											ext = saveFile.substring(saveFile.length() - 3, saveFile.length());
											if (ext.equalsIgnoreCase("txt") || ext.equalsIgnoreCase("csv")
													|| ext.equalsIgnoreCase("xls")) {
												//==write the file
												try {
													String pathTes = application.getRealPath("/") + "uploadedFiles";

													File fileTes = new File(pathTes);
													if (!fileTes.exists())
														fileTes.mkdirs();
													fi.write(new File(application.getRealPath("/") + "uploadedFiles", saveFile));
													pathFile = pathTes + "/" + saveFile;
													out.println(
															"<script language='javascript'>alert('File has been uploaded successfully.')</script>");
													outPUT += "Upload success|";
												} catch (Exception e) {
													out.println("File upload is failed. Error message is [" + e.getMessage() + "]");
													outPUT += ("File upload failed.Error :[" + e.getMessage() + "]");
												}
											} else {
												out.println(
														"<script language='javascript'>alert('Error, File must be txt, xls, or csv.')</script>");
												outPUT += "CSV TXT XLS only|";
											}
										}
									} else {
										/* Get form fields value */
										if (fi.getFieldName().equals("idLog1"))
											encLog = fi.getString();
										if (fi.getFieldName().equals("idLog2"))
											encPass = fi.getString();
										if (fi.getFieldName().equals("days"))
											days = fi.getString();
									}
								}

								//==setelah selesai mengambil data.
								if (encLog == null)
									encLog = "";
								if (encPass == null)
									encPass = "";
								if (days == null)
									days = "H";

								//==check database
								query = "select * from tsel_webstarter_user where username='" + encLog + "' and password='"
										+ encPass + "'";
								stmt = con.createStatement();
								rs = stmt.executeQuery(query);
								if (!rs.next()) {
									//con.close();
									response.sendRedirect("https://10.2.114.121:9082/tcash-web/web-starter/Login.jsp");
								}
								rs.close();
								stmt.close();

								if (pathFile == "") {
									out.println(
											"<script language='javascript'>alert('Path file is blank, please correct it.')</script>");
									outPUT += "Path blank|";
								}
							}

							if (!pathFile.equals("") && !encLog.equals("") && !encPass.equals("")) {
								//==UPDATE DATABASA ACC_STATEMENT DARI FILE CSV
								//==SISTEMNYA YANG BAKALAN NGURUSIN, jadi ngebaca dulu, terus tentuin itu filenya Mandiri atau BNI
								String Hasil[] = new String[10];

								//==baca satu baris dulu, liat kalau kosong itu BNI, kalau Mandiri kan ga kosong dari awal
								String thisLine;
								BufferedReader fileIn = new BufferedReader(new FileReader(pathFile));
								thisLine = fileIn.readLine();

								// check if H-1 or H
								if (days.equals("H"))
									ifToday = true;
								else if (days.equals("H-"))
									ifToday = false;

								int rowAffected = 0;

								// check BNI (CSV/TXT, Bukan yang XL)
								if ((ext.equalsIgnoreCase("csv") || ext.equalsIgnoreCase("txt"))
										&& thisLine.startsWith("120883432")) {
									//ini file BNI
									bankType = "BNI";

									//simpan baris pertama yang sudah dibaca sebelumnya
									String[] records = null;
									records = get_records(thisLine);
									if (records[4].equalsIgnoreCase("DR")) {
										//cek dulu apakah data ada atau tidak. pake update
										query = "UPDATE ACC_STATEMENT SET TIPE='D' WHERE TX_DATE=TO_DATE('" + records[1]
												+ "', 'DD/MM/YYYY HH24.MI.SS') AND DESCRIPTION='" + records[2] + "' AND AMOUNT="
												+ records[3];
										pstmt = con.prepareStatement(query);
										rowAffected = pstmt.executeUpdate();
										pstmt.close();
										if (rowAffected == 0) {
											query = "INSERT INTO ACC_STATEMENT (TX_DATE, DESCRIPTION, AMOUNT, TIPE) VALUES (TO_DATE('"
													+ records[1] + "', 'DD/MM/YYYY HH24.MI.SS'), '" + records[2] + "', "
													+ records[3] + ", 'D')";
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
											if (records[4].equalsIgnoreCase("DR")) {
												//cek dulu apakah data ada atau tidak. pake update
												query = "UPDATE ACC_STATEMENT SET TIPE='D' WHERE TX_DATE=TO_DATE('" + records[1]
														+ "', 'DD/MM/YYYY HH24.MI.SS') AND DESCRIPTION='" + records[2]
														+ "' AND AMOUNT=" + records[3];
												pstmt = con.prepareStatement(query);
												rowAffected = pstmt.executeUpdate();
												pstmt.close();
												if (rowAffected == 0) {
													query = "INSERT INTO ACC_STATEMENT (TX_DATE, DESCRIPTION, AMOUNT, TIPE) VALUES (TO_DATE('"
															+ records[1] + "', 'DD/MM/YYYY HH24.MI.SS'), '" + records[2] + "', "
															+ records[3] + ", 'D')";
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
								} else if (ext.equalsIgnoreCase("xls") && !ext.equalsIgnoreCase("")) {
									bankType = "BNI";

									File inputWorkbook = new File(pathFile);
									Workbook w;
									w = Workbook.getWorkbook(inputWorkbook);
									Sheet sheet = w.getSheet(0);

									boolean b1 = false, b2 = false, b3 = false, b_final = false;

									ArrayList<String> no_inquiry = new ArrayList<String>();
									ArrayList<String> posting_date = new ArrayList<String>();
									ArrayList<String> effective_date = new ArrayList<String>();
									ArrayList<String> branch = new ArrayList<String>();
									ArrayList<String> journal = new ArrayList<String>();
									ArrayList<String> trans_desc = new ArrayList<String>();
									ArrayList<String> amount = new ArrayList<String>();
									ArrayList<String> DBC = new ArrayList<String>();

									for (int j = 0; j < sheet.getColumns(); j++) {
										for (int i = 0; i < sheet.getRows(); i++) {
											// get cell content
											Cell cell = sheet.getCell(j, i);
											String cellString = cell.getContents();
											if (cell.getType() == CellType.DATE || cell.getType() == CellType.NUMBER
													|| cell.getType() == CellType.LABEL) {
												// check if inquiry or statement based on cell 1,2
												if (j == 1 && i == 2 && (cellString.equalsIgnoreCase("ACCOUNT STATEMENT"))) {
													b1 = true;
												} else
													if (j == 1 && i == 2 && (cellString.equalsIgnoreCase("Transaction Inquiry"))) {
													ifInq = true;
													b2 = true;
												} else if (j == 1 && i == 2 && (!cellString.equalsIgnoreCase("Transaction Inquiry")
														|| !cellString.equalsIgnoreCase("Transaction Inquiry"))) {
													b3 = true;
												} else if (b2 && j == 1) {
													if (!(cellString.equalsIgnoreCase("Transaction Inquiry")
															|| cellString.equalsIgnoreCase("Account")
															|| cellString.equalsIgnoreCase("Period")
															|| cellString.equalsIgnoreCase("Beginning Balance")
															|| cellString.equalsIgnoreCase("Total Debit")
															|| cellString.equalsIgnoreCase("Total Credit")
															|| cellString.equalsIgnoreCase("No.")))
														no_inquiry.add(cellString);
												} else if (b2 && j == 2) {
													posting_date.add(cellString);
												} else if (b2 && j == 3) {
													branch.add(cellString);
												} else if (b2 && j == 6) {
													journal.add(cellString);
												} else if (b2 && j == 7) {
													trans_desc.add(cellString);
												} else if (b2 && j == 11) {
													amount.add(cellString);
												} else if (b2 && j == 14) {
													DBC.add(cellString);
												} else if (b1 && j == 1) {
													if (!(cellString.equalsIgnoreCase("ACCOUNT STATEMENT")
															|| cellString.equalsIgnoreCase("TELEKOMUNIKASI SELULAR ,PT")
															|| cellString.equalsIgnoreCase("WISMA MULIA LT.M-19")
															|| cellString.equalsIgnoreCase("JL. GATOT SUBROTO KAV.42")
															|| cellString.equalsIgnoreCase("JAKARTA")
															|| cellString.equalsIgnoreCase("Posting Date")
															|| cellString.contains("Ledger Balance:")))
														posting_date.add(cellString);
												} else if (b1 && j == 3) {
													//if(!(cellString.equalsIgnoreCase("Effective Date")))
													effective_date.add(cellString);
												} else if (b1 && j == 5) {
													//if(!(cellString.equalsIgnoreCase("Branch")))
													branch.add(cellString);
												} else if (b1 && j == 8) {
													//if(!(cellString.equalsIgnoreCase("Journal ")))
													journal.add(cellString);
												} else if (b1 && j == 9) {
													//if(!(cellString.equalsIgnoreCase("Transaction Description")))
													trans_desc.add(cellString);
												} else if (b1 && j == 15) {
													//if(!(cellString.equalsIgnoreCase("Amount")))
													amount.add(cellString);
												} else if (b1 && j == 18) {
													//if(!(cellString.equalsIgnoreCase("DB/CR")))
													DBC.add(cellString);
												}
											}
											if (b3)
												break;
										}
										if (b3)
											break;
									}
									if (b2) {
										// cleaning up inquiry data       
										journal.remove(0);
										for (int i = 0; i < journal.size(); i++) {
											if (journal.get(i).equalsIgnoreCase("Journal No."))
												journal.remove(i);
										}

										posting_date.remove(0);
										if (posting_date.size() - no_inquiry.size() == journal.size() - no_inquiry.size() + 1) {
											for (int i = 0; i < posting_date.size(); i++) {
												if (posting_date.get(i).equalsIgnoreCase("Post Date"))
													posting_date.remove(i);
											}
										} else if (posting_date.size() - no_inquiry.size() > journal.size() - no_inquiry.size()) {
											for (int i = 0; i < posting_date.size(); i++) {
												if (i > 1 && posting_date.get(i - 1).equalsIgnoreCase("Post Date")) {
													posting_date.set(i - 2, posting_date.get(i - 2) + posting_date.get(i));
													posting_date.remove(i - 1);
													posting_date.remove(i - 1);
												}
											}
										}

										branch.remove(0);
										if (branch.size() - no_inquiry.size() == journal.size() - no_inquiry.size() + 1) {
											for (int i = 0; i < branch.size(); i++) {
												if (branch.get(i).equalsIgnoreCase("Branch"))
													branch.remove(i);
											}
										} else if (branch.size() - no_inquiry.size() > journal.size() - no_inquiry.size()) {
											for (int i = 0; i < branch.size(); i++) {
												if (i > 1 && branch.get(i - 1).equalsIgnoreCase("Branch")) {
													branch.set(i - 2, branch.get(i - 2) + branch.get(i));
													branch.remove(i - 1);
													branch.remove(i - 1);
												}
											}
										}

										trans_desc.remove(0);
										if (trans_desc.size() - no_inquiry.size() == journal.size() - no_inquiry.size() + 1) {
											for (int i = 0; i < trans_desc.size(); i++) {
												if (trans_desc.get(i).equalsIgnoreCase("Description"))
													trans_desc.remove(i);
											}
										} else if (trans_desc.size() - no_inquiry.size() > journal.size() - no_inquiry.size()) {
											for (int i = 0; i < trans_desc.size(); i++) {
												if (i > 1 && trans_desc.get(i - 1).equalsIgnoreCase("Description")) {
													trans_desc.set(i - 2, trans_desc.get(i - 2) + trans_desc.get(i));
													trans_desc.remove(i - 1);
													trans_desc.remove(i - 1);
												}
											}
										}

										amount.remove(0);
										if (amount.size() - no_inquiry.size() == journal.size() - no_inquiry.size() + 1) {
											for (int i = 0; i < amount.size(); i++) {
												if (amount.get(i).equalsIgnoreCase("Amount"))
													amount.remove(i);
											}
										} else if (amount.size() - no_inquiry.size() > journal.size() - no_inquiry.size()) {
											for (int i = 0; i < amount.size(); i++) {
												if (i > 1 && amount.get(i - 1).equalsIgnoreCase("Amount")) {
													amount.set(i - 2, amount.get(i - 2) + amount.get(i));
													amount.remove(i - 1);
													amount.remove(i - 1);
												}
											}
										}

										DBC.remove(0);
										if (DBC.size() - no_inquiry.size() == journal.size() - no_inquiry.size() + 1) {
											for (int i = 0; i < DBC.size(); i++) {
												if (DBC.get(i).equalsIgnoreCase("Db/Cr"))
													DBC.remove(i);
											}
										} else if (DBC.size() - no_inquiry.size() > journal.size() - no_inquiry.size()) {
											for (int i = 0; i < DBC.size(); i++) {
												if (i > 1 && DBC.get(i - 1).equalsIgnoreCase("Db/Cr")) {
													DBC.set(i - 2, DBC.get(i - 2) + DBC.get(i));
													DBC.remove(i);
													DBC.remove(i - 1);
												}
											}
										}
										// end of cleaning data
										if (posting_date.size() == no_inquiry.size() && branch.size() == no_inquiry.size()
												&& journal.size() == no_inquiry.size() && trans_desc.size() == no_inquiry.size()
												&& amount.size() == no_inquiry.size() && DBC.size() == no_inquiry.size()) {
											b_final = true;
										} else {
											System.out.println("BNI Transaction Inquiry is mismatched.");
										}

									} else if (b1) {
										effective_date.remove(0);
										for (int i = 0; i < effective_date.size(); i++) {
											if (effective_date.get(i).equalsIgnoreCase("Effective Date"))
												effective_date.remove(i);
										}

										branch.remove(0);
										if (branch.size() - posting_date.size() == effective_date.size() - posting_date.size()
												+ 1) {
											for (int i = 0; i < branch.size(); i++) {
												if (branch.get(i).equalsIgnoreCase("Branch"))
													branch.remove(i);
											}
										} else
											if (branch.size() - posting_date.size() > effective_date.size() - posting_date.size()) {
											for (int i = 0; i < branch.size(); i++) {
												if (i > 1 && branch.get(i - 1).equalsIgnoreCase("Branch")) {
													branch.set(i - 2, branch.get(i - 2) + branch.get(i));
													branch.remove(i - 1);
													branch.remove(i - 1);
												}
											}
										}

										journal.remove(0);
										if (journal.size() - posting_date.size() == effective_date.size() - posting_date.size()
												+ 1) {
											for (int i = 0; i < journal.size(); i++) {
												if (journal.get(i).equalsIgnoreCase("Journal "))
													journal.remove(i);
											}
										} else if (journal.size() - posting_date.size() > effective_date.size()
												- posting_date.size()) {
											for (int i = 0; i < journal.size(); i++) {
												if (i > 1 && journal.get(i - 1).equalsIgnoreCase("Journal ")) {
													journal.set(i - 2, journal.get(i - 2) + journal.get(i));
													journal.remove(i - 1);
													journal.remove(i - 1);
												}
											}
										}

										trans_desc.remove(0);
										if (trans_desc.size() - posting_date.size() == effective_date.size() - posting_date.size()
												+ 1) {
											for (int i = 0; i < trans_desc.size(); i++) {
												if (trans_desc.get(i).equalsIgnoreCase("Transaction Description"))
													trans_desc.remove(i);
											}
										} else if (trans_desc.size() - posting_date.size() > effective_date.size()
												- posting_date.size()) {
											for (int i = 0; i < trans_desc.size(); i++) {
												if (i > 1 && trans_desc.get(i - 1).equalsIgnoreCase("Transaction Description")) {
													trans_desc.set(i - 2, trans_desc.get(i - 2) + trans_desc.get(i));
													trans_desc.remove(i - 1);
													trans_desc.remove(i - 1);
												}
											}
										}

										amount.remove(0);
										if (amount.size() - posting_date.size() == effective_date.size() - posting_date.size()
												+ 1) {
											for (int i = 0; i < amount.size(); i++) {
												if (amount.get(i).equalsIgnoreCase("Amount"))
													amount.remove(i);
											}
										} else
											if (amount.size() - posting_date.size() > effective_date.size() - posting_date.size()) {
											for (int i = 0; i < amount.size(); i++) {
												if (i > 1 && amount.get(i - 1).equalsIgnoreCase("Amount")) {
													amount.set(i - 2, amount.get(i - 2) + amount.get(i));
													amount.remove(i - 1);
													amount.remove(i - 1);
												}
											}
										}

										DBC.remove(0);
										if (DBC.size() - posting_date.size() == effective_date.size() - posting_date.size() + 1) {
											for (int i = 0; i < DBC.size(); i++) {
												if (DBC.get(i).equalsIgnoreCase("DB/CR"))
													DBC.remove(i);
											}
										} else if (DBC.size() - posting_date.size() > effective_date.size() - posting_date.size()) {
											for (int i = 0; i < DBC.size(); i++) {
												if (i > 1 && DBC.get(i - 1).equalsIgnoreCase("DB/CR")) {
													DBC.set(i - 2, DBC.get(i - 2) + DBC.get(i));
													DBC.remove(i - 1);
													DBC.remove(i - 1);
												}
											}
										}

										if (effective_date.size() == posting_date.size() && branch.size() == posting_date.size()
												&& journal.size() == posting_date.size() && trans_desc.size() == posting_date.size()
												&& amount.size() == posting_date.size() && DBC.size() == posting_date.size()) {
											b_final = true;
										} else {
											System.out.println("BNI Account Statement is mismatched.");
										}
									}

									if (b_final) {
										// process arraylist joined, every member of arraylist is an array itself
										if (b1 || b2) {
											if ((ifInq && ifToday) || (!ifInq && !ifToday)) {
												for (int i = 0; i < posting_date.size(); i++) {
													if (!(DBC.get(i).equalsIgnoreCase("K") || DBC.get(i).equalsIgnoreCase("C"))) {
														if (b1)
															query = "UPDATE ACC_STATEMENT SET TIPE='D' WHERE TX_DATE=TO_DATE('"
																	+ effective_date.get(i).substring(0, 19)
																	+ "', 'DD/MM/YYYY HH24.MI.SS') AND DESCRIPTION='"
																	+ trans_desc.get(i) + "' AND AMOUNT="
																	+ (amount.get(i).substring(0, amount.get(i).length() - 3)
																			.replace(",", ""));
														else if (b2)
															query = "UPDATE ACC_STATEMENT SET TIPE='D' WHERE TX_DATE=TO_DATE('"
																	+ posting_date.get(i).substring(0, 19)
																	+ "', 'DD/MM/YYYY HH24.MI.SS') AND DESCRIPTION='"
																	+ trans_desc.get(i) + "' AND AMOUNT="
																	+ (amount.get(i).substring(0, amount.get(i).length() - 3)
																			.replace(",", ""));
														pstmt = con.prepareStatement(query);
														rowAffected = pstmt.executeUpdate();
														pstmt.close();
														if (rowAffected == 0) {
															if (b1)
																query = "INSERT INTO ACC_STATEMENT (TX_DATE, DESCRIPTION, AMOUNT, TIPE) VALUES (TO_DATE('"
																		+ effective_date.get(i).substring(0, 19)
																		+ "', 'DD/MM/YYYY HH24.MI.SS'), '" + trans_desc.get(i)
																		+ "', "
																		+ (amount.get(i).substring(0, amount.get(i).length() - 3)
																				.replace(",", ""))
																		+ ", 'D')";
															else if (b2)
																query = "INSERT INTO ACC_STATEMENT (TX_DATE, DESCRIPTION, AMOUNT, TIPE) VALUES (TO_DATE('"
																		+ posting_date.get(i).substring(0, 19)
																		+ "', 'DD/MM/YYYY HH24.MI.SS'), '" + trans_desc.get(i)
																		+ "', "
																		+ (amount.get(i).substring(0, amount.get(i).length() - 3)
																				.replace(",", ""))
																		+ ", 'D')";
															pstmt = con.prepareStatement(query);
															pstmt.executeUpdate();
															pstmt.close();
															jmlInsert++;
														} else
															jmlUpdate++;
													}
												}
												ifProceed = true;
											} else if (!ifInq && ifToday) {
												out.println(
														"<script language='javascript'>alert('Format file salah, tolong masukkan format file inquiry.')</script>");
												outPUT += "Inquiry only|";
												ifProceed = false;
											} else if (ifInq && !ifToday) {
												out.println(
														"<script language='javascript'>alert('Format file salah, tolong masukkan format file account statement.')</script>");
												outPUT += "Statement only|";
												ifProceed = false;
											}
										}
									}
								} else if ((ext.equalsIgnoreCase("txt") || ext.equalsIgnoreCase("csv"))
										&& thisLine.startsWith("1240004904539")) {
									//== Mandiri
									//== Check if inquiry or account statement

									Hasil = thisLine.split(",", 10);
									bankType = "Mandiri";

									if (Hasil[0].equals("Account No"))
										ifInq = true;
									else
										ifInq = false;
									bankType = "Mandiri";

									if (ifInq && ifToday) {
										while ((thisLine = fileIn.readLine()) != null) {
											if (thisLine.equalsIgnoreCase("")) {
												break;
											} else {
												Hasil = convertMandiri(thisLine).split(",", 10);
												if (Hasil[8].equals(".00")) {
													query = "UPDATE ACC_STATEMENT SET TIPE='D' WHERE TX_DATE=TO_DATE('" + Hasil[2]
															+ "', 'DD/MM/RR') AND DESCRIPTION='" + Hasil[6] + "' AND AMOUNT="
															+ Hasil[7];
													pstmt = con.prepareStatement(query);
													rowAffected = pstmt.executeUpdate();
													pstmt.close();
													if (rowAffected == 0) {
														query = "INSERT INTO ACC_STATEMENT (TX_DATE, DESCRIPTION, AMOUNT, TIPE) VALUES (TO_DATE('"
																+ Hasil[2] + "', 'DD/MM/RR'), '" + Hasil[6] + "', " + Hasil[7]
																+ ", 'D')";
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
									} else if (!ifInq && !ifToday) {
										//simpan baris pertama yang sudah dibaca sebelumnya
										Hasil = thisLine.split(";", 7);
										if (Hasil[5].contains("DR")) {
											pstmt = con.prepareStatement("UPDATE ACC_STATEMENT SET TIPE='D' WHERE TX_DATE=TO_DATE('"
													+ Hasil[2].substring(0, 10) + "', 'DD/MM/YYYY') AND DESCRIPTION='" + Hasil[3]
													+ "|" + Hasil[4] + "' AND AMOUNT="
													+ Hasil[5].substring(0, (Hasil[5].length()) - 2));
											rowAffected = pstmt.executeUpdate();
											pstmt.close();
											if (rowAffected == 0) {
												pstmt = con.prepareStatement(
														"INSERT INTO ACC_STATEMENT (TX_DATE, DESCRIPTION, AMOUNT, TIPE) VALUES (TO_DATE('"
																+ Hasil[2].substring(0, 10) + "', 'DD/MM/YYYY'), '" + Hasil[3] + "|"
																+ Hasil[4] + "', " + Hasil[5].substring(0, (Hasil[5].length()) - 2)
																+ ", 'D')");
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
												if (Hasil[5].contains("DR")) {
													pstmt = con.prepareStatement(
															"UPDATE ACC_STATEMENT SET TIPE='D' WHERE TX_DATE=TO_DATE('"
																	+ Hasil[2].substring(0, 10)
																	+ "', 'DD/MM/YYYY') AND DESCRIPTION='" + Hasil[3] + "|"
																	+ Hasil[4] + "' AND AMOUNT="
																	+ Hasil[5].substring(0, (Hasil[5].length()) - 2));
													rowAffected = pstmt.executeUpdate();
													pstmt.close();
													if (rowAffected == 0) {
														pstmt = con.prepareStatement(
																"INSERT INTO ACC_STATEMENT (TX_DATE, DESCRIPTION, AMOUNT, TIPE) VALUES (TO_DATE('"
																		+ Hasil[2].substring(0, 10) + "', 'DD/MM/YYYY'), '"
																		+ Hasil[3] + "|" + Hasil[4] + "', "
																		+ Hasil[5].substring(0, (Hasil[5].length()) - 2)
																		+ ", 'D')");
														pstmt.executeUpdate();
														pstmt.close();
														jmlInsert++;
													} else
														jmlUpdate++;
												}
											}
										}
										ifProceed = true;
									} else if (!ifInq && ifToday) {
										out.println(
												"<script language='javascript'>alert('Format file salah, tolong masukkan format file inquiry.')</script>");
										outPUT += "Inquiry only|";
										ifProceed = false;
									} else if (ifInq && !ifToday) {
										out.println(
												"<script language='javascript'>alert('Format file salah, tolong masukkan format file account statement.')</script>");
										outPUT += "Statement only|";
										ifProceed = false;
									}
								} else {
									ifProceed = false;
									out.println(
											"<script language='javascript'>alert('File format is wrong, please check again.')</script>");
									outPUT += "File format is wrong|";
								}

							}
							//================= end of parsing file

							if (ifProceed) {
								con.commit();
								//Proses berhasil, keluarkan alert
								out.println("<script language='javascript'>alert('" + bankType
										+ " Account Statement has successfully uploaded(" + jmlInsert + ") or updated(" + jmlUpdate
										+ "). ')</script>");
								outPUT += (bankType + "," + jmlInsert + " Uploaded," + jmlUpdate + " Updated|");
							}
							if (ifProceed) {
								//PENCOCOKAN ANTARA REQUEST SETTLEMENT DAN ACCOUNT STATEMENT DIMULAI
								//untuk keperluan pencocokan
								int jmlFileInt = 0, jmlRecordInt = 0;
								String username = "";
								if (!encLogP.equals(""))
									username = encLog;
								else if (!encLog.equals(""))
									username = encLogP;
								else
									username = "finance";

								pstmt = con.prepareStatement(
										"SELECT COUNT(*) AS jmlFile FROM ACC_STATEMENT WHERE STATUS='0' AND TIPE='D' AND REF IS NULL");
								rs = pstmt.executeQuery();
								while (rs.next()) {
									jmlFileInt = rs.getInt("jmlFile");
								}
								pstmt.close();
								rs.close();

								pstmt = con.prepareStatement(
										"SELECT COUNT(*) AS jmlRecord from merchant a, merchant_cashout b, merchant_info c where b.MERCHANT_ID=a.MERCHANT_ID AND a.MERCHANT_INFO_ID=c.MERCHANT_INFO_ID AND b.IS_EXECUTED='3' AND b.PRINT_DATE IS NOT NULL AND b.COMPLETION_DATE IS NULL AND b.RECEIPT_ID IS NOT NULL ORDER BY DEPOSIT_TIME DESC");
								rs = pstmt.executeQuery();
								while (rs.next()) {
									jmlRecordInt = rs.getInt("jmlRecord");
								}
								pstmt.close();
								rs.close();

								//cek kalau ada request settlement atau account statement yang akan dibandingkan
								if (!pathFile.equals("") && jmlFileInt != 0 && jmlRecordInt != 0) {
									//load dari tabel ke array HasilFile
									ArrayList<String> tabelFile = new ArrayList<String>();
									pstmt = con.prepareStatement(
											"SELECT TX_DATE, DESCRIPTION, AMOUNT FROM ACC_STATEMENT WHERE STATUS='0' AND TIPE='D' AND REF IS NULL");
									rs = pstmt.executeQuery();
									while (rs.next()) {
										tabelFile.add(
												(rs.getTimestamp(1)).toString() + "," + rs.getString(2) + "," + rs.getString(3));
									}
									pstmt.close();
									rs.close();

									String matriksFile[][] = new String[jmlFileInt][3];

									//load matriksFilenya
									for (int i = 0; i < jmlFileInt; i++) {
										matriksFile[i] = tabelFile.get(i).split(",");
									}

									ArrayList<String> tabelDeposit = new ArrayList<String>();
									pstmt = con.prepareStatement(
											"SELECT b.DEPOSIT_TIME, b.MERCHANT_ID, b.AMOUNT, CASHOUT_ID from merchant a, merchant_cashout b, merchant_info c where b.MERCHANT_ID=a.MERCHANT_ID AND a.MERCHANT_INFO_ID=c.MERCHANT_INFO_ID AND b.IS_EXECUTED='3' AND b.PRINT_DATE IS NOT NULL AND b.COMPLETION_DATE IS NULL AND b.RECEIPT_ID IS NOT NULL ORDER BY DEPOSIT_TIME DESC");
									rs = pstmt.executeQuery();
									while (rs.next()) {
										tabelDeposit.add((rs.getTimestamp(1)).toString() + "," + rs.getString(2) + ","
												+ rs.getString(3) + "," + rs.getString(4));
									}
									pstmt.close();
									rs.close();

									//load tabel merchant deposit ke array

									String matriksDeposit[][] = new String[jmlRecordInt][4];
									//load matriksDepositnya
									for (int i = 0; i < jmlRecordInt; i++) {
										matriksDeposit[i] = tabelDeposit.get(i).split(",");
									}

									//load array pencocokan
									int[] matchedOnes = new int[jmlRecordInt];
									for (int i = 0; i < jmlRecordInt; i++) {
										matchedOnes[i] = 0;
									}
									//sesudah me-load kedua matriks, saatnya mencocokan dan menaruhnya ke 4 array
									int[] idMatch = new int[50], fileIdMatch = new int[50];
									int idMatchInt = 0, fileIdMatchInt = 0;

									//proses mencocokan
									for (int i = 0; i < jmlFileInt; i++) {
										for (int j = 0; j < jmlRecordInt; j++) {
											if ((matriksFile[i][2].equalsIgnoreCase(matriksDeposit[j][2]))
													&& (matriksFile[i][1].contains(matriksDeposit[j][3])) && matchedOnes[j] == 0) {
												//mulai pencocokan, kalau cocok masukin ke array hasil idMatch dan fileIdMatch
												idMatch[idMatchInt] = j;
												fileIdMatch[fileIdMatchInt] = i;
												idMatchInt++;
												fileIdMatchInt++;
												matchedOnes[j] = 1;
												break;
											}
										}
									}

									//PROSES PENGUPDATEAN
									if (idMatchInt != 0) {
										//keluarkan hasil pencocokan
					%>
					<table width="90%" border="1" cellspacing="0" cellpadding="0"
						bordercolor="#FFF6EF">
						<tr>
							<td bgcolor="#CC6633"><div align="center">
									<font color="#FFFFFF" size="1"
										face="Verdana, Arial, Helvetica, sans-serif"><strong>Baris
											File</strong></font>
								</div></td>
							<td bgcolor="#CC6633"><div align="center">
									<font color="#FFFFFF" size="1"
										face="Verdana, Arial, Helvetica, sans-serif"><strong>Transaction
											Date</strong></font>
								</div></td>
							<td bgcolor="#CC6633"><div align="center">
									<font color="#FFFFFF" size="1"
										face="Verdana, Arial, Helvetica, sans-serif"><strong>Description</strong></font>
								</div></td>
							<td bgcolor="#CC6633"><div align="center">
									<font color="#FFFFFF" size="1"
										face="Verdana, Arial, Helvetica, sans-serif"><strong>Amount</strong></font>
								</div></td>
							<td bgcolor="#CC6633"><div align="center">
									<font color="#FFFFFF" size="1"
										face="Verdana, Arial, Helvetica, sans-serif"><strong>Baris
											Record</strong></font>
								</div></td>
							<td bgcolor="#CC6633"><div align="center">
									<font color="#FFFFFF" size="1"
										face="Verdana, Arial, Helvetica, sans-serif"><strong>Settlement
											Date</strong></font>
								</div></td>
							<td bgcolor="#CC6633"><div align="center">
									<font color="#FFFFFF" size="1"
										face="Verdana, Arial, Helvetica, sans-serif"><strong>Merchant
											ID</strong></font>
								</div></td>
							<td bgcolor="#CC6633"><div align="center">
									<font color="#FFFFFF" size="1"
										face="Verdana, Arial, Helvetica, sans-serif"><strong>Settlement
											Amount</strong></font>
								</div></td>
							<td bgcolor="#CC6633"><div align="center">
									<font color="#FFFFFF" size="1"
										face="Verdana, Arial, Helvetica, sans-serif"><strong>Settlement
											ID</strong></font>
								</div></td>
						</tr>
						<%
							con.setAutoCommit(false);
											for (int i = 0; i < idMatchInt; i++) {
												//out.println("<tr>");
												//out.println("<td>"+fileIdMatch[i]+"</td><td>"+matriksFile[fileIdMatch[i]][0]+"</td><td>"+matriksFile[fileIdMatch[i]][1]+"</td><td>"+matriksFile[fileIdMatch[i]][2]+"</td>   <td>"+idMatch[i]+"</td><td>"+matriksDeposit[idMatch[i]][0]+"</td><td>"+matriksDeposit[idMatch[i]][1]+"</td><td>"+matriksDeposit[idMatch[i]][2]+"</td><td>"+matriksDeposit[idMatch[i]][3]+"</td>");
						%>
						<tr>
							<td><div align="center">
									<font size="1" face="Verdana, Arial, Helvetica, sans-serif"><%=fileIdMatch[i]%></font>
								</div></td>
							<td><div align="center">
									<font size="1" face="Verdana, Arial, Helvetica, sans-serif"><%=matriksFile[fileIdMatch[i]][0]%></font>
								</div></td>
							<td><div align="center">
									<font size="1" face="Verdana, Arial, Helvetica, sans-serif"><%=matriksFile[fileIdMatch[i]][1]%></font>
								</div></td>
							<td><div align="center">
									<font size="1" face="Verdana, Arial, Helvetica, sans-serif"><%=matriksFile[fileIdMatch[i]][2]%></font>
								</div></td>
							<td><div align="center">
									<font size="1" face="Verdana, Arial, Helvetica, sans-serif"><%=idMatch[i]%></font>
								</div></td>
							<td><div align="center">
									<font size="1" face="Verdana, Arial, Helvetica, sans-serif"><%=matriksDeposit[idMatch[i]][0]%></font>
								</div></td>
							<td><div align="center">
									<font size="1" face="Verdana, Arial, Helvetica, sans-serif"><%=matriksDeposit[idMatch[i]][1]%></font>
								</div></td>
							<td><div align="center">
									<font size="1" face="Verdana, Arial, Helvetica, sans-serif"><%=matriksDeposit[idMatch[i]][2]%></font>
								</div></td>
							<td><div align="center">
									<font size="1" face="Verdana, Arial, Helvetica, sans-serif"><%=matriksDeposit[idMatch[i]][3]%></font>
								</div></td>
						</tr>
						<%
							//out.println("</tr>");
											}
						%>
					</table>
					<%
						//PROSES PENGUPDATEAN
										String sXid = ", ";
										Boolean statusUpdate = true;
										try {
											for (int i = 0; i < idMatchInt; i++) {
												sXid = sXid + matriksDeposit[idMatch[i]][3] + ", ";
												//UPDATE 1
												pstmt = con.prepareStatement(
														"UPDATE merchant_cashout SET is_executed = '2', completion_date = TO_DATE('"
																+ (matriksFile[fileIdMatch[i]][0]).substring(0, 10)
																+ "', 'YYYY-MM-DD'), executor = '" + username
																+ "' WHERE cashout_id = '" + matriksDeposit[idMatch[i]][3] + "'");
												pstmt.executeUpdate();
												pstmt.close();

												pstmt = con.prepareStatement(
														"UPDATE settlement_history SET status = '2' WHERE exec_id = '"
																+ matriksDeposit[idMatch[i]][3] + "' AND amount > 0");
												pstmt.executeUpdate();
												pstmt.close();

												//UPDATE 2
												//String sql = "UPDATE ACC_STATEMENT SET REF='"+matriksDeposit[idMatch[i]][3]+"', STATUS='2' WHERE TX_DATE=TO_DATE('"+matriksFile[fileIdMatch[i]][0].substring(0,10)+"', 'YYYY-MM-DD') AND DESCRIPTION='"+matriksFile[fileIdMatch[i]][1]+"' AND TIPE='D' AND AMOUNT="+matriksFile[fileIdMatch[i]][2];
												String sql = "UPDATE ACC_STATEMENT SET REF='" + matriksDeposit[idMatch[i]][3]
														+ "', STATUS='2' WHERE TX_DATE between TO_DATE('"
														+ matriksFile[fileIdMatch[i]][0].substring(0, 10)
														+ " 000000', 'YYYY-MM-DD HH24MISS') and TO_DATE('"
														+ matriksFile[fileIdMatch[i]][0].substring(0, 10)
														+ " 235959', 'YYYY-MM-DD HH24MISS') AND DESCRIPTION='"
														+ matriksFile[fileIdMatch[i]][1] + "' AND TIPE='D' AND AMOUNT="
														+ matriksFile[fileIdMatch[i]][2];
												pstmt = con.prepareStatement(sql);
												pstmt.executeUpdate();
												pstmt.close();
												statusUpdate &= true;
											}
											con.commit();
										} catch (Exception sqlerr) {
											statusUpdate &= false;
											con.rollback();
										}
										if (statusUpdate) {
											con.commit();
											out.println("<script language='javascript'>alert('Solve tickets no " + sXid.substring(2)
													+ " successful')</script>");
											outPUT += (sXid.substring(2) + "Solved|");

											// send sms to all merchant
											for (int i = 0; i < idMatchInt; i++) {
												// send SMS to Merchant ======================
												String amt = null, dnb = null, accno = null, bala = null, nmr = null, mrid = null;
												try {
													query = "select merchant_id, doc_number, amount from merchant_cashout where cashout_id='"
															+ matriksDeposit[idMatch[i]][3] + "'";
													pstmt = con.prepareStatement(query);
													rs = pstmt.executeQuery();
													if (rs.next()) {
														amt = rs.getString("amount");
														dnb = rs.getString("doc_number");
														mrid = rs.getString("merchant_id");
													}
													pstmt.close();
													rs.close();

													if (mrid != null && !mrid.equals("")) {
														query = "select acc_no, merchant_info_id,msisdn from merchant where merchant_id='"
																+ mrid + "'";
														pstmt = con.prepareStatement(query);
														rs = pstmt.executeQuery();
														if (rs.next()) {
															accno = rs.getString("acc_no");
															mrid = rs.getString("merchant_info_id");
															nmr = rs.getString("msisdn");
														}
														pstmt.close();
														rs.close();
													}

													if (accno != null && !accno.equals("")) {
														query = "select balance from tsel_merchant_account where acc_no='" + accno
																+ "'";
														pstmt = con.prepareStatement(query);
														rs = pstmt.executeQuery();
														if (rs.next()) {
															bala = rs.getString("balance");
														}
														pstmt.close();
														rs.close();
													}

													SimpleDateFormat sdf1 = new SimpleDateFormat("dd/MM/yy HH:mm");

													//reg.sendSms(nmr, sdf1.format(Calendar.getInstance().getTime())+" Cashout sebesar Rp "+returnFloat(amt)+" sudah dibayarkan. No. Doc: "+dnb+". Balance anda Rp "+returnFloat(bala)+".", "2828");
													pstmt = con.prepareStatement(
															"insert into notif(msisdn, msg, source, s_time) values('" + nmr + "', '"
																	+ sdf1.format(Calendar.getInstance().getTime())
																	+ " Cashout sebesar Rp " + returnFloat(amt)
																	+ " sudah dibayarkan. No. Doc: " + dnb + ". Balance anda Rp "
																	+ returnFloat(bala) + "." + "','2828', sysdate)");
													//pstmt.clearParameters();
													pstmt.executeUpdate();
													con.commit();
													// end of send sms to merchant ======================
													outPUT += (matriksDeposit[idMatch[i]][3] + "," + mrid + " SMS sent|");
												} catch (Exception e_sms) {
													outPUT += (matriksDeposit[idMatch[i]][3] + "," + mrid + " SMS not sent|");
												}
											}
										} else {
											out.println(
													"<script language='javascript'>alert('Solve tickets is unsuccessful.')</script>");
											outPUT += "Solve tickets is unsuccessful. Please check again|";
										}
										con.setAutoCommit(true);
									} else {
										out.println(
												"<script language='javascript'>alert('Tidak ada account statement yang cocok dengan cashout. Tidak ada data yang diubah.')</script>");
										outPUT += "No matching between statement and cashout cashout. No data changed|";
									}
								} else {
									out.println(
											"<script language='javascript'>alert('Account statement atau cashout ada yang kosong.')</script>");
									outPUT += "Either account statement or cashout records is empty|";
								}
							}
						}

						catch (Exception e) {
							e.printStackTrace();
							out.println("<script language='javascript'>alert('Error : " + e.getMessage() + "')</script>");
							outPUT += "Exception occured. Error :" + e.getMessage();
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
									System.out.println("[" + timeNOW + "]new_uploadPaymentStatus.jsp|" + outPUT);
								//=====================================================================//
							} catch (Exception e) {
							}
						}
					%>

					<p>Please input Mandiri and BNI account statement to proceed.</p>
					<form action="new_uploadPaymentStatus.jsp"
						enctype="multipart/form-data" method="post">
						<input type="radio" name="days" value="H"
							<%if (!days.equals("H-"))
				out.print("checked");%>>H <input
							type="radio" name="days" value="H-"
							<%if (days.equals("H-"))
				out.print("checked");%>>H-x days
						<input type="file" name="path"><input type="Submit"
							name="Submit" value="Upload File"> <input type="hidden"
							name="idLog1" value="<%=(encLog.equals("")) ? encLogP : encLog%>">
						<input type="hidden" name="idLog2"
							value="<%=(encPass.equals("")) ? encPassP : encPass%>">
					</form>

					<a
						href="https://10.2.114.121:9082/tcash-web/finance/new_cashout_approve.jsp">Back
						to New Cashout Approval</a>
				</center> <br />
			<br />
			<br />


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
