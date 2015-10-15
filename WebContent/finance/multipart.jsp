<%-- 
    Document   : multipart
    Created on : Jun 10, 2010, 7:06:36 PM
    Author     : madeady
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.io.*" %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
   "http://www.w3.org/TR/html4/loose.dtd">

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>JSP Page</title>
    </head>
    <body>
<%
try{
        String fileName = request.getParameter("file");
        FileInputStream is = new FileInputStream(fileName);

        int ch;
        while ((ch = is.read()) >= 0)
          System.out.print((char) ch);

        is.close();
}catch(Exception e){out.print(e.getMessage());}
%>
    </body>
</html>
