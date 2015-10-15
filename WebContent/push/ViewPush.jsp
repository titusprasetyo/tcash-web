<%@ include file="/web-starter/taglibs.jsp" %>
<jsp:useBean id='today' class='java.util.Date'/>
<jsp:useBean id='enumFleet' class='com.telkomsel.itvas.garudasmscrew.enumeration.Fleet'/>
<jsp:useBean id='enumCategory' class='com.telkomsel.itvas.garudasmscrew.enumeration.Category'/>
<stripes:layout-render name="/web-starter/layout/standard.jsp" title="View Push SMS">
    <stripes:layout-component name="contents">
        <stripes:form action="/smscrew/push/ViewPush.action">
            <stripes:errors/>
			<table class="leftRightForm">
				<tr>
                    <th>ID Crew:</th>
                    <td><stripes:text value="" name="idCrew"/></td>
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
                    <th>Tipe Push SMS:</th>
                    <td>
                    	<select name="pushType">
                    		<option value="-1" ${npushType == -1 ? "selected" : ""}>All Types</option>
                    		<option value="0" ${npushType == 0 ? "selected" : ""}>Publish Schedule</option>
                    		<option value="1" ${npushType == 1? "selected" : ""}>Revise Schedule</option>
                    		<option value="2" ${npushType == 2? "selected" : ""}>Family Reason</option>
                    		<option value="3" ${npushType == 3? "selected" : ""}>Free Message</option>
                    		<option value="4" ${npushType == 4? "selected" : ""}>ETD</option>
                    		<option value="5" ${npushType == 5? "selected" : ""}>Pull Response PUB</option>
                    		<option value="6" ${npushType == 6? "selected" : ""}>Pull Response SCH</option>
                    		<option value="7" ${npushType == 7? "selected" : ""}>Pull Response CKI</option>
                    		<option value="8" ${npushType == 8? "selected" : ""}>Pull Response CPP</option>
                    		<option value="9" ${npushType == 9? "selected" : ""}>Pull Response FAT</option>
                    		<option value="10" ${npushType == 10? "selected" : ""}>Pull Response MISC</option>
                    	</select>
                    </td>
                </tr>
                <tr>
                    <th>Delivery Status:</th>
                    <td>
                    	<select name="delivered">
                    		<option value="-1" ${ndelivered == -1? "selected" : ""}>All Status</option>
                    		<option value="0" ${ndelivered == 0? "selected" : ""}>Not Delivered Yet</option>
                    		<option value="1" ${ndelivered == 1? "selected" : ""}>Delivered</option>
                    		<option value="2" ${ndelivered == 2? "selected" : ""}>Not Send Because Incorrect Crew Data</option>
                    	</select>
                    </td>
                </tr>
                <tr>
                    <th>Crew Type:</th>
                    <td>
                    	<stripes:select name="crewType">
                    		<stripes:option value="-1">All</stripes:option>
                    		<stripes:options-enumeration enum="com.telkomsel.itvas.garudasmscrew.enumeration.CrewType" />
                    	</stripes:select>
                    </td>
                </tr>
                <tr>
                    <th>Fleet:</th>
                    <td>
                    	<stripes:select name="fleet">
                    		<stripes:option value="-1">All</stripes:option>
                    		<stripes:options-collection collection="${enumFleet.enumeration}" label="label" value="value" />
                    	</stripes:select>
                    </td>
                </tr>
                <tr>
                    <th>Category:</th>
                    <td>
                    	<stripes:select name="category">
                    		<stripes:option value="-1">All</stripes:option>
                    		<stripes:options-collection collection="${enumCategory.enumeration}" label="label" value="value" />
                    	</stripes:select>
                    </td>
                </tr>
                <tr>
                    <th>Data Ordering By:</th>
                    <td>
                    	<select name="orderBy">
                    		<option value="1" ${norderBy == 1? "selected" : ""}>Timestamp (ASC)</option>
                    		<option value="2" ${norderBy == 2? "selected" : ""}>Timestamp (DESC)</option>
                    		<option value="3" ${norderBy == 3? "selected" : ""}>ID Crew (ASC)</option>
                    		<option value="4" ${norderBy == 4? "selected" : ""}>ID Crew (DESC)</option>
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
	                    <th>ID Crew</th>
	                    <th>Push Type</th>
	                    <th>Message</th>
	                    <th>Nb. Part</th>
	                    <th>Nb. Part Delivered</th>
	                    <th>Delivery Status</th>
	                    <th>Notes</th>
	                    <th>Detailed</th>
	                </tr>
	                <c:forEach items="${data}" var="d" varStatus="rowstat">
		                <tr class="${d.deliveryCode != "2" ? (d.deliveryCode != 0 ? (rowstat.count mod 2 == 0 ? "even" : "odd"): "warn")  : "error"}">
		                    <td>${d.ts}</td>
		                    <td><stripes:link href="/smscrew/crew/ViewCrew.action?id=${d.id_crew}">${d.id_crew}</stripes:link></td>
		                    <td>${d.push_type}</td>
		                    <td>${d.message}</td>
		                    <td>${d.nb_part == -1 ? "-" : d.nb_part}</td>
		                    <td>${d.nb_delivered}</td>
		                    <td>${d.delivered}</td>
		                    <td>${d.notes}</td>
		                    <td><stripes:link href="/smscrew/push/ViewDetailed.action?id=${d.id}">detail</stripes:link></td>
		                </tr>
	                </c:forEach>
	            </table>
        </stripes:form>
    </stripes:layout-component>
</stripes:layout-render>
<c:remove var="data"/>
<c:remove var="generateResult"/>
