<%@ include file="/web-starter/taglibs.jsp" %>
<%@ page import="java.sql.*"%>
<%@page import="com.telkomsel.itvas.webstarter.WebStarterProperties"%>
<jsp:useBean id="DbCon" scope="page" class="tsel_tunai.DbCon"></jsp:useBean>
<jsp:useBean id="Tx" scope="page" class="tsel_tunai.UssdTx"></jsp:useBean>
<%@page import="com.telkomsel.itvas.webstarter.User"%>
<stripes:layout-render name="/web-starter/layout/standard.jsp" title="Edit Account">
	<stripes:layout-component name="contents">
		<link rel="stylesheet" href="my.css" type="text/css">

<%
String msisdn = (String)session.getValue("msisdn");
String cust_info_id = (String)session.getValue("cust_info_id");
String acc_no = (String)session.getValue("acc_no");
String cur_status = (String)session.getValue("cur_status");
String name = request.getParameter("name");
String address = request.getParameter("address");
String city = request.getParameter("city");
String zipcode = request.getParameter("zipcode");
String ktpno = request.getParameter("ktpno");
String phonenum = request.getParameter("phonenum");
String mother = request.getParameter("mother");
String status = request.getParameter("status");
String confirm = request.getParameter("confirm");
String s_amount = request.getParameter("amount");
String s_acc_balance = request.getParameter("acc_balance");
String tsel_account = WebStarterProperties.getInstance().getProperty("merchant.tsel.acc");

Connection con = null;
PreparedStatement ps = null;
ResultSet rs = null;
String sql = "";
String resp = "";

boolean doUpdate = false;
boolean doCharge = false;

int amount = 0;
long acc_balance = 0;
long tsel_balance = 0;

if(s_amount != null && !s_amount.equals(""))
	amount = Integer.parseInt(s_amount);
if(s_acc_balance != null && !s_acc_balance.equals(""))
	acc_balance = Long.parseLong(s_acc_balance);

int ret1 = 0;
int ret2 = 0;
int ret3 = 0;
int ret4 = 0;
int ret5 = 0;
int ret6 = 0;

