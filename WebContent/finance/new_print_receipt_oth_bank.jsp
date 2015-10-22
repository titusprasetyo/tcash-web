<%@ page
	import="java.io.*, java.util.*,java.text.*, oracle.jdbc.driver.*, java.sql.*, com.itextpdf.text.*,com.itextpdf.text.pdf.*,com.telkomsel.itvas.webstarter.User,com.telkomsel.itvas.webstarter.WebStarterProperties"%>
<jsp:useBean id="DbCon" scope="page" class="tsel_tunai.DbCon"></jsp:useBean>
<%
	//=========================================
	Calendar CAL = Calendar.getInstance();
	SimpleDateFormat SDF = new SimpleDateFormat("dd-MM-yyyy HH:mm:ss");
	String timeNOW = SDF.format(CAL.getTime());
	String outPUT = "";
	//=========================================

	User user = (User) session.getValue("user");
	String date = request.getParameter("date");
	String xid = request.getParameter("xid"); //settlement id

	String type = request.getParameter("type");
	String queryPrint = request.getParameter("query");

	//untuk keperluan mass approval
	String method = request.getParameter("method");
	String[] xID = request.getParameterValues("xID");
	String[] merchantID = request.getParameterValues("merchant_id");
	Document document = new Document(PageSize.A4.rotate());

	String name = null;
	String address = null;
	String npwp = null;
	String bank_name = null;
	String bank_acc = null;
	String acc_holder = null;
	String amount = null;
	String doc = null;
	String note = null;
	String rid = null;
	String deposit_time = null;
	//String bank_name = null;
	String mid = null;

	String[] _date = null;
	String[] _approver_title = WebStarterProperties.getInstance().getProperty("settlement.approver.title")
			.split("\\|");
	String[] _approver_name = WebStarterProperties.getInstance().getProperty("settlement.approver.name")
			.split("\\|");
	String[] _month = { "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI", "XII" };

	String doc_type = type.equals("deposit") ? "IN" : "OUT";
	String s1 = type.equals("deposit") ? "terima dari" : "dibayarkan ke";
	String s2 = type.equals("deposit") ? "Pembayaran" : "Terima";
	String docTitle = type.equals("deposit") ? "KUITANSI" : "PERINTAH BAYAR";

	SimpleDateFormat sdf = new SimpleDateFormat("dd-MM-yyyy");
	NumberFormat nf = NumberFormat.getInstance(Locale.ITALY);

	String query = null;
	Connection conn = null;
	PreparedStatement pstmt = null;
	ResultSet rs = null;

	try {
		conn = DbCon.getConnection();

		if (method != null && xid == null && xID != null && merchantID != null) {
			outPUT += "MULTI|";
			//INI BAGIAN MASS APRROVAL
			response.reset();
			response.setContentType("application/pdf");

			// check dulu apakah semua id tersebut sudah mempunyai receipt id atau tidak, ini mungkin saja terjadi bila setelah receipt diprint, user menekan tombol back dan melakukan proses yang sama (page belum refresh) 

			boolean check_is_receipt = true;
			for (int i = 0; i < xID.length; i++) {
				if (date == null) {
					query = "select * from merchant_" + type + " WHERE " + type
							+ "_id = ? and receipt_id is not null";
					pstmt = conn.prepareStatement(query);
					pstmt.clearParameters();
					pstmt.setString(1, xID[i]);
					rs = pstmt.executeQuery();
					if (rs.next()) {
						check_is_receipt &= false;
					}
					rs.close();
					pstmt.close();
				}
			}

			if (!check_is_receipt) {
				response.sendRedirect("new_cashout_approve.jsp");
			}

			//mass aproval, update semuanya..
			conn.setAutoCommit(false);
			for (int i = 0; i < xID.length; i++) {
				if (date == null) {
					query = "UPDATE merchant_" + type
							+ " SET print_date = SYSDATE, receipt_id = settlement_doc_sequence.NEXTVAL WHERE "
							+ type + "_id = ?";
					pstmt = conn.prepareStatement(query);
					pstmt.clearParameters();
					pstmt.setString(1, xID[i]);
					pstmt.executeUpdate();
					pstmt.close();
					outPUT += (xID[i] + "|");
				}
			}
			conn.commit();

			PdfWriter.getInstance(document, response.getOutputStream());
			//NEW DOCUMENT
			document.open();

			PdfPTable table;
			PdfPCell cell;
			Paragraph p1;

			// start writing PDF summary
			//NEW TABLE
			table = new PdfPTable(1);
			cell = new PdfPCell();

			//NEW CELL
			p1 = new Paragraph();
			p1.add("SUMMARY " + type + " TCASH");
			p1.setAlignment(Element.ALIGN_CENTER);
			cell.addElement(p1);
			cell.setBorder(0);
			table.addCell(cell);
			document.add(table);

			//NEW TABLE			
			table = new PdfPTable(2);
			cell = new PdfPCell();

			//NEW CELL
			p1 = new Paragraph();
			p1.add("");
			p1.setAlignment(Element.ALIGN_CENTER);
			cell.setBorder(0);
			cell.addElement(p1);
			table.addCell(cell);

			//NEXT CELL
			cell = new PdfPCell();

			p1 = new Paragraph();
			p1.add("PT. TELEKOMUNIKASI SELULAR");
			p1.setAlignment(Element.ALIGN_RIGHT);
			cell.addElement(p1);

			p1 = new Paragraph();
			p1.add("Wisma Mulia");
			p1.setAlignment(Element.ALIGN_RIGHT);
			cell.addElement(p1);

			p1 = new Paragraph();
			p1.add("Jl. Gatot Subroto KAV 42 Jakarta Selatan 12710");
			p1.setAlignment(Element.ALIGN_RIGHT);
			cell.addElement(p1);

			p1 = new Paragraph();
			p1.add("NPWP/PKP: 01.718.327.8.091.00");
			p1.setAlignment(Element.ALIGN_RIGHT);
			cell.setBorder(0);
			cell.addElement(p1);

			cell.setPadding(10.0f);
			table.addCell(cell);

			document.add(table);

			//NEW TABLE			
			float[] tableCol = { 1.2f, 2.0f, 1.8f, 1.6f, 1.2f, 1.2f, 1.0f };
			table = new PdfPTable(tableCol);
			// NEW CELL
			cell = new PdfPCell();
			p1 = new Paragraph();
			p1.add("TANGGAL");
			p1.setAlignment(Element.ALIGN_CENTER);
			cell.addElement(p1);
			table.addCell(cell);

			// NEXT CELL
			cell = new PdfPCell();
			p1 = new Paragraph();
			p1.add("MERCHANT");
			p1.setAlignment(Element.ALIGN_CENTER);
			cell.addElement(p1);
			table.addCell(cell);

			// NEXT CELL
			cell = new PdfPCell();
			p1 = new Paragraph();
			p1.add("MERCHANT ID");
			p1.setAlignment(Element.ALIGN_CENTER);
			cell.addElement(p1);
			table.addCell(cell);

			// NEXT CELL
			cell = new PdfPCell();
			p1 = new Paragraph();
			p1.add("NOMINAL");
			p1.setAlignment(Element.ALIGN_CENTER);
			cell.addElement(p1);
			table.addCell(cell);

			// NEXT CELL
			cell = new PdfPCell();
			p1 = new Paragraph();
			p1.add("ACCOUNT NO");
			p1.setAlignment(Element.ALIGN_CENTER);
			cell.addElement(p1);
			table.addCell(cell);

			// NEXT CELL
			cell = new PdfPCell();
			p1 = new Paragraph();
			p1.add("ACCOUNT");
			p1.setAlignment(Element.ALIGN_CENTER);
			cell.addElement(p1);
			table.addCell(cell);

			// NEXT CELL
			cell = new PdfPCell();
			p1 = new Paragraph();
			p1.add("BANK");
			p1.setAlignment(Element.ALIGN_CENTER);
			cell.addElement(p1);
			table.addCell(cell);

			document.add(table);

			int counter = 0;
			int tamo = 0;
			// looping for data
			//for(int j=0;j<10;j++){
			for (int i = 0; i < xID.length; i++) {
				//MULAI AMBIL DATA PER xID
				query = "SELECT * from merchant_" + type + " a, merchant b, merchant_info c WHERE a." + type
						+ "_id = ? AND a.merchant_id = b.merchant_id AND b.merchant_info_id = c.merchant_info_id";
				pstmt = conn.prepareStatement(query);
				pstmt.clearParameters();
				pstmt.setString(1, xID[i]);
				rs = pstmt.executeQuery();
				if (rs.next()) {
					name = rs.getString("name");
					bank_name = rs.getString("bank_name");
					bank_acc = rs.getString("bank_acc_no");
					acc_holder = rs.getString("bank_acc_holder");
					amount = rs.getString("amount");
					deposit_time = sdf.format(rs.getTimestamp("deposit_time"));
					mid = rs.getString("merchant_id");
					tamo += rs.getInt("amount");
				}
				rs.close();
				pstmt.close();

				_date = deposit_time.split("-");

				String[] _amount = amount.split(",");
				if (_amount.length > 1)
					amount = nf.format(Long.parseLong(_amount[0])) + "," + _amount[1];
				else
					amount = nf.format(Long.parseLong(_amount[0]));

				// starting to write a record

				//NEW TABLE	
				table = new PdfPTable(tableCol);
				// NEW CELL
				cell = new PdfPCell();
				p1 = new Paragraph();
				p1.add(deposit_time);
				p1.setAlignment(Element.ALIGN_CENTER);
				cell.addElement(p1);
				table.addCell(cell);

				// NEXT CELL
				cell = new PdfPCell();
				p1 = new Paragraph();
				p1.add(name);
				p1.setAlignment(Element.ALIGN_LEFT);
				cell.addElement(p1);
				table.addCell(cell);

				// NEXT CELL
				cell = new PdfPCell();
				p1 = new Paragraph();
				p1.add(mid);
				p1.setAlignment(Element.ALIGN_LEFT);
				cell.addElement(p1);
				table.addCell(cell);

				// NEXT CELL
				cell = new PdfPCell();
				p1 = new Paragraph();
				p1.add(amount);
				p1.setAlignment(Element.ALIGN_RIGHT);
				cell.addElement(p1);
				table.addCell(cell);

				// NEXT CELL
				cell = new PdfPCell();
				p1 = new Paragraph();
				p1.add(bank_acc);
				p1.setAlignment(Element.ALIGN_RIGHT);
				cell.addElement(p1);
				table.addCell(cell);

				// NEXT CELL
				cell = new PdfPCell();
				p1 = new Paragraph();
				p1.add(acc_holder);
				p1.setAlignment(Element.ALIGN_RIGHT);
				cell.addElement(p1);
				table.addCell(cell);

				// NEXT CELL
				cell = new PdfPCell();
				p1 = new Paragraph();
				p1.add(bank_name);
				p1.setAlignment(Element.ALIGN_CENTER);
				cell.addElement(p1);
				table.addCell(cell);

				document.add(table);
				counter++;

				if (counter % 15 == 0)
					document.newPage();

			}
			//=== tuliskan detail total amount + record
			String tamp = "";
			String[] _tamo = String.valueOf(tamo).split(",");
			if (_tamo.length > 1)
				tamp = nf.format(Long.parseLong(_tamo[0])) + "," + _tamo[1];
			else
				tamp = nf.format(Long.parseLong(_tamo[0]));
			//NEW TABLE	
			table = new PdfPTable(1);
			// NEW CELL
			cell = new PdfPCell();
			p1 = new Paragraph();
			p1.add("Total Amount : Rp. " + tamp + "  (" + counter + " records)");
			p1.setAlignment(Element.ALIGN_CENTER);
			cell.addElement(p1);
			table.addCell(cell);

			document.add(table);

			//}	

			// end of writing tcash cashout/deposit summary

			// now looping detail invoice.
			for (int i = 0; i < xID.length; i++) {
				//MULAI AMBIL DATA PER xID
				query = "SELECT * from merchant_" + type + " a, merchant b, merchant_info c WHERE a." + type
						+ "_id = ? AND a.merchant_id = b.merchant_id AND b.merchant_info_id = c.merchant_info_id";
				pstmt = conn.prepareStatement(query);
				pstmt.clearParameters();
				pstmt.setString(1, xID[i]);
				rs = pstmt.executeQuery();
				if (rs.next()) {
					name = rs.getString("name");
					address = rs.getString("address");
					npwp = rs.getString("npwp");
					bank_name = rs.getString("bank_name");
					bank_acc = rs.getString("bank_acc_no");
					acc_holder = rs.getString("bank_acc_holder");
					amount = rs.getString("amount");
					doc = rs.getString("doc_number");
					note = rs.getString("note");
					date = sdf.format(rs.getTimestamp("print_date"));
					rid = rs.getString("receipt_id");
				}
				rs.close();
				pstmt.close();

				_date = date.split("-");

				String[] _amount = amount.split(",");
				if (_amount.length > 1)
					amount = nf.format(Long.parseLong(_amount[0])) + "," + _amount[1];
				else
					amount = nf.format(Long.parseLong(_amount[0]));
				// start write the pdf

				//==========================================================================

				document.newPage(); // halaman kedua

				table = new PdfPTable(2);
				cell = new PdfPCell();

				//NEW TABLE
				//float [] colWidth = {1f, 2f};
				table.setWidthPercentage(90);

				//NEW CELL

				p1 = new Paragraph();

				p1.add(docTitle);
				p1.setAlignment(Element.ALIGN_CENTER);
				cell.addElement(p1);

				p1 = new Paragraph();
				p1.add("NO: " + rid + "/TSEL/TCASH-" + doc_type + "/" + _month[Integer.parseInt(_date[1]) - 1]
						+ "/" + _date[2]);
				p1.setAlignment(Element.ALIGN_CENTER);
				cell.setBorder(0);
				cell.addElement(p1);

				cell.setPadding(10.0f);
				table.addCell(cell);

				//NEXT CELL
				cell = new PdfPCell();

				p1 = new Paragraph();
				p1.add("PT. TELEKOMUNIKASI SELULAR");
				p1.setAlignment(Element.ALIGN_RIGHT);
				cell.addElement(p1);

				p1 = new Paragraph();
				p1.add("Wisma Mulia");
				p1.setAlignment(Element.ALIGN_RIGHT);
				cell.addElement(p1);

				p1 = new Paragraph();
				p1.add("Jl. Gatot Subroto KAV 42 Jakarta Selatan 12710");
				p1.setAlignment(Element.ALIGN_RIGHT);
				cell.addElement(p1);

				p1 = new Paragraph();
				p1.add("NPWP/PKP: 01.718.327.8.091.00");
				p1.setAlignment(Element.ALIGN_RIGHT);
				cell.setBorder(0);
				cell.addElement(p1);

				cell.setPadding(10.0f);
				table.addCell(cell);

				document.add(table);

				//NEXT TABLE
				float[] colWidth = { 0.5f, 2f };
				table = new PdfPTable(colWidth);
				table.setWidthPercentage(100);
				//NEW CELL
				cell = new PdfPCell();
				//cell.setPadding (10.0f);
				p1 = new Paragraph();
				p1.add("Sudah " + s1);
				//p1.setAlignment(Element.ALIGN_RIGHT);
				cell.setBorder(0);
				cell.addElement(p1);
				table.addCell(cell);
				//NEXT CELL
				cell = new PdfPCell();
				p1 = new Paragraph();
				p1.add(": " + name);
				//p1.setAlignment(Element.ALIGN_RIGHT);
				cell.setBorder(0);
				cell.addElement(p1);
				table.addCell(cell);
				//NEXT CELL
				cell = new PdfPCell();
				p1 = new Paragraph();
				p1.add("Alamat");
				//p1.setAlignment(Element.ALIGN_RIGHT);
				cell.setBorder(0);
				cell.addElement(p1);
				table.addCell(cell);
				//NEXT CELL
				cell = new PdfPCell();
				p1 = new Paragraph();
				p1.add(": " + address);
				//p1.setAlignment(Element.ALIGN_RIGHT);
				cell.setBorder(0);
				cell.addElement(p1);
				table.addCell(cell);
				//NEXT CELL
				cell = new PdfPCell();
				p1 = new Paragraph();
				p1.add("NPWP");
				//p1.setAlignment(Element.ALIGN_RIGHT);
				cell.setBorder(0);
				cell.addElement(p1);
				table.addCell(cell);
				//NEXT CELL
				cell = new PdfPCell();
				p1 = new Paragraph();
				p1.add(": " + npwp);
				//p1.setAlignment(Element.ALIGN_RIGHT);
				cell.setBorder(0);
				cell.addElement(p1);
				table.addCell(cell);
				//NEXT CELL
				cell = new PdfPCell();
				p1 = new Paragraph();
				p1.add("Bank");
				//p1.setAlignment(Element.ALIGN_RIGHT);
				cell.setBorder(0);
				cell.addElement(p1);
				table.addCell(cell);
				//NEXT CELL
				cell = new PdfPCell();
				p1 = new Paragraph();
				p1.add(": " + bank_name);
				//p1.setAlignment(Element.ALIGN_RIGHT);
				cell.setBorder(0);
				cell.addElement(p1);
				table.addCell(cell);
				//NEXT CELL
				cell = new PdfPCell();
				p1 = new Paragraph();
				p1.add("No Rekening");
				//p1.setAlignment(Element.ALIGN_RIGHT);
				cell.setBorder(0);
				cell.addElement(p1);
				table.addCell(cell);
				//NEXT CELL
				cell = new PdfPCell();
				p1 = new Paragraph();
				p1.add(": " + bank_acc);
				//p1.setAlignment(Element.ALIGN_RIGHT);
				cell.setBorder(0);
				cell.addElement(p1);
				table.addCell(cell);
				//NEXT CELL
				cell = new PdfPCell();
				p1 = new Paragraph();
				p1.add("Pemegang Rekening");
				//p1.setAlignment(Element.ALIGN_RIGHT);
				cell.setBorder(0);
				cell.addElement(p1);
				table.addCell(cell);
				//NEXT CELL
				cell = new PdfPCell();
				p1 = new Paragraph();
				p1.add(": " + acc_holder);
				//p1.setAlignment(Element.ALIGN_RIGHT);
				cell.setBorder(0);
				cell.addElement(p1);
				table.addCell(cell);

				document.add(table);

				p1 = new Paragraph("Untuk Pembayaran dengan rincian:");
				p1.setSpacingBefore(10f);
				p1.setIndentationLeft(2f);
				document.add(new Paragraph(p1));

				//NEW TABLE
				float[] colWidth2 = { 0.5f, 6.5f, 3f };
				table = new PdfPTable(colWidth2);
				table.setWidthPercentage(100);
				table.setSpacingBefore(5f);

				//NEW CELL
				cell = new PdfPCell();

				//Chunk c1;

				//c1 = new Chunk();
				//c1.setFont("Tahoma",11,"BOLD")
				p1 = new Paragraph();
				p1.add("No");
				p1.setAlignment(Element.ALIGN_CENTER);
				p1.setSpacingAfter(5f);

				//cell.setPaddingTop(0.5f);
				cell.addElement(p1);
				cell.setBorderWidth(2f);
				table.addCell(cell);

				//NEXT CELL
				cell = new PdfPCell();

				p1 = new Paragraph();
				p1.add("Keterangan");
				p1.setAlignment(Element.ALIGN_CENTER);

				//cell.setPaddingTop(0.5f);
				cell.addElement(p1);
				cell.setBorderWidth(2f);
				table.addCell(cell);

				//NEXT CELL
				cell = new PdfPCell();

				p1 = new Paragraph();
				p1.add("Jumlah (Rp)");
				p1.setAlignment(Element.ALIGN_CENTER);

				//cell.setPaddingTop(0.5f);
				cell.addElement(p1);
				cell.setBorderWidth(2f);
				table.addCell(cell);

				//NEXT CELL
				cell = new PdfPCell();

				p1 = new Paragraph();
				p1.add("1.");
				p1.setAlignment(Element.ALIGN_RIGHT);

				//cell.setBorder(0);
				cell.addElement(p1);
				cell.setBorderWidth(2f);
				table.addCell(cell);

				//NEXT CELL
				cell = new PdfPCell();

				p1 = new Paragraph();
				p1.add("T-Cash " + type);
				p1.setAlignment(Element.ALIGN_LEFT);

				//cell.setBorder(0);
				cell.addElement(p1);

				p1 = new Paragraph();
				p1.add("Doc Number: " + doc);
				p1.setAlignment(Element.ALIGN_LEFT);

				//cell.setBorder(0);
				cell.addElement(p1);

				p1 = new Paragraph();
				p1.add("Note: " + note);
				p1.setAlignment(Element.ALIGN_LEFT);
				p1.setSpacingAfter(5f);

				//cell.setBorder(0);
				cell.addElement(p1);
				cell.setBorderWidth(2f);
				table.addCell(cell);

				//NEXT CELL
				cell = new PdfPCell();

				p1 = new Paragraph();
				p1.add(amount);
				p1.setAlignment(Element.ALIGN_RIGHT);

				//cell.setBorder(0);
				cell.addElement(p1);
				cell.setBorderWidth(2f);
				table.addCell(cell);

				cell = new PdfPCell();
				cell.setBorderWidth(2f);
				table.addCell(cell);

				//NEXT CELL
				cell = new PdfPCell();

				p1 = new Paragraph();
				p1.add("Total Pembayaran");
				p1.setAlignment(Element.ALIGN_RIGHT);
				p1.setSpacingAfter(5f);

				//cell.setBorder(0);
				cell.addElement(p1);
				cell.setBorderWidth(2f);
				table.addCell(cell);

				//NEXT CELL
				cell = new PdfPCell();

				p1 = new Paragraph();
				p1.add(amount);
				p1.setAlignment(Element.ALIGN_RIGHT);

				//cell.setBorder(0);
				cell.addElement(p1);
				cell.setBorderWidth(2f);
				table.addCell(cell);

				document.add(table);

				//NEW TABLE
				float[] colWidth3 = { 1f, 1f, 1f };
				table = new PdfPTable(colWidth3);
				table.setWidthPercentage(90);

				//NEW CELL
				cell = new PdfPCell();
				cell.setBorder(0);
				table.addCell(cell);
				//NEW CELL
				cell = new PdfPCell();
				cell.setBorder(0);
				table.addCell(cell);

				//NEW CELL
				cell = new PdfPCell();
				p1 = new Paragraph();
				p1.add("Jakarta HQ, " + date);
				p1.setSpacingBefore(10f);
				p1.setAlignment(Element.ALIGN_CENTER);

				cell.setBorder(0);
				cell.addElement(p1);
				table.addCell(cell);

				//NEW CELL
				cell = new PdfPCell();
				cell.setBorder(0);
				//cell.setPadding (10.0f);
				p1 = new Paragraph();
				p1.add("Printed by:");
				p1.setAlignment(Element.ALIGN_CENTER);
				cell.setBorder(0);
				cell.addElement(p1);
				table.addCell(cell);

				//NEW CELL
				cell = new PdfPCell();
				cell.setBorder(0);
				table.addCell(cell);

				//NEW CELL
				cell = new PdfPCell();
				cell.setBorder(0);
				//cell.setPadding (10.0f);
				p1 = new Paragraph();
				p1.add("Approved by:");
				p1.setAlignment(Element.ALIGN_CENTER);
				cell.setBorder(0);
				cell.addElement(p1);
				table.addCell(cell);

				cell = new PdfPCell();
				cell.setBorder(0);
				table.addCell(cell);

				cell = new PdfPCell();
				cell.setBorder(0);
				table.addCell(cell);

				cell = new PdfPCell();
				cell.setBorder(0);
				table.addCell(cell);

				cell = new PdfPCell();
				cell.setBorder(0);
				table.addCell(cell);

				cell = new PdfPCell();
				cell.setBorder(0);
				table.addCell(cell);

				cell = new PdfPCell();
				cell.setBorder(0);
				table.addCell(cell);

				cell = new PdfPCell();
				cell.setBorder(0);
				table.addCell(cell);

				cell = new PdfPCell();
				cell.setBorder(0);
				table.addCell(cell);

				cell = new PdfPCell();
				cell.setBorder(0);
				table.addCell(cell);

				cell = new PdfPCell();
				cell.setBorder(0);
				table.addCell(cell);

				cell = new PdfPCell();
				cell.setBorder(0);
				table.addCell(cell);

				cell = new PdfPCell();
				cell.setBorder(0);
				table.addCell(cell);

				cell = new PdfPCell();
				cell.setBorder(0);
				table.addCell(cell);

				cell = new PdfPCell();
				cell.setBorder(0);
				table.addCell(cell);

				cell = new PdfPCell();
				cell.setBorder(0);
				table.addCell(cell);

				cell = new PdfPCell();
				cell.setBorder(0);
				table.addCell(cell);

				cell = new PdfPCell();
				cell.setBorder(0);
				table.addCell(cell);

				cell = new PdfPCell();
				cell.setBorder(0);
				table.addCell(cell);

				cell = new PdfPCell();
				cell.setBorder(0);
				table.addCell(cell);

				cell = new PdfPCell();
				cell.setBorder(0);
				table.addCell(cell);

				cell = new PdfPCell();
				cell.setBorder(0);
				table.addCell(cell);

				cell = new PdfPCell();
				cell.setBorder(0);
				table.addCell(cell);

				cell = new PdfPCell();
				cell.setBorder(0);
				table.addCell(cell);

				cell = new PdfPCell();
				cell.setBorder(0);
				table.addCell(cell);

				cell = new PdfPCell();
				cell.setBorder(0);
				table.addCell(cell);

				cell = new PdfPCell();
				cell.setBorder(0);
				table.addCell(cell);

				cell = new PdfPCell();
				cell.setBorder(0);
				table.addCell(cell);

				cell = new PdfPCell();
				cell.setBorder(0);
				table.addCell(cell);

				cell = new PdfPCell();
				cell.setBorder(0);
				table.addCell(cell);

				cell = new PdfPCell();
				cell.setBorder(0);
				table.addCell(cell);

				cell = new PdfPCell();
				cell.setBorder(0);
				table.addCell(cell);

				cell = new PdfPCell();
				cell.setBorder(0);
				table.addCell(cell);

				cell = new PdfPCell();
				cell.setBorder(0);
				table.addCell(cell);

				cell = new PdfPCell();
				cell.setBorder(0);
				table.addCell(cell);

				cell = new PdfPCell();
				cell.setBorder(0);
				table.addCell(cell);

				cell = new PdfPCell();
				cell.setBorder(0);
				table.addCell(cell);

				cell = new PdfPCell();
				cell.setBorder(0);
				table.addCell(cell);

				cell = new PdfPCell();
				cell.setBorder(0);
				table.addCell(cell);

				cell = new PdfPCell();
				cell.setBorder(0);
				table.addCell(cell);

				cell = new PdfPCell();
				cell.setBorder(0);
				table.addCell(cell);

				cell = new PdfPCell();
				cell.setBorder(0);
				table.addCell(cell);

				cell = new PdfPCell();
				cell.setBorder(0);
				table.addCell(cell);

				cell = new PdfPCell();
				cell.setBorder(0);
				table.addCell(cell);

				cell = new PdfPCell();
				cell.setBorder(0);
				table.addCell(cell);

				cell = new PdfPCell();
				cell.setBorder(0);
				table.addCell(cell);

				//NEW CELL
				cell = new PdfPCell();
				cell.setBorder(0);
				//cell.setPadding (10.0f);
				p1 = new Paragraph();
				p1.add(user.getFullName());
				p1.setAlignment(Element.ALIGN_CENTER);
				cell.setBorder(0);
				cell.addElement(p1);
				table.addCell(cell);

				//NEW CELL
				cell = new PdfPCell();
				cell.setBorder(0);
				//cell.setPadding (10.0f);
				p1 = new Paragraph();
				p1.add(_approver_name[0]);
				p1.setAlignment(Element.ALIGN_CENTER);
				cell.setBorder(0);
				cell.addElement(p1);
				table.addCell(cell);

				//NEW CELL
				cell = new PdfPCell();
				//cell.setPadding (10.0f);
				cell.setBorder(0);
				p1 = new Paragraph();
				p1.add(_approver_name[1]);
				p1.setAlignment(Element.ALIGN_CENTER);
				cell.setBorder(0);
				cell.addElement(p1);
				table.addCell(cell);

				//NEW CELL
				cell = new PdfPCell();
				cell.setBorder(0);
				//cell.setPadding (10.0f);
				cell.setBorder(0);
				//cell.addElement(p1);
				table.addCell(cell);

				//NEW CELL
				cell = new PdfPCell();
				cell.setBorder(0);
				//cell.setPadding (10.0f);
				p1 = new Paragraph();
				p1.add(_approver_title[0]);
				p1.setAlignment(Element.ALIGN_CENTER);
				cell.setBorder(0);
				cell.addElement(p1);
				table.addCell(cell);

				//NEW CELL
				cell = new PdfPCell();
				//cell.setPadding (10.0f);
				cell.setBorder(0);
				p1 = new Paragraph();
				p1.add(_approver_title[1]);
				p1.setAlignment(Element.ALIGN_CENTER);
				cell.setBorder(0);
				cell.addElement(p1);
				table.addCell(cell);

				document.add(table);
				//==============================================================================

				if (i != xID.length)
					document.newPage();
			}
			document.close();
			outPUT += "Invoice Printed|";
		}
	} catch (Exception e) {
		e.printStackTrace(System.out);
		try {
			conn.rollback();
		} catch (Exception e2) {
		}
		outPUT += ("Exception occured. Error:" + e.getMessage());
	} finally {
		try {
			conn.close();
		} catch (Exception e) {
		}
		//=====================================================================//
		if (!outPUT.equals(""))
			System.out.println("[" + timeNOW + "]new_print_receipt.jsp|" + outPUT);
		//=====================================================================//	
	}
%>