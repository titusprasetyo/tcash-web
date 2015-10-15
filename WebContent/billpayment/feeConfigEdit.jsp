<%@page import="tsel_tunai.Util"%>
<%@page import="org.apache.commons.lang.StringUtils"%>
<%@ page import="java.sql.*"%>
<%@page import="org.apache.commons.lang.StringEscapeUtils"%>
<%@ include file="/web-starter/taglibs.jsp"%>

<stripes:layout-render name="/web-starter/layout/standard.jsp"
	title="Fee Config">
	<stripes:layout-component name="contents">
	<meta http-equiv="X-UA-Compatible" content="IE=EmulateIE8" >
	<script type="text/javascript" src="js/jquery-1.4.2.min.js"></script>
	<script type="text/javascript">
	$(document).ready(
			function() {
				$.urlParam = function(name){RegExp
				    var results = new RegExp('[\\?&]' + name + '=([^&#]*)').exec(window.location.href);
				    return results[1] || 0;
				}
							
				var trx_type = decodeURIComponent($.urlParam('trx_type'));
				var cust_fee = decodeURIComponent($.urlParam('cust_fee'));
				var merc_fee = decodeURIComponent($.urlParam('merc_fee'));
				var merchant_id = decodeURIComponent($.urlParam('merchant_id'));
				
				var type;
				var am;
				var floor;
				var ceil;
				var floor_ceil;
				
				var splitOne = cust_fee.split("|");
				if (splitOne[0] == "2") {					
					var splitTwo = splitOne[1].split(":");
					for (i in splitTwo) {
						var splitThree = splitTwo[i].split(",");					
						type = splitThree[0];
						am = splitThree[1];
						if (splitThree[2] != null) {
							floor_ceil = splitThree[2].split("-");
							floor = floor_ceil[0];
							ceil = floor_ceil[1];
							yesDiv();
							document.getElementById('feeTiring').checked = true;
							if (type == "1") {
								var am11 = am * 100;							
								//addRowEdit(type, am11, floor, ceil);
							} else {
								//addRowEdit(type, am, floor, ceil);								
							}
							
						} 			
					}  
				} else { 
						noDiv();
						document.getElementById('feeTiring').checked = false;
						/* if (splitOne[0] == "1") {
							var am12 = splitOne[1] * 100;							
							addCustomerFeeWithoutTiringEdit(splitOne[0], am12.toFixed());
						} else {
							addCustomerFeeWithoutTiringEdit(splitOne[0], splitOne[1]);
						} */
				}
				var type2;
				var am2;
				var floor2;
				var ceil2;
				var floor_ceil2;
								
				var splitOne2 = merc_fee.split("|");
				if (splitOne2[0] == "2") {
					var splitTwo2 = splitOne2[1].split(":");
					for (i in splitTwo2) {
						var splitThree2 = splitTwo2[i].split(",");					
						type2 = splitThree2[0];
						am2 = splitThree2[1];
						if (splitThree2[2] != null) {
							floor_ceil2 = splitThree2[2].split("-");
							floor2 = floor_ceil2[0];
							ceil2 = floor_ceil2[1];
							yesDivMerchantFee();							
							document.getElementById('merchantFeeTiring').checked = true;
							if (type2 == "1") {
								var am21 = am2 * 100;							
								//addRowMerchantFeeEdit(type2, am21, floor2, ceil2);
							} else {
								//addRowMerchantFeeEdit(type2, am2, floor2, ceil2);
							}
							
						} 		
					}  	
				} else { 
					noDivMerchantFee();
					document.getElementById('merchantFeeTiring').checked = false;					
					/* if (splitOne2[0] == "1") {
						var am22 = splitOne2[1] * 100;							
						addMerchantFeeWithoutTiringEdit(splitOne2[0], am22.toFixed());
					} else {
						addMerchantFeeWithoutTiringEdit(splitOne2[0], splitOne2[1]);
					} */
				}
				showState(merchant_id);
				
				
			});
	</script>
	<script language="javascript" type="text/javascript">  
	      var xmlHttp;  
	      var xmlHttp;
	      function showState(str, terminal_ids){
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
		      var url="stateEdit.jsp";
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
				
				var radioBtns = document.formInput.feeTiring;
				for(var i=0; i<radioBtns.length; i++){
					if(radioBtns[i].checked){
						if(radioBtns[i].value == "1"){
							if(document.formInput.textAmWT.value == null || document.formInput.textAmWT.value == ""){
								alert("Customer fee : Amount requiered");
								return false;
							 }
							 if(document.formInput.textAmWT.value != null || document.formInput.textAmWT.value != ""){
								if(isNaN(document.formInput.textAmWT.value)){
									alert("Customer fee : Amount must be number");
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
										alert("Customer fee : Amounts requiered");
										return false;
									 }
									if(document.forms[0].textFloor.value == null || document.forms[0].textFloor.value == ""){
										alert("Customer fee : Floors requiered");
										return false;
									 }
									if(document.forms[0].textCeiling.value == null || document.forms[0].textCeiling.value == ""){
										alert("Customer fee : Ceiling requiered");
										return false;
									 }
									if(isNaN(document.forms[0].textAm.value)){
										alert("Customer fee : Amount must be number");
										return false;
									}
									if(isNaN(document.forms[0].textFloor.value)){
										alert("Customer fee : Floor must be number");
										return false;
									}
									if(isNaN(document.forms[0].textCeiling.value)){
										alert("Customer fee : Ceiling must be number");
										return false;
									}
									if(parseInt(document.forms[0].textFloor.value) >= parseInt(document.forms[0].textCeiling.value)){
										alert("Customer fee : Floor cannot be grather or equals than ceiling");
										return false;
									}
									if(parseInt(document.forms[0].textCeiling.value)  > 5000000){
										alert("Customer fee : Ceiling cannot be grather than 5000000");
										return false;
									}
									ceiling = parseInt(document.forms[0].textCeiling.value);
								}else{							 
									for(var i=0; i<lastRow; i++){
										if(document.forms[0].textAm[i].value == null || document.forms[0].textAm[i].value == ""){
											alert("Customer fee : Amounts requiered");
											return false;
										 }
										if(document.forms[0].textFloor[i].value == null || document.forms[0].textFloor[i].value == ""){
											alert("Customer fee : Floor requiered");
											return false;
										 }
										if(document.forms[0].textCeiling[i].value == null || document.forms[0].textCeiling[i].value == ""){
											alert("Customer fee : Ceiling requiered");
											return false;
										 }
										if(isNaN(document.forms[0].textAm[i].value)){
											alert("Customer fee : Amount must be number");
											return false;
										}
										if(isNaN(document.forms[0].textFloor[i].value)){
											alert("Customer fee : Floor must be number");
											return false;
										}
										if(isNaN(document.forms[0].textCeiling[i].value)){
											alert("Customer fee : Ceiling must be number");
											return false;
										}
										
										if(parseInt(document.forms[0].textFloor[i].value) >= parseInt(document.forms[0].textCeiling[i].value)){
											alert("Customer fee : Floor cannot be grather or equals than ceiling");
											return false;
										}
										if(parseInt(document.forms[0].textCeiling[i].value)  > 5000000){
											alert("Customer fee : Ceiling cannot be grather than 5000000");
											return false;
										}
										if(parseInt(document.forms[0].textFloor[i].value) <= parseInt(ceiling)){
											alert("Customer fee : Bottom of Floor cannot be less or equals than top ceiling");
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
						if(merchantFeeRadioBtns[i].value == "1"){
							if(document.formInput.textAmMfWt.value == null || document.formInput.textAmMfWt.value == ""){
								alert("Merchant fee : amount requiered");
								return false;
							 }
							 if(document.formInput.textAmMfWt.value != null || document.formInput.textAmMfWt.value != ""){
								if(isNaN(document.formInput.textAmMfWt.value)){
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
				var checkStatus = confirm('Are you sure want to edit this data?');
				if (checkStatus){
					return true;
				}else{
					return false;
				}
			}
		
		function noDiv() { 
			if (document.getElementById) { 
				document.getElementById('divCustomerFee').style.visibility = 'hidden'; 
				document.getElementById('divCustomerFee').style.display = 'none';
				document.getElementById('divCustomerFeeWithoutTiring').style.visibility = 'visible'; 
				document.getElementById('divCustomerFeeWithoutTiring').style.display = 'block'; 
				//removeAllRows();
			} 
		} 
		function yesDiv() { 
			if (document.getElementById) { 
				document.getElementById('divCustomerFee').style.visibility = 'visible'; 
				document.getElementById('divCustomerFee').style.display = 'block'; 
				document.getElementById('divCustomerFeeWithoutTiring').style.visibility = 'hidden'; 
				document.getElementById('divCustomerFeeWithoutTiring').style.display = 'none'; 
				/* removeAllCustomerFeeWithoutTiring(); */
				
			} 
		}
		
		function noDivMerchantFee() { 
			if (document.getElementById) { 
				document.getElementById('divMerchantFee').style.visibility = 'hidden'; 
				document.getElementById('divMerchantFee').style.display = 'none';
				document.getElementById('divMerchantFeeWithoutTiring').style.visibility = 'visible'; 
				document.getElementById('divMerchantFeeWithoutTiring').style.display = 'block'; 
				//removeAllRows();
			} 
		} 
		function yesDivMerchantFee() { 
			if (document.getElementById) { 
				document.getElementById('divMerchantFee').style.visibility = 'visible'; 
				document.getElementById('divMerchantFee').style.display = 'block'; 
				document.getElementById('divMerchantFeeWithoutTiring').style.visibility = 'hidden'; 
				document.getElementById('divMerchantFeeWithoutTiring').style.display = 'none'; 
			} 
		}
		
		function addRowEdit(type, am, floor, ceil)
		{
		  var tbl = document.getElementById('tblSample');
		  var lastRow = tbl.rows.length;
		  var iteration = lastRow;
		  var row = tbl.insertRow(lastRow);
		  
		  var cellRightType = row.insertCell(0);
		  var el = document.createElement('select');
		  el.name = 'textType';
		  el.id = 'textType';
		  
		  if (type == "0") {
			  el.options[0] = new Option('Fixed', '0', true);
			  el.options[1] = new Option('Percentage', '1');
		  } else {
			  el.options[0] = new Option('Fixed', '0');
			  el.options[1] = new Option('Percentage', '1', true);
		  }
		 el.style.width = "70px";
		  cellRightType.appendChild(el);
		  
		  var cellRightAm = row.insertCell(1);
		  var el = document.createElement('input');
		  el.type = 'text';
		  el.name = 'textAm';
		  el.id = 'textAm';
		  el.value = am;
		  el.size = 5;
		  cellRightAm.appendChild(el);
		  
		  if (floor != "") {
			  var cellRight = row.insertCell(2);
			  var el = document.createElement('input');
			  el.type = 'text';
			  el.name = 'textFloor';
			  el.id = 'textFloor';
			  el.value = floor;
			  el.size = 5;		  
			  cellRight.appendChild(el);
			  
			  var cellRightSel = row.insertCell(3);
			  var el = document.createElement('input');
			  el.type = 'text';
			  el.name = 'textCeiling';
			  el.id = 'textCeiling';
			  el.value = ceil;
			  el.size = 5;
			  cellRightSel.appendChild(el);
		  }
		}
		
		function setSelectedCombo(){			
			var element = document.getElementById("textType");
			alert(element.options.length);
			 for (var i = 0; i < element.options.length; i++) {					
				 alert("elemt Text="+element.options[i].text);
		         if (element.options[i].text == "Percentage") {
			         	element.options[i].selected = true;
			         	return;
			     }
			  }
		}
		
		function setSelectedComboMF(type){
			var element = document.getElementById("textTypeMF");
			 for (var i = 0; i < element.options.length; i++) {
				    if (element.options[i].text == 'Fixed') {
			        	element.options[i].selected = true;
			            return;
			        }
			    }
		}
		
		function addCustomerFeeWithoutTiringEdit(type, am)
		{
		  var tbl = document.getElementById('tblCustomerFeeWithoutTiring');
		  var lastRow = tbl.rows.length;
		  var iteration = lastRow;
		  var row = tbl.insertRow(lastRow);
		  
		  var cellRightType = row.insertCell(0);
		  var el = document.createElement('select');
		  el.name = 'textTypeWT';
		  el.id = 'textTypeWT';
		  if (type == "0") {
			  el.options[0] = new Option('Fixed', '0');
			  el.options[1] = new Option('Percentage', '1');
		  } else {
			  el.options[0] = new Option('Fixed', '0');
			  el.options[1] = new Option('Percentage', '1');
		  }
		  el.style.width = "70px";
		  cellRightType.appendChild(el);
		  
		  var cellRightAm = row.insertCell(1);
		  var el = document.createElement('input');
		  el.type = 'text';
		  el.name = 'textAmWT';
		  el.id = 'textAmWT';
		  el.value = am;
		  el.size = 5;
		  cellRightAm.appendChild(el);
		  
		}
		
		function addRowMerchantFeeEdit(type, am, floor, ceil)
		{
		  var tbl = document.getElementById('tblMerchantFee');
		  var lastRow = tbl.rows.length;
		  var iteration = lastRow;
		  var row = tbl.insertRow(lastRow);
		  
		  var cellRightType = row.insertCell(0);
		  var el = document.createElement('select');
		  el.name = 'textTypeMF';
		  el.id = 'textTypeMF';
		  if (type == "0") {
			  el.options[0] = new Option('Fixed', '0', true);
			  el.options[1] = new Option('Percentage', '1');
		  } else {
			  el.options[0] = new Option('Fixed', '0');
			  el.options[1] = new Option('Percentage', '1', true);
		  }
		  el.style.width = "70px";
		  cellRightType.appendChild(el);
		  
		  var cellRightAm = row.insertCell(1);
		  var el = document.createElement('input');
		  el.type = 'text';
		  el.name = 'textAmMF';
		  el.id = 'textAmMF';
		  el.value = am;
		  el.size = 5;
		  cellRightAm.appendChild(el);
		  
		  var cellRight = row.insertCell(2);
		  var el = document.createElement('input');
		  el.type = 'text';
		  el.name = 'textFloorMF';
		  el.id = 'textFloorMF';
		  el.value = floor;
		  el.size = 5;		  
		  cellRight.appendChild(el);
		  
		  var cellRightSel = row.insertCell(3);
		  var el = document.createElement('input');
		  el.type = 'text';
		  el.name = 'textCeilingMF';
		  el.id = 'textCeilingMF';
		  el.value = ceil;
		  el.size = 5;
		  cellRightSel.appendChild(el);
		  
		}
		
		function addMerchantFeeWithoutTiringEdit(type, am)
		{
		  var tbl = document.getElementById('tblMerchantFeeWithoutTiring');
		  var lastRow = tbl.rows.length;
		  var iteration = lastRow;
		  var row = tbl.insertRow(lastRow);
		  
		  var cellRightType = row.insertCell(0);
		  var el = document.createElement('select');
		  el.name = 'textTypeMfWt';
		  el.id = 'textTypeMfWt';
		  el.options[0] = new Option('Fixed', '0');
		  el.options[1] = new Option('Percentage', '1');
		  if (type == "0") {
			  el.options[0] = new Option('Fixed', '0', true);
			  el.options[1] = new Option('Percentage', '1');
		  } else {
			  el.options[0] = new Option('Fixed', '0');
			  el.options[1] = new Option('Percentage', '1', true);
		  }
		  el.style.width = "70px";
		  cellRightType.appendChild(el);
		  
		  var cellRightAm = row.insertCell(1);
		  var el = document.createElement('input');
		  el.type = 'text';
		  el.name = 'textAmMfWt';
		  el.id = 'textAmMfWt';
		  el.value = am;
		  el.size = 5;
		  cellRightAm.appendChild(el);
		  
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
		
		function addCustomerFeeWithoutTiring()
		{
		  var tbl = document.getElementById('tblCustomerFeeWithoutTiring');
		  var lastRow = tbl.rows.length;
		  var iteration = lastRow;
		  var row = tbl.insertRow(lastRow);
		  
		  var cellRightType = row.insertCell(0);
		  var el = document.createElement('select');
		  el.name = 'textTypeWT';
		  el.id = 'textTypeWT';
		  el.options[0] = new Option('Fixed', '0');
		  el.options[1] = new Option('Percentage', '1');
		  el.style.width = "70px";
		  cellRightType.appendChild(el);
		  
		  var cellRightAm = row.insertCell(1);
		  var el = document.createElement('input');
		  el.type = 'text';
		  el.name = 'textAmWT';
		  el.id = 'textAmWT';
		  el.size = 5;
		  cellRightAm.appendChild(el);
		  
		}
		
		function removeCustomerFeeWithoutTiring()
		{
		  var tbl = document.getElementById('tblCustomerFeeWithoutTiring');
		  var lastRow = tbl.rows.length;
		  //if (lastRow > 1) 
			  tbl.deleteRow(lastRow - 1);
		}
		
		function removeAllCustomerFeeWithoutTiring(){
		    var table = document.getElementById("tblCustomerFeeWithoutTiring");
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
		  //if (lastRow > 1) 
			  tbl.deleteRow(lastRow - 1);
		}
		
		function addMerchantFeeWithoutTiring()
		{
		  var tbl = document.getElementById('tblMerchantFeeWithoutTiring');
		  var lastRow = tbl.rows.length;
		  var iteration = lastRow;
		  var row = tbl.insertRow(lastRow);
		  
		  var cellRightType = row.insertCell(0);
		  var el = document.createElement('select');
		  el.name = 'textTypeMfWt';
		  el.id = 'textTypeMfWt';
		  el.options[0] = new Option('Fixed', '0');
		  el.options[1] = new Option('Percentage', '1');
		  el.style.width = "70px";
		  cellRightType.appendChild(el);
		  
		  var cellRightAm = row.insertCell(1);
		  var el = document.createElement('input');
		  el.type = 'text';
		  el.name = 'textAmMfWt';
		  el.id = 'textAmMfWt';
		  el.size = 5;
		  cellRightAm.appendChild(el);
		  
		}
		
		function removeMerchantFeeWithoutTiring()
		{
		  var tbl = document.getElementById('tblMerchantFeeWithoutTiring');
		  var lastRow = tbl.rows.length;
		  //if (lastRow > 1) 
			  tbl.deleteRow(lastRow - 1);
		}
		
		function removeAllCustomerFeeWithoutTiring(){
		    var table = document.getElementById("tblMerchantFeeWithoutTiring");
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
					String trxType2 = "";
					String msisdn = "";
					String merchantId = "";
					String terminalId = "";
					String alias = "";
					String bearer = "";
					String source = "";
					String status = "";
					String trxDescription = "";
					String custFee = "";

					if (request.getParameter("trx_type") != null){
						trxType = StringEscapeUtils.escapeHtml(request
								.getParameter("trx_type"));
						trxType2 = StringEscapeUtils.escapeHtml(Util.decMy(request
							.getParameter("trxType")).replaceAll(" ", "+"));
					}
					
					if (!trxType.equals(trxType2)) { 
						response.sendRedirect("feeConfigList.jsp");
					}
					
					if(request.getParameter("cust_fee")!=null){
						custFee = request.getParameter("cust_fee");
					}
					String custFeeSplit[] = custFee.split("\\|");
					String amounts = "";
					
					if(custFeeSplit!=null){
						if(!custFeeSplit[0].equals("2")){						
							if (custFeeSplit[0].equals("1")) {
								Double am12 = Double.parseDouble(custFeeSplit[1]) * 100;							
								amounts = String.valueOf(am12.intValue());
							} else {
								amounts = custFeeSplit[1];
							} 
						}
					}
					String mercFee = "";
					if(request.getParameter("merc_fee")!=null){
						mercFee = request.getParameter("merc_fee");
					}
					String mercFeeSplit[] = mercFee.split("\\|");
					String merchantAmounts = "";
					if(mercFeeSplit!=null){
						if(!mercFeeSplit[0].equals("2")){						
							if (mercFeeSplit[0].equals("1")) {
								Double am12 = Double.parseDouble(mercFeeSplit[1]) * 100;							
								merchantAmounts = String.valueOf(am12);
							} else {
								merchantAmounts = mercFeeSplit[1];
							} 
						}
					}
					
					String sourceTemp = StringEscapeUtils.escapeHtml(request
							.getParameter("source"));
					
					String bearerTemp = StringEscapeUtils.escapeHtml(request
							.getParameter("bearer"));
					
					String merchantTemp = StringEscapeUtils.escapeHtml(request
							.getParameter("merchant_id"));
					String merchantValue ="";											
					
					
					
					User user = (User) session.getValue("user");
					Connection conn = null;
					try {
						conn = DbCon.getConnection();
						String q1 = "select * from FEE_CONFIG where TRX_TYPE= ? and source =? and bearer=? and merchant_id =?";
						PreparedStatement st1 = conn.prepareStatement(q1);
						st1.setString(1, trxType);
						st1.setString(2, sourceTemp);
						st1.setString(3, bearerTemp);
						st1.setString(4, merchantTemp);
						ResultSet rs1 = st1.executeQuery();
						if (rs1.next()) {
							source = rs1.getString("SOURCE");
							bearer = rs1.getString("BEARER");
							status = rs1.getString("STATUS");
							//merchantId = rs1.getString("MERCHANT_ID");
							trxDescription = rs1.getString("TRX_DESCRIPTION");
							if(rs1.getString("MERCHANT_ID").contains("|")){
								String merchantArray[] = rs1.getString("MERCHANT_ID").split("\\|");
								merchantValue = merchantArray[0];
							}else{
								merchantValue = rs1.getString("MERCHANT_ID");
							}
						}
						rs1.close();
						
						String q = "select TERMINAL_ID, MSISDN, MERCHANT_ID, DESCRIPTION, KEYTERMINAL, ADDRESS, URL "
								+ ", CHARGE_INFO, IS_LOCKED, ALIAS from READER_TERMINAL where TERMINAL_ID= ?";
						PreparedStatement st = conn.prepareStatement(q);
						st.setString(1, trxType);
						ResultSet rs = st.executeQuery();

						if (rs.next()) {
							msisdn = rs.getString("MSISDN");
							alias = rs.getString("ALIAS");
						}

						rs.close();
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
						if (stat.equals("0")) {
						} else if (stat.equals("1")) {
							out.println("<SCRIPT LANGUAGE=javascript> alert('MSISDN must be fill');</SCRIPT>");
						} else if (stat.equals("2")) {
							out.println("<SCRIPT LANGUAGE=javascript> alert('Reader Terminal Succesfully Created !!');</SCRIPT>");
						} else {
							out.println("<SCRIPT LANGUAGE=javascript> alert('Reader Terminal Failed to create, probably because MSISDN already used');</SCRIPT>");
						}
					}
		%>
		<br>
		<form id="formInput" name="formInput" onsubmit="return validation();"
			method="post" action="feeConfigExecution.jsp">
			<table width="70%" border="0" cellspacing="1" cellpadding="2">
				<tr bgcolor="#CC6633">
					<td colspan="2"><div align="center">
							<font color="#FFFFFF" size="2"
								face="Verdana, Arial, Helvetica, sans-serif"><strong>Update Fee Config </strong> </font>
						</div>
					</td>
				</tr>
				<tr>
					<td><font color="#999999" size="1"
						face="Verdana, Arial, Helvetica, sans-serif"><strong>Transaction
								Type *</strong> </font></td>
					<td>
						<input type="hidden" name="hiddenId" id="hiddenId" value="<%=trxType%>" /> 
						<input type="hidden" name="hiddenSource" id="hiddenId" value="<%=sourceTemp%>" /> 
						<input type="hidden" name="hiddenBearer" id="hiddenId" value="<%=bearerTemp%>" /> 
						<input type="hidden" name="hiddenMerchant" id="hiddenId" value="<%=merchantTemp%>" /> 
						<select id="trxType" name="trxType" onchange="getTextTrxType()">
							<option value="">Select</option>
							<%
								Connection con = null;
										try {
											con = DbCon.getConnection();
											String q = "select distinct(trx_type), trx_description from fee_config order by trx_description";
											PreparedStatement st = con.prepareStatement(q);
											ResultSet rs = st.executeQuery();
											while (rs.next()) {
							%>
							<option value="<%=rs.getString("trx_type")%>"
								<%=(trxType.equals(rs.getString("trx_type")) && trxDescription.equals(rs.getString("trx_description"))) ? "selected"
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
					<input type="hidden" name="trxDescription" id="trxDescription"  value="<%=trxDescription%>"/>
					</td>
				</tr>
				<tr>
					<td><font color="#999999" size="1"
						face="Verdana, Arial, Helvetica, sans-serif"><strong>Source *</strong>
					</font>
					</td>
					<td><select name="source">
						<% if (source.equals("a")) { %>
							<option value="e">Emoney</option>
							<option value="a" selected>Air Time</option>
						<% } else { %>	
							<option value="e" selected>Emoney</option>
							<option value="a">Air Time</option>
						<% } %>	
					</select></td>
				</tr>
				<tr>
					<td><font color="#999999" size="1"
						face="Verdana, Arial, Helvetica, sans-serif"><strong>Bearer *</strong>
					</font>
					</td>
					<td><select name="bearer" style="width: 50px">
						<% if (bearer.equals("all")) { %>
							<option value="all" selected>All</option>
							<option value="sms">SMS</option>
							<option value="ussd">USSD</option>
							<option value="web">Web</option>
						<% } else if (bearer.equals("sms")) { %>	
							<option value="all">All</option>
							<option value="sms" selected>SMS</option>
							<option value="ussd">USSD</option>
							<option value="web">Web</option>
						<% } else if (bearer.equals("ussd")) { %>	
							<option value="all">All</option>
							<option value="sms">SMS</option>
							<option value="ussd" selected>USSD</option>
							<option value="web">Web</option>
						<% } else { %>	
							<option value="all">All</option>
							<option value="sms">SMS</option>
							<option value="ussd">USSD</option>
							<option value="web" selected>Web</option>	
						<% } %>	
					</select></td>
				</tr>				
				<tr>
					<td><font color="#999999" size="1"
						face="Verdana, Arial, Helvetica, sans-serif"><strong>Merchant *</strong>
					</font>
					</td>
					<td><select name='merchant'
						onchange="showState(this.value)">
							<option value="all">Select</option>
							<%
								Connection conMerchant = null;
										try {
											conMerchant = DbCon.getConnection();
											String q = "select m.merchant_id,mi.name from merchant m, merchant_info mi  "+
											" where m.merchant_info_id = mi.merchant_info_id and m.status = 'A' order by name";
											PreparedStatement st = conMerchant.prepareStatement(q);
											ResultSet rs = st.executeQuery();
											while (rs.next()) {
							%>
							<option value="<%=rs.getString("MERCHANT_ID")%>"
								<%=(merchantValue.equals(rs.getString("MERCHANT_ID"))) ? "selected"
									: ""%>> <%=rs.getString("NAME")%></option>
							<%
								}
											rs.close();
										} catch (Exception e) {
											e.printStackTrace();
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
							</select>
						</div></td>
				</tr>
				<!-- customer fee tiring -->
				<tr>
					<td><font color="#999999" size="1"
						face="Verdana, Arial, Helvetica, sans-serif"><strong>Customer Fee *</strong> </font>
					</td>
					<td>
						<font color="#999999" size="1"
						face="Verdana, Arial, Helvetica, sans-serif"><strong>Tiring Type :</strong></font>
					</td>
				</tr>
				<tr>					
					<td>
						<!-- <div id="divTiring" style="visibility: visible; display: none;"> -->
						<font color="#999999" size="1"
							face="Verdana, Arial, Helvetica, sans-serif"><strong></strong></font>
						<!-- </div> -->	
					</td>
					<td>
						<input type="radio" name="feeTiring" id="feeTiring" value="2" onclick="yesDiv();">
							<font color="#999999" size="1"	face="Verdana, Arial, Helvetica, sans-serif"><strong>Yes</strong></font>&nbsp;&nbsp; 
						<input type="radio" name="feeTiring" id="feeTiring" value="1" checked="checked" onclick="noDiv();">
							<font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>No</strong></font>	
						<div id="divCustomerFee" style="visibility: visible; display: none;"
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
									<%
									String type = "";
									String am = "";
									String floor="";
									String ceil="";
									String splitOne[] = custFee.split("\\|");
									if(splitOne != null){
									if (splitOne[0].equals("2")) {					
										String splitTwo[] = splitOne[1].split(":");
										for (int i = 0; i < splitTwo.length; i++) {
											String splitThree[] = splitTwo[i].split(",");					
											type = splitThree[0];
											am = splitThree[1];
											if (splitThree[2] != null) {
												String floor_ceil[] = splitThree[2].split("-");
												floor = floor_ceil[0];
												ceil = floor_ceil[1];	
												Double amPercentage = 0d;
												amPercentage = Double.parseDouble(am) * 100;							
												 
												%>
												<tr>
												<td>
													<select name="textType" style="width: 70px">
														<option value="0" <%=type.equals("0")?"selected" : ""%>>Fixed</option>
														<option value="1" <%=type.equals("1")?"selected" : ""%>>Pecentage</option>
													</select>
												</td>
												<td>
													<input type="text" name="textAm" size="5" value="<%=type.equals("1")?amPercentage.intValue() : am%>">
												</td>
												<td>
													<input type="text" name="textFloor" size="5" value="<%=floor%>">
												</td>
												<td>
													<input type="text" name="textCeiling" size="5" value="<%=ceil%>">
												</td>
												</tr>
												<%
											} 			
										}  
									}
									}
									 %>							
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
										<%if(custFeeSplit[0].equals("0")){ %>
											<option value="0" selected>Fixed</option>
											<option value="1">Pecentage</option>
										<%}else if(custFeeSplit[0].equals("1")){ %>
											<option value="0">Fixed</option>
											<option value="1" selected>Pecentage</option>
										<%}else{ %>
											<option value="0" selected>Fixed</option>
											<option value="1">Pecentage</option>
										<%} %>
										</select>
									</td>
									<td><input type="text" name="textAmWT" size="5" value="<%=amounts%>"></td>
								</tr>
									
							</table>
						</div> 
					</td>					
				</tr>				
				<!-- end customer fee tiring -->
				
				<!-- merchant fee tiring -->
				<tr>
					<td><font color="#999999" size="1"
						face="Verdana, Arial, Helvetica, sans-serif"><strong>Merchant Fee*</strong> </font>
					</td>
					<td>
						<font color="#999999" size="1"
						face="Verdana, Arial, Helvetica, sans-serif"><strong>Tiring Type :</strong></font>
					</td>
				</tr>
				<tr>					
					<td>
					<!-- <div id="divMerchantFee" style="visibility: visible; display: none"> -->
						<font color="#999999" size="1"
						face="Verdana, Arial, Helvetica, sans-serif"><strong></strong></font>
					<!-- </div>	 -->
					</td>
					<td>
						<input type="radio" name="merchantFeeTiring" id="merchantFeeTiring" value="2" onclick="yesDivMerchantFee();">
							<font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Yes</strong></font>&nbsp;&nbsp; 
						<input type="radio" name="merchantFeeTiring" id="merchantFeeTiring" value="1"	checked onclick="noDivMerchantFee();">
							<font color="#999999" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>No</strong></font>
						<div id="divMerchantFee" style="visibility: visible; display: none"
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
								<%
									String typeMF = "";
									String amMF = "";
									String floorMF ="";
									String ceilMF ="";
									String splitOneMF[] = mercFee.split("\\|");
									if(splitOneMF != null){
									if (splitOneMF[0].equals("2")) {					
										String splitTwoMF[] = splitOneMF[1].split(":");
										for (int i = 0; i < splitTwoMF.length; i++) {
											String splitThreeMF[] = splitTwoMF[i].split(",");					
											typeMF = splitThreeMF[0];
											amMF = splitThreeMF[1];
											if (splitThreeMF[2] != null) {
												String floorCeilMF[] = splitThreeMF[2].split("-");
												floorMF = floorCeilMF[0];
												ceilMF = floorCeilMF[1];	
												Double amPercentageMF = 0d;
													amPercentageMF = Double.parseDouble(amMF) * 100;							
												 
												%>
												<tr>
												<td>
													<select name="textTypeMF" style="width: 70px">
														<option value="0" <%=typeMF.equals("0")?"selected" : ""%>>Fixed</option>
														<option value="1" <%=typeMF.equals("1")?"selected" : ""%>>Pecentage</option>
													</select>
												</td>
												<td>
													<input type="text" name="textAmMF" size="5" value="<%=typeMF.equals("1")?amPercentageMF.intValue() : amMF%>">
												</td>
												<td>
													<input type="text" name="textFloorMF" size="5" value="<%=floorMF%>">
												</td>
												<td>
													<input type="text" name="textCeilingMF" size="5" value="<%=ceilMF%>">
												</td>
												</tr>
												<%
											} 			
										}  
									}
									}
									 %>	
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
										<%if(mercFeeSplit[0].equals("0")){ %>
											<option value="0" selected>Fixed</option>
											<option value="1">Pecentage</option>
										<%}else if(mercFeeSplit[0].equals("1")){ %>
											<option value="0">Fixed</option>
											<option value="1" selected>Pecentage</option>
										<%}else{ %>
											<option value="0" selected>Fixed</option>
											<option value="1">Pecentage</option>
										<%} %>
										</select>
										
									</td>
									<td><input type="text" name="textAmMfWt" size="5" value="<%=merchantAmounts%>"></td>
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
					<td><select name="status" style="width: 80px">
						<% if (status.equals("a")) { %>
							<option value="a" selected>Active</option>
							<option value="n">Not Active</option>
						<% } else { %>	
							<option value="a">Active</option>
							<option value="n" selected>Not Active</option>
						<% } %>								
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
