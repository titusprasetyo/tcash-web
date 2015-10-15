<%@ include file="/web-starter/taglibs.jsp" %>
<jsp:useBean id='today' class='java.util.Date'/>
<stripes:layout-render name="/web-starter/layout/standard.jsp" title="System Configuration">
    <stripes:layout-component name="contents">
        <stripes:form action="/smscrew/system/Configuration.action">
            <stripes:errors/>
 			<table class="display">
	                <tr>
	                    <th>Config</th>
	                    <th>Description</th>
	                    <th>Value</th>
	                </tr>
	                <c:forEach items="${data}" var="d" varStatus="rowstat">
		                <tr class="${rowstat.count mod 2 == 0 ? "even" : "odd"}">
		                    <td>${d.config}</td>
		                    <td>${d.description}</td>
		                    <td><stripes:text value="${d.value}" name="configs[${rowstat.index}].value"/></td>
		                    <td><stripes:hidden value="${d.config}" name="configs[${rowstat.index}].config"/></td>
		                </tr>
	                </c:forEach>
	            </table>
            <div class="buttons">
                <stripes:submit name="view" value="Save Configuration"/>
            </div>
        </stripes:form>
        <strong><c:out value="${msgResult}"></c:out></strong>
    </stripes:layout-component>
</stripes:layout-render>
<c:remove var="data"/>
<c:remove var="generateResult"/>
<c:remove var="msgResult"/>
