package tsel_tunai;

import org.apache.log4j.*;
import java.util.*;
import java.net.*;

public class NotifThr implements Runnable {
  SendNotif sn;
  Logger log = Logger.getLogger(NotifThr.class.getName());

  public NotifThr(SendNotif s) {
    this.sn = s;
    Thread t = new Thread(this);
    t.start();
  }


  public void run(){

    String msisdn = "";
    String source = "";
    String msg = "";
    String url = "";

    for(;;){

      try {

        String dat [] = (String []) sn.q.get();
        msisdn = dat[0];
        msg = dat[1];
        source = dat[2];

        source = URLEncoder.encode(source, "UTF-8");
        msg = URLEncoder.encode(msg, "UTF-8");
        url = this.sn.url_k+"&from="+source+"&to="+msisdn+"&text="+msg;
        String ret [] = HttpGet.get(url, 10000);

        if(ret[0].equals("OK") && ret[1].startsWith("Sent")){

          log.info("send_notif success msisdn:"+msisdn+" msg:"+dat[1]);

        } else log.info("send_notif fail msisdn:"+msisdn+" msg:"+dat[1]);

        dat = null;
        ret = null;



      }catch(Exception e){

        log.error(e.getMessage(), e);
        try { Thread.sleep(2000); } catch(Exception e2){}

      }



    }



  }

}
