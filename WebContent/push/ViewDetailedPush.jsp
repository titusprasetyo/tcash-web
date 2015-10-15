<%@ include file="/web-starter/taglibs.jsp" %>
<jsp:useBean id='today' class='java.util.Date'/>
<stripes:layout-render name="/web-starter/layout/standard.jsp" title="View Detailed Push SMS">
	<strong><c:out value="${message}"/></strong>
    <stripes:layout-component name="contents">
	            <table class="display">
	                <tr>
	                    <th>Part No.</th>
	                    <th>MSISDN</th>
	                    <th>Message</th>
	                    <th>Sent Time</th>
	                    <th>Retry Count</th>
	                    <th>Is Delivered?</th>
	                    <th>Delivery Code</th>
	                    <th>Delivery Time</th>
						<th>Action</th>	                    
	                </tr>
	                <c:forEach items="${data}" var="d" varStatus="rowstat">
		                <tr class="${d.deliveryCode != 1 ? (rowstat.count mod 2 == 0 ? "even" : "odd"): "warn"}">
		                    <td>${d.part_id}</td>
		                    <td>${d.msisdn}</td>
		                    <td>${d.message}</td>
		                    <td>${d.sent_time}</td>
		                    <td>${d.retry_count}</td>
		                    <td>${d.delivered == 1 ? "Yes" : "No"}</td>
		                    <td>${d.delivery_code}</td>
		                    <td>${d.delivery_time}</td>
		                    <td><stripes:link href="/smscrew/push/ViewDetailed.action?id=${d.single_sms_id}&resend_id=${d.id}">resend</stripes:link></td>
		                </tr>
	                </c:forEach>
	            </table>
    </stripes:layout-component>
</stripes:layout-render>
<c:remove var="data"/>
<c:remove var="message"/>
<c:remove var="generateResult"/>
