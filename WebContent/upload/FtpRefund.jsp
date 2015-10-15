<%@ include file="/web-starter/taglibs.jsp" %>

<stripes:layout-render name="/web-starter/layout/standard.jsp" title="FTP Refund">
    <stripes:layout-component name="contents">
        <stripes:errors action="/refunder/FtpRefund.action"/>
        <stripes:form action="/refunder/FtpRefund.action">
            <table class="leftRightForm">
                <tr>
                    <th><stripes:label for="FTPRefund.name"/>:</th>
                    <td><stripes:text name="ftpFilename" /></td>
                </tr>
            </table>
            <div class="buttons">
                <stripes:submit name="doRefund" value="Execute Refund"/>
            </div>
        </stripes:form>
    </stripes:layout-component>
</stripes:layout-render>