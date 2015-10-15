<%@ include file="/web-starter/taglibs.jsp" %>
<%@page import="com.telkomsel.itvas.webstarter.RoleType"%>
<jsp:useBean id='today' class='java.util.Date'/>
<jsp:useBean id="userManager" scope="page"
             class="com.telkomsel.itvas.webstarter.UserManager"/>
<jsp:useBean id="roleType" scope="page" class="com.telkomsel.itvas.webstarter.RoleType"/>
<jsp:setProperty property="userRoleId" name="roleType" value="${user.role}"/>

<stripes:layout-render name="/web-starter/layout/standard.jsp" title="User Management">
    <stripes:layout-component name="contents">
        <div class="subtitle">User</div>
        <stripes:form action="/UserManagement.action">
            <stripes:errors/>

            <table class="display">
                <tr>
                    <th>No</th>
                    <th>Username</th>
                    <th>Fullname</th>
                    <th>Email</th>
                    <th>Role</th>
                    <th>Account Expiry</th>
                    <th>Delete</th>
                    <th>Reset Password</th>
                    <th>Unblock User</th>
                </tr>	
                <c:forEach items="${userManager.allUser}" var="user" varStatus="loop">
                    <tr>
	                    <td>
                            ${loop.index + 1}
                            <stripes:hidden name="user[${loop.index}].id" value="${user.id}"/>
                            <stripes:hidden name="user[${loop.index}].username" value="${user.username}"/>
                        </td>
                        <td>${user.username}</td>
                        <td><stripes:text name="user[${loop.index}].fullName" value="${user.fullName}"/></td>
                        <td><stripes:text name="user[${loop.index}].email"  value="${user.email}"/></td>
                        <td>
						<stripes:select name="user[${loop.index}].role">
							<c:forEach items="${roleType.allRoleTypes}" var="role">
								<c:choose>
									<c:when test="${role.id == user.role}">
										<option selected value="${role.id}">${role.label}</option>
									</c:when>								
									<c:otherwise>
										<stripes:option value="${role.id}">${role.label}</stripes:option>								
									</c:otherwise>
								</c:choose>
							</c:forEach>
						</stripes:select>
						</td>
                        <td><stripes:text name="user[${loop.index}].accountExpiry" formatType="date" formatPattern="yyyy-MM-dd" value="${user.accountExpiry}"/></td>
						<td align="center"><stripes:checkbox name="deleteIds" value="${user.id}"
                                              onclick="handleCheckboxRangeSelection(this, event);"/></td>
						<td align="center"><stripes:checkbox name="resetIds" value="${user.id}"
                                              onclick="handleCheckboxRangeSelection(this, event);"/></td>
						<td align="center"><stripes:checkbox name="unblockIds" value="${user.id}"
                                              onclick="handleCheckboxRangeSelection(this, event);"/></td>
                    </tr>
                    <c:set var="newIndex" value="${loop.index + 1}" scope="page"/>
                </c:forEach>
                <%-- And now, an empty row, to ow the adding of new users. --%>
                <tr>
                    <td></td>
					<td><stripes:text name="newUser.username"/></td>
                    <td><stripes:text name="newUser.fullName"/></td>
                    <td><stripes:text name="newUser.email"/></td>
                    <td>
				<stripes:select name="newUser.role">
					<c:forEach items="${roleType.allRoleTypes}" var="role">
						<stripes:option value="${role.id}">${role.label}</stripes:option>								
					</c:forEach>
				</stripes:select>
				</td>
				 <td><stripes:text name="newUser.accountExpiry" formatType="date" formatPattern="yyyy-MM-dd" value="${today}" /></td>
                 <td></td>
                 <td></td>
                </tr>
            </table>
            <div class="buttons"><stripes:submit name="Save" value="Save Changes"/></div>
        </stripes:form>
    </stripes:layout-component>
</stripes:layout-render>