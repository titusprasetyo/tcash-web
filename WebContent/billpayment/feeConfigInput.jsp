<%@page import="org.apache.commons.lang.StringUtils"%>
<%@ page import="java.sql.*"%>
<%@page import="org.apache.commons.lang.StringEscapeUtils"%>
<%@ include file="/web-starter/taglibs.jsp"%>
<stripes:layout-render name="/web-starter/layout/standard.jsp"
	title="Fee Config">
	<stripes:layout-component name="contents">
		<script language="javascript" type="text/javascript">  
	      var xmlHttp;  
	      var xmlHttp;
	      function showState(str){
		      if (typeof XMLHttpRequest != "undefined"){
		      	xmlHttp= new XMLHttpRequest();
		      }
		      else if (window.ActiveXObject){
		      	xmlHttp= new ActiveXObject("Microsoft.XMLHTTP");
		      }
		      if (xmlHttp==null){
		      	alert("Browser does not support XMLHTTP Request")
		      	return;
		      } 
		      var url="state.jsp";
		      url +="?count=" +str;
		      xmlHttp.onreadystatechange = stateChange;
		      xmlHttp.open("GET", url, true);
		      xmlHttp.send(null);
	      }
	
	      function stateChange(){   
		      if (xmlHttp.readyState==4 || xmlHttp.readyState=="complete"){   
		      		document.getElementById("divTerminal").innerHTML=xmlHttp.responseText;   
		      }   
	      }
      	</script>
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
		
		 function getTextTrxType(){
			var trxTypeText = document.getElementById("trxType").options[document.getElementById("trxType").selectedIndex].text;
			document.formInput.trxDescription.value = trxTypeText;
		 } 
		
		function validation(){
			if(document.forms[0].trxType.value == null || document.forms[0].trxType.value == ""){
				alert("Transaction Type required");
				return false;
			 }
			if(document.forms[0].merchant.value == null || document.forms[0].merchant.value == ""){
				alert("Merchant required");
				return false;
			 }
			
			var radioBtns = document.forms[0].feeTiring;
			for(var i=0; i<radioBtns.length; i++){
				if(radioBtns[i].checked){
					if(radioBtns[i].value == '1'){
						if(document.forms[0].textAmWT.value == null || document.forms[0].textAmWT.value == ""){
							alert("Customer Fee : Amount requiered");
							return false;
						 }
						 if(document.forms[0].textAmWT.value != null || document.forms[0].textAmWT.value != ""){
							if(isNaN(document.forms[0].textAmWT.value)){
								alert("Customer Fee : Amount must be number");
								return false;
							}
						 }
					} else {
						var tbl = document.getElementById('tblSample');
						 var lastRow = tbl.rows.length - 1;					
						 if(lastRow > 0){
							var ceiling = "";
							if(lastRow == 1){
								if(document.forms[0].textAm.value == null || document.forms[0].textAm.value == ""){
									alert("Customer Fee : Amounts requiered");
									return false;
								 }
								if(document.forms[0].textFloor.value == null || document.forms[0].textFloor.value == ""){
									alert("Customer Fee : Floors requiered");
									return false;
								 }
								if(document.forms[0].textCeiling.value == null || document.forms[0].textCeiling.value == ""){
									alert("Customer Fee : Ceiling requiered");
									return false;
								 }
								if(isNaN(document.forms[0].textAm.value)){
									alert("Customer Fee : Amount must be number");
									return false;
								}
								if(isNaN(document.forms[0].textFloor.value)){
									alert("Customer Fee : Floor must be number");
									return false;
								}
								if(isNaN(document.forms[0].textCeiling.value)){
									alert("Customer Fee : Ceiling must be number");
									return false;
								}
								if(parseInt(document.forms[0].textFloor.value) >= parseInt(document.forms[0].textCeiling.value)){
									alert("Customer Fee : Floor cannot be grather or equals than ceiling");
									return false;
								}
								if(parseInt(document.forms[0].textCeiling.value)  > 5000000){
									alert("Customer Fee : Ceiling cannot be grather than 5000000");
									return false;
								}
								ceiling = parseInt(document.forms[0].textCeiling.value);
							}else{							 
								for(var i=0; i<lastRow; i++){
									if(document.forms[0].textAm[i].value == null || document.forms[0].textAm[i].value == ""){
										alert("Customer Fee : Amounts requiered");
										return false;
									 }
									if(document.forms[0].textFloor[i].value == null || document.forms[0].textFloor[i].value == ""){
										alert("Customer Fee : Floor requiered");
										return false;
									 }
									if(document.forms[0].textCeiling[i].value == null || document.forms[0].textCeiling[i].value == ""){
										alert("Customer Fee : Ceiling requiered");
										return false;
									 }
									if(isNaN(document.forms[0].textAm[i].value)){
										alert("Customer Fee : Amount must be number");
										return false;
									}
									if(isNaN(document.forms[0].textFloor[i].value)){
										alert("Customer Fee : Floor must be number");
										return false;
									}
									if(isNaN(document.forms[0].textCeiling[i].value)){
										alert("Customer Fee : Ceiling must be number");
										return false;
									}
									
									if(parseInt(document.forms[0].textFloor[i].value) >= parseInt(document.forms[0].textCeiling[i].value)){
										alert("Customer Fee : Floor cannot be grather or equals than ceiling");
										return false;
									}
									if(parseInt(document.forms[0].textCeiling[i].value)  > 5000000){
										alert("Customer Fee : Ceiling cannot be grather than 5000000");
										return false;
									}
									if(parseInt(document.forms[0].textFloor[i].value) <= parseInt(ceiling)){
										alert("Customer Fee : Bottom of Floor cannot be less or equals than top ceiling");
										return false;
									}
									ceiling = document.forms[0].textCeiling[i].value;
								}
							}
						}	 
					}
				}
			}	
			
			
			var merchantFeeRadioBtns = document.forms[0].merchantFeeTiring;
			for(var i=0; i<merchantFeeRadioBtns.length; i++){
				if(merchantFeeRadioBtns[i].checked){
					if(merchantFeeRadioBtns[i].value == '1'){
						if(document.forms[0].textAmMfWt.value == null || document.forms[0].textAmMfWt.value == ""){
							alert("Merchant fee : amount requiered");
							return false;
						 }
						 if(document.forms[0].textAmMfWt.value != null || document.forms[0].textAmMfWt.value != ""){
							if(isNaN(document.forms[0].textAmMfWt.value)){
								alert("Merchant fee : amount must be number");
								return false;
							}
						 }
					} else {
						var tbl = document.getElementById('tblMerchantFee');
						 var lastRow = tbl.rows.length - 1;					
						 if(lastRow > 0){
							var ceiling = "";
							if(lastRow == 1){
								if(document.forms[0].textAmMF.value == null || document.forms[0].textAmMF.value == ""){
									alert("Merchant fee : Amounts requiered");
									return false;
								 }
								if(document.forms[0].textFloorMF.value == null || document.forms[0].textFloorMF.value == ""){
									alert("Merchant fee : Floors requiered");
									return false;
								 }
								if(document.forms[0].textCeilingMF.value == null || document.forms[0].textCeilingMF.value == ""){
									alert("Merchant fee : Ceiling requiered");
									return false;
								 }
								if(isNaN(document.forms[0].textAmMF.value)){
									alert("Merchant fee : Amount must be number");
									return false;
								}
								if(isNaN(document.forms[0].textFloorMF.value)){
									alert("Merchant fee : Floor must be number");
									return false;
								}
								if(isNaN(document.forms[0].textCeilingMF.value)){
									alert("Merchant fee : Ceiling must be number");
									return false;
								}
								if(parseInt(document.forms[0].textFloorMF.value) >= parseInt(document.forms[0].textCeilingMF.value)){
									alert("Merchant fee : Floor cannot be grather or equals than ceiling");
									return false;
								}
								if(parseInt(document.forms[0].textCeilingMF.value)  > 5000000){
									alert("Merchant fee : Ceiling cannot be grather than 5000000");
									return false;
								}
								ceiling = parseInt(document.forms[0].textCeilingMF.value);
							}else{							 
								for(var i=0; i<lastRow; i++){
									if(document.forms[0].textAmMF[i].value == null || document.forms[0].textAmMF[i].value == ""){
										alert("Merchant fee : Amounts requiered");
										return false;
									 }
									if(document.forms[0].textFloorMF[i].value == null || document.forms[0].textFloorMF[i].value == ""){
										alert("Merchant fee : Floors requiered");
										return false;
									 }
									if(document.forms[0].textCeilingMF[i].value == null || document.forms[0].textCeilingMF[i].value == ""){
										alert("Merchant fee : Ceilings requiered");
										return false;
									 }
									if(isNaN(document.forms[0].textAmMF[i].value)){
										alert("Merchant fee : Amounts must be number");
										return false;
									}
									if(isNaN(document.forms[0].textFloorMF[i].value)){
										alert("Merchant fee : Floors must be number");
										return false;
									}
									if(isNaN(document.forms[0].textCeilingMF[i].value)){
										alert("Merchant fee : Ceilings must be number");
										return false;
									}
									
									if(parseInt(document.forms[0].textFloorMF[i].value) >= parseInt(document.forms[0].textCeilingMF[i].value)){
										alert("Merchant fee : Floors cannot be grather or equals than ceilings");
										return false;
									}
									if(parseInt(document.forms[0].textCeilingMF[i].value)  > 5000000){
										alert("Merchant fee : Ceilings cannot be grather than 5000000");
										return false;
									}
									if(parseInt(document.forms[0].textFloorMF[i].value) <= parseInt(ceiling)){
										alert("Merchant fee : Bottom of floors cannot be less or equals than top ceilings");
										return false;
									}
									ceiling = document.forms[0].textCeilingMF[i].value;
								}
							}
						}	 
					}
				}
			}
		}
		
		function noDiv() { 
			if (document.getElementById) { 
				document.getElementById('divCustomerFee').style.visibility = 'hidden'; 
				document.getElementById('divCustomerFee').style.display = 'none';
				document.getElementById('divCustomerFeeWithoutTiring').style.visibility = 'visible'; 
				document.getElementById('divCustomerFeeWithoutTiring').style.display = 'block'; 
				removeAllRows();
			} 
		} 
		function yesDiv() { 
			if (document.getElementById) { 
				document.getElementById('divCustomerFee').style.visibility = 'visible'; 
				document.getElementById('divCustomerFee').style.display = 'block'; 
				document.getElementById('divCustomerFeeWithoutTiring').style.visibility = 'hidden'; 
				document.getElementById('divCustomerFeeWithoutTiring').style.display = 'none'; 
				document.formInput.textAmWT.value = "";
				
			} 
		}
		
		function noDivMerchantFee() { 
			if (document.getElementById) { 
				document.getElementById('divMerchantFee').style.visibility = 'hidden'; 
				document.getElementById('divMerchantFee').style.display = 'none';
				document.getElementById('divMerchantFeeWithoutTiring').style.visibility = 'visible'; 
				document.getElementById('divMerchantFeeWithoutTiring').style.display = 'block'; 
				removeAllMerchantFee();
			} 
		} 
		function yesDivMerchantFee() { 
			if (document.getElementById) { 
				document.getElementById('divMerchantFee').style.visibility = 'visible'; 
				document.getElementById('divMerchantFee').style.display = 'block'; 
				document.getElementById('divMerchantFeeWithoutTiring').style.visibility = 'hidden'; 
				document.getElementById('divMerchantFeeWithoutTiring').style.display = 'none'; 
				document.formInput.textAmMfWt.value="";
			} 
		}
		
		function addRow()
		{
		  var tbl = document.getElementById('tblSample');
		  var lastRow = tbl.rows.length;
		  var iteration = lastRow;
		  var row = tbl.insertRow(lastRow);
		  
		  var cellRightType = row.insertCell(0);
		  var el = document.createElement('select');
		  el.name = 'textType';
		  el.id = 'textType';
		  el.options[0] = new Option('Fixed', '0');
		  el.options[1] = new Option('Percentage', '1');
		  el.style.width = "70px";
		  cellRightType.appendChild(el);
		  
		  var cellRightAm = row.insertCell(1);
		  var el = document.createElement('input');
		  el.type = 'text';
		  el.name = 'textAm';
		  el.id = 'textAm';
		  el.size = 5;
		  cellRightAm.appendChild(el);
		  
		  var cellRight = row.insertCell(2);
		  var el = document.createElement('input');
		  el.type = 'text';
		  el.name = 'textFloor';
		  el.id = 'textFloor';
		  el.size = 5;		  
		  cellRight.appendChild(el);
		  
		  var cellRightSel = row.insertCell(3);
		  var el = document.createElement('input');
		  el.type = 'text';
		  el.name = 'textCeiling';
		  el.id = 'textCeiling';
		  el.size = 5;
		  cellRightSel.appendChild(el);
		  
		}
		
		function removeRow()
		{
		  var tbl = document.getElementById('tblSample');
		  var lastRow = tbl.rows.length;
		  //if (lastRow > 1) 
			  tbl.deleteRow(lastRow - 1);
		}
		
		function removeAllRows(){
		    var table = document.getElementById("tblSample");
		    //or use : var table = document.all.tableid;
		    for(var i = table.rows.length - 1; i > 0; i--){
		    	table.deleteRow(i);
		    }
		}
		
		function addRowMerchantFee()
		{
		  var tbl = document.getElementById('tblMerchantFee');
		  var lastRow = tbl.rows.length;
		  var iteration = lastRow;
		  var row = tbl.insertRow(lastRow);
		  
		  var cellRightType = row.insertCell(0);
		  var el = document.createElement('select');
		  el.name = 'textTypeMF';
		  el.id = 'textTypeMF';
		  el.options[0] = new Option('Fixed', '0');
		  el.options[1] = new Option('Percentage', '1');
		  el.style.width = "70px";
		  cellRightType.appendChild(el);
		  
		  var cellRightAm = row.insertCell(1);
		  var el = document.createElement('input');
		  el.type = 'text';
		  el.name = 'textAmMF';
		  el.id = 'textAmMF';
		  el.size = 5;
		  cellRightAm.appendChild(el);
		  
		  var cellRight = row.insertCell(2);
		  var el = document.createElement('input');
		  el.type = 'text';
		  el.name = 'textFloorMF';
		  el.id = 'textFloorMF';
		  el.size = 5;		  
		  cellRight.appendChild(el);
		  
		  var cellRightSel = row.insertCell(3);
		  var el = document.createElement('input');
		  el.type = 'text';
		  el.name = 'textCeilingMF';
		  el.id = 'textCeilingMF';
		  el.size = 5;
		  cellRightSel.appendChild(el);
		  
		}
		
		function removeRowMerchantFee()
		{
		  var tbl = document.getElementById('tblMerchantFee');
		  var lastRow = tbl.rows.length;
		  tbl.deleteRow(lastRow - 1);
		}
		
		function removeAllMerchantFee(){
		    var table = document.getElementById("tblMerchantFee");
		    //or use : var table = document.all.tableid;
		    for(var i = table.rows.length - 1; i > 0; i--){
		    	table.deleteRow(i);
		    }
		}
		
		//-->
		</script>


		<jsp:useBean id="DbCon" scope="page" class="tsel_tunai.DbCon"></jsp:useBean>
		<%@page import="com.telkomsel.itvas.webstarter.User"%>
		<%
			String trxType = "";
					String msisdn = "";
					String merchantId = "";
					String terminalId = "";
					String alias = "";
					String bearer = "";
					String source = "";

					if (request.getParameter("trxType") != null){
						trxType = StringEscapeUtils.escapeHtml(request
								.getParameter("trxType"));
					}

					User user = (User) session.getValue("user");
					Connection conn = null;
					try {
						conn = DbCon.getConnection();
						String q = "select TERMINAL_ID, MSISDN, MERCHANT_ID, DESCRIPTION, KEYTERMINAL, ADDRESS, URL "
								+ ", CHARGE_INFO, IS_LOCKED, ALIAS from READER_TERMINAL where TERMINAL_ID= ?";
						PreparedStatement st = conn.prepareStatement(q);
						st.setString(1, trxType);
						ResultSet rs = st.executeQuery();

						if (rs.next()) {
							msisdn = rs.getString("MSISDN");
							merchantId = rs.getString("MERCHANT_ID");
							alias = rs.getString("ALIAS");
						}

						rs.close();
					} catch (Exception e) {
					} finally {
						if (conn != null) {
							conn.close();
						}
					}

					if (request.getParameter("stat") != null) {
						String stat = StringEscapeUtils.escapeHtml(request
								.getParameter("stat"));
						if (stat.equals("1")) {
							out.println("<SCRIPT LANGUAGE=javascript> alert('MSISDN must be fill');</SCRIPT>");
						} else {
							out.println("<SCRIPT LANGUAGE=javascript> alert('Fee Config Failed to create, probably because error in database');</SCRIPT>");
						}
					}
		%>
		<br>
		<form id="formInput" name="formInput" onsubmit="return validation();"
			method="post" action="feeConfigExecution.jsp">
			<table width="70%" border="0" cellspacing="3" cellpadding="3">
				<tr bgcolor="#CC6633">
					<td colspan="2"><div align="center">
							<font color="#FFFFFF" size="2"
								face="Verdana, Arial, Helvetica, sans-serif"><strong>Save
									/ Update Fee Config </strong> </font>
						</div>
					</td>
				</tr>
				<tr>
					<td><font color="#999999" size="1"
						face="Verdana, Arial, Helvetica, sans-serif"><strong>Transaction
								Type *</strong> </font></td>
					<td><input type="hidden" name="hiddenId" id="hiddenId"  /> 
						<select name="trxType" id="trxType" onchange="getTextTrxType()">
						<option value="">Select</option>
							<%
								Connection con = null;
										try {
											con = DbCon.getConnection();
											String q = "select distinct(trx_type), trx_description from fee_config order by trx_description";
											Statement st = con.createStatement();
											ResultSet rs = st.executeQuery(q);
											while (rs.next()) {
							%>
							<option value="<%=rs.getString("trx_type")%>"
								<%=(trxType.equals(rs.getString("trx_type"))) ? "selected"
									: ""%>><%=rs.getString("trx_description")%></option>
							<%
								}
											rs.close();
										} catch (Exception e) {
										} finally {
											if (con != null) {
												con.close();
											}
										}
							%>
					</select>
					<input type="hidden" name="trxDescription" id="trxDescription"  />					
					</td>
				</tr>
				<tr>
					<td><font color="#999999" size="1"
						face="Verdana, Arial, Helvetica, sans-serif"><strong>Source *</strong>
					</font>
					</td>
					<td><select name="source" style="width: 100px">
							<option value="e" selected>Emoney</option>
							<option value="a">Air Time</option>
					</select></td>
				</tr>
				<tr>
					<td><font color="#999999" size="1"
						face="Verdana, Arial, Helvetica, sans-serif"><strong>Bearer *</strong>
					</font>
					</td>
					<td><select name="bearer" style="width: 80px">
							<option value="all" selected>All</option>
							<option value="sms">SMS</option>
							<option value="ussd">USSD</option>
							<option value="web">Web</option>
					</select></td>
				</tr>				
				<tr>
					<td><font color="#999999" size="1"
						face="Verdana, Arial, Helvetica, sans-serif"><strong>Merchant *</strong>
					</font>
					</td>
					<td><select name='merchant'
						onchange="showState(this.value)">
							<option value="">Select</option>
							<%
								Connection conMerchant = null;
										try {
											conMerchant = DbCon.getConnection();
											String q = "select m.merchant_id,mi.name from merchant m, merchant_info mi  where m.merchant_info_id = mi.merchant_info_id and m.status = 'A' order by name";
											Statement st = conMerchant.createStatement();
											ResultSet rs = st.executeQuery(q);
											while (rs.next()) {
							%>
							<option value="<%=rs.getString("MERCHANT_ID")%>"
								<%=(merchantId.equals(rs
									.getString("MERCHANT_ID"))) ? "selected"
									: ""%>><%=rs.getString("NAME")%></option>
							<%
								}
											rs.close();
										} catch (Exception e) {
										} finally {
											if (conMerchant != null) {
												conMerchant.close();
											}
										}
							%>
					</select></td>
				</tr>
				<tr>
					<td><font color="#999999" size="1"
						face="Verdana, Arial, Helvetica, sans-serif"><strong>Terminal</strong>
					</font>
					</td>
					<td>
						<div id="divTerminal">
							<select name="terminal">
								<option value="all">Select</option>
							</select>
						</div></td>
				</tr>
				<!-- customer fee tiring -->
				<tr>
					<td><font color="#999999" size="1"
						face="Verdana, Arial, Helvetica, sans-serif"><strong>Customer Fee*</strong> </font>
					</td>
					<td>
						<font color="#999999" size="1"
						face="Verdana, Arial, Helvetica, sans-serif"><strong>Tiring Type :</strong></font>
					</td>
				</tr>
				<tr>					
					<td>
						<font color="#999999" size="1"
							face="Verdana, Arial, Helvetica, sans-serif"><strong></strong></font>
					</td>
					<td>
						<input type="radio" name="feeTiring" value="2" onclick="yesDiv();">
							<font color="#999999" size="1"	face="Verdana, Arial, Helvetica, sans-serif"><strong>Yes</strong></font>&nbsp;&nbsp; 
						<input type="radio" name="feeTiring" value="1" checked onclick="noDiv();">
							<font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>No</strong></font><br>
						<div id="divCustomerFee" style="visibility: hidden; display: none;"
							align="left">
							<input type="button" name="addRows" value="Add" onclick="addRow();" />
							<input type="button" value="Remove" onclick="removeRow();" />						
							<table border="0" id="tblSample">
								<tr>
								    <th><font color="#999999" size="1"
										face="Verdana, Arial, Helvetica, sans-serif"><strong>Type</strong></font></th>
									<th><font color="#999999" size="1"
										face="Verdana, Arial, Helvetica, sans-serif"><strong>Amount</strong></font></th>
									<th><font color="#999999" size="1"
										face="Verdana, Arial, Helvetica, sans-serif"><strong>Floor</strong></font></th>
										<th><font color="#999999" size="1"
										face="Verdana, Arial, Helvetica, sans-serif"><strong>Ceil</strong></font></th>
								</tr>
							</table>
						</div>
						<div id="divCustomerFeeWithoutTiring" style="visibility: visible; display: block;"
							align="left">
							<table border="0" id="tblCustomerFeeWithoutTiring">
								<tr>
								    <th><font color="#999999" size="1"
										face="Verdana, Arial, Helvetica, sans-serif"><strong>Type</strong></font></th>
									<th><font color="#999999" size="1"
										face="Verdana, Arial, Helvetica, sans-serif"><strong>Amount</strong></font></th>
									
								</tr>
								<tr>
									<td>
										<select name="textTypeWT" style="width: 70px">
											<option value="0" selected>Fixed</option>
											<option value="1">Pecentage</option>
										</select>
									</td>
									<td><input type="text" name="textAmWT" size="5"></td>
								</tr>
							</table>
						</div>
					</td>					
				</tr>				
				<!-- end customer fee tiring -->
				
				<!-- merchant fee tiring -->
				<tr>
					<td><font color="#999999" size="1"
						face="Verdana, Arial, Helvetica, sans-serif"><strong>Merchant Fee*</strong></font>
					</td>
					<td>
						<font color="#999999" size="1"
						face="Verdana, Arial, Helvetica, sans-serif"><strong>Tiring Type :</strong></font>
					</td>
				</tr>
				<tr>					
					<td>
						<font color="#999999" size="1"
						face="Verdana, Arial, Helvetica, sans-serif"><strong></strong></font>
					</td>
					<td>
							<input type="radio" name="merchantFeeTiring" value="2" onclick="yesDivMerchantFee();">
							<font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Yes</strong></font>&nbsp;&nbsp; 
						<input type="radio" name="merchantFeeTiring" value="1"	checked onclick="noDivMerchantFee();">
							<font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>No</strong></font><br>
						<div id="divMerchantFee" style="visibility: hidden; display: none"
							align="left">
							<input type="button" name="addRows" value="Add" onclick="addRowMerchantFee();" />
							<input type="button" value="Remove" onclick="removeRowMerchantFee()"/>							
						
							<table border="0" id="tblMerchantFee">
								<tr>
								    <th><font color="#999999" size="1"
										face="Verdana, Arial, Helvetica, sans-serif"><strong>Type</strong></font></th>
									<th><font color="#999999" size="1"
										face="Verdana, Arial, Helvetica, sans-serif"><strong>Amount</strong></font></th>
									<th><font color="#999999" size="1"
										face="Verdana, Arial, Helvetica, sans-serif"><strong>Floor</strong></font></th>
										<th><font color="#999999" size="1"
										face="Verdana, Arial, Helvetica, sans-serif"><strong>Ceil</strong></font></th>
								</tr>
							</table>
						</div>
						<div id="divMerchantFeeWithoutTiring" style="visibility: visible; display: block;"
							align="left">						
							<table border="0" id="tblMerchantFeeWithoutTiring">
								<tr>
								    <th><font color="#999999" size="1"
										face="Verdana, Arial, Helvetica, sans-serif"><strong>Type</strong></font></th>
									<th><font color="#999999" size="1"
										face="Verdana, Arial, Helvetica, sans-serif"><strong>Amount</strong></font></th>									
								</tr>
								<tr>
									<td>
										<select name="textTypeMfWt" style="width: 70px">
											<option value="0" selected>Fixed</option>
											<option value="1">Pecentage</option>
										</select>
									</td>
									<td><input type="text" name="textAmMfWt" size="5"></td>
								</tr>
							</table>
						</div>
					</td>					
				</tr>
				<!-- end merchant fee -->
				<tr>
					<td><font color="#999999" size="1"
						face="Verdana, Arial, Helvetica, sans-serif"><strong>Status *</strong></font>
					</td>
					<td><select name="status" style="width: 70px">
							<option value="a" selected>Active</option>
							<option value="n">Not Active</option>
					</select>
					</td>
				</tr>
				<tr>
					<td>&nbsp;</td>
					<td><input type="submit" name="Submit" value="Save"></td>
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
					</div>
				</td>
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
				</div>
			</td>
			<td valign="top" bgcolor="#CC6633">
				<div align="right">
					<font color="#FFFFFF" size="1"
						face="Verdana, Arial, Helvetica, sans-serif"><strong>IT
							VAS Development 2007</strong> </font>
				</div>
			</td>
		</tr>
		</table>
		</div>
		</body>
		</html>
	</stripes:layout-component>
</stripes:layout-render>
