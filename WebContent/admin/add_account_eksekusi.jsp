<%@ page import="java.sql.*,java.lang.String.*,java.util.*,java.text.*,java.util.regex.*, tsel_tunai.*" %>
<%@page import="com.telkomsel.itvas.webstarter.User"%>
<jsp:useBean id="DbCon" scope="page" class="tsel_tunai.DbCon"></jsp:useBean>
<%!public String expDate() {
	Calendar cal = new GregorianCalendar();
	java.util.Date dt = new java.util.Date();
	SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
	cal.setTime(dt);
	//cal.set(cal.DAY_OF_MONTH,cal.getActualMaximum(cal.DAY_OF_MONTH)+1) ;
	cal.set(cal.DAY_OF_MONTH,cal.DAY_OF_MONTH+30) ;
	dt = cal.getTime();
	return sdf.format(dt);
}%>
<%
	String ipaddr = request.getRemoteAddr();
	String username = request.getParameter("username");
	String password = request.getParameter("password");
	String akses = request.getParameter("akses");
	Connection conn = null;
	conn = DbCon.getConnection();
	User user = (User)session.getValue("user"); 
	if (user != null) {
		if (username.equals("") || password.equals("")) {
			//out.println( "<SCRIPT LANGUAGE=javascript> alert('username and password cannot be empty');</SCRIPT>" );
			try {
				String s = "insert into activity_log (userlogin,access_time,activity,note,IP,Reason) values('"+user.getUsername()+"',sysdate,'Add User','Failed','"+ipaddr+"','Username & Password Cannot Be Empty ')";
				PreparedStatement st = conn.prepareStatement(s);
				st.executeUpdate();
				st.close();
			}
			catch(Exception  e){
				e.printStackTrace(System.out);
			} finally{
				try { conn.close(); } catch(Exception ee){}
			}
			response.sendRedirect("add_account.jsp?stat=1");
		} else {
				//cek existing user
				
				try {
					String sql = "select count(*) as ada from admin where username = ? ";
					PreparedStatement pstmt = conn.prepareStatement(sql);
					pstmt.setString(1,username);
					ResultSet rs = pstmt.executeQuery();
					//get the result
					int ada = 0;
					if (rs.next()) {
						ada = rs.getInt("ada");
					}
					//check the existing username
					if (ada > 0) {
						String s = "insert into activity_log (userlogin,access_time,activity,note,IP,Reason) values('"+user.getUsername()+"',sysdate,'Add User','Failed','"+ipaddr+"','Username Has been exist')";
						PreparedStatement st = conn.prepareStatement(s);
						st.executeUpdate();
						st.close();
						response.sendRedirect("add_account.jsp?stat=3");
					} else {
						//check the password length
						if (password.length() < 8) {
							String s = "insert into activity_log (userlogin,access_time,activity,note,IP,Reason) values('"+user.getUsername()+"',sysdate,'Add User','Failed','"+ipaddr+"','Password Length must 8 min.')";
							PreparedStatement st = conn.prepareStatement(s);
							st.executeUpdate();
							st.close();
							response.sendRedirect("add_account.jsp?stat=2");
						} else {
								//kombinasi huruf besar kecil special karakter n angka			
								//for lowe case
								Pattern h_kecil = Pattern.compile("[a-z]+");
								//for upper case
								Pattern h_besar = Pattern.compile("[A-Z]+");
								//for numeric
								Pattern angka = Pattern.compile("\\d+");
								//for special characters
								Pattern s_char = Pattern.compile("[\\! @ # $ % ^ & * ( )  _ + ? < > ( ) } { \\]  \\[  ~ \\-  = \\\\ /  . , \\|]");
								int c_angka = 0;
								int c_h_besar = 0;
								int c_h_kecil = 0;
								int c_spe_char = 0;
								int a = 0;
								
                 				for (int i=0; i<password.length(); i++) {
									a = i+1;
                         			Matcher fit_h_kecil = h_kecil.matcher(password.substring(i,a));
									Matcher fit_h_besar = h_besar.matcher(password.substring(i,a));
									Matcher fit_angka = angka.matcher(password.substring(i,a));
									Matcher fit_char = s_char.matcher(password.substring(i,a));
                         			if (fit_h_kecil.matches()) {
                                 		c_h_kecil = c_h_kecil + 1;;
                         			}
									if (fit_h_besar.matches()) {
                                 		c_h_besar = c_h_besar + 1;;
                         			}
									if (fit_angka.matches()) {
                                 		c_angka = c_angka + 1;;
                         			}
									if (fit_char.matches()) {
                                 		c_spe_char = c_spe_char + 1;;
                         			}
                 				}
         						//
								//out.println("huruf kecil : "+ c_h_kecil +"\n");
								//out.println("huruf besar : "+ c_h_besar  +"\n") ;
								//out.println("huruf angka : "+ c_angka  +"\n");
								//out.println("huruf special character : "+ c_spe_char  +"\n");
							//
								if ((c_h_kecil > 0) && (c_h_besar > 0) && (c_angka > 0) && (c_spe_char > 0)) {
									//out.print("success");
									
									
									String s = "insert into activity_log (userlogin,access_time,activity,note,IP) values('"+user.getUsername()+"',sysdate,'Add User "+username+"','Success','"+ipaddr+"')";
									PreparedStatement st = conn.prepareStatement(s);
									st.executeUpdate();
									st.close();
																	
									String s2 = "insert into admin (username,password,exp_date,login_err,max_login,status,akses) values('"+username+"','"+Util.getMd5Digest(password)+"',to_date('"+expDate()+"','YYYY-MM-DD'),'3','3','ACT','"+akses+"')";
									System.out.println(s2);
									//String s2 = "insert into admin (username,password,to_date(exp_date, 'YYYY-MM-DD'),login_err,max_login,status,akses) values('"+username+"','"+password+"','"+expDate()+"','3','3','ACT','"+akses+"')";
									PreparedStatement st2 = conn.prepareStatement(s2);
									st2.executeUpdate();
									st2.close();

									
									//set d pass history							
									//masukin ke pass_history
									String mskPassHis = "insert into pass_history values('"+username+"','"+Util.getMd5Digest(password)+"','1',sysdate)";
									System.out.println(mskPassHis);
									//String mskPassHis = "insert into pass_history values('"+username+"','"+password+"','1',sysdate)";
									PreparedStatement psMskPassHis = conn.prepareStatement(mskPassHis);
									psMskPassHis.executeUpdate();
									psMskPassHis.close();
									conn.close();
									response.sendRedirect("add_account.jsp?stat=5");
								}
								else {
									String s = "insert into activity_log (userlogin,access_time,activity,note,IP,Reason) values('"+user.getUsername()+"',sysdate,'Add User','Failed','"+ipaddr+"','Password Must include special character and alphanumeric (a-z, A-Z,0-9,* ! @ #.. *)')";
									PreparedStatement st = conn.prepareStatement(s);
									st.executeUpdate();
									st.close();
									conn.close();
									response.sendRedirect("add_account.jsp?stat=4");	
								}
						}
					}
				}
				catch(Exception  e){
					e.printStackTrace(System.out);
				} finally{
					try { conn.close(); } catch(Exception ee){}
				}
		}
	} else {
		response.sendRedirect("admin.html");
	} 
	
%>
