package tsel_tunai;

import java.io.*;
import java.net.*;
import java.util.Date;
import org.apache.commons.httpclient.*;
import org.apache.commons.httpclient.methods.*;
import org.apache.log4j.*;
import java.util.*;

public class HttpGet {

  static Logger log = Logger.getLogger(HttpGet.class.getName());



public static String [] get(String surl, int ti) {
  String ret[] = new String[3];
  ret[0] = "NOK";
  ret[2] = "-1";

  org.apache.commons.httpclient.HttpClient client = new org.apache.commons.httpclient.HttpClient();

  client.setConnectionTimeout(ti);
  client.setTimeout(ti);

  GetMethod method = new GetMethod(surl);
  method.setHttp11(false);
    // Provide custom retry handler is necessary
    DefaultMethodRetryHandler retryhandler = new DefaultMethodRetryHandler();
    retryhandler.setRequestSentRetryEnabled(false);
    //retryhandler.setRetryCount(3);
    method.setMethodRetryHandler(retryhandler);

    try {
      // Execute the method.
      int statusCode = client.executeMethod(method);
      ret[2] = String.valueOf(statusCode);

      if ((statusCode == HttpStatus.SC_OK) || (statusCode == 202) ) {

        ret[0] = "OK";
        ret[1] = method.getResponseBodyAsString();
        //log.info(surl+" "+ret[0]+" :"+ret[1]);


      } else {

        ret[0] = "NOK";
        ret[1] = method.getStatusLine().toString()+" "+method.getResponseBodyAsString();
        log.error(surl+" "+ret[0]+" :"+ret[1]);

      }

    } catch (Exception e) {

      log.error(surl+" fail:"+e);

    } finally {
      // Release the connection.
      method.releaseConnection();
    }

    return ret;

}


public static String [] post(String surl, int ti, Vector ve){

    String ret[] = new String[3];
    ret[0] = "NOK";
    ret[1] = "-1";

    org.apache.commons.httpclient.HttpClient client = new org.apache.commons.httpclient.HttpClient();

    client.setConnectionTimeout(ti);
    client.setTimeout(ti);

    PostMethod method = new PostMethod(surl);
    method.setHttp11(false);
    NameValuePair[] data = new NameValuePair[ve.size()];

    for(int i=0; i<data.length; i++){
      String [] s = (String []) ve.elementAt(i);
      data[i] = new NameValuePair(s[0], s[1]);
    }

    method.setRequestBody(data);

    method.setHttp11(false);
      // Provide custom retry handler is necessary
      DefaultMethodRetryHandler retryhandler = new DefaultMethodRetryHandler();
      retryhandler.setRequestSentRetryEnabled(false);
      //retryhandler.setRetryCount(3);
      method.setMethodRetryHandler(retryhandler);

      try {
        // Execute the method.
        int statusCode = client.executeMethod(method);
        ret[2] = String.valueOf(statusCode);

        if ((statusCode == HttpStatus.SC_OK) || (statusCode == 202) ) {

          ret[0] = "OK";
          ret[1] = method.getResponseBodyAsString();
          log.info(surl+" "+ret[0]+" :"+ret[1]);


        } else {

          ret[0] = "NOK";
          ret[1] = method.getStatusLine().toString()+" "+method.getResponseBodyAsString();
          log.error(surl+" "+ret[0]+" :"+ret[1]);

        }

      } catch (Exception e) {

        log.error(surl+" fail:"+e);

      } finally {
        // Release the connection.
        method.releaseConnection();
      }
      ve.clear();
      ve = null;
      return ret;


}

public static void post2 (String login, String pass) throws Exception {
        URL url = new URL("http://10.1.89.211/cust_care/test.jsp");
        URLConnection connection = url.openConnection();
        connection.setDoOutput(true);

        ByteArrayOutputStream byteStream = new ByteArrayOutputStream(512); // Grows if necessary
      // Stream that writes into buffer
      PrintWriter out = new PrintWriter(byteStream, true);
      String postData =  "login="+login+"&password="+pass+"&ok=Login";

      // Write POST data into local buffer
      out.print(postData);
      out.flush(); // Flush since above used print, not println


      String lengthString = String.valueOf(byteStream.size());
      connection.setRequestProperty("Content-Length", lengthString);

      // Netscape sets the Content-Type to multipart/form-data
      // by default. So, if you want to send regular form data,
      // you need to set it to
      // application/x-www-form-urlencoded, which is the
      // default for Internet Explorer. If you send
      // serialized POST data with an ObjectOutputStream,
      // the Content-Type is irrelevant, so you could
      // omit this step.
      connection.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");

      // Write POST data to real output stream
      byteStream.writeTo(connection.getOutputStream());

      BufferedReader in =
        new BufferedReader(new InputStreamReader
                             (connection.getInputStream()));
      String line;
      String linefeed = "\n";

      while((line = in.readLine()) != null) {
        System.out.println(line);

      }



        /* from sun


        PrintWriter out = new PrintWriter(
                              connection.getOutputStream());
        out.println("login=" + login+"&password="+pass+"&ok=Login");
        out.close();

        BufferedReader in = new BufferedReader(
                                new InputStreamReader(
                                connection.getInputStream()));
        String inputLine;

        while ((inputLine = in.readLine()) != null)
            System.out.println(inputLine);

        in.close();

      */
}






}
