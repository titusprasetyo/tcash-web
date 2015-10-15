<%@ include file="/web-starter/taglibs.jsp" %>
<jsp:useBean id='today' class='java.util.Date'/>
<%
	String myID = request.getParameter("id");
	if (myID == null) {
		myID = "";
	}
%>
<stripes:layout-render name="/web-starter/layout/standard.jsp" title="Send Mass SMS">
    <stripes:layout-component name="contents">
        <stripes:form action="/smscrew/push/SendMassSMS.action">
            <stripes:errors/>
			<table class="leftRightForm">
				<tr>
                    <th>Type:</th>
                    <td>
                    <stripes:select name="massType">
						<stripes:option value="1">All Crew</stripes:option>
					</stripes:select>
					</td>
                </tr>
                <tr>
                    <th>Message:</th>
                    <td><stripes:text value="" name="message" size="100" maxlength="1500"/></td>
                </tr>
            </table>
            <div class="buttons">
                <stripes:submit name="view" value="Send"/>
            </div>
	            <c:out value="${result}"></c:out>
        </stripes:form>
    </stripes:layout-component>
</stripes:layout-render>
<c:remove var="result"/>
