package tsel_tunai;

import java.security.*;
import java.sql.*;
import java.text.*;


public class LogTx {

  String cardid = "";
  String sequence = "";
  String ev = "";
  String sh = "";
  String r_v = "";
  String sm = "";
  String r_ev_sh = "";

  String sh_msg = "";
  String sm_msg = "";

  boolean valid = false;
  String timestamp = "";

  SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
  static long l2000 = Long.parseLong("946659600000");

  private String merchant_id;
  private String password;
  private String login;
  private String data;
  private String keyMerchant;
  private String keyHost;
  private String msisdn;
  private String paymentTerminalId = "";


  public void setMerchant_id(String merchant_id) {
    this.merchant_id = merchant_id;
  }

  public void setPaymentTerminalId(String paymentTerminalId) {
    this.paymentTerminalId = paymentTerminalId;
  }

  public void setLogin(String login) {
    this.login = login;
  }

  public void setPassword(String password) {
    this.password = password;
  }

  public void setData(String data) {
    this.data = data;
  }

  public void setKeyHost(String keyHost) {
    this.keyHost = keyHost;
  }

  public void setKeyMerchant(String keyMerchant) {
    this.keyMerchant = keyMerchant;
  }

  public void setMsisdn(String msisdn) {
    this.msisdn = msisdn;
  }

  public LogTx() {

  }


  public boolean validateInputReader() {
    boolean b = true;

    if (this.data == null || (this.data.length() != 138)) {
      b = false;
    }

    if (this.msisdn == null || (this.msisdn.length() < 1)) {
      b = false;

    }

    return b;
  }


  public boolean validateInput() {
    boolean b = true;
    if (this.data == null || (this.data.length() != 138)) {
      b = false;
    }
    if (this.login == null || (this.login.length() < 1)) {
      b = false;
    }
    if (this.password == null || (this.password.length() < 1)) {
      b = false;

    }
    if (this.paymentTerminalId == null || (this.paymentTerminalId.length() < 1)) {
      b = false;
    }
    if (this.merchant_id == null || (this.merchant_id.length() < 1)) {
      b = false;

    }

    return b;
  }


  public boolean validateLoginPass() {
    boolean b = false;

    Connection con = null;
    try {
      con = DbCon.getConnection();
      String sql = "select m.login from merchant m, reader_terminal l where l.terminal_id = ? and m.login = ? and m.password= ? and m.merchant_id = l.merchant_id";
      PreparedStatement ps = con.prepareStatement(sql);
      ps.setString(1, this.paymentTerminalId);
      ps.setString(2, this.login);
      ps.setString(3, this.password);
      ResultSet rs = ps.executeQuery();

      if (rs.next()) {
        b = true;

      }
      rs.close();
      ps.close();

    } catch (Exception e) {
      e.printStackTrace(System.out);

    } finally {
      if (con != null) {try {con.close();
      } catch (Exception ee) {}

      }
    }

    return b;
  }

