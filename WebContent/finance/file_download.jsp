<%@page import="java.io.*, java.util.*, java.text.*, java.sql.*"%>
<%@ include file="/web-starter/taglibs.jsp"%>
<%@page import="com.telkomsel.itvas.webstarter.User"%>

<%
String fileName = request.getParameter("fileName");
String pathFile = request.getParameter("pathFile");

if(fileName !=null && pathFile !=null){
    ServletOutputStream outPut = null;
    BufferedInputStream buf= null;
    try{
        //menuliskan response
        response.reset();
        response.setContentType("application/text");
        response.setHeader("Content-disposition","attachment; filename=" +fileName);

        File file = new File(pathFile);
        FileInputStream fileIn = new FileInputStream(file);
        outPut = response.getOutputStream();
        buf= new BufferedInputStream(fileIn);

        int readBytes = 0;

        while((readBytes = buf.read( )) != -1)
            outPut.write(readBytes);
    }
    catch (IOException ioe){
        throw new ServletException(ioe.getMessage( ));
    }
    finally{
    //close the input/output streams
    if (outPut != null)
        outPut.close( );
    if (buf != null)
        buf.close( );

     }
}
%>