try
{
	if(confirm == null || confirm.equals(""))
	{
		if(cur_status.equals("0"))
		{
			if(status.equals("0"))
				resp = "Update gagal<br>Status pelanggan block";
			else
			{
				con = DbCon.getConnection();
				
				sql = "select amount from tsel_cust_mon_debt_recap where acc_no = ? and counter >= 3";
				ps = con.prepareStatement(sql);
				ps.clearParameters();
				ps.setString(1, acc_no);
				rs = ps.executeQuery();
				if(rs.next())
					amount = rs.getInt(1);
				ps.close();
				rs.close();
				
				if(amount == 0)
					doUpdate = true;
				else
				{
					sql = "select balance from tsel_cust_account where acc_no = ?";
					ps = con.prepareStatement(sql);
					ps.clearParameters();
					ps.setString(1, acc_no);
					rs = ps.executeQuery();
					if(rs.next())
						acc_balance = rs.getLong(1);
					ps.close();
					rs.close();
					
					if(acc_balance < amount)
					{
						resp = "Update gagal<br>Pelanggan memiliki tunggakan Rp." + amount + "<br>Akun pelanggan tidak mencukupi utk pembayaran tunggakan<br>Mohon lakukan cash-in sebelum reaktivasi<br>Saldo pelanggan Rp." + acc_balance;
					}
					else
					{
%>
		<form action="acc_info4.jsp" method="post">
			Pelanggan memiliki tunggakan sebesar Rp.<%= amount %><br>
			Saldo pelanggan Rp.<%= acc_balance %><br>
			Update info akan menyebabkan akun pelanggan dipotong sebesar tunggakan<br><br>
			<input type="radio" name="confirm" value="1" checked><font size="2">Lanjutkan</font>&nbsp&nbsp
			<input type="radio" name="confirm" value="0"><font size="2">Batal</font><br><br>
			<input type="hidden" name="name" value="<%= name %>">
			<input type="hidden" name="address" value="<%= address %>">
			<input type="hidden" name="city" value="<%= city %>">
			<input type="hidden" name="zipcode" value="<%= zipcode %>">
			<input type="hidden" name="ktpno" value="<%= ktpno %>">
			<input type="hidden" name="phonenum" value="<%= phonenum %>">
			<input type="hidden" name="mother" value="<%= mother %>">
			<input type="hidden" name="status" value="<%= status %>">
			<input type="hidden" name="amount" value="<%= amount %>">
			<input type="hidden" name="acc_balance" value="<%= acc_balance %>">
			<input type="submit" name="Submit" value="   OK   ">
		</form>
<%
					}
				}
			}
		}
		else
			doUpdate = true;
	}
	else
	{
		session.putValue("msisdn", "");
		session.putValue("cust_info_id", "");
		session.putValue("acc_no", "");
		session.putValue("cur_status", "");
		
		if(confirm.equals("0"))
			resp = "Update dibatalkan";
		else if(confirm.equals("1"))
		{
			doUpdate = true;
			doCharge = true;
		}
	}
	
	if(doUpdate)
	{
		if(con == null || con.isClosed())
			con = DbCon.getConnection();
			
		con.setAutoCommit(false);
		
		sql = "update customer_info set name = ?, address = ?, city = ?, zipcode = ?, phone_num = ?, ktp_no = ?, mother = ? where cust_info_id = ?";
		ps = con.prepareStatement(sql);
		ps.clearParameters();
		ps.setString(1, name);
		ps.setString(2, address);
		ps.setString(3, city);
		ps.setString(4, zipcode);
		ps.setString(5, phonenum);
		ps.setString(6, ktpno);
		ps.setString(7, mother);
		ps.setString(8, cust_info_id);
		ret1 = ps.executeUpdate();
		ps.close();
		
		sql = "update tsel_cust_account set status = ?, balance = balance - ? where acc_no = ?";
		ps = con.prepareStatement(sql);
		ps.clearParameters();
		ps.setString(1, status);
		ps.setInt(2, amount);
		ps.setString(3, acc_no);
		ret2 = ps.executeUpdate();
		ps.close();
	}
	
	if(doCharge)
	{
		sql = "update tsel_merchant_account set balance = balance + ? where acc_no = ?";
		ps = con.prepareStatement(sql);
		ps.clearParameters();
		ps.setInt(1, amount);
		ps.setString(2, tsel_account);
		ret3 = ps.executeUpdate();
		ps.close();
		
		sql = "select balance from tsel_merchant_account where acc_no = ?";
		ps = con.prepareStatement(sql);
		ps.clearParameters();
		ps.setString(1, tsel_account);
		rs = ps.executeQuery();
		if(rs.next())
			tsel_balance = rs.getLong(1);
		ps.close();
		rs.close();
		
		sql = "delete from tsel_cust_mon_debt_recap where acc_no = ?";
		ps = con.prepareStatement(sql);
		ps.clearParameters();
		ps.setString(1, acc_no);
		ret4 = ps.executeUpdate();
		ps.close();
		
		String ref_num = Tx.getMerchantTrxid();
		
		sql = "insert into tsel_cust_account_history values(?, '0', ?, '99', ?, 0, ?, sysdate, '', 'fee', ?)";
		ps = con.prepareStatement(sql);
		ps.clearParameters();
		ps.setString(1, ref_num);
		ps.setString(2, acc_no);
		ps.setInt(3, amount);
		ps.setLong(4, (acc_balance - amount));
		ps.setString(5, Tx.getTxtipe(99));
		ret5 = ps.executeUpdate();
		ps.close();
		
		sql = "insert into tsel_merchant_account_history values(?, '0', ?, ?, '99', 0, ?, ?, sysdate, '', 'fee', ?)";
		ps = con.prepareStatement(sql);
		ps.clearParameters();
		ps.setString(1, ref_num);
		ps.setString(2, tsel_account);
		ps.setString(3, msisdn);
		ps.setInt(4, amount);
		ps.setLong(5, tsel_balance);
		ps.setString(6, Tx.getTxtipe(99));
		ret6 = ps.executeUpdate();
		ps.close();
	}
	
	if(doUpdate)
	{
		if(doCharge)
		{
			if(ret1 == 1 && ret2 == 1 && ret3 == 1 && ret4 == 1 && ret5 == 1 && ret6 == 1)
			{
				con.commit();
				resp = "Update berhasil";
			}
			else
			{
				con.rollback();
				resp = "Update gagal";
			}
		}
		else
		{
			if(ret1 == 1 && ret2 == 1)
			{
				con.commit();
				resp = "Update berhasil";
			}
			else
			{
				con.rollback();
				resp = "Update gagal";
			}
		}
	}
	
	if(!resp.equals(""))
	{
%>

		<p class="unnamed1">Result : <%= resp %> </p> 

<%
	}
}
catch(Exception e)
{
	out.println("Data update gagal, harap isi semua field dengan nilai yang valid");
	e.printStackTrace(System.out);
	con.rollback();
}
finally
{
	if(con != null)
	{
		try
		{
			con.close();
			con = null;
		}
		catch(Exception e2)
		{
		}
	}
}
%>

	</stripes:layout-component>
</stripes:layout-render>
