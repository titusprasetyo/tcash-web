<%@ include file="/web-starter/taglibs.jsp" %>
<jsp:useBean id='today' class='java.util.Date'/>
<stripes:layout-render name="/web-starter/layout/standard.jsp" title="Send Free Message">
    <stripes:layout-component name="contents">
        <stripes:form action="/smscrew/push/FreeMessage.action">
            <stripes:errors/>
			<table class="leftRightForm">
	            <tr>
                    <th>Crew:</th>
                    <td><stripes:text value="Jhonny / 0811911234" name="crew"/> <a href='anu'>[search crew]</a></td>
                </tr>
	            <tr>
                    <th>Pesan:</th>
                    <td><stripes:textarea cols="15" rows="20" value="Berita anda telah kami terima. Terima kasih :)" name="message"/></td>
                </tr>
            </table>
            <div class="buttons">
                <stripes:submit name="action" value="Kirim Free Message"/>
            </div>
            <stripes:hidden name="idCrew" value="123456"></stripes:hidden>
        </stripes:form>
    </stripes:layout-component>
</stripes:layout-render>
