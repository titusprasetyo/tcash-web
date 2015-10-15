<%@page import="tsel_tunai.Util"%>
<jsp:useBean id="m" scope="request" class="tsel_tunai.Merchant" />
<%
String name = request.getParameter("name");
String address = request.getParameter("address");
String city = request.getParameter("city");
String zipcode = request.getParameter("zipcode");
String phonenum = request.getParameter("phonenum");
String msisdn = request.getParameter("msisdn");
String login = request.getParameter("login");
String ktpno = request.getParameter("ktpno");
String npwp = request.getParameter("npwp");
String key_merchant = "00";
String bank_name = request.getParameter("bank_name");
String bank_acc_no = request.getParameter("bank_acc_no");
String bank_acc_holder = request.getParameter("bank_acc_holder");
String tsel_bank_acc = request.getParameter("tsel_bank_acc");
String merchant_type = request.getParameter("merchant_type");

String Hsl = "Merchant registration fail";

m.setName(name);
m.setAddress(address);
m.setCity(city);
m.setZipcode(zipcode);
m.setPhonenum(phonenum);
m.setMsisdn(msisdn);
m.setLogin(login);
m.setKtpno(ktpno);
m.setNpwp(npwp);
m.setKeyMerchant(key_merchant);
m.setBankName(bank_name);
m.setBankAccNo(bank_acc_no);
m.setBankAccHolder(bank_acc_holder);
m.setTselBankAcc(tsel_bank_acc);
m.setMerchantType(merchant_type);


String [] ret = m.create();
//out.print("result :"+ret[0]+" note:"+ret[1]);
//response.sendRedirect("reg_merchant.jsp?stat=1&suc="+ret[0]+"&msg="+ret[1]);

if(ret[0].equals("1"))
{
	String notif_sms = "Registrasi Merchant " + name + " berhasil. Akses web report di https://202.3.208.133/mcare dg login username: " + login + " & password: " + ret[1] + ". Atau ketik BAL <password> kirim ke 2828 utk Cek Account Merchant Anda";
	Hsl = "Merchant registration success";
	Util.sendNotif(msisdn, notif_sms, "2828");
}
else
	Hsl = "Input data harus lengkap dan valid : " + ret[1];

response.sendRedirect("reg_merchant.jsp?stat=1&suc=" + Hsl);

%>
<%= Hsl %>