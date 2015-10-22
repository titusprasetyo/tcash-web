<%@page import="java.io.*, java.util.*, java.text.*, java.sql.*, org.apache.commons.lang.*"%>
<%@ include file="/web-starter/taglibs.jsp"%>
<%@page import="com.telkomsel.itvas.webstarter.User"%>
<jsp:useBean id="DbCon" scope="page" class="tsel_tunai.DbCon"></jsp:useBean>
<%
String comm = request.getParameter("comm");


%>
<stripes:layout-render name="/web-starter/layout/standard.jsp"
	title="Bulk Payment CSV Maker">
	<stripes:layout-component name="contents">
		<%
//=========================================
Calendar CAL = Calendar.getInstance();
SimpleDateFormat SDF = new SimpleDateFormat("dd-MM-yyyy HH:mm:ss");
String timeNOW=SDF.format(CAL.getTime());
String outPUT = "";
//=========================================

Connection con = null;
Statement stmt = null;
PreparedStatement pstmt = null;
PreparedStatement pstmt2 = null;
ResultSet rs = null;

String TotalDetailRecords = "";
String TotalData = "";
String TotalAmount = "";
String JumlahBaris = "";
String TanggalTransaksi = "";
String TotalNominal = "";

String TotalDetailRecords_bni = "";
String TotalData_bni = "";
String TotalAmount_bni = "";
String JumlahBaris_bni = "";
String TanggalTransaksi_bni = "";
String TotalNominal_bni = "";

Boolean existt = false;

