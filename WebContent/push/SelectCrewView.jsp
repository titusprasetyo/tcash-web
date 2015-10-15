<%@ include file="/web-starter/taglibs.jsp" %>
<html>
<head>
<title>
Select Crew <c:out value="sd" /> ${test} <c:out value="${test}" />
</title>
</head>
<body>
<stripes:form action="/push/SelectCrew.action">
Search Crew : <stripes:text name="searchCrew"></stripes:text><br>
<stripes:options-collection collection="${results}" value="id" label="name"/>
</stripes:form>
<c:forEach items="${results}" var="d" varStatus="rowstat">
anu :: ${d.search} -- ${d.search}<br> 
</c:forEach>
</body>
</html>
