<%@ include file="/web-starter/taglibs.jsp" %>
<stripes:layout-render name="/web-starter/layout/standard.jsp" title="Change Password">
    <stripes:layout-component name="contents">
        <stripes:errors action="/ChangePassword.action"/>

        <stripes:form action="/ChangePassword.action" focus="oldPassword">
            <table class="leftRightForm">
	            <tr>
                    <th><stripes:label for="ChangePassword.old_password"/>:</th>
                    <td><stripes:password name="oldPassword" /></td>
                </tr>
                <tr>
                    <th><stripes:label for="ChangePassword.new_password"/>:</th>
                    <td><stripes:password name="newPassword" /></td>
                </tr>
				<tr>
                    <th><stripes:label for="ChangePassword.re_password"/>:</th>
                    <td><stripes:password name="rePassword" /></td>
                </tr>
            </table>

            <div class="buttons">
                <stripes:submit name="changePassword" value="Save"/>
            </div>
        </stripes:form>
    </stripes:layout-component>
</stripes:layout-render>