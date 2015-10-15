<%@ include file="/web-starter/taglibs.jsp" %>
<jsp:useBean id='today' class='java.util.Date'/>
<stripes:layout-render name="/web-starter/layout/standard.jsp" title="View Uploaded Files">
    <stripes:layout-component name="contents">
        <stripes:form action="/refunder/SingleRefundView.action">
            <stripes:errors/>
			<table class="leftRightForm">
	            <tr>
                    <th>Tanggal Awal:</th>
                    <td><stripes:text value="02-01-2008" name="tanggalAwal"/></td>
                </tr>
	            <tr>
                    <th>Tanggal Akhir:</th>
                    <td><stripes:text value="12-01-2008" name="tanggalAkhir"/></td>
                </tr>
            </table>
            <div class="buttons">
                <stripes:submit name="view" value="View"/>
            </div>
	            <table class="display">
	                <tr>
	                    <th>Nama File</th>
	                    <th>Tipe File</th>
	                    <th>Waktu Upload</th>
	                    <th>Telah diekesekusi?</th>
	                    <th>Operator</th>
	                </tr>
					<tr class="even">
	                    <td>PUB1212.txt</td>
	                    <td>Publish Schedule</td>
	                    <td>03-01-2008 13:14:14</td>
	                    <td>Ya</td>
	                    <td>Budi</td>
	                </tr>
	                <tr class="odd">
	                    <td>PUB1232.txt</td>
	                    <td>Publish Schedule</td>
	                    <td>04-01-2008 13:14:14</td>
	                    <td>Ya</td>
	                    <td>Budi</td>
	                </tr>
	                <tr class="even">
	                    <td>REV99922.txt</td>
	                    <td>Revise Schedule</td>
	                    <td>07-01-2008 11:28:07</td>
	                    <td>Ya</td>
	                    <td>Budi</td>
	                </tr>
	                <tr class="odd">
	                    <td>FRE133232.txt</td>
	                    <td>Free Message</td>
	                    <td>10-01-2008 03:12:14</td>
	                    <td>Ya</td>
	                    <td>Budi</td>
	                </tr>
	            </table>
        </stripes:form>
    </stripes:layout-component>
</stripes:layout-render>
<c:remove var="data"/>
<c:remove var="generateResult"/>
