<%@ page import="java.sql.*"%>
<jsp:useBean id="DbCon" scope="page" class="tsel_tunai.DbCon"></jsp:useBean>
<%@ include file="/web-starter/taglibs.jsp" %>
<%@page import="com.telkomsel.itvas.webstarter.User"%>
<stripes:layout-render name="/web-starter/layout/standard.jsp" title="Create Ticket">
    <stripes:layout-component name="contents">
<link rel="stylesheet" href="my.css" type="text/css">
<table width="60%" border="0" cellspacing="3" cellpadding="3">
  <form name="form" method="post" action="ticket_create2.jsp">
    <tr> 
      <td class="unnamed1" width="28%">Msisdn</td>
      <td width="72%" class="unnamed1"> 
        <input name="msisdn" type="text" size="20" class="box_text" value="">
      </td>
    </tr>
    <tr> 
      <td class="unnamed1" width="28%">Rfid card number</td>
      <td width="72%" class="unnamed1"> 
        <input name="card_num" type="text" size="30" class="box_text">
      </td>
    </tr>
    <tr> 
      <td width="28%" class="unnamed1">Name</td>
      <td width="72%" class="unnamed1"> 
        <input name="name" type="text" size="50" class="box_text">
      </td>
    </tr>
    <tr> 
      <td class="unnamed1" width="28%">Problem</td>
      <td width="72%" class="unnamed1"> 
        <textarea name="problem" cols="45" class="box_text"></textarea>
      </td>
    </tr>
    <tr> 
      <td width="28%" class="unnamed1">Priority</td>
      <td width="72%" class="unnamed1"> 
        <select name="priority" class="box_text">
          <option value="high">High</option>
          <option value="medium" selected>Medium</option>
          <option value="low">Low</option>
        </select>
      </td>
    </tr>
    <tr> 
      <td class="unnamed1" width="28%">&nbsp;</td>
      <td class="unnamed1" width="72%"> 
        <input type="submit" name="Submit" value="   Submit    " class="box_text">
      </td>
    </tr>
  </form>
</table>
    </stripes:layout-component>
</stripes:layout-render>