  public String[] saveDataReader() {

    String ret[] = {"03", "internal_problem"};

    if (!this.validateInputReader()) {
      ret[0] = "03";
      ret[1] = "parameter_error";
      return ret;
    }

    if (!this.validateTxidReader()) {
      ret[0] = "00";
      ret[1] = "data_already_received";
      return ret;
    }

    if (!this.validateTerminal()) {
      ret[0] = "06";
      ret[1] = "terminal_not_register";
      return ret;
    }

    if (!this.parseData()) {
      ret[0] = "09";
      ret[1] = "data_verification_fail";
      return ret;
    }

    if (!validateCardId()) {
      ret[0] = "05";
      ret[1] = "cardid_not_valid";
      return ret;
    }

    Connection con = null;
    try {

      con = DbCon.getConnection();
      con.setAutoCommit(false);

      String sql = "insert into log_rfid_reader(trx_id, terminal_id, merchant_id, card_id, payment_value, tx_date, receive_time)"
                   + " values(?, ?, ?, ?, ?, to_date(?, 'YYYY-MM-DD HH24:MI:SS'), sysdate)";
      PreparedStatement ps = con.prepareStatement(sql);
      ps.setString(1, this.data);
      ps.setString(2, this.paymentTerminalId);
      ps.setString(3, this.merchant_id);
      ps.setString(4, this.cardid);
      ps.setString(5, this.ev);
      ps.setString(6, this.timestamp);
      ps.executeUpdate();
      ps.close();

      sql =
          "select acc_no, balance from rfid_account where card_id = ? for update";
      ps = con.prepareStatement(sql);
      ps.setString(1, this.cardid);
      ResultSet rs = ps.executeQuery();

      double balance_card = 0;
      String acc_no = "";
      if (rs.next()) {

        acc_no = rs.getString(1);
        balance_card = rs.getDouble(2);

      } else {
        throw new Exception("Log Tx reader fail, rfid account_not_found :" +
                            this.cardid);
      }

      sql =
          "insert into rfid_account_history values('', ?, ?, ?, ?, ?, ?, ?, to_date(?, 'YYYY-MM-DD HH24:MI:SS'), ?, ?, ?)";
      ps = con.prepareStatement(sql);
      ps.setString(1, this.data);
      ps.setString(2, acc_no);
      ps.setString(3, this.cardid);
      ps.setString(4, "rfid_payment");
      ps.setString(5, this.ev);
      ps.setString(6, "0");
      ps.setDouble(7, (balance_card - Double.parseDouble(this.ev)));
      ps.setString(8, this.timestamp);
      ps.setString(9, "");
      ps.setString(10, this.paymentTerminalId);
      ps.setString(11, "");
      ps.executeUpdate();
      ps.close();

      sql = "update rfid_account set balance=balance-? , create_time = sysdate where card_id = ? ";
      ps = con.prepareStatement(sql);
      ps.setString(1, this.ev);
      ps.setString(2, this.cardid);
      ps.executeUpdate();
      ps.close();

      con.commit();
      ret[0] = "00";
      ret[1] = "success";

    } catch (Exception e) {
      e.printStackTrace(System.out);
      try {con.rollback();
      } catch (Exception ex) {}
    } finally {
      if (con != null) {
        try {con.setAutoCommit(true);
        } catch (Exception e3) {}
        try {con.close();
        } catch (Exception e2) {}
      }
    }

    return ret;
  }


  public String[] saveData() {
    String ret[] = {"03", "internal_problem"};
    if (!this.validateInput()) {
      ret[0] = "03";
      ret[1] = "parameter_error";
      return ret;
    }
    if (!validateLoginPass()) {
      ret[0] = "01";
      ret[1] = "login_pass error";
      return ret;
    }

    if (!this.validateTxid()) {
      ret[0] = "00";
      ret[1] = "data_already_received";
      return ret;
    }

    if (!this.parseData()) {
      ret[0] = "09";
      ret[1] = "data_verification_fail";
      return ret;
    }

    if (!validateCardId()) {
      ret[0] = "05";
      ret[1] = "cardid_not_valid";
      return ret;
    }

    Connection con = null;
    try {

      con = DbCon.getConnection();
      String sql = "insert into log_merchant(trx_id, terminal_id, merchant_id, card_id, payment_value, tx_date, receive_time)"
                   + " values(?, ?, ?, ?, ?, ?, sysdate)";
      PreparedStatement ps = con.prepareStatement(sql);
      ps.setString(1, this.data);
      ps.setString(2, this.paymentTerminalId);
      ps.setString(3, this.merchant_id);
      ps.setString(4, this.cardid);
      ps.setString(5, this.ev);
      ps.setString(6, this.timestamp);
      ps.executeUpdate();

      ps.close();

      ret[0] = "00";
      ret[1] = "success";
    } catch (Exception e) {
      e.printStackTrace(System.out);
    } finally {
      try {con.close();
      } catch (Exception e2) {}
    }

    return ret;
  }

