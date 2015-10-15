<%@ include file="/web-starter/taglibs.jsp" %>
<jsp:useBean id='today' class='java.util.Date'/>
<stripes:layout-render name="/web-starter/layout/standard.jsp" title="View Uploaded FTP Files">
    <stripes:layout-component name="contents">
        <stripes:form action="/smscrew/FtpFiles.action">
            <stripes:errors/>
			<table class="leftRightForm">
				<tr>
                    <th>Filename:</th>
                    <td><stripes:text value="" name="filename"/></td>
                </tr>
	            <tr>
                    <th>Tanggal Awal:</th>
                    <td><stripes:text formatType="date" formatPattern="dd-MM-yyyy" value="${date != null ? date : today}" name="startDate"/></td>
                    
                </tr>
	            <tr>
                    <th>Tanggal Akhir:</th>
                    <td><stripes:text formatType="date" formatPattern="dd-MM-yyyy" value="${date != null ? date : today}" name="endDate"/></td>
                </tr>
                <tr>
                    <th>Data Ordering By:</th>
                    <td>
                    	<select name="orderBy">
                    		<option value="1" ${norderBy == 1? "selected" : ""}>Timestamp (ASC)</option>
                    		<option value="2" ${norderBy == 2? "selected" : ""}>Timestamp (DESC)</option>
                    		<option value="3" ${norderBy == 3? "selected" : ""}>Filename (ASC)</option>
                    		<option value="4" ${norderBy == 4? "selected" : ""}>Filename (DESC)</option>
                    	</select>
                    </td>
                </tr>
            </table>
            <div class="buttons">
                <stripes:submit name="view" value="View"/>
            </div>
	            <table class="display">
	                <tr>
	                    <th>TS</th>
	                    <th>Filename</th>
	                </tr>
	                <c:forEach items="${data}" var="d" varStatus="rowstat">
		                <tr class="${rowstat.count mod 2 == 0 ? "even" : "odd"}">
		                    <td>${d.ts}</td>
		                    <td>${d.filename}</td>
		                </tr>
	                </c:forEach>
	            </table>
        </stripes:form>
    </stripes:layout-component>
</stripes:layout-render>
<c:remove var="data"/>
<c:remove var="generateResult"/>
