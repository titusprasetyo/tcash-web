<%@page import="com.telkomsel.itvas.util.HexaCharUtils"%>
<%@ page import="java.sql.*"%>
<%@page import="org.apache.commons.lang.StringEscapeUtils"%>
<%@ include file="/web-starter/taglibs.jsp"%>
<stripes:layout-render name="/web-starter/layout/standard.jsp"
	title="Create Reader Terminal">
	<stripes:layout-component name="contents">
		<script language="JavaScript">
		<!--
		function numeralsOnly(evt) {
		    evt = (evt) ? evt : event;
		    var charCode = (evt.charCode) ? evt.charCode : ((evt.keyCode) ? evt.keyCode : 
		        ((evt.which) ? evt.which : 0));
		    if (charCode > 31 && (charCode < 48 || charCode > 57) && charCode!=37818 &&  charCode!=37 && charCode!=39 && charCode!=46 && charCode!=17) {
		        alert("Enter numerals only in this field.");
		        return false;
		    }
		    return true;
		}
		
		
		function check(){
			var radioBtns = document.formInput.encryption;
			for(var i=0; i<radioBtns.length; i++){
			    if(radioBtns[i].checked){
			        if(radioBtns[i].value == "on"){
			        	document.formInput.encryptionText.disabled = false;
			        //	document.formInput.encryptionText.value ="1000000000000001";
			        }else{
			        	document.formInput.encryptionText.disabled = true;
			        	document.formInput.encryptionText.value="";
			        }
			    }
			}
		}
		
		function validation(){
			
			if(document.formInput.msisdn.value == null || document.formInput.msisdn.value == ""){
				alert("Terminal/Keyword required");
				return false;
			}
			if(document.formInput.keyTerminal.value == null || document.formInput.keyTerminal.value == ""){
				alert("Password / pin required");
				return false;
			}
			if(document.formInput.description.value == null || document.formInput.description.value == ""){
				alert("Description required");
				return false;
			}
			
			if(document.formInput.keyTerminal.value != null || document.formInput.keyTerminal.value != ""){
				if(document.formInput.keyTerminal.value.length < 6){
					alert("Password/pin must be 6 digit");
					return false;
				}
			}
			
			if(document.formInput.encryptionText.value != null && document.formInput.encryptionText.value != ""){
				if(document.formInput.encryptionText.value.length < 16){
					alert("Encryption must be 16 digit");
					return false;
				}
				if(isNaN(document.formInput.encryptionText.value)){
					alert("Encryption must be number");
					return false;
				}
				
			}
			
			if(document.forms[0].msisdn.value != null && document.forms[0].msisdn.value != ""){
				var numbers = ["0811","0812","0813","0852","0821","0853","62811","62812","62813","62852","62821","62853"];
				var msisdn = document.forms[0].msisdn.value;
				var found = 0;
				//if(msisdn.substring(0,2) == "08" || msisdn.substring(0,3) == "628"){
				if(!isNaN(msisdn)){
					for (var i = 0; i < numbers.length; i++) {
				    	if(msisdn.indexOf(numbers[i]) != -1){//jika ada
				    		found++;
						}
				    }
					if(msisdn.substring(0,2) == "08" && msisdn.length < 10){
						alert("Terminal/keyword is not complete");
						return false;
					}
					if(msisdn.substring(0,3) == "628" && msisdn.length < 11){
						alert("Terminal/keyword is not complete");
						return false;
					}
					if(found == 0){
						alert("If Terminal/keyword is number please use telkomsel msisdn");
						return false;
					}
				}
				
			}
			
			if(document.forms[0].hiddenId.value != ""){
				var checkStatus = confirm('Are you sure want to edit this data?');
				if (checkStatus){
					return true;
				}else{
					return false;
				}
			}
			
		}
		
		//-->		
		
		</script>
		<jsp:useBean id="DbCon" scope="page" class="tsel_tunai.DbCon"></jsp:useBean>
		<%@page import="com.telkomsel.itvas.webstarter.User"%>
		<%
			String terminalId = "";
					String msisdn = "";
					String merchantId = "";
					String description = "";
					String keyTerminal = "";
					String address = "";
					String url = "";
					String chargeInfo = "";
					String isLocked = "";
					int terminalType = 0;
					String alias = "";
					String encKey = "";
					String merchantIdEdit = "";
					
					

					if (request.getParameter("rtId") != null){
						terminalId = request.getParameter("rtId");
					}
					if (request.getParameter("merchantId") != null){
						merchantIdEdit = request.getParameter("merchantId");
					}

					User user = (User) session.getValue("user");
					Connection conn = null;
					try {
						conn = DbCon.getConnection();
						String q = "select TERMINAL_ID, MSISDN, MERCHANT_ID, DESCRIPTION, KEYTERMINAL, ADDRESS, URL "
								+ ", CHARGE_INFO, IS_LOCKED, ALIAS from READER_TERMINAL where TERMINAL_ID= ?";
						PreparedStatement st = conn.prepareStatement(q);
						st.setString(1, terminalId);
						ResultSet rs = st.executeQuery();

						if (rs.next()) {
							msisdn = rs.getString("MSISDN");
							merchantId = rs.getString("MERCHANT_ID");
							description = rs.getString("DESCRIPTION");
							keyTerminal = rs.getString("KEYTERMINAL");
							address = rs.getString("ADDRESS");
							url = rs.getString("URL");
							chargeInfo = rs.getString("CHARGE_INFO");
							isLocked = rs.getString("IS_LOCKED");
							alias = rs.getString("ALIAS");
						}
						rs.close();
						
						String qMRollingKey = "select * from merchant_rolling_key where merchant_id = ?";
						PreparedStatement ps = conn.prepareStatement(qMRollingKey);
						ps.setString(1, merchantIdEdit);
						ResultSet rsMerchantRK = ps.executeQuery();
						if (rsMerchantRK.next()) {
							encKey = HexaCharUtils.HexaToChar(rsMerchantRK.getString("enc_key"));
						}
						rsMerchantRK.close();
					} catch (Exception e) {
						e.printStackTrace();
						//response.sendRedirect("index.jsp");
					} finally {
						if (conn != null) {
							conn.close();
						}
					}

					if (request.getParameter("stat") != null) {
						String stat = StringEscapeUtils.escapeHtml(request
								.getParameter("stat"));
						String count = StringEscapeUtils.escapeHtml(request
								.getParameter("count"));
						if (stat.equals("0")) {
						} else if (stat.equals("1")) {
							out.println("<SCRIPT LANGUAGE=javascript> alert('Terminal/keyword must be fill');</SCRIPT>");
						} else if (stat.equals("2") && count.equals("1")) {
							out.println("<SCRIPT LANGUAGE=javascript> alert('Reader Terminal Succesfully Created and encryption already exist !!');</SCRIPT>");
						}else if (stat.equals("2") && count.equals("0")) {
							out.println("<SCRIPT LANGUAGE=javascript> alert('Reader Terminal Succesfully Created !!');</SCRIPT>");
						} else if (stat.equals("3")) {
							out.println("<SCRIPT LANGUAGE=javascript> alert('Reader Terminal Succesfully Edited !!');</SCRIPT>");
						}else if (stat.equals("4")) {
							out.println("<SCRIPT LANGUAGE=javascript> alert('Reader Terminal Unsuccessfully create, data already exist or error database !!');</SCRIPT>");
						}else {
							out.println("<SCRIPT LANGUAGE=javascript> alert('Reader Terminal Failed to create, data already exist or error database !!');</SCRIPT>");
						}
					}
		%>
		<br>
		<form id="formInput" name="formInput" onsubmit="return validation();" method="post" action="readerTerminalExecution.jsp" autocomplete="off">
			<table width="50%" border="0" cellspacing="3" cellpadding="3">
				<tr bgcolor="#CC6633">
					<td colspan="2"><div align="center">
							<font color="#FFFFFF" size="2"
								face="Verdana, Arial, Helvetica, sans-serif"><strong>Save
									/ Update Reader Terminal </strong> </font>
						</div></td>
				</tr>
				<tr>
					<td width="20%"><font color="#999999" size="1"
						face="Verdana, Arial, Helvetica, sans-serif"><strong>Merchant</strong>
					</font>
					</td>
					<td width="80%"><input type="hidden" name="hiddenId"
						id="hiddenId" value="<%=terminalId%>" /> <select name='merchant'>
							<%
								Connection con = null;
								try {
									con = DbCon.getConnection();
									String q = "select m.MERCHANT_ID, mi.NAME from MERCHANT m inner join MERCHANT_INFO mi on m.merchant_info_id = mi.merchant_info_id  order by mi.NAME";
									Statement st = con.createStatement();
									ResultSet rs = st.executeQuery(q);
									while (rs.next()) {
							%>
							<option value="<%=rs.getString("MERCHANT_ID")%>" <%=(merchantId.equals(rs.getString("MERCHANT_ID"))) ? "selected"
									: ""%>><%=rs.getString("NAME")%></option>
							<%
								}
											rs.close();
										} catch (Exception e) {
											e.printStackTrace();
										
										} finally {
											if (con != null) {
												con.close();
											}
										}
							%>
					</select>					
					</td>
				</tr>
				<tr>
					<td><font color="#999999" size="1"
						face="Verdana, Arial, Helvetica, sans-serif"><strong>Terminal
								/ Keyword *</strong> </font></td>
					<td width="100%"><input type="text" name="msisdn"
						value="<%=msisdn%>" width="200" <%=terminalId.equals("")?"": "readonly" %>>
						<font color="#999999" size="1"
						face="Verdana, Arial, Helvetica, sans-serif"><strong><%=terminalId%></strong></font>
					</td>
				</tr>
				<tr>
					<td><font color="#999999" size="1"
						face="Verdana, Arial, Helvetica, sans-serif"><strong>Terminal
								Type *</strong> </font></td>
					<td width="100%"><select name="terminalType">
							<option value="0" selected>Default</option>
							<option value="6">Grapari Kios</option>
					</select>
					</td>
				</tr>
				<tr>
					<td><font color="#999999" size="1"
						face="Verdana, Arial, Helvetica, sans-serif"><strong>Alias</strong>
					</font></td>
					<td width="100%"><input type="text" name="alias" value="<%=alias%>"
						width="200">
					</td>
				</tr>
				<tr>
					<td><font color="#999999" size="1"
						face="Verdana, Arial, Helvetica, sans-serif"><strong>Active</strong>
					</font></td>
					<td>
						<%if(isLocked == null || isLocked.equals("")){ %> 
							<input type="radio" name="isLocked" value="1" checked><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Yes</strong></font>&nbsp;&nbsp; 
							<input type="radio" name="isLocked" value="0"><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>No</strong></font>
						<%} else { %> 
							<input type="radio" name="isLocked" value="1" <%=isLocked != null && isLocked == "0"?"checked":""%>>
							<font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Yes</strong></font> &nbsp;&nbsp; 
							<input type="radio" name="isLocked" value="0" <%=isLocked != null && isLocked == "1"?"checked":""%>>
							<font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>No</strong></font>
					</td>
					<%} %>
				</tr>
				<tr>
					<td width="46%"><font color="#999999" size="1"
						face="Verdana, Arial, Helvetica, sans-serif"><strong>Password/PIN *</strong>
					</font></td>
					<td width="100%"><input type="password" name="keyTerminal"
						width="200" value="<%=keyTerminal%>">
					</td>
				</tr>
				<tr>
					<td width="46%"><font color="#999999" size="1"
						face="Verdana, Arial, Helvetica, sans-serif"><strong>Description *</strong>
					</font></td>
					<td width="100%"><textarea name="description" cols="15"><%=description%></textarea>
					</td>
				</tr>
				<tr>
					<td width="46%"><font color="#999999" size="1"
						face="Verdana, Arial, Helvetica, sans-serif"><strong>Address</strong>
					</font></td>
					<td width="100%"><textarea name="address" cols="15"><%=address%></textarea>
					</td>
				</tr>
				<tr>
					<td width="46%"><font color="#999999" size="1"
						face="Verdana, Arial, Helvetica, sans-serif"><strong>URL</strong>
					</font></td>
					<td width="100%"><select name="urlType">
							<option value="" selected>Indirect Payment</option>
							<option value="x">Direct Payment</option>
					</select>
					<input type="text" name="url" size="30"	value="<%=url%>">&nbsp;<font color="#999999" size="1"
						face="Verdana, Arial, Helvetica, sans-serif"><strong>use http://</strong>
					</font>
					</td>
				</tr>
				<tr>
					<td width="46%"><font color="#999999" size="1"
						face="Verdana, Arial, Helvetica, sans-serif"><strong>Assumption</strong>
					</font></td>
					<td width="100%"><select name="chargeInfo">
						<%if(chargeInfo == null || chargeInfo.equals("")){ %> 
							<option value="Negative" selected>Negative</option>
							<option value="Positive">Positive</option>
						<%} else { %>
							<option value="Negative" <%=(chargeInfo.equals("Negative")) ? "selected"
									: ""%>>Negative</option>
							<option value="Positive" <%=(chargeInfo.equals("Positive")) ? "selected"
									: ""%>>Positive</option> 
						<%}%>
					</select>
					</td>
				</tr>
				<tr>
					<td><font color="#999999" size="1"
						face="Verdana, Arial, Helvetica, sans-serif"><strong>Encryption</strong>
					</font></td>
					<td>
						<%if(encKey == null || encKey.equals("")){ %> 
						<input type="radio" name="encryption" value="on" onclick="check();"><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>On</strong></font>&nbsp;&nbsp; 
						<input type="radio" name="encryption" value="off" checked onclick="check();"><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Off</strong></font>
						<br>
						<input type="text" name="encryptionText" value="<%=encKey%>" size="30" maxlength="16" disabled="true">
						<%} else { %> 
						<input type="radio" name="encryption" value="on" checked onclick="check();"><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>On</strong></font>&nbsp;&nbsp; 
						<input type="radio" name="encryption" value="off" onclick="check();"><font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Off</strong></font>
						<br>
						<input type="text" name="encryptionText" value="<%=encKey%>" size="30" maxlength="16">
						<%} %>
					</td>
				</tr>
				<tr>
					<td>&nbsp;</td>
					<td><input type="submit" name="Submit" value="Save">
					</td>
				</tr>
			</table>
		</form>

		<br>
		<br>
		<br>
		<br>
		<table width="40%" border="0" cellspacing="0" cellpadding="0">
			<tr>
				<td><div align="center">
						<font color="#CC6633" size="1"
							face="Verdana, Arial, Helvetica, sans-serif">Sebelum anda
							keluar dari layanan ini pastikan anda telah logout agar login
							anda tidak dapat dipakai oleh orang lain.</font>
					</div></td>
			</tr>
		</table>

		<br>
		</td>
		</tr>
		<tr>
			<td valign="top" bgcolor="#CC6633">
				<div align="right">
					<font color="#FFFFFF" size="1"
						face="Verdana, Arial, Helvetica, sans-serif"></font>
				</div></td>
			<td valign="top" bgcolor="#CC6633">
				<div align="right">
					<font color="#FFFFFF" size="1"
						face="Verdana, Arial, Helvetica, sans-serif"><strong>IT
							VAS Development 2007</strong> </font>
				</div></td>
		</tr>
		</table>
		</div>
		</body>
		</html>
	</stripes:layout-component>
</stripes:layout-render>
