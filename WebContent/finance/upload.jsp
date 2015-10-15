<%@ page language = "java" import = "java.io.*, java.util.*, java.text.*, java.sql.*, java.net.*" %>
<%@ include file="/web-starter/taglibs.jsp"%>
<%@page import="com.telkomsel.itvas.webstarter.User"%>

<%--<jsp:useBean id="userClass" scope="page" class="com.telkomsel.web2sms.corp.userClass"></jsp:useBean>
<jsp:useBean id="Db" scope="page" class="com.telkomsel.web2sms.corp.DbBean"></jsp:useBean>
<jsp:useBean id="Send" scope="page" class="com.telkomsel.web2sms.corp.SMSBean"></jsp:useBean>
--%>
<%--<%@ include file="loggedin.inc" %>
<%@ include file="member_zone.inc" %>--%>

<stripes:layout-render name="/web-starter/layout/standard.jsp" title="Upload ">
	<stripes:layout-component name="contents">
		<form method="post" action="upload2.jsp" name="upform" enctype="multipart/form-data">
			<p>
				<input type="file" name="uploadfile" size="30">
				<input type="hidden" name="todo" value="upload">
			</p>
			<p>
				<input type="submit" value="Upload">
			</p>
        </form>
	</stripes:layout-component>
</stripes:layout-render>
