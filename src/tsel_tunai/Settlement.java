package tsel_tunai;

import java.util.*;
import java.sql.*;
import org.apache.log4j.*;
import java.io.*;
import java.text.*;


public class Settlement {
  static Logger log = Logger.getLogger(Settlement.class.getName());
  Properties prop;
  int thr_num;
  String jdbc_url, fetch_num, url_k;
  boolean dbCon = false;
  Connection con = null;
  Connection con2 = null;

  public static String Kemarin() {

    Calendar cal = new GregorianCalendar();
    java.util.Date dt = new java.util.Date();
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
    cal.setTime(dt);
    //cal.set(cal.DAY_OF_MONTH,cal.getActualMaximum(cal.DAY_OF_MONTH)+1) ;
    cal.set(cal.DAY_OF_MONTH, cal.DAY_OF_MONTH - 1);
    dt = cal.getTime();
    return sdf.format(dt);
  }

  public Settlement(String f, String tgl) {

    try {
      prop = new Properties();
      prop.load(new FileInputStream(f));
      thr_num = Integer.parseInt(prop.getProperty("thr_num", "5"));
      fetch_num = prop.getProperty("fetch_num", "100");
      this.jdbc_url = prop.getProperty("jdbc_url",
                                       "jdbc:mysql://10.1.105.23/prov?user=prov&password=prov123");
      this.url_k = prop.getProperty("url_k",
                                    "http://10.1.89.197:19002/cgi-bin/sendsms?username=tester&password=foobar");

      BasicConfigurator.resetConfiguration();
      PropertyConfigurator.configure(f);

      log.info("jdbc_url :" + this.jdbc_url);

    } catch (Exception e) {
      log.error(e.getMessage(), e);
      e.printStackTrace(System.out);
      System.exit( -1);
    }

    try {
      doConnect();

      String tanggal = tgl;
      log.info("start == " + tgl);
      String sql =
          "SELECT  distinct(merchant_id) from  log_merchant l where l.tx_date like '" +
          tanggal + " %'";
      log.info(sql);
      PreparedStatement pstmt = con.prepareStatement(sql);
      ResultSet rs = pstmt.executeQuery();
      String status = "";
      String mid = "";
      double amount = 0;
      while (rs.next()) {
        mid = rs.getString(1);

        String sqld = "delete from settlement_status where merchant_id = ? and settlement_date = ?";
        PreparedStatement psd = con.prepareStatement(sqld);
        psd.setString(1, mid);
        psd.setString(2, tgl);
        psd.executeUpdate();




        String sql_cek = "SELECT  m.trx_id as am FROM  `log_merchant` m  left join log_rfid_reader l "
                      +"on l.trx_id=m.trx_id where  m.tx_date like '"+tgl+" %'   and m.merchant_id='"+mid+"' and l.trx_id is null";
     log.info(sql_cek);
     Statement st = con.createStatement();
     ResultSet rs_cek = st.executeQuery(sql_cek);
     if(rs_cek.next()) status = "N";
     else status = "Ok";
     log.info("merchantid:" + mid + " status:" + status);
        String sql2 =
            "select sum(payment_value) as a from log_merchant where merchant_id = '" +
            mid + "' and tx_date like '" + tanggal + " %'";

        PreparedStatement pstmt2 = con.prepareStatement(sql2);

        ResultSet rs2 = pstmt2.executeQuery();
        if (rs2.next()) {
          amount = rs2.getDouble("a");

        }
        rs2.close();

        String sql3 = "insert into settlement_status(settlement_date,merchant_id,amount,status) values(?,?,?,?)";
        PreparedStatement pstmt3 = con.prepareStatement(sql3);
        pstmt3.setString(1, tgl);
        pstmt3.setString(2, mid);
        pstmt3.setDouble(3, amount);
        pstmt3.setString(4, status);
        pstmt3.executeUpdate();

        pstmt2.close();
        pstmt3.close();
        rs2.close();

        String sql4 = "SELECT m.trx_id, m.terminal_id, m.merchant_id, m.card_id, m.seq_num_terminal, m.random_num_terminal, m.payment_value, m.signature_terminal, m.signature_merchant, m.tx_date, m.receive_time FROM `log_merchant` m left join log_rfid_reader l on l.trx_id = m.trx_id where m.merchant_id = ? " +
                      " AND m.tx_date LIKE '" + tanggal + " %' and l.trx_id is null";
        log.info(sql4);
        PreparedStatement pstmt4 = con.prepareStatement(sql4);
        pstmt4.setString(1, mid);

        ResultSet rs3 = pstmt4.executeQuery();
        while (rs3.next()) {
          //System.out.print(rs3.getString("m.trx_id"));
          String sql5 =
              "insert ignore into log_merchant_fail values(?,?,?,?,?,?,?,?,?,?,?)";

          PreparedStatement pstmt5 = con.prepareStatement(sql5);
          pstmt5.setString(1, rs3.getString("m.trx_id"));
          pstmt5.setString(2, rs3.getString("m.terminal_id"));
          pstmt5.setString(3, rs3.getString("m.merchant_id"));
          pstmt5.setString(4, rs3.getString("m.card_id"));
          pstmt5.setString(5, rs3.getString("m.seq_num_terminal"));
          pstmt5.setString(6, rs3.getString("m.random_num_terminal"));
          pstmt5.setString(7, rs3.getString("m.payment_value"));
          pstmt5.setString(8, rs3.getString("m.signature_terminal"));
          pstmt5.setString(9, rs3.getString("m.signature_merchant"));
          pstmt5.setString(10, rs3.getString("m.tx_date"));
          pstmt5.setString(11, rs3.getString("m.receive_time"));
          log.info("log_merchant fail :" + rs3.getString("m.trx_id") +
                   " cardid" + rs3.getString("m.card_id"));
          pstmt5.executeUpdate();
          pstmt5.close();
        }

        rs3.close();

      }
      pstmt.close();
      rs.close();

      con2 = DbCon.createDBConnection(this.jdbc_url);
      con2.setAutoCommit(false);
      sql =
          "select * from settlement_status where settlement_date = ? and status = 'Ok'";
      PreparedStatement ps = con.prepareStatement(sql);
      ps.setString(1, tgl);
      rs = ps.executeQuery();

      PreparedStatement ps2 = null;
      ResultSet rs2 = null;

      while (rs.next()) {
        String merchantid = rs.getString("merchant_id");
        amount = rs.getDouble("amount");
        this.doCredit(con2, merchantid, amount, tgl);

      }

    } catch (Exception e) {
      log.error(e.getMessage(), e);
      this.dbCon = false;
      try {

        if (con2 != null) {
          con2.rollback();

        }
      } catch (Exception ex1) {}

    } finally {

      try {if (con != null) {
        con.close();
      }
      } catch (Exception e2) {}
      try {if (con2 != null) {
        con2.setAutoCommit(true);
      }
      } catch (Exception e3) {}
      try {if (con2 != null) {
        con2.close();
      }
      } catch (Exception e3) {}
    }
  }

