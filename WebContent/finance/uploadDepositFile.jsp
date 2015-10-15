<%-- 
    Document   : uploadDepositFile
    Created on : Apr 12, 2010, 10:30:46 AM
    Author     : madeady
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.io.*, java.sql.*, java.util.*,java.text.*" %>
<%@ page import="org.apache.commons.fileupload.FileItem" %>
<%@ page import="org.apache.commons.fileupload.FileUploadException" %>
<%@ page import="org.apache.commons.fileupload.disk.DiskFileItemFactory" %>
<%@ page import="org.apache.commons.fileupload.servlet.ServletFileUpload" %>
<%@page import="org.apache.commons.io.*" %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
   "http://www.w3.org/TR/html4/loose.dtd">



<%
//<jsp:useBean id="reg" scope="request" class="tsel_tunai.Register2Bean"/>
//String path = request.getParameter("F1");
%>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Upload Account Statement for Deposit</title>
    </head>
    
    <body>
        <center>
            <b>Upload Account Statement for Merchant Deposit</b>
<%
//PROSES UPLOAD FILE CSV MENJADI KE DATABASE
/*
Connection con = null;
Statement stmt = null;
PreparedStatement pstmt = null;
ResultSet rs = null;
*/
try{
	//Buka dulu si databasenya
	/*Class.forName("oracle.jdbc.OracleDriver");
	con = DriverManager.getConnection("jdbc:oracle:thin:@10.2.114.121:1521:OPTUNAI", "tunai", "b0m#RK4du21");
	con.setAutoCommit(false);
        */
	//String pathFile = "";
        if (ServletFileUpload.isMultipartContent(request)){
            DiskFileItemFactory  fileItemFactory = new DiskFileItemFactory ();
            fileItemFactory.setSizeThreshold(1*1024*1024);
            ServletFileUpload servletFileUpload = new ServletFileUpload(fileItemFactory);
            List items = servletFileUpload.parseRequest(request);

            ListIterator itr = items.listIterator();
            while(itr.hasNext()){
                FileItem item = (FileItem)itr.next();
                if(item.isFormField()) {
                        out.println("File Name = "+item.getFieldName()+", Value = "+item.getString());
                } else {
                        //Handle Uploaded files.
                        out.println("Field Name = "+item.getFieldName()+
                                ", File Name = "+item.getName()+
                                ", Content type = "+item.getContentType()+
                                ", File Size = "+item.getSize());
                        /*
                         * Write file to the ultimate location.
                         */
                        //File file = new File(destinationDir,item.getName());
                        //item.write(file);
                        String saveFile = item.getName().substring(item.getName().lastIndexOf("\\")+1);
                        String pathFile = application.getRealPath("/");
                        out.println(pathFile);
                        File f = new File(pathFile,saveFile);
                        //if (!f.exists())f.mkdir();
                        item.write(f);
                        out.println("<script language='javascript'>alert('FileUpload berhasil.')</script>");
                        out.println("<a href='file_download.jsp?pathFile="+pathFile+"&fileName="+saveFile+"'>"+saveFile+"</a> <br />");
                        /*if(!f.exists()){
                            f.createNewFile();
                            //out.println("<a href='file_download.jsp?pathFile="+pathFile+"&fileName="+fileName+"'>"+fileName+"</a> <br />");
                        }*/
                }
            }
            /*
            String fileName = fi.getName();

            String saveFile = fileName.substring(fileName.lastIndexOf("\\")+1);
            String ext = saveFile.substring(saveFile.length()-3, saveFile.length());
            if(ext.equalsIgnoreCase("txt") || ext.equalsIgnoreCase("csv")){
            
            // write the file
            try {
                String pathTes = application.getRealPath("/")+"uploadedFiles";

                File fileTes = new File(pathTes);
                if(!fileTes.exists())fileTes.mkdirs();
                fi.write(new File(application.getRealPath("/")+"uploadedFiles\\", saveFile));
                pathFile = pathTes+"\\"+saveFile;
            }
            catch (Exception e) {
                //System.err.println("inside uploadUpdateACtion while writing the uploded file Exception is ["+e.getMessage()+"]");
                out.println("inside uploadUpdateACtion while writing the uploded file Exception is ["+e.getMessage()+"]");
            }
            out.println("<script language='javascript'>alert('File has uploaded')</script>");
            }
         */
        }
/*
        if(!pathFile.equals("")){
                //UPDATE DATABASA ACC_STATEMENT DARI FILE CSV

                //SISTEMNYA YANG BAKALAN NGURUSIN, jadi ngebaca dulu, terus tentuin itu filenya Mandiri atau BNI
                String Hasil[]= new String [6];
                //baca satu baris dulu, liat kalau kosong itu BNI, kalau Mandiri kan ga kosong dari awal
                String thisLine;
                ArrayList al = new ArrayList();
                out.println("<script language='javascript'>alert('Path file = "+pathFile+"')</script>");
                BufferedReader fileIn = new BufferedReader(new FileReader(pathFile));
                thisLine = fileIn.readLine();
                int rowAffected = 0;
                String bankType = "";
                int jmlInsert = 0;
                int jmlUpdate = 0;
                //String accType = "";
                if(thisLine.equalsIgnoreCase("")){
                    thisLine = fileIn.readLine();
                    if(thisLine.equalsIgnoreCase("PT BANK NEGARA INDONESIA (PERSERO) TBK.")){
                        //ini file BNI
                        //out.println("File BNI");
                        bankType = "BNI";
                        //baca 4x dulu biar sampai diatas datanya
                        thisLine = fileIn.readLine();thisLine = fileIn.readLine();thisLine = fileIn.readLine();thisLine = fileIn.readLine();
                        while((thisLine=fileIn.readLine())!=null){
                            if(thisLine.equalsIgnoreCase("")){
                                break;
                            }
                            else{
                                Hasil = thisLine.split(";", 8);
                                if(Hasil[6].equalsIgnoreCase("C")){
                                    //cek dulu apakah data ada atau tidak. pake update
                                    pstmt = con.prepareStatement("UPDATE ACC_STATEMENT SET TIPE='C' WHERE TX_DATE=TO_DATE('"+Hasil[1].substring(0, 19)+"', 'YYYY-MM-DD HH24:MI:SS') AND DESCRIPTION='"+Hasil[4]+"' AND AMOUNT="+Hasil[5]);
                                    rowAffected = pstmt.executeUpdate();
                                    pstmt.close();
                                    //con.commit();
                                    if(rowAffected==0){
                                        pstmt = con.prepareStatement("INSERT INTO ACC_STATEMENT (TX_DATE, DESCRIPTION, AMOUNT, TIPE) VALUES (TO_DATE('"+Hasil[1].substring(0, 19)+"', 'YYYY-MM-DD HH24:MI:SS'), '"+Hasil[4]+"', "+Hasil[5]+", 'C')");
                                        pstmt.executeUpdate();
                                        pstmt.close();
                                        jmlInsert++;
                                    }else jmlUpdate++;
                                }
                            }
                        }
                    }
                    else{
                        out.println("File yang diupload tidak mempunyai format standar dari BNI atau Mandiri.");
                    }
                }
                else if(!thisLine.equalsIgnoreCase("")){
                    //ini file Mandiri
                    bankType = "Mandiri";
                    //simpan baris pertama yang sudah dibaca sebelumnya
                    Hasil = thisLine.split(";", 7) ;
                    if(!Hasil[5].contains("DR")){
                        pstmt = con.prepareStatement("UPDATE ACC_STATEMENT SET TIPE='C' WHERE TX_DATE=TO_DATE('"+Hasil[2].substring(0, 10)+"', 'DD/MM/YYYY') AND DESCRIPTION='"+Hasil[3]+"' AND AMOUNT="+Hasil[5]);
                        rowAffected = pstmt.executeUpdate();
                        pstmt.close();
                        //con.commit();
                        if (rowAffected==0){
                            pstmt = con.prepareStatement("INSERT INTO ACC_STATEMENT (TX_DATE, DESCRIPTION, AMOUNT, TIPE) VALUES (TO_DATE('"+Hasil[2].substring(0, 10)+"', 'DD/MM/YYYY'), '"+Hasil[3]+"', "+Hasil[5]+", 'C')");
                            pstmt.executeUpdate();
                            pstmt.close();
                            jmlInsert++;
                        }else jmlUpdate++;
                    }
                    //simpan baris-baris selanjutnya
                    while((thisLine=fileIn.readLine())!=null){
                        if(thisLine.equalsIgnoreCase("")){
                            break;
                        }
                        else{
                            Hasil = thisLine.split(";", 7) ;
                            if(!Hasil[5].contains("DR")){
                                pstmt = con.prepareStatement("UPDATE ACC_STATEMENT SET TIPE='C' WHERE TX_DATE=TO_DATE('"+Hasil[2].substring(0, 10)+"', 'DD/MM/YYYY') AND DESCRIPTION='"+Hasil[3]+"' AND AMOUNT="+Hasil[5]);
                                rowAffected = pstmt.executeUpdate();
                                pstmt.close();
                                //con.commit();
                                if(rowAffected==0){
                                    pstmt = con.prepareStatement("INSERT INTO ACC_STATEMENT (TX_DATE, DESCRIPTION, AMOUNT, TIPE) VALUES (TO_DATE('"+Hasil[2].substring(0, 10)+"', 'DD/MM/YYYY'), '"+Hasil[3]+"', "+Hasil[5]+", 'C')");
                                    pstmt.executeUpdate();
                                    pstmt.close();
                                    jmlInsert++;
                                }else jmlUpdate++;
                            }
                        }
                    }
                }
                con.commit();
                //Proses berhasil, keluarkan alert
                out.println("<script language='javascript'>alert('"+bankType+" Account Statement has successfully uploaded("+jmlInsert+") or updated("+jmlUpdate+"). ')</script>");
        }        
        //KIRIM SMS KE ADMIN (RANI)
        //reg.sendSms('628119881802', 'Finance sudah mengupload file account statement, tolong admin T-Cash untuk melakukan sugesti jika ada.', "2828");
        */
}
catch(Exception e){
	e.printStackTrace();
	out.println("<script language='javascript'>alert('Error : "+e.getMessage()+"')</script>");
	
}
finally{ 
	try{
            /*if(!con.getAutoCommit()) con.setAutoCommit(true);
            if(con!=null) con.close();
            if(rs!=null) rs.close();
            if(stmt!=null) stmt.close();
            if(pstmt!=null) pstmt.close();*/
	}
	catch(Exception e){}
}

%>            
        </center>
    </body>
</html>