  public boolean validateCardId() {
    boolean b = false;
    Connection con = null;
    try {
      con = DbCon.getConnection();
      String sql = "select card_id from rfid_account where card_id = ? ";
      PreparedStatement ps = con.prepareStatement(sql);
      ps.setString(1, this.cardid);
      ResultSet rs = ps.executeQuery();

      if (rs.next()) {
        b = true;

      }
      rs.close();
      ps.close();

    } catch (Exception e) {
      e.printStackTrace(System.out);

    } finally {
      if (con != null) {try {con.close();
      } catch (Exception ee) {}

      }
    }

    return b;
  }

  public boolean validateTerminal() {
    boolean b = false;
    Connection con = null;
    try {
      con = DbCon.getConnection();
      String sql =
          "select terminal_id, merchant_id from reader_terminal where msisdn = ?";
      PreparedStatement ps = con.prepareStatement(sql);
      ps.setString(1, this.msisdn);
      ResultSet rs = ps.executeQuery();

      if (rs.next()) {
        b = true;
        this.paymentTerminalId = rs.getString(1);
        this.merchant_id = rs.getString(2);
      }

      rs.close();
      ps.close();

    } catch (Exception e) {
      e.printStackTrace(System.out);
    } finally {
      try {
        con.close();
      } catch (Exception e2) {}
    }
    return b;
  }


  public boolean validateTxidReader() {
    boolean b = true;
    Connection con = null;
    try {
      con = DbCon.getConnection();
      String sql =
          "select trx_id from log_rfid_reader where trx_id= ?";
      PreparedStatement ps = con.prepareStatement(sql);
      ps.setString(1, this.data);

      ResultSet rs = ps.executeQuery();

      if (rs.next()) {
        b = false;

      }
      rs.close();
      ps.close();

    } catch (Exception e) {
      e.printStackTrace(System.out);

    } finally {
      if (con != null) {try {con.close();
      } catch (Exception ee) {}

      }
    }

    return b;

  }


  public boolean validateTxid() {
    boolean b = true;
    Connection con = null;
    try {
      con = DbCon.getConnection();
      String sql =
          "select trx_id from log_merchant where trx_id= ?";
      PreparedStatement ps = con.prepareStatement(sql);
      ps.setString(1, this.data);

      ResultSet rs = ps.executeQuery();

      if (rs.next()) {
        b = false;

      }
      rs.close();
      ps.close();

    } catch (Exception e) {
      e.printStackTrace(System.out);

    } finally {
      if (con != null) {try {con.close();
      } catch (Exception ee) {}

      }
    }

    return b;

  }


  public boolean getKeyHost() {

    boolean b = false;
    Connection con = null;
    try {

      con = DbCon.getConnection();
      String sql =
          "select keyTerminal from reader_terminal where terminal_id = ?";

      PreparedStatement ps = con.prepareStatement(sql);
      ps.setString(1, this.paymentTerminalId);
      ResultSet rs = ps.executeQuery();
      if (rs.next()) {
        this.keyHost = rs.getString(1);
        b = true;
      }

      rs.close();
      ps.close();

    } catch (Exception e) {
      e.printStackTrace(System.out);
    } finally {
      try {
        con.close();
      } catch (Exception e2) {}
    }

    return b;

  }


  public boolean getKeyMerchant() {

    boolean b = false;
    Connection con = null;
    try {
      con = DbCon.getConnection();
      String sql = "select keyMerchant from merchant where merchant_id = ?";
      PreparedStatement ps = con.prepareStatement(sql);
      ps.setString(1, this.merchant_id);
      ResultSet rs = ps.executeQuery();
      if (rs.next()) {
        this.keyMerchant = rs.getString(1);
        b = true;
      }

      rs.close();
      ps.close();

    } catch (Exception e) {
      e.printStackTrace(System.out);
    } finally {
      try {
        con.close();
      } catch (Exception e2) {}
    }

    return b;

  }


