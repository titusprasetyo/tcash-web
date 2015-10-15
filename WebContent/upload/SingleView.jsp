<%@ include file="/web-starter/taglibs.jsp" %>
<jsp:useBean id='today' class='java.util.Date'/>
<stripes:layout-render name="/web-starter/layout/standard.jsp" title="Single Refund View">
    <stripes:layout-component name="contents">
        <stripes:form action="/refunder/SingleRefundView.action">
            <stripes:errors/>
			<table class="leftRightForm">
	            <tr>
                    <th><stripes:label for="SingleRefund.msisdn"/>:</th>
                    <td><stripes:text value="${msisdn != null ? msisdn : ''}" name="msisdn"/></td>
                </tr>
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
	                    <th>MSISDN</th>
	                    <th>Refund Value</th>
	                    <th>Refund Type</th>
	                    <th>Execution Time</th>
	                    <th>Trx ID</th>
	                    <th>Original Balance</th>
	                    <th>Added Balance</th>
	                    <th>Status</th>
	                    <th>Description</th>
	                    <th>Operator</th>
	                    <th>IP</th>
	                    <th>Reason</th>
	                </tr>
	                <c:forEach items="${data}" var="d" varStatus="rowstat">
	                    <tr class="${d.status == "2" ? (rowstat.count mod 2 == 0 ? "even" : "odd") : "error"}">
	                        <td>${d.msisdn}</td>
							<td>${d.value}</td>
							<td>${d.refundType}</td>
							<td><fmt:formatDate value="${d.executionTime}" pattern='yyyy-MM-dd HH:mm:ss'/></td>
							<td>${d.transactionId}</td>
							<td>${d.originalBalance}</td>
							<td>${d.addedBalance}</td>
							<td>${d.status}</td>
							<td>${d.strStatus}</td>
							<td>${d.operator}</td>
							<td>${d.ip}</td>
							<td>${d.reason}</td>
	                    </tr>
	                </c:forEach>
	            </table>
	        </c:if>
        </stripes:form>
    </stripes:layout-component>
</stripes:layout-render>
<c:remove var="data"/>
<c:remove var="generateResult"/>
