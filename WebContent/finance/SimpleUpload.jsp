
<%@ page language="java" import="javazoom.upload.*,java.util.*, java.io.*" %>

<html>
<head>
<title>Samples : Simple Upload</title>
<style TYPE="text/css">
<!--
.style1 {
	font-size: 12px;
	font-family: Verdana;
}
-->
</style>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>
<body bgcolor="#FFFFFF" text="#000000">
<ul class="style1">
<%
try{

out.println("<script language='javascript'>alert('Masuk JSPnya.')</script>");
      if (MultipartFormDataRequest.isMultipartFormData(request))
      {
out.println("<script language='javascript'>alert('Masuk kedalam ifnya.')</script>");
         UploadBean uB = new UploadBean();
         String pathfile = application.getRealPath("\\");
         File f1 = new File(pathfile);
         if (!f1.exists())f1.mkdir();
         uB.setFolderstore(pathfile);
         // Uses MultipartFormDataRequest to parse the HTTP request.

         MultipartFormDataRequest mrequest = new MultipartFormDataRequest(request);
out.println("<script language='javascript'>alert('Uses MultipartFormDataRequest to parse the HTTP request.')</script>");
         String todo = null;
         if (mrequest != null) todo = mrequest.getParameter("todo");
out.println("<script language='javascript'>alert('Masuk ngecek kalau mrequest null.')</script>");
	     if ( (todo != null) && (todo.equalsIgnoreCase("upload")) ){
out.println("<script language='javascript'>alert('Masuk ngecek kalau todonya ada atau tidak.')</script>");
                Hashtable files = mrequest.getFiles();
                if ( (files != null) && (!files.isEmpty()) ){
out.println("<script language='javascript'>alert('Masuk ngecek kalau ada file atau tidak.')</script>");
                    UploadFile file = (UploadFile) files.get("uploadfile");
                    if (file != null) out.println("<li>Form field : uploadfile"+"<BR> Uploaded file : "+file.getFileName()+" ("+file.getFileSize()+" bytes)"+"<BR> Content Type : "+file.getContentType());
                    // Uses the bean now to store specified by jsp:setProperty at the top.
                    uB.store(mrequest, "uploadfile");
                }
                else
                {
                  out.println("<li>No uploaded files");
                }
	     }
         else out.println("<BR> todo="+todo);
      }

}catch(Exception e){out.println("<script language='javascript'>alert('Error message : '+e.e.getMessage())</script>");}
%>
</ul>
<form method="post" action="SimpleUpload.jsp" name="upform" enctype="multipart/form-data">
  <table width="60%" border="0" cellspacing="1" cellpadding="1" align="center" class="style1">
    <tr>
      <td align="left"><b>Select a file to upload :</b></td>
    </tr>
    <tr>
      <td align="left">
        <input type="file" name="uploadfile" size="50">
        </td>
    </tr>
    <tr>
      <td align="left">
		<input type="hidden" name="todo" value="upload">
        <input type="submit" name="Submit" value="Upload">
        <input type="reset" name="Reset" value="Cancel">
        </td>
    </tr>
  </table>
  <br>
  <br>
  <table border="0" cellspacing="1" cellpadding="0" align="center">
    <tr>
      <td bgcolor="#666666">
        <table width="100%" border="0" cellspacing="1" cellpadding="0" align="center" class="style1">
          <tr>
            <td bgcolor="#FFFFFF"><b><font color="#0000FF">&nbsp;
              HTML tags used in this form : </font></b></td>
          </tr>
          <tr>
            <td bgcolor="#FFFFFF">&nbsp;&lt;<b>form</b>
              <b>method</b>=&quot;<b><font color="#FF0000">post</font></b>&quot;
              <b>action</b>=&quot;<b><font color="#FF0000">SimpleUpload.jsp</font></b>&quot;
              name=&quot;upload&quot; <b>enctype</b>=&quot;<b><font color="#FF0000">multipart/form-data</font></b>&quot;&gt;</td>
          </tr>
          <tr>
            <td bgcolor="#FFFFFF">&nbsp;&lt;<b>input</b>
              <b>type</b>=&quot;<b><font color="#FF0000">file</font></b>&quot;
              <b>name</b>=&quot;<font color="#FF0000"><b>uploadfile</b></font>&quot;
              size=&quot;50&quot;&gt;</td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
  <p>&nbsp;</p>
  <p>&nbsp;</p>
  <p align="center">&nbsp;</p>
  <p align="center">&nbsp;</p>
  <p align="center"><font size="-1" face="Courier New, Courier, mono">Copyright
    &copy; <a href="http://www.javazoom.net" target="_blank">JavaZOOM</a> 1999-2006</font></p>
</form>
</body>
</html>