  public boolean parseData() {
    boolean b = false;
    String dat = this.data;

    try {
      String hexAll = "";
      String temp1 = dat.substring(0, 138);
      for (int i = 1; i <= temp1.length(); i++) {
        if ((i % 3) == 0) {
          int r = Integer.parseInt(temp1.substring(i - 3, i));
          //System.out.print(" r :"+r+ " ");
          String t2 = Integer.toHexString(r).toUpperCase();
          if (t2.length() < 2) {
            t2 = "0" + t2;
          }
          hexAll = hexAll + t2;
        }

      }

      System.out.println("hexa_all :" + hexAll);

      temp1 = dat.substring(0, 48);
      System.out.println(temp1.length());

      for (int i = 1; i <= temp1.length(); i++) {
        if ((i % 3) == 0) {
          int r = Integer.parseInt(temp1.substring(i - 3, i));
          //System.out.print(" r :"+r+ " ");
          String t2 = Integer.toHexString(r).toUpperCase();
          if (t2.length() < 2) {
            t2 = "0" + t2;
            //System.out.println(t2);
          }
          this.cardid = this.cardid + t2;
        }

      }

      temp1 = dat.substring(69, 78);

      for (int i = 1; i <= temp1.length(); i++) {
        if ((i % 3) == 0) {
          int r = Integer.parseInt(temp1.substring(i - 3, i));
          //System.out.print(" r :"+r+ " ");
          String t2 = Integer.toHexString(r).toUpperCase();
          if (t2.length() < 2) {
            t2 = "0" + t2;
          }
          this.ev = this.ev + t2;
        }

      }

      System.out.println("cardid:" + this.cardid);
      this.ev = String.valueOf(HexUtils.convertToInt("00" + this.ev)[0]);
      System.out.println("ev :" + this.ev);

      temp1 = dat.substring(78, 108);

      for (int i = 1; i <= temp1.length(); i++) {
        if ((i % 3) == 0) {
          int r = Integer.parseInt(temp1.substring(i - 3, i));
          //System.out.print(" r :"+r+ " ");
          String t2 = Integer.toHexString(r).toUpperCase();
          if (t2.length() < 2) {
            t2 = "0" + t2;
          }
          this.sh = this.sh + t2;
        }

      }

      System.out.println("sh :" + this.sh + " digit:" + temp1);

      temp1 = dat.substring(0, 78);

      for (int i = 1; i <= temp1.length(); i++) {
        if ((i % 3) == 0) {
          int r = Integer.parseInt(temp1.substring(i - 3, i));
          //System.out.print(" r :"+r+ " ");
          String t2 = Integer.toHexString(r).toUpperCase();
          if (t2.length() < 2) {
            t2 = "0" + t2;
          }
          this.r_v = this.r_v + t2;
        }

      }

      //System.out.println("r_v :"+this.r_v);
      if (!this.getKeyHost()) {
        System.out.println("get key terminal fail");
        return false;
      }

      if (!this.getKeyMerchant()) {
        System.out.println("get key merchant fail");
        return false;
      }

      //this.r_v = this.r_v + "F660CADD6A0CB6D1C304C64D4A9489B5";
      String temp_r_ev = this.r_v + this.keyHost;

      String sh_rv = this.doDigest(HexUtils.convertToByte(temp_r_ev));
      System.out.println("sh_rv :" + sh_rv);

      if (sh_rv.length() == 40) {

        this.sh_msg = sh_rv.substring(20, 40);
        if (this.sh_msg.equals(this.sh)) {
          this.valid = true;
        } else {
          System.out.println("verify signature terminal fail");
          return false;
        }

      }

      System.out.println("sh_msg terminal after digest :" + this.sh_msg +
                         " valid:" +
                         valid);

      temp1 = dat.substring(108, 138);

      for (int i = 1; i <= temp1.length(); i++) {
        if ((i % 3) == 0) {
          int r = Integer.parseInt(temp1.substring(i - 3, i));
          //System.out.print(" r :"+r+ " ");
          String t2 = Integer.toHexString(r).toUpperCase();
          if (t2.length() < 2) {
            t2 = "0" + t2;
          }
          this.sm = this.sm + t2;
        }

      }

      System.out.println("sm :" + this.sm + " digit:" + temp1);
      this.r_ev_sh = this.r_v + this.sh;
      String temp_r_ev_sh = this.r_ev_sh + this.keyMerchant;
      System.out.println("r_ev_sh :" + this.r_ev_sh);
      System.out.println("key_merchant :" + this.keyMerchant);

      String sm_rv = this.doDigest(HexUtils.convertToByte(temp_r_ev_sh));
      System.out.println("sm_r_ev_s :" + sm_rv);

      if (sm_rv.length() == 40) {

        this.sm_msg = sm_rv.substring(20, 40);
        if (this.sm_msg.equals(this.sm)) {
          this.valid = true;
        } else {
          System.out.println("verify signature merchant fail");
          return false;
        }

      }

      //this.calculateThn70();
      System.out.println("l2000 :" + l2000);
      temp1 = dat.substring(54, 66);

      for (int i = 1; i <= temp1.length(); i++) {
        if ((i % 3) == 0) {
          int r = Integer.parseInt(temp1.substring(i - 3, i));
          //System.out.print(" r :"+r+ " ");
          String t2 = Integer.toHexString(r).toUpperCase();
          if (t2.length() < 2) {
            t2 = "0" + t2;
          }
          this.timestamp = this.timestamp + t2;
        }

      }
      System.out.println("hex timestamp :" + this.timestamp);

      long l_temp = this.byteArrayToLong(HexUtils.convertToByte("00000000" +
          this.timestamp));
      l_temp = l_temp * 1000;
      System.out.println("ms detik from 2000:" + l_temp);

      java.util.Date dMsg = new java.util.Date((l_temp + this.l2000));
      this.timestamp = sdf.format(dMsg);
      System.out.println("timestamp tx:" + this.timestamp);

      b = true;
    } catch (Exception e) {
      e.printStackTrace(System.out);
    }

    return b;
  }

