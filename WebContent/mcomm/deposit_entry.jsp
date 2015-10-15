<%@ page import="org.apache.commons.dbutils.*, org.apache.commons.dbutils.handlers.*, java.sql.*,java.lang.String.*,java.util.*,java.text.*,java.util.regex.*" %>
<%@page import="com.telkomsel.itvas.webstarter.User"%>
<jsp:useBean id="DbCon" scope="page" class="tsel_tunai.DbCon"></jsp:useBean>
<%@ include file="/web-starter/taglibs.jsp"%>
<%@ page language = "java" import = "java.io.*, java.util.*, java.text.*, java.sql.*" %>

<stripes:layout-render name="/web-starter/layout/standard.jsp" title="Deposit List">
	<stripes:layout-component name="contents">

<%
User login_user = (User)session.getValue("user");
if(login_user == null) {
	response.sendRedirect("index.jsp");
}

String encLogin = login_user.getUsername();
String encPass = login_user.getPassword();


String 	merchant = "",
				amount = "",
				doc_number = "",
				note = "",
				deposit_id = "", journalid="";

System.out.println("haiya3 : anu" );
	
if (request.getParameter("deposit_id") != null) {
	deposit_id = request.getParameter("deposit_id");
	Connection conn = null;
	try {
		conn = DbCon.getConnection();
		String q = "select * from merchant_deposit where deposit_id=" + deposit_id;
		Statement st = conn.createStatement();
		ResultSet rs = st.executeQuery(q);
		if (rs.next()) {
			merchant = rs.getString("merchant_id");		
			amount = rs.getString("amount");
			doc_number = rs.getString("doc_number");
			deposit_id = rs.getString("deposit_id");
			note = rs.getString("note");
			journalid = rs.getString("journalid");
		}
		
		rs.close();
	} catch (Exception e) {
		response.sendRedirect("index.jsp?msg=Database+error");
	} finally {
		if (conn != null) {
			conn.close();
		}
	}

}
				
					
if (request.getMethod().equals("POST")) {
	merchant = request.getParameter("merchant");	
	amount = request.getParameter("amount");
	doc_number = request.getParameter("doc_number");
	note = request.getParameter("note");
	journalid = request.getParameter("journalid");
			
	boolean b12 = true;
	
	Connection conn = DbCon.getConnection();
	try {
		QueryRunner qr = new QueryRunner();
		String q = null;
		Object res = null;
		if (request.getParameter("deposit_id") == null) {
			q = "select doc_number from MERCHANT_DEPOSIT where doc_number=?";
			res = qr.query(conn, q, new Object[] {doc_number}, new ScalarHandler("doc_number"));
		} else {
			q = "select doc_number from MERCHANT_DEPOSIT where doc_number=? AND not (deposit_id=?)";
			res = qr.query(conn, q, new Object[] {doc_number, request.getParameter("deposit_id")}, new ScalarHandler("doc_number"));
		}
		if (res != null) {
			//b12 = false;
			if (request.getParameter("deposit_id") == null) {
				response.sendRedirect("deposit_entry.jsp?msg=Doc+number+telah+digunakan+sebelumnya");
			} else {
				response.sendRedirect("deposit_entry.jsp?msg=Doc+number+telah+digunakan+sebelumnya&deposit_id=" + request.getParameter("deposit_id"));
			}
		} else {
			int nAmount = 0;
			try {
				nAmount = Integer.parseInt(amount);	
			} catch (Exception e) {
				b12 = false;
				if (request.getParameter("deposit_id") == null) {
					response.sendRedirect("deposit_entry.jsp?msg=Jumlah+deposit+tidak+valid");	
				} else {
					response.sendRedirect("deposit_entry.jsp?msg=Jumlah+deposit+tidak+valid&deposit_id=" + request.getParameter("deposit_id"));
				}				
			}
			if (nAmount <= 0) {
				b12 = false;
				if (request.getParameter("deposit_id") == null) {
					response.sendRedirect("deposit_entry.jsp?msg=Jumlah+deposit+tidak+valid");	
				} else {
					response.sendRedirect("deposit_entry.jsp?msg=Jumlah+deposit+tidak+valid&deposit_id=" + request.getParameter("deposit_id"));
				}
			}
		}
		
		if(b12){
			if (request.getParameter("deposit_id") == null) {
					q = "insert into MERCHANT_DEPOSIT (MERCHANT_ID, AMOUNT, DOC_NUMBER, NOTE, DEPOSIT_TIME, IS_EXECUTED, ENTRY_LOGIN, JOURNALID) VALUES (?,?,?,?,sysdate,'0',?,?)";
					qr.update(conn, q, new Object[] {merchant, amount, doc_number, note, login_user.getUsername(), journalid});	
			} else {
				deposit_id = request.getParameter("deposit_id");
				System.out.println("haiya3 : " + deposit_id);
				q = "update MERCHANT_DEPOSIT set MERCHANT_ID=?, AMOUNT=?, DOC_NUMBER=?, NOTE=?, DEPOSIT_TIME=sysdate, ENTRY_LOGIN=?, JOURNALID=? WHERE deposit_id=?";
				qr.update(conn, q, new Object[] {merchant, amount, doc_number, note, login_user, journalid, deposit_id});
			}
			
			q = "INSERT INTO ACTIVITY_LOG (USERLOGIN, ACCESS_TIME, ACTIVITY, NOTE, IP, REASON) values (?, sysdate, ?, ?, ?, ?)";
			qr.update(conn, q, new Object[] {login_user.getUsername(), "Modify Deposit", merchant+ "|" + amount+ "|" + doc_number, request.getRemoteAddr(), "-"});
			
			response.sendRedirect("deposit_entry.jsp?msg=Deposit+successfully+added");
		}
	} catch (Exception e) {
		e.printStackTrace();
		response.sendRedirect("deposit_entry.jsp?msg=Ada+kesalahan+pada+data+yang+anda+masukkan+mohon+periksa+kembali");
	} finally {
		DbUtils.close(conn);
	}
}