  public void doCredit(Connection con, String merchant_id, double amount,
                       String tgl) throws
      Exception {
    String sql = "select acc_no from merchant where merchant_id = ?";
    PreparedStatement ps = con.prepareStatement(sql);
    ps.setString(1, merchant_id);
    ResultSet rs = ps.executeQuery();
    if (!rs.next()) {
      throw new Exception("acc_no not found merchantid:" + merchant_id +
                          " amount:" + amount);
    }
    String acc_no = rs.getString(1);
    rs.close();
    ps.close();

    sql =
        "select balance from tsel_merchant_account where acc_no = ? for update";
    ps = con.prepareStatement(sql);
    ps.setString(1, acc_no);
    rs = ps.executeQuery();
    if (!rs.next()) {
      throw new Exception("acc_no not found merchantid:" + merchant_id +
                          " amount:" + amount);
    }
    double balance = rs.getDouble(1);
    rs.close();
    ps.close();

    sql =
        "update tsel_merchant_account set balance = balance + ?, create_time=now() where acc_no = ?";
    ps = con.prepareStatement(sql);
    ps.setString(1, String.valueOf(amount));
    ps.setString(2, acc_no);
    int ret = ps.executeUpdate();
    log.info(sql+" ret:"+ret);
    ps.close();

    sql = "insert into tsel_merchant_account_history values('', ?, ?, ?, ?, ?, ?, ?, now(), ?, ?, ?)";
    ps = con.prepareStatement(sql);
    ps.setString(1, "txid");
    ps.setString(2, acc_no);
    ps.setString(3, "");
    ps.setString(4, "payment_settlement");
    ps.setString(5, "0");
    ps.setString(6, String.valueOf(amount));
    ps.setDouble(7, (balance + amount));
    ps.setString(8, "");
    ps.setString(9, "");
    ps.setString(10, "settlement " + tgl);
    ret = ps.executeUpdate();
    log.info(sql+" ret:"+ret);
    ps.close();
    con.commit();
    log.info("settlement success merchantid:" + merchant_id + " amount:" +
             amount + " tgl:" + tgl + " account:" + acc_no);

  }


  public void doConnect() {
    try {
      if (this.con != null) {
        con.close();
      }
    } catch (Exception e) {
      log.error(e.getMessage(), e);
    }

    try {
      this.con = DbCon.createDBConnection(this.jdbc_url);
      this.dbCon = true;

    } catch (Exception e) {
      log.error(e.getMessage(), e);
    }

  }

  public static void main(String[] args) {
    new Settlement(args[0], args[1]);
  }

}
