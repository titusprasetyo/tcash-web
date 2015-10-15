<%@ page import="tsel_tunai.*, java.sql.*,java.lang.String.*,java.util.*,java.text.*,java.util.regex.*" %>
<%@page import="com.telkomsel.itvas.webstarter.User"%>
<jsp:useBean id="DbCon" scope="page" class="tsel_tunai.DbCon"></jsp:useBean>
<%
	String ipaddr = request.getRemoteAddr();
	String username = request.getParameter("username");
	String log = request.getParameter("log");
	String password = request.getParameter("password");
	String hashPassword = Util.getMd5Digest(password);
	String akses = request.getParameter("akses");
	String [] checkbox = request.getParameterValues("checkbox");
	String s2 = null;
	String status = request.getParameter("status");
	//if (checkbox != null) 
	//out.print(checkbox[0]);
	//else
	//out.print("0");
	Connection conn = null;
	conn = DbCon.getConnection();
	User user = (User)session.getValue("user"); 
	if (user != null) {
		if (username.equals("") || password.equals("")) {
			//out.println( "<SCRIPT LANGUAGE=javascript> alert('username and password cannot be empty');</SCRIPT>" );
			try {
				String s = "insert into activity_log (userlogin,access_time,activity,note,IP,Reason) values('"+user.getUsername()+"',sysdate,'Edit User','Failed','"+ipaddr+"','Username & Password Cannot Be Empty ')";
				PreparedStatement st = conn.prepareStatement(s);
				st.executeUpdate();
				st.close();
			}
			catch(Exception  e){
				e.printStackTrace(System.out);
			} finally{
				try { conn.close(); } catch(Exception ee){}
			}
			response.sendRedirect("edit_account.jsp?stat=1&username="+log);
		} else {
				//cek existing user
				
				try {
					String sql = "select count(*) as ada from admin where username <> ? and username = ?";
					PreparedStatement pstmt = conn.prepareStatement(sql);
					pstmt.setString(1,log);
					pstmt.setString(2,username);
					ResultSet rs = pstmt.executeQuery();
					//get the result
					int ada = 0;
					if (rs.next()) {
						ada = rs.getInt("ada");
					}
					//check the existing username
					if (ada > 0) {
						String s = "insert into activity_log (userlogin,access_time,activity,note,IP,Reason) values('"+user+"',sysdate,'Edit User','Failed','"+ipaddr+"','Username Has been exist')";
						PreparedStatement st = conn.prepareStatement(s);
						st.executeUpdate();
						st.close();
						response.sendRedirect("edit_account.jsp?stat=3&username="+log);
					} else {
						//if (checkbox != null) {
						//} else {							
						//}
						//check the password length
						
						if (password.length() < 8 ) {
							String s = "insert into activity_log (userlogin,access_time,activity,note,IP,Reason) values('"+user+"',sysdate,'Edit User','Failed','"+ipaddr+"','Password Length must 8 min.')";
							PreparedStatement st = conn.prepareStatement(s);
							st.executeUpdate();
							st.close();
							response.sendRedirect("edit_account.jsp?stat=2&username="+log);
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
								
								//update logon_failure
								if (status.equals("ACT")) {
									String UpdateStat = "delete from logon_failure where username = ? ";
									PreparedStatement psUpdateStat = conn.prepareStatement(UpdateStat);
									psUpdateStat.setString(1,log);
									psUpdateStat.executeUpdate();
									psUpdateStat.close();
								}
								
								if (checkbox != null) {
									//cek password history
									int JmlPass = 0;
									String CekPassHiss = "select count(*) as ada from pass_history where username = ? and password = ?";
									//out.println("sql : " + CekPassHiss);
									PreparedStatement psCekPassHis = conn.prepareStatement(CekPassHiss);
									psCekPassHis.setString(1,log);
									psCekPassHis.setString(2,hashPassword);
									ResultSet rsCekPassHiss = psCekPassHis.executeQuery();
									if (rsCekPassHiss.next()) 
										JmlPass = rsCekPassHiss.getInt("ada");
										
									//out.print("Jml : "+JmlPass);
									if (JmlPass > 0) {
										response.sendRedirect("edit_account.jsp?stat=6&username="+log);
									}
									rsCekPassHiss.close();
									psCekPassHis.close();
												 																					
									s2 = "update admin set username = '"+username+"' , password = '"+hashPassword+"' , akses='"+akses+"', status = '"+status+"' where username='"+log+"'";
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
								}
								else {
									s2 = "update admin set username = '"+username+"' , akses='"+akses+"', status = '"+status+"' where username='"+log+"'";
									c_angka = 1;
									c_h_besar = 1;
									c_h_kecil = 1;
									c_spe_char = 1;
								}
         						//
								//out.println("huruf kecil : "+ c_h_kecil +"\n");
								//out.println("huruf besar : "+ c_h_besar  +"\n") ;
								//out.println("huruf angka : "+ c_angka  +"\n");
								//out.println("huruf special character : "+ c_spe_char  +"\n");
							//
								if ((c_h_kecil > 0) && (c_h_besar > 0) && (c_angka > 0) && (c_spe_char > 0)) {
									//out.print("success");
									response.sendRedirect("admin.jsp?username=");
									//out.print("sqlnya : "+ s2);
									//("edit_account.jsp?stat=5&username="+log);
									//insert into activity log
									String s = "insert into activity_log (userlogin,access_time,activity,note,IP) values('"+user+"',sysdate,'Edit User "+log+"','Success','"+ipaddr+"')";
									PreparedStatement st = conn.prepareStatement(s);
									st.executeUpdate();
									st.close();
									//update di table admin				
									PreparedStatement st2 = conn.prepareStatement(s2);
									st2.executeUpdate();
									st2.close();
									//out.println(s2);
									
									//update user d pass_history
									String UpdateUser = "update pass_history set username = ? where username= ?";
									PreparedStatement psUpdateUser = conn.prepareStatement(UpdateUser);
									psUpdateUser.setString(1,username);
									psUpdateUser.setString(2,log);
									psUpdateUser.executeUpdate();
									psUpdateUser.close();
									
									//set urutan password
									int UrutPassHiss = 0;
									String SqlPassHiss = "select count(*) as urut from pass_history where username = ? ";
									PreparedStatement psUrutPassHiss = conn.prepareStatement(SqlPassHiss);
									psUrutPassHiss.setString(1,username);
									ResultSet rsUrutPassHiss = psUrutPassHiss.executeQuery();
									if (rsUrutPassHiss.next()) 
										 UrutPassHiss = rsUrutPassHiss.getInt("urut");
									//out.print("Urutan : " + UrutPassHiss);
									psUrutPassHiss.close();
									rsUrutPassHiss.close();
									//jika jumlah pass his user tsb telah mencapai 12
									if (UrutPassHiss ==  12) {
										//delete urutan pertama pass history
										String delPassHis = "delete from pass_history where username = ? and urutan = 1";
										PreparedStatement psdelPassHis = conn.prepareStatement(delPassHis);
										psdelPassHis.setString(1,username);
										psdelPassHis.executeUpdate();
										psdelPassHis.close();
										
										//update urutan , msg2 mundur satu langkah k belakang
										String UpdateUrutan = "update pass_history set urutan = urutan-1 where username = ? ";
										PreparedStatement psUpdateUrutan = conn.prepareStatement(UpdateUrutan);
										psUpdateUrutan.setString(1,username);
										psUpdateUrutan.executeUpdate();
										psUpdateUrutan.close();
										
										//set urutan jadi 11
										UrutPassHiss = 11;
									}
									
									//tambahkan satu langkah urutan lg
									UrutPassHiss = UrutPassHiss + 1;
									
																		
									//masukin ke pass_history
									String mskPassHis = "insert into pass_history values('"+username+"','"+hashPassword+"','"+UrutPassHiss+"',sysdate)";
									PreparedStatement psMskPassHis = conn.prepareStatement(mskPassHis);
									psMskPassHis.executeUpdate();
									psMskPassHis.close();
									
								}
								else {
									String s = "insert into activity_log (userlogin,access_time,activity,note,IP,Reason) values('"+user+"',sysdate,'Edit User','Failed','"+ipaddr+"','Password Must include special character and alphanumeric (a-z, A-Z,0-9,* ! @ #.. *)')";
									PreparedStatement st = conn.prepareStatement(s);
									st.executeUpdate();
									st.close();
									response.sendRedirect("edit_account.jsp?stat=4&username="+log);	
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
