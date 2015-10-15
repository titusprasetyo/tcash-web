<%@ include file="/web-starter/taglibs.jsp" %>

<stripes:layout-render name="/web-starter/layout/standard.jsp" title="Upload File">
    <stripes:layout-component name="contents">
        <stripes:errors action="/smscrew/Publish.action"/>
        <stripes:form action="/smscrew/Publish.action">
            <table class="leftRightForm">
	            <tr>
                    <th>File:</th>
                    <td><stripes:file name="publishFile"/></td>
                </tr>
                <tr>
                    <th><stripes:label for="General.AdditionalInfo"/>:</th>
                    <td><stripes:text name="info" /></td>
                </tr>
            </table>
            <div class="buttons">
                <stripes:submit name="doRefund" value="Upload File"/>
            </div>
            <br>
             Notes:<br>
                        <ul>
                                <li>Nama file yang di upload menentukan jenis file.
                                	<br>- PUB : File publish schedule
                                	<br>- FRE : File free 
                                	<br>- PUB : File publish schedule
                                </li>
                                <li>Jika nama file diawali oleh selain nama itu, maka akan dianggap file separate</li>
                                
                        <ul>
        </stripes:form>
    </stripes:layout-component>
</stripes:layout-render>