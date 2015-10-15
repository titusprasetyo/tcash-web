<%@ include file="/web-starter/taglibs.jsp" %>
<jsp:useBean id='today' class='java.util.Date'/>
<stripes:layout-render name="/web-starter/layout/standard.jsp" title="Ftp Refund View">
    <stripes:layout-component name="contents">
        <stripes:form action="/refunder/FtpRefundView.action">
            <stripes:errors/>
			<table class="leftRightForm">
	            <tr>
                    <th><stripes:label for="SingleRefund.Date"/>:</th>
                    <td><stripes:text name="date" formatType="date" formatPattern="yyyy-MM-dd" value="${date != null ? date : today}"/></td>
                </tr>
            </table>
            <div class="buttons">
                <stripes:submit name="view" value="View"/>
            </div>
            <c:if test="${generateResult == 1}">
	            <table class="display">
	                <tr>
	                    <th>Source File</th>
	                    <th>Execution Status</th>
	                    <th>Entry Time</th>
	                    <th>Execution Time</th>
	                    <th>Operator</th>
	                </tr>
	                <c:forEach items="${data}" var="d" varStatus="rowstat">
	                    <tr class="${rowstat.count mod 2 == 0 ? "even" : "odd"}">
	                        <td>
	                        	${d.sourceFile}
	                        </td>
	                        <td>
	                        	${(d.executed == true) ? "processed" : "-" }
	                        </td>
	                        <td><fmt:formatDate value="${d.entryTime}" pattern='yyyy-MM-dd HH:mm:ss'/></td>
	                        <td><fmt:formatDate value="${d.executionTime}" pattern='yyyy-MM-dd HH:mm:ss'/></td>
							<td>${d.operator}</td>
	                    </tr>
	                </c:forEach>
	            </table>
	        </c:if>
        </stripes:form>
    </stripes:layout-component>
</stripes:layout-render>
<c:remove var="data"/>
<c:remove var="generateResult"/>