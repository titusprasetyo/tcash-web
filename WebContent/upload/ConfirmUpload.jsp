<%@ include file="/web-starter/taglibs.jsp" %>

<stripes:layout-render name="/web-starter/layout/standard.jsp" title="Konfirmasi Upload File">
    <stripes:layout-component name="contents">
        <stripes:errors action="/smscrew/Publish.action"/>
        <stripes:form action="/smscrew/Publish.action">
            <table class="leftRightForm">
	            <tr>
                    <th><stripes:label for="General.FileName"/>:</th>
                    <td>PUB001.txt</td>
                </tr>
                <tr>
                    <th><stripes:label for="General.FileType"/>:</th>
                    <td>Publish Schedule</td>
                </tr>
                <tr>
                    <th>Size:</th>
                    <td>345.112 bytes</td>
                </tr>
                <tr>
                    <th>Jumlah Data:</th>
                    <td>1.121 data</td>
                </tr>
            </table>
            <br>
            Apakah anda mengkonfirmasi data yang akan di upload ini?
            <br>
            <div class="buttons">
                <stripes:submit name="doRefund" value="Konfirmasi Upload"/>
            </div>
        </stripes:form>
    </stripes:layout-component>
</stripes:layout-render>