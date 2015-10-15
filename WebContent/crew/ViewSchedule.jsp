<%@ include file="/web-starter/taglibs.jsp" %>
<jsp:useBean id='today' class='java.util.Date'/>
<jsp:useBean id='enumFleet' class='com.telkomsel.itvas.garudasmscrew.enumeration.Fleet'/>
<jsp:useBean id='enumCategory' class='com.telkomsel.itvas.garudasmscrew.enumeration.Category'/>
<jsp:useBean id='enumPull' class='com.telkomsel.itvas.garudasmscrew.enumeration.PullType'/>
<stripes:layout-render name="/web-starter/layout/standard.jsp" title="View Schedule">
    <stripes:layout-component name="contents">
        <stripes:form action="/smscrew/crew/ViewSchedule.action">
            <stripes:errors/>
			<table class="leftRightForm">
				<tr>
                    <th>Tanggal Awal:</th>
                    <td><stripes:text formatType="date" formatPattern="dd-MM-yyyy" value="${startDate != null ? startDate : today}" name="startDate"/></td>
                </tr>
				<tr>
                    <th>ID Crew:</th>
                    <td><stripes:text value="" name="idCrew"/></td>
                </tr>
                <tr>
                    <th>Name:</th>
                    <td><stripes:text value="" name="name"/></td>
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
                    		<option value="1" ${norderBy == 1? "selected" : ""}>Nama (ASC)</option>
                    		<option value="2" ${norderBy == 2? "selected" : ""}>Nama (DESC)</option>
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
	                    <th>ID Crew</th>
	                    <th>Nama</th>
	                    <th>Crew Type</th>
	                    <th>Fleet</th>
	                    <th>Category</th>
	                    <th>Start Date</th>
	                    <th>End Date</th>
	                    <th>Pattern Type</th>
	                    <th>PID</th>
	                    <th>Duty Length</th>
	                    <th>STA</th>
	                    <th>STD</th>
	                </tr>
	                <c:forEach items="${data}" var="d" varStatus="rowstat">
		                <tr class="${rowstat.count mod 2 == 0 ? "even" : "odd"}">
		                    <td><stripes:link href="/smscrew/crew/ViewCrew.action?id=${d.id}">${d.id}</stripes:link></td>
		                    <td>${d.name}</td>
		                    <td>${d.crew_type}</td>
		                    <td>${d.fleet}</td>
		                    <td>${d.category}</td>
		                    <td>${d.start_date}</td>
		                    <td>${d.end_date}</td>
		                    <td>${d.pattern_type}</td>
		                    <td>${d.pid}</td>
		                    <td>${d.duty_length}</td>
		                    <td>${d.sta}</td>
		                    <td>${d.std}</td>
		                </tr>
	                </c:forEach>
	            </table>
        </stripes:form>
    </stripes:layout-component>
</stripes:layout-render>
<c:remove var="data"/>
<c:remove var="generateResult"/>
