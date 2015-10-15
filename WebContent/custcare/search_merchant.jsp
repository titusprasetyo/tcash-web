<%@ page import="java.sql.*"%>
<jsp:useBean id="DbCon" scope="page" class="tsel_tunai.DbCon"></jsp:useBean>
<%@ include file="/web-starter/taglibs.jsp" %>
<%@page import="com.telkomsel.itvas.webstarter.User"%>
<stripes:layout-render name="/web-starter/layout/standard.jsp" title="Search Merchant">
    <stripes:layout-component name="contents">
<link rel="stylesheet" href="my.css" type="text/css">
<table width="60%" border="0" cellspacing="3" cellpadding="3">
  <form name="form" method="post" action="search_merchant2.jsp">
    <tr> 
      <td class="unnamed1" width="20%">Merchant name</td>
      <td width="80%" class="unnamed1"> 
        <input name="name" type="text" size="20" class="box_text">
      </td>
    </tr>
    <tr> 
      <td class="unnamed1" width="20%">&nbsp;</td>
      <td class="unnamed1" width="80%"> 
        <input type="submit" name="Submit" value="   Submit     " class="box_text">
      </td>
    </tr>
  </form>
</table>
    </stripes:layout-component>
</stripes:layout-render>
