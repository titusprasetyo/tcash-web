<%@ include file="/web-starter/taglibs.jsp" %>
<jsp:useBean id='today' class='java.util.Date'/>
<stripes:layout-render name="/web-starter/layout/standard.jsp" title="View Push SMS Monthly Report">
    <stripes:layout-component name="contents">
        <stripes:form action="/refunder/SingleRefundView.action">
            <stripes:errors/>
			<table class="leftRightForm">
	            <tr>
                    <th>Bulan:</th>
                    <td>
                    	<select name="bulan">
                    		<option value="1">Januari</option>
                    	</select>
                    </td>
                </tr>
	            <tr>
                    <th>Tahun:</th>
                    <td><stripes:text value="2008" name="tahun"/></td>
                </tr>
			</table>
            <div class="buttons">
                <stripes:submit name="view" value="Lihat Report"/>
            </div>
	        <br/>
	        <br/>
	        <hr/>
	        <br/>
	        <br/>
	        <h2>Report Januari 2008</h2>
	        <br/><br/>
	        <table class="leftRightForm">
		        <tr>
                    <th>Jumlah File Upload:</th>
                    <td>Publish = 56, Revise = 11, Free Message = 44</td>
                </tr>
	            <tr>
                    <th>Total SMS Push:</th>
                    <td>342.122</td>
                </tr>
	            <tr>
                    <th>Total SMS Pull:</th>
                    <td>674</td>
                </tr>
                <tr>
                    <th>SMS / hari</th>
                    <td>11.057</td>
                </tr>
                <tr>
                    <th>SMS terbanyak / hari</th>
                    <td>23.051 (11 Januari 2008)</td>
                </tr>
            </table>
        </stripes:form>
    </stripes:layout-component>
</stripes:layout-render>
<c:remove var="data"/>
<c:remove var="generateResult"/>
