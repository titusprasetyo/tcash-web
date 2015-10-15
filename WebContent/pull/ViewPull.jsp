<%@ include file="/web-starter/taglibs.jsp" %>
<jsp:useBean id='today' class='java.util.Date'/>
<jsp:useBean id='enumFleet' class='com.telkomsel.itvas.garudasmscrew.enumeration.Fleet'/>
<jsp:useBean id='enumCategory' class='com.telkomsel.itvas.garudasmscrew.enumeration.Category'/>
<jsp:useBean id='enumPull' class='com.telkomsel.itvas.garudasmscrew.enumeration.PullType'/>
<stripes:layout-render name="/web-starter/layout/standard.jsp" title="View Pull SMS">
    <stripes:layout-component name="contents">
        <stripes:form action="/smscrew/pull/ViewPull.action">
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
                    <th>Pull Type:</th>
                    <td>
                    	<stripes:select name="pullType">
                    		<stripes:option value="-1">All</stripes:option>
                    		<stripes:options-collection collection="${enumPull.enumeration}" label="label" value="value" />
                    	</stripes:select>
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
	                    <th>Request Message</th>
	                    <th>Response Message</th>
	                    <th>Response Nb. Part</th>
	                    <th>Response Nb. Part Delivered</th>
	                    <th>Response Delivery Status</th>
	                    <th>Response Detailed</th>
	                </tr>
	                <c:forEach items="${data}" var="d" varStatus="rowstat">
		                <tr class="${d.deliveryCode != "2" ? (d.deliveryCode != 0 ? (rowstat.count mod 2 == 0 ? "even" : "odd"): "warn")  : "error"}">
		                    <td>${d.ts}</td>
		                    <td><stripes:link href="/smscrew/crew/ViewCrew.action?id=${d.id_crew}">${d.id_crew}</stripes:link></td>
		                    <td>${d.request_message}</td>
		                    <td>${d.response_message}</td>
		                    <td>${d.nb_part == -1 ? "-" : d.nb_part}</td>
		                    <td>${d.nb_delivered}</td>
		                    <td>${d.delivered}</td>
		                    <td><stripes:link href="/smscrew/push/ViewDetailed.action?id=${d.push_entry_id}">response detail</stripes:link></td>
		                </tr>
	                </c:forEach>
	            </table>
        </stripes:form>
    </stripes:layout-component>
</stripes:layout-render>
<c:remove var="data"/>
<c:remove var="generateResult"/>
