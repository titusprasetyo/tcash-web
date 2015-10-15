package tsel_tunai;

import java.util.*;
import java.sql.*;
import org.apache.log4j.*;
import java.io.*;


public class SendNotif {

  static Logger log = Logger.getLogger(SendNotif.class.getName());
  Properties prop;
  int thr_num;
  String jdbc_url, fetch_num, url_k;
  boolean dbCon = false;
  Connection con = null;
  Que q;
  int max_q;

  public SendNotif(String f) {

    try {
      prop = new Properties();
      prop.load(new FileInputStream(f));
      thr_num = Integer.parseInt(prop.getProperty("thr_num", "5"));
      fetch_num = prop.getProperty("fetch_num", "100");
      this.jdbc_url = prop.getProperty("jdbc_url", "jdbc:mysql://10.1.105.23/prov?user=prov&password=prov123");
      this.url_k = prop.getProperty("url_k", "http://10.1.89.197:19002/cgi-bin/sendsms?username=tester&password=foobar");
      this.max_q = Integer.parseInt(prop.getProperty("max_q", "100"));
      BasicConfigurator.resetConfiguration();
      PropertyConfigurator.configure(f);

      log.info("thr_num :"+this.thr_num);
      log.info("fetch_num :"+this.fetch_num);
      log.info("jdbc_url :"+this.jdbc_url);
      log.info("max_q :"+this.max_q);

    }catch(Exception e){
      log.error(e.getMessage(), e);
      System.exit(-1);
    }

    q = new Que();

    for(int i=0; i<thr_num; i++){
      new NotifThr(this);
    }



    //String sql = "select * from notif order by id limit 0,"+this.fetch_num;
    String sql = "select * from notif where rownum < "+this.fetch_num+" order by id ";

    Statement st = null;
    ResultSet rs = null;
    Statement st2 = null;

    for(;;){

      try { Thread.sleep(1000); }catch(InterruptedException ix){}
      try {

        if(!this.dbCon) this.doConnect();
        st = this.con.createStatement();
        rs = st.executeQuery(sql);

        while(rs.next()){
          String msg [] = new String[3];
          msg[0] = rs.getString("msisdn");
          msg[1] = rs.getString("msg");
          msg[2] = rs.getString("source");

          if(this.q.getSize() < this.max_q) {

            this.q.add2(msg);
            String sql2 = "delete from notif where id='" + rs.getString("id") +
                          "'";
            st2 = con.createStatement();
            st2.executeUpdate(sql2);
            st2.close();
            st2 = null;
          } else {
            Thread.sleep(2000);
            log.info("wait ....");
          }

        }

        rs.close();
        st.close();
        rs = null;
        st = null;


      }catch(Exception e){
        log.error(e.getMessage(), e);
        this.dbCon = false;
      }



    }



  }

  public void doConnect(){
    try {
      if(this.con != null){
        con.close();
      }
      }catch(Exception e){
      log.error(e.getMessage(), e);
    }

    try {
      this.con = DbCon.createDBConnectionOra(this.jdbc_url);
      this.dbCon = true;

    }catch(Exception e){
      log.error(e.getMessage(), e);
    }

  }

  public static void main(String[] args) {
    new SendNotif(args[0]);
  }

}
