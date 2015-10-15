<%@ include file="/web-starter/taglibs.jsp" %>
<jsp:useBean id="refundType" scope="page"
                     class="com.telkomsel.itvas.refunder.RefundType"/>
                     
<stripes:layout-render name="/web-starter/layout/standard.jsp" title="Single Refund">
    <stripes:layout-component name="contents">
        <stripes:errors action="/refunder/SingleRefund.action"/>
        <stripes:form action="/refunder/SingleRefund.action" focus="msisdn">
            <table class="leftRightForm">
	            <tr>
                    <th><stripes:label for="SingleRefund.msisdn"/>:</th>
                    <td><stripes:text name="msisdn" /></td>
                </tr>
                <tr>
                    <th><stripes:label for="SingleRefund.value"/> (max Rp 1.000.000) :</th>
                    <td><stripes:text name="value" /></td>
                </tr>
                <tr>
                    <th><stripes:label for="SingleRefund.refundType"/>:</th>
                    <td>
                    <stripes:select name="type">
						<stripes:options-collection collection="${refundType.allRefundTypes}"
							label="label" value="id"/>
					</stripes:select>
                    </td>
                </tr>
                <tr>
                    <th><stripes:label for="SingleRefund.reason"/>:</th>
                    <td><stripes:text name="reason" /></td>
                </tr>
            </table>
            <div class="buttons">
                <stripes:submit name="doRefund" value="Execute Refund"/>
            </div>
        </stripes:form>
    </stripes:layout-component>
</stripes:layout-render>