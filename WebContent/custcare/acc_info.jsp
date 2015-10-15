<%@ page import="java.sql.*"%>
<%@ include file="/web-starter/taglibs.jsp" %>
<%@page import="com.telkomsel.itvas.webstarter.User"%>
<stripes:layout-render name="/web-starter/layout/standard.jsp" title="Account Info">
	<stripes:layout-component name="contents">
		<table width="60%" border="0" cellspacing="3" cellpadding="3">
		<form name="form" method="post" action="acc_info2.jsp">
			<tr> 
				<td class="unnamed1" width="20%">MSISDN</td>
				<td class="unnamed1" width="80%"><input type="text" name="msisdn" size="20" class="box_text" value=""></td>
			</tr>
			<tr> 
				<td class="unnamed1" width="20%">&nbsp;</td>
				<td class="unnamed1" width="80%"><input type="submit" name="Submit" class="box_text" value="   Submit   " ></td>
			</tr>
		</form>
		</table>
	</stripes:layout-component>
</stripes:layout-render>
