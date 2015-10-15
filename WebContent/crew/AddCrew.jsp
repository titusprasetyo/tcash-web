<%@ include file="/web-starter/taglibs.jsp" %>
<jsp:useBean id='today' class='java.util.Date'/>
<jsp:useBean id='enumFleet' class='com.telkomsel.itvas.garudasmscrew.enumeration.Fleet'/>
<jsp:useBean id='enumCategory' class='com.telkomsel.itvas.garudasmscrew.enumeration.Category'/>
<stripes:layout-render name="/web-starter/layout/standard.jsp" title="Add Crew">
    <stripes:layout-component name="contents">
        <stripes:form action="/smscrew/crew/AddCrew.action">
            <stripes:errors/>
			<table class="leftRightForm">
				<tr>
                    <th>ID Crew:</th>
                    <td><stripes:text value="${id}" name="id"/></td>
                </tr>
                <tr>
                    <th>Name:</th>
                    <td><stripes:text value="${name}" name="name"/></td>
                </tr>
                <tr>
                    <th>MSISDN:</th>
                    <td><stripes:text value="${msisdn}" name="msisdn"/></td>
                </tr>
                <tr>
                    <th>Old MSISDN:</th>
                    <td><stripes:text value="${msisdnOld}" name="{msisdnOld}"/></td>
                </tr>
                <tr>
                    <th>Crew Type:</th>
                    <td>
                    	<stripes:select name="crewType">
                    		<stripes:options-enumeration enum="com.telkomsel.itvas.garudasmscrew.enumeration.CrewType" />
                    	</stripes:select>
                    </td>
                </tr>
                <tr>
                    <th>Fleet:</th>
                    <td>
                    	<stripes:select name="fleet">
                    		<stripes:options-collection collection="${enumFleet.enumeration}" label="label" value="value" />
                    	</stripes:select>
                    </td>
                </tr>
                <tr>
                    <th>Category:</th>
                    <td>
                    	<stripes:select name="category">
                    		<stripes:options-collection collection="${enumCategory.enumeration}" label="label" value="value" />
                    	</stripes:select>
                    </td>
                </tr>
            </table>
            <div class="buttons">
                <stripes:submit name="add" value="Edit"/>
            </div>
        </stripes:form>
        <br/>
        <strong><c:out value="${msgResponse}"/></strong>
        <br/>
        <stripes:link href="/smscrew/crew/ViewCrew.action?id=${id}">back</stripes:link>
    </stripes:layout-component>
</stripes:layout-render>
<c:remove var="data"/>
<c:remove var="generateResult"/>
<c:remove var="msgResponse"/>
