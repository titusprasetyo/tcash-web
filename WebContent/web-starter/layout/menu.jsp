<%@ include file="/web-starter/taglibs.jsp"%>
<c:forEach items='${user.eligibleMenus}' var='menu'>
	<p><span class='bodycopyred'><b>&nbsp;&nbsp;&nbsp;<font
		color="#CC3300" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong><stripes:link href="${menu.link}" class="link">${menu.title}</stripes:link></strong></font></b><br>
	<c:if test="${menu.childCount > 0}">
		<c:forEach items='${menu.childs}' var='child'>
			&nbsp;&nbsp;&nbsp;<font color="#CC6633" size="1"
				face="Verdana, Arial, Helvetica, sans-serif"><stripes:link href="${child.link}">${child.title}</stripes:link></font>
			<br>
		</c:forEach>
	</c:if>
	</span>
	</p>
</c:forEach>