  public static long byteArrayToLong(byte[] bytes) {
    long result = 0;
    result = result | (0xFF00000000000000L & (((long) bytes[0]) << 56));
    result = result | (0x00FF000000000000L & (((long) bytes[1]) << 48));
    result = result | (0x0000FF0000000000L & (((long) bytes[2]) << 40));
    result = result | (0x000000FF00000000L & (((long) bytes[3]) << 32));
    result = result | (0x00000000FF000000L & (((long) bytes[4]) << 24));
    result = result | (0x0000000000FF0000L & (((long) bytes[5]) << 16));
    result = result | (0x000000000000FF00L & (((long) bytes[6]) << 8));
    result = result | (0x00000000000000FFL & (((long) bytes[7])));
    return result;
  }


  public String doDigest(byte input[]) throws Exception {
    String ret = "";

    MessageDigest md = MessageDigest.getInstance("SHA1");
    md.update(input);
    byte[] output = md.digest();
    ret = bytesToHex(output);

    return ret;
  }

  public static String bytesToHex(byte[] b) {
    char hexDigit[] = {'0', '1', '2', '3', '4', '5', '6', '7',
                      '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'};
    StringBuffer buf = new StringBuffer();
    for (int j = 0; j < b.length; j++) {
      buf.append(hexDigit[(b[j] >> 4) & 0x0f]);
      buf.append(hexDigit[b[j] & 0x0f]);
    }
    return buf.toString();
  }


  public static void main(String[] args) throws Exception {
    //LogTx logTest1 = new LogTx("c:/work/telkomsel_tunai/log.txt");
  }

}
