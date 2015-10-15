<%@ include file="/web-starter/taglibs.jsp" %>
<jsp:useBean id='today' class='java.util.Date'/>
<%
	String myID = request.getParameter("id");
	if (myID == null) {
		myID = "";
	}
%>
<stripes:layout-render name="/web-starter/layout/standard.jsp" title="Dashboard">
    <stripes:layout-component name="contents">
        <stripes:form action="/smscrew/crew/SendSMS.action">
            <stripes:errors/>
			
	            <c:out value="${result}"></c:out>
        </stripes:form>
    </stripes:layout-component>
</stripes:layout-render>
<c:remove var="result"/>
