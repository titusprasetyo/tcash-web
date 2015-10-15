<%@ page import="java.sql.*,java.lang.String.*,java.util.*,java.text.*,java.util.regex.*;" %>
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
	String OldPass = request.getParameter("OldPass");
	String NewPass = request.getParameter("NewPass");
	String ConfPass = request.getParameter("ConfPass");
	String s2 = null;
	//if (checkbox != null) 
	//out.print(checkbox[0]);
	//else
	//out.print("0");
	Connection conn = null;
	conn = DbCon.getConnection();
	// 
	//if (user != null) {
		//session.putValue("user", user);
		if (OldPass.equals("") || NewPass.equals("") ||  ConfPass.equals("")) {
		
			//out.println( "<SCRIPT LANGUAGE=javascript> alert('username and NewPass cannot be empty');</SCRIPT>" );
			try {
				String s = "insert into activity_log (userlogin,access_time,activity,note,IP,Reason) values('"+username+"',now(),'Change Pass User','Failed','"+ipaddr+"','Password Cannot Be Empty ')";
				PreparedStatement st = conn.prepareStatement(s);
				st.executeUpdate();
				st.close();
				
			}
			catch(Exception  e){
				e.printStackTrace(System.out);
			} finally{
				try { conn.close(); } catch(Exception ee){}
			}
			response.sendRedirect("change_pass_admin.jsp?stat=1&username="+username);
		} else {
				//cek Pass n ConfPass is it same or not
				if (ConfPass.equals(NewPass)) {
					//out.println("Pass Sama");
					try {
						String sql = "select count(*) as ada from admin where username = ? and password = password(?)";
						PreparedStatement pstmt = conn.prepareStatement(sql);
						pstmt.setString(1,username);
						pstmt.setString(2,OldPass);
						ResultSet rs = pstmt.executeQuery();
						//out.println(sql +"<br>");
						//get the result
						int ada = 0;
						if (rs.next()) {
							ada = rs.getInt("ada");
						}
						//out.println(ada +"<br>");
						//check the existing username
						if (ada == 0) {
							String s = "insert into activity_log(userlogin,access_time,activity,note,IP,Reason) values('"+username+"',now(),'Change Pass User','Failed','"+ipaddr+"','Old Password Invalid')";
							PreparedStatement st = conn.prepareStatement(s);
							st.executeUpdate();
							st.close();
							response.sendRedirect("change_pass_admin.jsp?stat=3&username="+username);
						} else {
						//check the NewPass length
							if (NewPass.length() < 8 ) {
								String s = "insert into activity_log(userlogin,access_time,activity,note,IP,Reason) values('"+username+"',now(),'Edit User','Failed','"+ipaddr+"','Password Length must 8 min.')";
								PreparedStatement st = conn.prepareStatement(s);
								st.executeUpdate();
								st.close();
								response.sendRedirect("change_pass_admin.jsp?stat=2&username="+username);
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
								
								
								//cek NewPass history
								int JmlPass = 0;
								String CekPassHiss = "select count(*) as ada from pass_history where username = ? and password = password(?)";
								//out.println("sql : " + CekPassHiss);
								PreparedStatement psCekPassHis = conn.prepareStatement(CekPassHiss);
								psCekPassHis.setString(1,username);
								psCekPassHis.setString(2,NewPass);
								ResultSet rsCekPassHiss = psCekPassHis.executeQuery();
								if (rsCekPassHiss.next()) 
									JmlPass = rsCekPassHiss.getInt("ada");
										
								//out.print("Jml : "+JmlPass);
								if (JmlPass > 0) {
									response.sendRedirect("change_pass_admin.jsp?stat=6&username="+username);
								}
								rsCekPassHiss.close();
								psCekPassHis.close();
												 																					
								s2 = "update admin set password = password('"+NewPass+"'),exp_date='"+expDate()+"' where username='"+username+"'";
								for (int i=0; i<NewPass.length(); i++) {
									a = i+1;
                         			Matcher fit_h_kecil = h_kecil.matcher(NewPass.substring(i,a));
									Matcher fit_h_besar = h_besar.matcher(NewPass.substring(i,a));
									Matcher fit_angka = angka.matcher(NewPass.substring(i,a));
									Matcher fit_char = s_char.matcher(NewPass.substring(i,a));
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
								
								if ((c_h_kecil > 0) && (c_h_besar > 0) && (c_angka > 0) && (c_spe_char > 0)) {
									//out.print("success");
									
									
									//("edit_account.jsp?stat=5&username="+username);
									//insert into activity username
									String s = "insert into activity_log (userlogin,access_time,activity,note,IP) values('"+username+"',now(),'Edit User "+username+"','Success','"+ipaddr+"')";
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
									psUpdateUser.setString(2,username);
									psUpdateUser.executeUpdate();
									psUpdateUser.close();
									
									//set urutan NewPass
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
									String mskPassHis = "insert into pass_history values('"+username+"',password('"+NewPass+"'),'"+UrutPassHiss+"',now())";
									PreparedStatement psMskPassHis = conn.prepareStatement(mskPassHis);
									psMskPassHis.executeUpdate();
									psMskPassHis.close();
									//send Redirect to admin.jsp
									session.putValue("user",username);
									response.sendRedirect("admin.jsp?username=");
								}
								else {
									String s = "insert into activity_log (userlogin,access_time,activity,note,IP,Reason) values('"+username+"',now(),'Edit User','Failed','"+ipaddr+"','Password Must include special character and alphanumeric (a-z, A-Z,0-9,* ! @ #.. *)')";
									PreparedStatement st = conn.prepareStatement(s);
									st.executeUpdate();
									st.close();
									response.sendRedirect("change_pass_admin.jsp?stat=4&username="+username);	
								}
							}
						}
					}
					catch(Exception  e){
						e.printStackTrace(System.out);
					} finally{
						try { conn.close(); } catch(Exception ee){}
					}
				} else {
					response.sendRedirect("change_pass_admin.jsp?stat=7&username="+username);
					//out.println("Pass Tidak sama");
					//out.println("New : " + NewPass.length() );
					//out.println("Conf : " + ConfPass.length());
				}
		}
	//} else {
	//	response.sendRedirect("admin.html");
	//} 
	
%>
