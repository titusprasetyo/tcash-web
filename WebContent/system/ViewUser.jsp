<%@ include file="/web-starter/taglibs.jsp" %>
<jsp:useBean id='today' class='java.util.Date'/>
<jsp:useBean id='roleType' class='com.telkomsel.itvas.webstarter.RoleType'/>
<stripes:layout-render name="/web-starter/layout/standard.jsp" title="View User">
    <stripes:layout-component name="contents">
        <stripes:form action="/smscrew/system/ViewUser.action">
            <stripes:errors/>
			<table class="leftRightForm">
				<tr>
                    <th>Username:</th>
                    <td><stripes:text value="" name="username"/></td>
                </tr>
                <tr>
                    <th>Name:</th>
                    <td><stripes:text value="" name="fullname"/></td>
                </tr>
                <tr>
                    <th>Role:</th>
                    <td>
                    	<stripes:select name="role">
                    		<stripes:option value="-1">All</stripes:option>
                    		<stripes:options-collection label="label" value="id" collection="${roleType.allRoleTypes}" />
                    	</stripes:select>
                    </td>
                </tr>
                <tr>
                    <th>Data Ordering By:</th>
                    <td>
                    	<select name="orderBy">
                    		<option value="1" ${norderBy == 1? "selected" : ""}>Nama (ASC)</option>
                    		<option value="2" ${norderBy == 2? "selected" : ""}>Nama (DESC)</option>
                    		<option value="3" ${norderBy == 3? "selected" : ""}>Username (ASC)</option>
                    		<option value="4" ${norderBy == 4? "selected" : ""}>Username (DESC)</option>
                    	</select>
                    </td>
                </tr>
            </table>
            <div class="buttons">
                <stripes:submit name="view" value="View"/>
            </div>
	            <table class="display">
	                <tr>
	                    <th>Username</th>
	                    <th>Name</th>
	                    <th>Role</th>
	                    <th>Email</th>
	                    <th>Account Expiry</th>
	                    <th>Last Login</th>
	                    <th>Action</th>
	                </tr>
	                <c:forEach items="${data}" var="d" varStatus="rowstat">
		                <tr class="${rowstat.count mod 2 == 0 ? "even" : "odd"}">
		                    <td>${d.username}</td>
		                    <td>${d.fullname}</td>
		                    <td>${d.role}</td>
		                    <td>${d.email}</td>
		                    <td>${d.account_expiry}</td>
		                    <td>${d.last_login_attempt}</td>
		                    <td>&nbsp;
		                    <c:if test="${d.editable == '1'}">
		                    	<stripes:link href="/smscrew/system/EditUser.action?id=${d.id}">edit</stripes:link></td>
		                    </c:if>
		                </tr>
	                </c:forEach>
	            </table>
        </stripes:form>
    </stripes:layout-component>
</stripes:layout-render>
<c:remove var="data"/>
<c:remove var="generateResult"/>