try{
	//untuk keperluan save as csv Mandiri
	String DATE_FORMAT_NOW = "ddMMyyyy_HHmmss";
	String DATE_FORMAT_NOW2 = "yyyyMMdd";
	String DATE_FORMAT_NOW3 = "yyyyMMddHHmmss";
	String DATE_FORMAT_NOW4 = "ddMMyyyy";
	String DATE_FORMAT_NOW5 = "dd-MM-yyyy";
	
	//untuk keperluan save as csv BNI
	String DATE_FORMAT_NOW_BNI = "dd/MM/yyyy hh:mm:ss a";
	String DATE_FORMAT_NOW2_BNI = "yyyyMMdd";
	
	Calendar cal = Calendar.getInstance();
	
	SimpleDateFormat sdf = new SimpleDateFormat(DATE_FORMAT_NOW);
	String time=sdf.format(cal.getTime());
	SimpleDateFormat sdf2 = new SimpleDateFormat(DATE_FORMAT_NOW2);
	String time2=sdf2.format(cal.getTime());
	SimpleDateFormat sdf3 = new SimpleDateFormat(DATE_FORMAT_NOW3);
	String time3=sdf3.format(cal.getTime());
	SimpleDateFormat sdf4 = new SimpleDateFormat(DATE_FORMAT_NOW4);
	String time4=sdf4.format(cal.getTime());
	SimpleDateFormat sdf5 = new SimpleDateFormat(DATE_FORMAT_NOW5);
	String time5=sdf5.format(cal.getTime());
	
	SimpleDateFormat sdf_bni = new SimpleDateFormat(DATE_FORMAT_NOW_BNI);
	String time_bni=sdf_bni.format(cal.getTime());
	SimpleDateFormat sdf_bni2 = new SimpleDateFormat(DATE_FORMAT_NOW2_BNI);
	String time_bni2=sdf_bni2.format(cal.getTime());
	
	
    con = DbCon.getConnection();
	String [] _month = {"I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI", "XII"};
	String [] _date = null;
	%>
		<table width='90%' border='1' cellspacing='0' cellpadding='0'
			bordercolor='#FFF6EF'>
			<tr>
				<td colspan='10'><div align='right'>
						<font color='#CC6633' size='2'
							face='Verdana, Arial, Helvetica, sans-serif'><strong>.::
								Cashout List Mandiri</strong></font>
					</div></td>
			</tr>

			<tr>
				<td bgcolor='#CC6633'><div align='center'>
						<font color='#FFFFFF' size='1'
							face='Verdana, Arial, Helvetica, sans-serif'><strong>Cashout
								ID</strong></font>
					</div></td>
				<td bgcolor='#CC6633'><div align='center'>
						<font color='#FFFFFF' size='1'
							face='Verdana, Arial, Helvetica, sans-serif'><strong>Merchant
								ID</strong></font>
					</div></td>
				<td bgcolor='#CC6633'><div align='center'>
						<font color='#FFFFFF' size='1'
							face='Verdana, Arial, Helvetica, sans-serif'><strong>Deposit
								Time</strong></font>
					</div></td>
				<td bgcolor='#CC6633'><div align='center'>
						<font color='#FFFFFF' size='1'
							face='Verdana, Arial, Helvetica, sans-serif'><strong>Amount</strong></font>
					</div></td>
				<td bgcolor='#CC6633'><div align='center'>
						<font color='#FFFFFF' size='1'
							face='Verdana, Arial, Helvetica, sans-serif'><strong>Note</strong></font>
					</div></td>
				<td bgcolor='#CC6633'><div align='center'>
						<font color='#FFFFFF' size='1'
							face='Verdana, Arial, Helvetica, sans-serif'><strong>Entry
								Login</strong></font>
					</div></td>
				<td bgcolor='#CC6633'><div align='center'>
						<font color='#FFFFFF' size='1'
							face='Verdana, Arial, Helvetica, sans-serif'><strong>Bank
								Acc No</strong></font>
					</div></td>
				<td bgcolor='#CC6633'><div align='center'>
						<font color='#FFFFFF' size='1'
							face='Verdana, Arial, Helvetica, sans-serif'><strong>Bank
								Acc Holder</strong></font>
					</div></td>
				<td bgcolor='#CC6633'><div align='center'>
						<font color='#FFFFFF' size='1'
							face='Verdana, Arial, Helvetica, sans-serif'><strong>Tsel
								Bank Acc</strong></font>
					</div></td>
				<td bgcolor='#CC6633'><div align='center'>
						<font color='#FFFFFF' size='1'
							face='Verdana, Arial, Helvetica, sans-serif'><strong>Bank
								Name</strong></font>
					</div></td>
			</tr>
			<%
	pstmt = con.prepareStatement("select b.CASHOUT_ID, b.MERCHANT_ID, b.DEPOSIT_TIME, b.AMOUNT, b.NOTE, b.ENTRY_LOGIN, c.BANK_ACC_NO, c.BANK_ACC_HOLDER, c.TSEL_BANK_ACC, c.BANK_NAME from merchant a, merchant_cashout b, merchant_info c where b.MERCHANT_ID=a.MERCHANT_ID AND a.MERCHANT_INFO_ID=c.MERCHANT_INFO_ID AND b.IS_EXECUTED='1' AND b.PRINT_DATE IS NOT NULL AND (b.PRINT_DATE between to_date('"+time5+" 00:00:00','DD-MM-YYYY HH24:MI:SS') AND sysdate) AND b.COMPLETION_DATE IS NULL AND b.RECEIPT_ID IS NOT NULL AND UPPER(c.BANK_NAME) = 'MANDIRI' AND c.BANK_ACC_NO <> '0' ORDER BY DEPOSIT_TIME DESC");
	rs = pstmt.executeQuery();            
    while(rs.next()){
		existt = true;
		%>
			<tr>
				<td><div align='center'>
						<font size='1' face='Verdana, Arial, Helvetica, sans-serif'><%= rs.getString("CASHOUT_ID") %></font>
					</div></td>
				<td><div align='center'>
						<font size='1' face='Verdana, Arial, Helvetica, sans-serif'><%= rs.getString("MERCHANT_ID") %></font>
					</div></td>
				<td><div align='center'>
						<font size='1' face='Verdana, Arial, Helvetica, sans-serif'><%= rs.getString("DEPOSIT_TIME") %></font>
					</div></td>
				<td><div align='center'>
						<font size='1' face='Verdana, Arial, Helvetica, sans-serif'><%= rs.getString("AMOUNT") %></font>
					</div></td>
				<td><div align='center'>
						<font size='1' face='Verdana, Arial, Helvetica, sans-serif'><%= rs.getString("NOTE") %></font>
					</div></td>
				<td><div align='center'>
						<font size='1' face='Verdana, Arial, Helvetica, sans-serif'><%= rs.getString("ENTRY_LOGIN") %></font>
					</div></td>
				<td><div align='center'>
						<font size='1' face='Verdana, Arial, Helvetica, sans-serif'><%= rs.getString("BANK_ACC_NO") %></font>
					</div></td>
				<td><div align='center'>
						<font size='1' face='Verdana, Arial, Helvetica, sans-serif'><%= rs.getString("BANK_ACC_HOLDER") %></font>
					</div></td>
				<td><div align='center'>
						<font size='1' face='Verdana, Arial, Helvetica, sans-serif'><%= rs.getString("TSEL_BANK_ACC") %></font>
					</div></td>
				<td><div align='center'>
						<font size='1' face='Verdana, Arial, Helvetica, sans-serif'><%= rs.getString("BANK_NAME") %></font>
					</div></td>
			</tr>
			<%
	}            
    pstmt.close();rs.close();
    %>
		</table>

		<table width='90%' border='1' cellspacing='0' cellpadding='0'
			bordercolor='#FFF6EF'>
			<tr>
				<td colspan='10'><div align='right'>
						<font color='#CC6633' size='2'
							face='Verdana, Arial, Helvetica, sans-serif'><strong>.::
								Cashout List BNI</strong></font>
					</div></td>
			</tr>

			<tr>
				<td bgcolor='#CC6633'><div align='center'>
						<font color='#FFFFFF' size='1'
							face='Verdana, Arial, Helvetica, sans-serif'><strong>Cashout
								ID</strong></font>
					</div></td>
				<td bgcolor='#CC6633'><div align='center'>
						<font color='#FFFFFF' size='1'
							face='Verdana, Arial, Helvetica, sans-serif'><strong>Merchant
								ID</strong></font>
					</div></td>
				<td bgcolor='#CC6633'><div align='center'>
						<font color='#FFFFFF' size='1'
							face='Verdana, Arial, Helvetica, sans-serif'><strong>Deposit
								Time</strong></font>
					</div></td>
				<td bgcolor='#CC6633'><div align='center'>
						<font color='#FFFFFF' size='1'
							face='Verdana, Arial, Helvetica, sans-serif'><strong>Amount</strong></font>
					</div></td>
				<td bgcolor='#CC6633'><div align='center'>
						<font color='#FFFFFF' size='1'
							face='Verdana, Arial, Helvetica, sans-serif'><strong>Note</strong></font>
					</div></td>
				<td bgcolor='#CC6633'><div align='center'>
						<font color='#FFFFFF' size='1'
							face='Verdana, Arial, Helvetica, sans-serif'><strong>Entry
								Login</strong></font>
					</div></td>
				<td bgcolor='#CC6633'><div align='center'>
						<font color='#FFFFFF' size='1'
							face='Verdana, Arial, Helvetica, sans-serif'><strong>Bank
								Acc No</strong></font>
					</div></td>
				<td bgcolor='#CC6633'><div align='center'>
						<font color='#FFFFFF' size='1'
							face='Verdana, Arial, Helvetica, sans-serif'><strong>Bank
								Acc Holder</strong></font>
					</div></td>
				<td bgcolor='#CC6633'><div align='center'>
						<font color='#FFFFFF' size='1'
							face='Verdana, Arial, Helvetica, sans-serif'><strong>Tsel
								Bank Acc</strong></font>
					</div></td>
				<td bgcolor='#CC6633'><div align='center'>
						<font color='#FFFFFF' size='1'
							face='Verdana, Arial, Helvetica, sans-serif'><strong>Bank
								Name</strong></font>
					</div></td>
			</tr>
			<%
	pstmt = con.prepareStatement("select b.CASHOUT_ID, b.MERCHANT_ID, b.DEPOSIT_TIME, b.AMOUNT, b.NOTE, b.ENTRY_LOGIN, c.BANK_ACC_NO, c.BANK_ACC_HOLDER, c.TSEL_BANK_ACC, c.BANK_NAME from merchant a, merchant_cashout b, merchant_info c where b.MERCHANT_ID=a.MERCHANT_ID AND a.MERCHANT_INFO_ID=c.MERCHANT_INFO_ID AND b.IS_EXECUTED='1' AND b.PRINT_DATE IS NOT NULL AND (b.PRINT_DATE between to_date('"+time5+" 00:00:00','DD-MM-YYYY HH24:MI:SS') AND sysdate) AND b.COMPLETION_DATE IS NULL AND b.RECEIPT_ID IS NOT NULL AND UPPER(c.BANK_NAME) = 'BNI' AND c.BANK_ACC_NO <> '0' ORDER BY DEPOSIT_TIME DESC");
	rs = pstmt.executeQuery();            
    while(rs.next()){
		existt = true;
		%>
			<tr>
				<td><div align='center'>
						<font size='1' face='Verdana, Arial, Helvetica, sans-serif'><%= rs.getString("CASHOUT_ID") %></font>
					</div></td>
				<td><div align='center'>
						<font size='1' face='Verdana, Arial, Helvetica, sans-serif'><%= rs.getString("MERCHANT_ID") %></font>
					</div></td>
				<td><div align='center'>
						<font size='1' face='Verdana, Arial, Helvetica, sans-serif'><%= rs.getString("DEPOSIT_TIME") %></font>
					</div></td>
				<td><div align='center'>
						<font size='1' face='Verdana, Arial, Helvetica, sans-serif'><%= rs.getString("AMOUNT") %></font>
					</div></td>
				<td><div align='center'>
						<font size='1' face='Verdana, Arial, Helvetica, sans-serif'><%= rs.getString("NOTE") %></font>
					</div></td>
				<td><div align='center'>
						<font size='1' face='Verdana, Arial, Helvetica, sans-serif'><%= rs.getString("ENTRY_LOGIN") %></font>
					</div></td>
				<td><div align='center'>
						<font size='1' face='Verdana, Arial, Helvetica, sans-serif'><%= rs.getString("BANK_ACC_NO") %></font>
					</div></td>
				<td><div align='center'>
						<font size='1' face='Verdana, Arial, Helvetica, sans-serif'><%= rs.getString("BANK_ACC_HOLDER") %></font>
					</div></td>
				<td><div align='center'>
						<font size='1' face='Verdana, Arial, Helvetica, sans-serif'><%= rs.getString("TSEL_BANK_ACC") %></font>
					</div></td>
				<td><div align='center'>
						<font size='1' face='Verdana, Arial, Helvetica, sans-serif'><%= rs.getString("BANK_NAME") %></font>
					</div></td>
			</tr>
			<%
	}            
    pstmt.close();rs.close();
    %>
		</table>

		<!-- [Start] Enhancement for Bulk Payment CSV for Others Bank -->
		<!-- Display Payment data Others Bank -->
		<!-- Dev by Titus, Ag-IT -->

		<table width='90%' border='1' cellspacing='0' cellpadding='0'
			bordercolor='#FFF6EF'>
			<tr>
				<td colspan='10'><div align='right'>
						<font color='#CC6633' size='2'
							face='Verdana, Arial, Helvetica, sans-serif'><strong>.::
								Cashout List Others Bank</strong></font>
					</div></td>
			</tr>

			<tr>
				<td bgcolor='#CC6633'><div align='center'>
						<font color='#FFFFFF' size='1'
							face='Verdana, Arial, Helvetica, sans-serif'><strong>Cashout
								ID</strong></font>
					</div></td>
				<td bgcolor='#CC6633'><div align='center'>
						<font color='#FFFFFF' size='1'
							face='Verdana, Arial, Helvetica, sans-serif'><strong>Merchant
								ID</strong></font>
					</div></td>
				<td bgcolor='#CC6633'><div align='center'>
						<font color='#FFFFFF' size='1'
							face='Verdana, Arial, Helvetica, sans-serif'><strong>Deposit
								Time</strong></font>
					</div></td>
				<td bgcolor='#CC6633'><div align='center'>
						<font color='#FFFFFF' size='1'
							face='Verdana, Arial, Helvetica, sans-serif'><strong>Amount</strong></font>
					</div></td>
				<td bgcolor='#CC6633'><div align='center'>
						<font color='#FFFFFF' size='1'
							face='Verdana, Arial, Helvetica, sans-serif'><strong>Note</strong></font>
					</div></td>
				<td bgcolor='#CC6633'><div align='center'>
						<font color='#FFFFFF' size='1'
							face='Verdana, Arial, Helvetica, sans-serif'><strong>Entry
								Login</strong></font>
					</div></td>
				<td bgcolor='#CC6633'><div align='center'>
						<font color='#FFFFFF' size='1'
							face='Verdana, Arial, Helvetica, sans-serif'><strong>Bank
								Acc No</strong></font>
					</div></td>
				<td bgcolor='#CC6633'><div align='center'>
						<font color='#FFFFFF' size='1'
							face='Verdana, Arial, Helvetica, sans-serif'><strong>Bank
								Acc Holder</strong></font>
					</div></td>
				<td bgcolor='#CC6633'><div align='center'>
						<font color='#FFFFFF' size='1'
							face='Verdana, Arial, Helvetica, sans-serif'><strong>Tsel
								Bank Acc</strong></font>
					</div></td>
				<td bgcolor='#CC6633'><div align='center'>
						<font color='#FFFFFF' size='1'
							face='Verdana, Arial, Helvetica, sans-serif'><strong>Bank
								Name</strong></font>
					</div></td>
			</tr>
			<%
	pstmt = con.prepareStatement("select b.CASHOUT_ID, b.MERCHANT_ID, b.DEPOSIT_TIME, b.AMOUNT, b.NOTE, b.ENTRY_LOGIN, c.BANK_ACC_NO, c.BANK_ACC_HOLDER, c.TSEL_BANK_ACC, c.BANK_NAME from merchant a, merchant_cashout b, merchant_info c where b.MERCHANT_ID=a.MERCHANT_ID AND a.MERCHANT_INFO_ID=c.MERCHANT_INFO_ID AND b.IS_EXECUTED='1' AND b.PRINT_DATE IS NOT NULL AND (b.PRINT_DATE between to_date('"+time5+" 00:00:00','DD-MM-YYYY HH24:MI:SS') AND sysdate) AND b.COMPLETION_DATE IS NULL AND b.RECEIPT_ID IS NOT NULL AND UPPER(c.BANK_NAME) NOT IN ('BNI','MANDIRI') AND c.BANK_ACC_NO <> '0' ORDER BY DEPOSIT_TIME DESC");
	rs = pstmt.executeQuery();            
    while(rs.next()){
		existt = true;
		%>
			<tr>
				<td><div align='center'>
						<font size='1' face='Verdana, Arial, Helvetica, sans-serif'><%= rs.getString("CASHOUT_ID") %></font>
					</div></td>
				<td><div align='center'>
						<font size='1' face='Verdana, Arial, Helvetica, sans-serif'><%= rs.getString("MERCHANT_ID") %></font>
					</div></td>
				<td><div align='center'>
						<font size='1' face='Verdana, Arial, Helvetica, sans-serif'><%= rs.getString("DEPOSIT_TIME") %></font>
					</div></td>
				<td><div align='center'>
						<font size='1' face='Verdana, Arial, Helvetica, sans-serif'><%= rs.getString("AMOUNT") %></font>
					</div></td>
				<td><div align='center'>
						<font size='1' face='Verdana, Arial, Helvetica, sans-serif'><%= rs.getString("NOTE") %></font>
					</div></td>
				<td><div align='center'>
						<font size='1' face='Verdana, Arial, Helvetica, sans-serif'><%= rs.getString("ENTRY_LOGIN") %></font>
					</div></td>
				<td><div align='center'>
						<font size='1' face='Verdana, Arial, Helvetica, sans-serif'><%= rs.getString("BANK_ACC_NO") %></font>
					</div></td>
				<td><div align='center'>
						<font size='1' face='Verdana, Arial, Helvetica, sans-serif'><%= rs.getString("BANK_ACC_HOLDER") %></font>
					</div></td>
				<td><div align='center'>
						<font size='1' face='Verdana, Arial, Helvetica, sans-serif'><%= rs.getString("TSEL_BANK_ACC") %></font>
					</div></td>
				<td><div align='center'>
						<font size='1' face='Verdana, Arial, Helvetica, sans-serif'><%= rs.getString("BANK_NAME") %></font>
					</div></td>
			</tr>
			<%
	}            
    pstmt.close();rs.close();
    %>
		</table>

		<!-- [End] Enhancement for Bulk Payment CSV for Others Bank -->

		<%  
    if(comm!=null && comm.equalsIgnoreCase("save") && existt){
        try{
            String pathTes = application.getRealPath("/")+"CSV";
            File fileTes = new File(pathTes);
            if(!fileTes.exists())fileTes.mkdirs();
        }catch(Exception eee){}
        
		// parameter Mandiri
        String fileName = "Mandiri_"+time+".csv";
        String pathFile = application.getRealPath("/")+"CSV/"+fileName;
		String ContentHeaderMarker = "P";
        String DebitAccountNumber = "";

        pstmt = con.prepareStatement("select distinct TSEL_BANK_ACC  from MERCHANT_INFO WHERE UPPER(BANK_NAME) = 'MANDIRI'");
        rs = pstmt.executeQuery();            
        if(rs.next())
			DebitAccountNumber = rs.getString("TSEL_BANK_ACC");           
        pstmt.close();rs.close();

        String TransactionInstructionDate = time2;
        
        pstmt = con.prepareStatement("select count(*) as jml from merchant a, merchant_cashout b, merchant_info c where b.MERCHANT_ID=a.MERCHANT_ID AND a.MERCHANT_INFO_ID=c.MERCHANT_INFO_ID AND b.IS_EXECUTED='1' AND b.PRINT_DATE IS NOT NULL AND (b.PRINT_DATE between to_date('"+time5+" 00:00:00','DD-MM-YYYY HH24:MI:SS') AND sysdate) AND b.COMPLETION_DATE IS NULL AND b.RECEIPT_ID IS NOT NULL AND UPPER(c.BANK_NAME) = 'MANDIRI' AND c.BANK_ACC_NO <> '0' ");
        rs = pstmt.executeQuery();            
        if(rs.next())
            TotalDetailRecords = String.valueOf(rs.getInt("jml"));           
        pstmt.close();rs.close();
        
		//============================
		if(!TotalDetailRecords.equals("0")){
			pstmt = con.prepareStatement("select SUM(b.AMOUNT) AS TOTALAMOUNT from merchant a, merchant_cashout b, merchant_info c where b.MERCHANT_ID=a.MERCHANT_ID AND a.MERCHANT_INFO_ID=c.MERCHANT_INFO_ID  AND UPPER(c.BANK_NAME) = 'MANDIRI' AND b.PRINT_DATE IS NOT NULL AND (b.PRINT_DATE between to_date('"+time5+" 00:00:00','DD-MM-YYYY HH24:MI:SS') AND sysdate) AND b.COMPLETION_DATE IS NULL AND b.RECEIPT_ID IS NOT NULL AND b.IS_EXECUTED='1' AND c.BANK_ACC_NO <> '0' ");
			rs = pstmt.executeQuery();            
			if(rs.next())
					TotalAmount = String.valueOf(rs.getInt("TOTALAMOUNT"));           
			pstmt.close();rs.close();
		}
		
        // parameter BNI
        String fileName2 = "BNI_"+time+".csv";
        String pathFile2 = application.getRealPath("/")+"CSV/"+fileName2;
		String HeaderMarker = "P";
        String RekDebet = "";
        
		pstmt = con.prepareStatement("select distinct TSEL_BANK_ACC from MERCHANT_INFO WHERE UPPER(BANK_NAME) = 'BNI'");
        rs = pstmt.executeQuery();
        if(rs.next())
            RekDebet = (rs.getString("TSEL_BANK_ACC")).substring(1);           
        pstmt.close();rs.close();
        
        String FileCreationTime = time_bni;
        
        pstmt = con.prepareStatement("select Count(*) as jml from merchant a, merchant_cashout b, merchant_info c where b.MERCHANT_ID=a.MERCHANT_ID AND a.MERCHANT_INFO_ID=c.MERCHANT_INFO_ID AND b.IS_EXECUTED='1' AND b.PRINT_DATE IS NOT NULL  AND (b.PRINT_DATE between to_date('"+time5+" 00:00:00','DD-MM-YYYY HH24:MI:SS') AND sysdate) AND b.COMPLETION_DATE IS NULL AND b.RECEIPT_ID IS NOT NULL AND UPPER(c.BANK_NAME) = 'BNI' AND c.BANK_ACC_NO <> '0' ORDER BY DEPOSIT_TIME DESC");
        rs = pstmt.executeQuery();            
        if(rs.next())
			TotalData = String.valueOf(rs.getInt("jml"));          
        pstmt.close();rs.close();
		
		// BNI =================
        if(!TotalData.equals("0")){
			JumlahBaris = String.valueOf(2+Integer.valueOf(TotalData));
			TanggalTransaksi = time2;

			pstmt = con.prepareStatement("select SUM(b.AMOUNT) AS TOTALAMOUNT from merchant a, merchant_cashout b, merchant_info c where b.MERCHANT_ID=a.MERCHANT_ID AND a.MERCHANT_INFO_ID=c.MERCHANT_INFO_ID  AND UPPER(c.BANK_NAME) = 'BNI' AND b.IS_EXECUTED='1' AND b.PRINT_DATE IS NOT NULL AND (b.PRINT_DATE between to_date('"+time5+" 00:00:00','DD-MM-YYYY HH24:MI:SS') AND sysdate) AND b.COMPLETION_DATE IS NULL AND b.RECEIPT_ID IS NOT NULL AND c.BANK_ACC_NO <> '0' ");
			rs = pstmt.executeQuery();
			if(rs.next())
				TotalNominal = String.valueOf(rs.getInt("TOTALAMOUNT"));
			pstmt.close();rs.close();
        }
        
		// [START] Enhancement CSV Payment file for BNI to Other Bank via Clearing
		// Parameter BNI Other Bank
		// Dev by Titus, Ag-IT
		String TotalDataOthBank = "";
		String JumlahBarisOthBank="";
		String TanggalTransaksiOthBank="";
		String TotalNominalOthBank="";
        String fileNameOthBank = "BNI_LLG_"+time+".csv";
        String pathFileOthBank = application.getRealPath("/")+"CSV/"+fileNameOthBank;
		String HeaderMarkerOthBank = "P";
        String RekDebetOthBank = "";
        
		pstmt = con.prepareStatement("select distinct TSEL_BANK_ACC from MERCHANT_INFO WHERE UPPER(BANK_NAME) NOT IN ('BNI','MANDIRI')");
        rs = pstmt.executeQuery();
        if(rs.next())
        	RekDebetOthBank = "0120883432";//(rs.getString("TSEL_BANK_ACC")).substring(1);           
        pstmt.close();rs.close();
        
        String FileCreationTimeOthBank = time_bni;
        
        pstmt = con.prepareStatement("select Count(*) as jml from merchant a, merchant_cashout b, merchant_info c where b.MERCHANT_ID=a.MERCHANT_ID AND a.MERCHANT_INFO_ID=c.MERCHANT_INFO_ID AND b.IS_EXECUTED='1' AND b.PRINT_DATE IS NOT NULL  AND (b.PRINT_DATE between to_date('"+time5+" 00:00:00','DD-MM-YYYY HH24:MI:SS') AND sysdate) AND b.COMPLETION_DATE IS NULL AND b.RECEIPT_ID IS NOT NULL AND UPPER(c.BANK_NAME) NOT IN ('BNI','MANDIRI') AND c.BANK_ACC_NO <> '0' ORDER BY DEPOSIT_TIME DESC");
        rs = pstmt.executeQuery();            
        if(rs.next())
			TotalDataOthBank = String.valueOf(rs.getInt("jml"));          
        pstmt.close();rs.close();
        
        if(!TotalDataOthBank.equals("0")){
			JumlahBarisOthBank = String.valueOf(2+Integer.valueOf(TotalDataOthBank));
			TanggalTransaksiOthBank = time2;

			pstmt = con.prepareStatement("select SUM(b.AMOUNT) AS TOTALAMOUNT from merchant a, merchant_cashout b, merchant_info c where b.MERCHANT_ID=a.MERCHANT_ID AND a.MERCHANT_INFO_ID=c.MERCHANT_INFO_ID  AND UPPER(c.BANK_NAME) NOT IN ('BNI','MANDIRI') AND b.IS_EXECUTED='1' AND b.PRINT_DATE IS NOT NULL AND (b.PRINT_DATE between to_date('"+time5+" 00:00:00','DD-MM-YYYY HH24:MI:SS') AND sysdate) AND b.COMPLETION_DATE IS NULL AND b.RECEIPT_ID IS NOT NULL AND c.BANK_ACC_NO <> '0' ");
			rs = pstmt.executeQuery();
			if(rs.next())
				TotalNominalOthBank = String.valueOf(rs.getInt("TOTALAMOUNT"));
			pstmt.close();rs.close();
        }
        
		// [END] Enhancement CSV Payment file for BNI to Other Bank via Clearing
		
		// Mandiri ===============
        if(!TotalDetailRecords.equals("0")){		
			// SAVE Mandiri CSV
			String content = "";
			
			pstmt = con.prepareStatement("select to_char(b.PRINT_DATE, 'YYYY') as THN, to_char(b.PRINT_DATE, 'MM') as MNT, b.RECEIPT_ID,b.CASHOUT_ID, b.MERCHANT_ID, b.DEPOSIT_TIME, b.AMOUNT, b.NOTE, b.ENTRY_LOGIN, c.BANK_ACC_NO, c.BANK_ACC_HOLDER, c.TSEL_BANK_ACC, c.BANK_NAME from merchant a, merchant_cashout b, merchant_info c where b.MERCHANT_ID=a.MERCHANT_ID AND a.MERCHANT_INFO_ID=c.MERCHANT_INFO_ID AND b.IS_EXECUTED='1' AND b.PRINT_DATE IS NOT NULL AND (b.PRINT_DATE between to_date('"+time5+" 00:00:00','DD-MM-YYYY HH24:MI:SS') AND sysdate) AND b.COMPLETION_DATE IS NULL AND b.RECEIPT_ID IS NOT NULL AND UPPER(c.BANK_NAME) = 'MANDIRI' AND c.BANK_ACC_NO <> '0' ORDER BY DEPOSIT_TIME DESC");
			rs = pstmt.executeQuery();            
			con.setAutoCommit(false);
			while(rs.next()){
				content+= rs.getString("BANK_ACC_NO")+",";
				content+= rs.getString("BANK_ACC_HOLDER")+",";
				content+="Indonesia,,,IDR,";
				content+= rs.getString("AMOUNT")+",";
				// naruh remark disini, maksimum karakter 20 karakter
				// check for daily settlement format
				// tambah receipt_id no perintah bayar
				content+= _month[rs.getInt("MNT")-1]+"/"+rs.getString("THN")+",";
				outPUT+=(rs.getString("CASHOUT_ID")+"|");
				if(rs.getString("NOTE").equals("Daily Settlement"))
					content+=StringUtils.left(("C"+rs.getString("CASHOUT_ID")+" P"+rs.getString("RECEIPT_ID") +" " + "" + time4),19)+ ",";
				else
					content+=StringUtils.left(("C"+rs.getString("CASHOUT_ID")+" P"+rs.getString("RECEIPT_ID") +" " +(((rs.getString("NOTE")).length()<13 )? rs.getString("NOTE") : (rs.getString("NOTE")).substring(0,13))),19)+",";
				content+="IBU,,,";
				content+=",,,,Y";
				content+=",nuke_kusumayanti@telkomsel.co.id,,,,,,,,,,,,,,,,,,,,,,,extended detail will be sent\n";
				
				//update is_executed=3
				pstmt2 = con.prepareStatement("UPDATE merchant_cashout SET is_executed = '3' WHERE cashout_id = '"+rs.getString("CASHOUT_ID")+"'");
				pstmt2.executeUpdate();
				pstmt2.close();
			}            
			pstmt.close();rs.close();		

			//menulis ke file menggunakan FileWriter (MASIH MANDIRI)
			try{
				File f = new File(pathFile);
				if(!f.exists()){
					f.createNewFile();
					out.println("<a href='file_download.jsp?pathFile="+pathFile+"&fileName="+fileName+"'>"+fileName+"</a> <br />");
					}else{
					out.println("Error, file is exist <br />");
				}
				
				// Create file
				BufferedWriter output = new BufferedWriter(new FileWriter(pathFile));
				output.write(ContentHeaderMarker+","+TransactionInstructionDate+","+DebitAccountNumber+","+TotalDetailRecords+","+TotalAmount+"\n");
				
				output.write(content);
				// Close the output stream
				output.close();
				//out.println("File Mandiri has been written. To save file, click right at it and Save Target As. <br />");
				con.commit();
				outPUT+="Mandiri file written,"+pathFile+","+fileName+"|";
			}catch (Exception e){//Catch exception if any
				out.println("Error: " + e.getMessage()+"<br />");
				con.rollback();
			}
			finally{
				con.setAutoCommit(true);
			}
		}

		// BNI ==============
		if(!TotalData.equals("0")){			
			
			// SAVE BNI CSV
			String content2 = "";

			pstmt = con.prepareStatement("select b.CASHOUT_ID, b.RECEIPT_ID, b.MERCHANT_ID, b.DEPOSIT_TIME, b.AMOUNT, b.NOTE, b.ENTRY_LOGIN, c.BANK_ACC_NO, c.BANK_ACC_HOLDER, c.TSEL_BANK_ACC, c.BANK_NAME from merchant a, merchant_cashout b, merchant_info c where b.MERCHANT_ID=a.MERCHANT_ID AND a.MERCHANT_INFO_ID=c.MERCHANT_INFO_ID AND b.IS_EXECUTED='1' AND b.PRINT_DATE IS NOT NULL AND (b.PRINT_DATE between to_date('"+time5+" 00:00:00','DD-MM-YYYY HH24:MI:SS') AND sysdate) AND b.COMPLETION_DATE IS NULL AND b.RECEIPT_ID IS NOT NULL AND UPPER(c.BANK_NAME) = 'BNI' AND c.BANK_ACC_NO <> '0' ORDER BY DEPOSIT_TIME DESC");
			rs = pstmt.executeQuery();
			
			con.setAutoCommit(false);

			while(rs.next()){
				content2+= rs.getString("BANK_ACC_NO")+",";
				content2+= rs.getString("BANK_ACC_HOLDER")+",";
				content2+= rs.getString("AMOUNT")+",";
				
				//Disini naruh remarknya, ada 3 remark dengan masing2 remark maximum 33 karakter
				if(rs.getString("NOTE").equals("Daily Settlement"))
					content2+= StringUtils.left(("C"+rs.getString("CASHOUT_ID") +" P"+ rs.getString("RECEIPT_ID") + " " + "DS_" + time4),33) + ",";
				else
					content2+= StringUtils.left(("C"+rs.getString("CASHOUT_ID") +" P"+ rs.getString("RECEIPT_ID") + " " + rs.getString("NOTE")),33) + ",";
				
				outPUT+=(rs.getString("CASHOUT_ID")+"|");				
				content2+=",,,,,,,,,,,,N,,,N\n";
				
				//update is_executed = 3
				pstmt2 = con.prepareStatement("UPDATE merchant_cashout SET is_executed = '3' WHERE cashout_id = '"+rs.getString("CASHOUT_ID")+"'");
				pstmt2.executeUpdate();
				pstmt2.close();
				
			}
			pstmt.close();rs.close();

			//menulis ke file menggunakan FileWriter (SUDAH BNI)
			try{
				// Create file

				File f2 = new File(pathFile2);
				if(!f2.exists()){
					f2.createNewFile();
					out.println("<a href='file_download.jsp?pathFile="+pathFile2+"&fileName="+fileName2+"'>"+fileName2+"</a> <br />");
				}else{
					out.println("Error, file is exist <br />");
				}
				
				BufferedWriter output2 = new BufferedWriter(new FileWriter(pathFile2));
				output2.write(FileCreationTime+","+JumlahBaris+",,,,,,,,,,,,,,,,,,\n"+HeaderMarker+","+TanggalTransaksi+","+RekDebet+","+TotalData+","+TotalNominal+",,,,,,,,,,,,,,,\n");
				output2.write(content2);
				// Close the output stream
				output2.close();
				//out.println("File BNI has been written. To save file, click right at it and Save Target As. <br />");
				con.commit();
				outPUT+="BNI file written,"+pathFile+","+fileName+"|";
			}catch (Exception e){
				out.println("Error: " + e.getMessage()+"<br />");
				con.rollback();
			}
			finally{
				con.setAutoCommit(true);
			}
		}
		
		// [START] Enhancement CSV Payment file for BNI to Other Bank via Clearing
		// BNI Other Bank save to CSV
		// Dev by Titus, Ag-IT
		
		if(!TotalDataOthBank.equals("0")){			
			
			// SAVE BNI OTH CSV
			String contentOthBank = "";
			String bankName = "";
			String kodeBank = "";
			
			pstmt = con.prepareStatement("select b.CASHOUT_ID, b.RECEIPT_ID, b.MERCHANT_ID, b.DEPOSIT_TIME, b.AMOUNT, b.NOTE, b.ENTRY_LOGIN, c.BANK_ACC_NO, c.BANK_ACC_HOLDER, c.TSEL_BANK_ACC, c.BANK_NAME from merchant a, merchant_cashout b, merchant_info c where b.MERCHANT_ID=a.MERCHANT_ID AND a.MERCHANT_INFO_ID=c.MERCHANT_INFO_ID AND b.IS_EXECUTED='1' AND b.PRINT_DATE IS NOT NULL AND (b.PRINT_DATE between to_date('"+time5+" 00:00:00','DD-MM-YYYY HH24:MI:SS') AND sysdate) AND b.COMPLETION_DATE IS NULL AND b.RECEIPT_ID IS NOT NULL AND UPPER(c.BANK_NAME) NOT IN ('BNI','MANDIRI') AND c.BANK_ACC_NO <> '0' ORDER BY DEPOSIT_TIME DESC");
			rs = pstmt.executeQuery();
			
			con.setAutoCommit(false);

			while(rs.next()){
				bankName = rs.getString("BANK_NAME");
				try{
					//kodeBank = mapBank.get(rs.getString("BANK_NAME")).toString();
					kodeBank = getKodeBank(rs.getString("BANK_NAME"));
				}catch(Exception ee){
					ee.printStackTrace();
				}
				contentOthBank+= rs.getString("BANK_ACC_NO")+",";
				contentOthBank+= rs.getString("BANK_ACC_HOLDER")+",";
				contentOthBank+= rs.getString("AMOUNT")+",";
				
				//Disini naruh remarknya, ada 3 remark dengan masing2 remark maximum 33 karakter
				if(rs.getString("NOTE").equals("Daily Settlement"))
					contentOthBank+= StringUtils.left(("C"+rs.getString("CASHOUT_ID") +" P"+ rs.getString("RECEIPT_ID") + " " + "DS_" + time4),33) + ",";
				else
					contentOthBank+= StringUtils.left(("C"+rs.getString("CASHOUT_ID") +" P"+ rs.getString("RECEIPT_ID") + " " + rs.getString("NOTE")),33) + ",";
				
				outPUT+=(rs.getString("CASHOUT_ID")+"|");				
				contentOthBank+=",,"+kodeBank+","+bankName+",,,,,,,,,N,,,N\n";
				
				//update is_executed = 3
				pstmt2 = con.prepareStatement("UPDATE merchant_cashout SET is_executed = '3' WHERE cashout_id = '"+rs.getString("CASHOUT_ID")+"'");
				pstmt2.executeUpdate();
				pstmt2.close();
				
			}
			pstmt.close();rs.close();

			//menulis ke file menggunakan FileWriter (SUDAH BNI OTHER BANK)
			try{
				// Create file

				File f2 = new File(pathFileOthBank);
				if(!f2.exists()){
					f2.createNewFile();
					out.println("<a href='file_download.jsp?pathFile="+pathFileOthBank+"&fileName="+fileNameOthBank+"'>"+fileNameOthBank+"</a> <br />");
				}else{
					out.println("Error, file is exist <br />");
				}
				
				BufferedWriter output2 = new BufferedWriter(new FileWriter(pathFileOthBank));
				output2.write(FileCreationTime+","+JumlahBarisOthBank+",,,,,,,,,,,,,,,,,,\n"+HeaderMarkerOthBank+","+TanggalTransaksiOthBank+","+RekDebetOthBank+","+TotalDataOthBank+","+TotalNominalOthBank+",,,,,,,,,,,,,,,\n");
				output2.write(contentOthBank);
				// Close the output stream
				output2.close();
				//out.println("File BNI has been written. To save file, click right at it and Save Target As. <br />");
				con.commit();
				outPUT+="BNI Other Bank file written,"+pathFileOthBank+","+fileNameOthBank+"|";
			}catch (Exception e){
				out.println("Error: " + e.getMessage()+"<br />");
				con.rollback();
			}
			finally{
				con.setAutoCommit(true);
			}
		}
		
		// [END] Enhancement CSV Payment file for BNI to Other Bank via Clearing
	}
}
catch(Exception e){
	e.printStackTrace(System.out);
	out.println("<br/ > <b> Database error, automation failed, please proceed with manual process.</b>");
	//System.out.println("<br/ > <b> Database error, automation failed, please proceed with manual process.</b>");
	
	try{con.rollback();} catch(Exception e2){}
	outPUT+=("Exception occured,error:"+e.getMessage());
}
finally{
	try{
		if(con!=null) con.close();
		if(rs!=null) rs.close();
		if(stmt!=null) stmt.close();
		if(pstmt!=null) pstmt.close();
	}
	catch(Exception e){}
	//=====================================================================//
	if (!outPUT.equals(""))
		System.out.println("["+timeNOW+"]bulk_payment_csv.jsp|"+outPUT);
	//=====================================================================//
}
if(existt){

%>

		<form action="bulk_payment_csv.jsp">
			Save as CSV file <input type="submit" value="Save" /> <input
				type="hidden" name="comm" value="save">
		</form>

		<%
}
%>
<%!
public String getKodeBank(String bankName){
	String kode = "";
	if ("BNI Syariah".equalsIgnoreCase(bankName)) kode="0090010";
	if ("Artha Graha Internasional".equalsIgnoreCase(bankName)) kode="0370028";
	if ("Bank Aceh".equalsIgnoreCase(bankName)) kode="1160017";
	if ("BANK AGRIS".equalsIgnoreCase(bankName)) kode="9450305";
	if ("BANK ANDA".equalsIgnoreCase(bankName)) kode="088";
	if ("BANK ANZ".equalsIgnoreCase(bankName)) kode="0610306";
	if ("Bank Artos Indonesia".equalsIgnoreCase(bankName)) kode="5420012";
	if ("BANK BCA SYARIAH".equalsIgnoreCase(bankName)) kode="5360017";
	if ("Bank Bengkulu".equalsIgnoreCase(bankName)) kode="1330012";
	if ("Bank BJB".equalsIgnoreCase(bankName)) kode="4250018";
	if ("Bank BPD DIY".equalsIgnoreCase(bankName)) kode="1120015";
	if ("Bank BPD Kaltim".equalsIgnoreCase(bankName)) kode="1220012";
	if ("Bank BPD Sulteng".equalsIgnoreCase(bankName)) kode="1350018";
	if ("Bank BRI Agro".equalsIgnoreCase(bankName)) kode="4940014";
	if ("Bank BTN".equalsIgnoreCase(bankName)) kode="2000150";
	if ("Bank BTPN".equalsIgnoreCase(bankName)) kode="2130017";
	if ("Bank Bukopin".equalsIgnoreCase(bankName)) kode="4410010";
	if ("BANK BUMI ARTA".equalsIgnoreCase(bankName)) kode="0760010";
	if ("Bank Capital".equalsIgnoreCase(bankName)) kode="0540308";
	if ("BANK CENTRAL ASIA".equalsIgnoreCase(bankName)) kode="0140397";
	if ("BANK CHINATRUST".equalsIgnoreCase(bankName)) kode="9490307";
	if ("Bank Commonwealth".equalsIgnoreCase(bankName)) kode="9500307";
	if ("Bank Danamon".equalsIgnoreCase(bankName)) kode="0110042";
	if ("Bank DKI".equalsIgnoreCase(bankName)) kode="1110012";
	if ("Bank Ekonomi Raharja".equalsIgnoreCase(bankName)) kode="0870010";
	if ("Bank Ganesha".equalsIgnoreCase(bankName)) kode="1610017";
	if ("Bank ICB Bumiputera".equalsIgnoreCase(bankName)) kode="4850010";
	if ("Bank Ina Perdana".equalsIgnoreCase(bankName)) kode="5130014";
	if ("Bank Index Selindo".equalsIgnoreCase(bankName)) kode="5550018";
	if ("Bank Jabar Banten Syariah".equalsIgnoreCase(bankName)) kode="4250018";
	if ("Bank Jambi".equalsIgnoreCase(bankName)) kode="1150014";
	if ("BANK JASA JAKARTA".equalsIgnoreCase(bankName)) kode="4720014";
	if ("Bank Jateng".equalsIgnoreCase(bankName)) kode="1130348";
	if ("Bank Jatim".equalsIgnoreCase(bankName)) kode="1140011";
	if ("Bank Kalbar".equalsIgnoreCase(bankName)) kode="1230015";
	if ("Bank Kalsel".equalsIgnoreCase(bankName)) kode="1220012";
	if ("Bank Kalteng".equalsIgnoreCase(bankName)) kode="1250011";
	if ("Bank Kesejahteraan Ekonomi".equalsIgnoreCase(bankName)) kode="5350014";
	if ("Bank Lampung".equalsIgnoreCase(bankName)) kode="1210051";
	if ("Bank Maluku".equalsIgnoreCase(bankName)) kode="1310016";
	if ("BANK MASPION".equalsIgnoreCase(bankName)) kode="1570021";
	if ("Bank Mayapada Internasional".equalsIgnoreCase(bankName)) kode="0970017";
	if ("Bank Mayora".equalsIgnoreCase(bankName)) kode="5530012";
	if ("Bank Mega".equalsIgnoreCase(bankName)) kode="4260121";
	if ("Bank Mega Syariah".equalsIgnoreCase(bankName)) kode="5060016";
	if ("Bank Mestika Dharma".equalsIgnoreCase(bankName)) kode="1510049";
	if ("Bank Muamalat".equalsIgnoreCase(bankName)) kode="1470011";
	if ("Bank Muamalat Indonesia Syariah".equalsIgnoreCase(bankName)) kode="1470011";
	if ("BANK MUTIARA".equalsIgnoreCase(bankName)) kode="0950011";
	if ("Bank Nagari".equalsIgnoreCase(bankName)) kode="1180259";
	if ("Bank NTB".equalsIgnoreCase(bankName)) kode="1280010";
	if ("Bank NTT".equalsIgnoreCase(bankName)) kode="1300013";
	if ("Bank Nusantara Parahyangan".equalsIgnoreCase(bankName)) kode="1450015";
	if ("Bank OCBC NISP".equalsIgnoreCase(bankName)) kode="0280024";
	if ("Bank of China".equalsIgnoreCase(bankName)) kode="0690300";
	if ("Bank of India Indonesia".equalsIgnoreCase(bankName)) kode="146";
	if ("Bank Papua".equalsIgnoreCase(bankName)) kode="1320019";
	if ("BANK PUNDI INDONESIA".equalsIgnoreCase(bankName)) kode="5580017";
	if ("Bank QNB Kesawan".equalsIgnoreCase(bankName)) kode="1670015";
	if ("BANK RABOBANK".equalsIgnoreCase(bankName)) kode="0890016";
	if ("BANK RAKYAT INDONESIA".equalsIgnoreCase(bankName)) kode="0020307";
	if ("BANK RIAU".equalsIgnoreCase(bankName)) kode="1190016";
	if ("BANK ROYAL INDONESIA".equalsIgnoreCase(bankName)) kode="5010011";
	if ("BANK SAHABAT SAMPOERNA".equalsIgnoreCase(bankName)) kode="523";
	if ("Bank Saudara".equalsIgnoreCase(bankName)) kode="212";
	if ("BANK SBI INDONESIA".equalsIgnoreCase(bankName)) kode="4980016";
	if ("Bank Sinarmas".equalsIgnoreCase(bankName)) kode="1530016";
	if ("Bank Sulselbar".equalsIgnoreCase(bankName)) kode="126";
	if ("Bank Sultra".equalsIgnoreCase(bankName)) kode="1350018";
	if ("Bank Sulut".equalsIgnoreCase(bankName)) kode="1270017";
	if ("Bank Sumsel Babel".equalsIgnoreCase(bankName)) kode="1200142";
	if ("Bank Sumut".equalsIgnoreCase(bankName)) kode="1170010";
	if ("Bank Syariah Mandiri".equalsIgnoreCase(bankName)) kode="4510017";
	if ("BANK UOB INDONESIA".equalsIgnoreCase(bankName)) kode="0230016";
	if ("BANK VICTORIA".equalsIgnoreCase(bankName)) kode="5660018";
	if ("BANK WINDU KENCANA".equalsIgnoreCase(bankName)) kode="0360300";
	if ("Bank Woori Indonesia ".equalsIgnoreCase(bankName)) kode="0680307";
	if ("BII Maybank".equalsIgnoreCase(bankName)) kode="0160131";
	if ("BPD Bali".equalsIgnoreCase(bankName)) kode="1290013";
	if ("BPR Eka Bumi Artha".equalsIgnoreCase(bankName)) kode="076";
	if ("BPR Karyajatnika Sadaya".equalsIgnoreCase(bankName)) kode="668";
	if ("BRI Syariah".equalsIgnoreCase(bankName)) kode="4220051";
	if ("CIMB Niaga".equalsIgnoreCase(bankName)) kode="0220026";
	if ("Citibank".equalsIgnoreCase(bankName)) kode="0310305";
	if ("DBS INDONESIA".equalsIgnoreCase(bankName)) kode="0460307";
	if ("Hana Bank".equalsIgnoreCase(bankName)) kode="4840017";
	if ("Harda".equalsIgnoreCase(bankName)) kode="5670011";
	if ("HSBC".equalsIgnoreCase(bankName)) kode="0410302";
	if ("Nobu Bank".equalsIgnoreCase(bankName)) kode="5030017";
	if ("Panin Bank".equalsIgnoreCase(bankName)) kode="019";
	if ("Permata Bank".equalsIgnoreCase(bankName)) kode="0130475";
	if ("Standard Chartered Bank Indonesia".equalsIgnoreCase(bankName)) kode="0500306";

	return kode;
}
%>
	</stripes:layout-component>
</stripes:layout-render>
