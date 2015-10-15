<%@ include file="/web-starter/taglibs.jsp" %>
<stripes:layout-definition>
<html>
<head>
<title>T-Cash Web Interface :: ${title}</title>
<link rel="stylesheet"
                  type="text/css"
                  href="${pageContext.request.contextPath}/STATIC/bugzooky.css"/>
            <script type="text/javascript"
                    src="${pageContext.request.contextPath}/STATIC/bugzooky.js"></script>
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
</script>
<style>
.link {
color : #CC6633;
text-decoration : none;
}

.link1 {
color : #CC6633;
text-decoration : underline;
}
</style>
</head>
<body>
<div align="center">
  <p>&nbsp;</p>

  

  <table width="100%" border="1" cellspacing="0" cellpadding="0" bordercolor="#CC6633">
  
   <tr> 
      <td width="19%" bgcolor="#CC6633"> <div align="center"><font color="#CC6633" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong><a href="logout.jsp" class="link"><font color="#FFFFFF" size="2">MENU</font></a></strong></font></div></td>
	  <td width="81%" bgcolor="#CC6633">
	  	<div align="right"> <font color="#CC6633" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong><font color="#FFFFFF" size="2">TCash Web Interface :: ${title}</font></strong></font><font color="#FFFFFF" face="Verdana, Arial, Helvetica, sans-serif"><strong>
          </strong></font></div>
	  </td>

    </tr>
    <tr> 
      <td valign="top">
      <br><br>
<stripes:layout-component name="menu">
	<jsp:include page="/web-starter/layout/menu.jsp"/>
</stripes:layout-component>
</td>
	  <td height="110" align="center" valign="top" background="${pageContext.request.contextPath}/STATIC/Liquisoft2.jpg">
	  <br/><br/>
             <stripes:messages/>
             <br/><br/>
             <stripes:layout-component name="contents"/>
	<br/><br/>
      </td>
    </tr>
    <tr> 
      <td  valign="top" bgcolor="#CC6633"> <div align="right"></div></td>
		  <td  valign="top" bgcolor="#CC6633"> <div align="right"><font color="#FFFFFF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>IT 
          VAS Development 2008 - Powered by Stripes Framework</strong></font></div></td>
    </tr>
  </table>
  </div>
</body>
</html>
</stripes:layout-definition>