%>

<script language="JavaScript">
<!--
function checkDelete()
{
	with(document)
	{
		var checkStatus = confirm('Do you really want to delete this member?');
		if (checkStatus)
		{
			checkStatus = true;
		}
		return checkStatus;
	}
}
//-->

<!--
function calendar(output)
{
	newwin = window.open('cal.jsp','','top=150,left=150,width=145,height=130,resizable=no');
	if (!newwin.opener) newwin.opener = self;
}

function calendar2(output)
{
	newwin = window.open('cal2.jsp','','top=150,left=150,width=145,height=130,resizable=no');
	if (!newwin.opener) newwin.opener = self;
}
//-->
</script>

<%
	String login = request.getParameter("login");
	String dari = request.getParameter("dari");
	String test = request.getParameter("test");
	//out.print(dari);
	String ampe = request.getParameter("ampe");
	User user = (User)session.getValue("user");
	//String msisdn = request.getParameter("msisdn");
	//String variabel = request.getParameter("variabel");
	//out.print(variabel);
%>
 
<link rel="stylesheet" href="my.css" type="text/css">
<table width="60%" border="0" cellspacing="3" cellpadding="3">
<%
if (request.getParameter("msg") != null) {
	out.println("<center><strong>" + request.getParameter("msg") + "</strong></center>");
}
%>

  <form name="form" method="post" action="deposit_entry.jsp">
    <tr> 
      <td class="unnamed1" width="20%">Merchant</td>
      <td width="80%" class="unnamed1">
<select name='merchant'>
<%
	if (amount.equals(""))amount=request.getParameter("amountx");
	if (doc_number.equals(""))doc_number=request.getParameter("doc_numberx");
	if (note.equals(""))note=request.getParameter("notex");
	
	Connection conn = null;
	try {
		conn = DbCon.getConnection();
		String q = "select a.MERCHANT_ID, b.NAME from MERCHANT a, MERCHANT_INFO b WHERE a.MERCHANT_INFO_ID=b.MERCHANT_INFO_ID and a.STATUS='A' order by b.NAME";
		Statement st = conn.createStatement();
		ResultSet rs = st.executeQuery(q);
		while (rs.next()) {
			if (rs.getString("MERCHANT_ID").equals(merchant)) {
				out.println("<option value='" + merchant +"' selected>" + rs.getString("NAME") + "</option>	");
			} else {
				out.println("<option value='" + rs.getString("MERCHANT_ID") + "'>" + rs.getString("NAME") + "</option>	");
			}
		}
		rs.close();
	} catch (Exception e) {
		e.printStackTrace();
		response.sendRedirect("index.jsp?msg=Database+error");
	} finally {
		if (conn != null) {
			conn.close();
		}
	}
%>
</select>
      </td>
    </tr>
    <tr> 
      <td class="unnamed1" width="20%">Amount</td>
      <td width="80%" class="unnamed1"> 
        <input name="amount" value="<%=(amount!=null)?amount:""%>" type="text" size="20" class="box_text" value="628">
      </td>
    </tr>
    <tr> 
      <td class="unnamed1" width="20%">Doc. Number</td>
      <td width="80%" class="unnamed1"> 
        <input name="doc_number" value="<%=(doc_number!=null)?doc_number:""%>" type="text" size="20" class="box_text" value="628">
      </td>
    </tr>
    <tr> 
      <td class="unnamed1" width="20%">Note</td>
      <td width="80%" class="unnamed1"> 
        <input name="note" value="<%=(note!=null)?note:""%>" type="text" size="20" class="box_text" value="628">
      </td>
    </tr>
    <tr> 
      <td class="unnamed1" width="20%">JournalID</td>
      <td width="80%" class="unnamed1"> 
        <input name="journalid" value="<%=(journalid!=null)?journalid:""%>" type="text" size="20" class="box_text" value="628">
      </td>
    </tr>    
    <tr> 
      <td class="unnamed1" width="20%">&nbsp;</td>
      <td class="unnamed1" width="80%"> 
        <input type="submit" name="Submit" value="   Submit     " class="box_text">
      </td>
    </tr>
<%
if (request.getParameter("deposit_id") != null) {
	out.println("<input type=hidden name=deposit_id value='" + deposit_id + "'>");
}
%>
  </form>
</table>
</td>
	
		</stripes:layout-component>
</stripes:layout-render>
