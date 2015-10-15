<%@ page import="java.sql.*"%>
<%@page import="com.telkomsel.itvas.webstarter.User"%>
<%@page import="com.telkomsel.itvas.webstarter.WebStarterProperties"%>
<%@ include file="/web-starter/taglibs.jsp"%>
<jsp:useBean id="DbCon" scope="page" class="tsel_tunai.DbCon"></jsp:useBean>
<%
String ipaddr = request.getRemoteAddr();
String name = request.getParameter("name");
String address = request.getParameter("address");
String city = request.getParameter("city");
String zipcode = request.getParameter("zipcode");
String phonenum = request.getParameter("phonenum");
String msisdn = request.getParameter("msisdn");
String login = request.getParameter("login");
String ktpno = request.getParameter("ktpno");
String npwp = request.getParameter("npwp");
String bank_name = request.getParameter("bank_name");
String bank_acc_no = request.getParameter("bank_acc_no");
String bank_acc_holder = request.getParameter("bank_acc_holder");
String tsel_bank_acc = request.getParameter("tsel_bank_acc");
String minfoid = request.getParameter("minfoid");	

Connection conn = null;
conn = DbCon.getConnection();
User user = (User)session.getValue("user");
String s = null;
PreparedStatement pstmt = null;

if(user != null)
{
	if(name == null || name.equals("") || address == null || address.equals("") || city == null || city.equals("") || zipcode == null || zipcode.equals("") || phonenum == null || phonenum.equals("") || msisdn == null || msisdn.equals("") || login == null || login.equals("") || ktpno == null || ktpno.equals("") || npwp == null || npwp.equals("") || bank_name == null || bank_name.equals("") || bank_acc_no == null || bank_acc_no.equals("") || bank_acc_holder == null || bank_acc_holder.equals("") || tsel_bank_acc == null || tsel_bank_acc.equals(""))
	{
		try
		{
			s = "insert into activity_log (userlogin, access_time, activity, note, IP, Reason) values ('" + user.getUsername() + "', sysdate, 'Edit Account Mechant', 'Failed', '" + ipaddr + "', 'Any Fields Cannot Be Empty')";
			pstmt = conn.prepareStatement(s);
			pstmt.executeUpdate();
			pstmt.close();
		}
		catch(Exception e)
		{
			e.printStackTrace(System.out);
		}
		finally
		{
			try
			{
				conn.close();
			}
			catch(Exception ee)
			{
			}
		}
		response.sendRedirect("edit_merchant.jsp?stat=1&minfoid=" + minfoid);
	}
	else
	{
		try
		{
			//update merchant
			s = "update merchant set login = ?, msisdn = ? where merchant_info_id = ?";
			pstmt = conn.prepareStatement(s);
			pstmt.setString(1, login);
			pstmt.setString(2, msisdn);
			pstmt.setString(3, minfoid);
			pstmt.executeUpdate();
			pstmt.close();
			
			//update merchant info
			s = "update merchant_info set name = ?, address = ?, city = ?, zipcode = ?, phone_num = ?, msisdn = ?, ktp_no = ?, npwp = ?, bank_name = ?, bank_acc_no = ?, bank_acc_holder = ?, tsel_bank_acc = ? where merchant_info_id = ?";
			pstmt = conn.prepareStatement(s);
			pstmt.setString(1, name);
			pstmt.setString(2, address);
			pstmt.setString(3, city);
			pstmt.setString(4, zipcode);
			pstmt.setString(5, phonenum);
			pstmt.setString(6, msisdn);
			pstmt.setString(7, ktpno);
			pstmt.setString(8, npwp);
			pstmt.setString(9, bank_name);
			pstmt.setString(10, bank_acc_no);
			pstmt.setString(11, bank_acc_holder);
			pstmt.setString(12, tsel_bank_acc);
			pstmt.setString(13, minfoid);
			pstmt.executeUpdate();
			pstmt.close();
			
			response.sendRedirect("edit_merchant.jsp?stat=2&minfoid=" + minfoid);				
		}
		catch(Exception e)
		{
			response.sendRedirect("edit_merchant.jsp?stat=3&minfoid=" + minfoid);
		}
		finally
		{
			try
			{
				conn.close();
			}
			catch(Exception ee)
			{
			}
		}
	}
}
else
	response.sendRedirect("admin.html");
%>
