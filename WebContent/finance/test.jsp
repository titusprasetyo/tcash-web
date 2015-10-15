<%@ include file="/web-starter/taglibs.jsp"%>
<%@page import="com.telkomsel.itvas.webstarter.User"%>

<stripes:layout-render name="/web-starter/layout/standard.jsp" title="Cashout Approval">
        <stripes:layout-component name="contents">
<%
String s = (String) session.getAttribute("names");
out.print(s);
%>
        </stripes:layout-component>
</stripes:layout-render>
