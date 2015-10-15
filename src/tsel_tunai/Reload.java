package tsel_tunai;

import java.util.regex.*;
import java.util.*;
import java.sql.*;
import java.text.*;

public class Reload {
  private String cardid;
  private String amount;
  private String pin;
  private String txid;
  private String password;
  private String login;
  private String pin_kartu;
  private String loadingTerminalId;
  private String acc_no = null;
  private String cust_msisdn;

  SimpleDateFormat sdf2 = new SimpleDateFormat("ddMMyyHHmmss");

  public String getId(Connection con) throws Exception {
    String ret = null;
    String sql = "select seq_id.nextval from dual";
    Statement st = con.createStatement();
    ResultSet rs = st.executeQuery(sql);
    if(rs.next()){

      ret = sdf2.format(new java.util.Date())+rs.getString(1);

    } else {
      throw new Exception("fail get id from oracle seq_id");
    }
    rs.close();
    st.close();

    return ret;
  }

  public String[] submit() {
    String ret[] = {"03", "03"};
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
    if (!validateCardId()) {
      ret[0] = "05";
      ret[1] = "cardid_not_valid";
      return ret;
    }

    if (!validatePin()) {
      ret[0] = "04";
      ret[1] = "pin_error";
      return ret;
    }

    if (!this.validatePinKartu()) {
      ret[0] = "06";
      ret[1] = "cardid_not_found";
      return ret;
    }

    Connection con = null;

    try {
      con = DbCon.getConnection();
      double balance_tsel = 0;
      double balance_rfid = 0;
      double balance_merchant = 0;

      con.setAutoCommit(false);
      boolean b1 = true; // amount ok
      boolean b2 = true;

      String sql =
          "select balance from tsel_cust_account where acc_no = ? for update ";
      PreparedStatement ps = con.prepareStatement(sql);
      ps.setString(1, this.acc_no);
      ResultSet rs = ps.executeQuery();

      if (rs.next()) {
        balance_tsel = rs.getDouble(1);
        if ((balance_tsel - Double.parseDouble(this.amount)) < 0) {
          b1 = false;

        }
      } else {
        throw new Exception("acc_no not exist");
      }

      rs.close();
      ps.close();



      sql = "select balance from rfid_account where card_id = ? for update ";
      ps = con.prepareStatement(sql);
      ps.setString(1, this.cardid);
      rs = ps.executeQuery();
      if (rs.next()) {
        balance_rfid = rs.getDouble(1);
      } else {
        b2 = false;
        throw new Exception("cardid not exist");
      }

      rs.close();
      ps.close();

      if (b1 && b2) {
        sql = "update tsel_cust_account set balance=balance-? , create_time=sysdate where acc_no = ?";
        ps = con.prepareStatement(sql);
        ps.setString(1, this.amount);
        ps.setString(2, this.acc_no);
        ps.executeUpdate();
        ps.close();

        sql = "update rfid_account set balance=balance+? ,create_time=sysdate where card_id = ?";
        ps = con.prepareStatement(sql);
        ps.setString(1, this.amount);
        ps.setString(2, this.cardid);
        ps.executeUpdate();
        ps.close();

        sql = "insert into log_reload values(?, ?, ?, ?, sysdate, '0')";
        ps = con.prepareStatement(sql);
        ps.setString(1, this.txid);
        ps.setString(2, this.cardid);
        ps.setString(3, this.amount);
        ps.setString(4, this.loadingTerminalId);
        ps.executeUpdate();
        ps.close();

        sql = "insert into tsel_cust_account_history values(? , ?, ?, ?, ?, ?, ?, sysdate, ?, ?, ?)";
        ps = con.prepareStatement(sql);
        ps.setString(1, this.getId(con));
        ps.setString(2, this.txid);
        ps.setString(3, this.acc_no);
        ps.setString(4, String.valueOf(UssdTx.OFFLINE_RELOAD));
        ps.setString(5, this.amount);
        ps.setString(6, "0");
        ps.setDouble(7, (balance_tsel - Double.parseDouble(this.amount)));
        ps.setString(8, this.loadingTerminalId);
        ps.setString(9, "");
        ps.setString(10, "");
        ps.executeUpdate();
        ps.close();

        sql = "insert into rfid_account_history values('', ?, ?, ?, ?, ?, ?, ?, sysdate, ?, ?, ?)";
        ps = con.prepareStatement(sql);
        //ps.setString(1, this.getId(con));
        ps.setString(1, this.txid);
        ps.setString(2, this.acc_no);
        ps.setString(3, this.cardid);
        ps.setString(4, String.valueOf(UssdTx.OFFLINE_RELOAD));
        ps.setString(5, "0");
        ps.setString(6, this.amount);
        ps.setDouble(7, (balance_rfid + Double.parseDouble(this.amount)));
        ps.setString(8, this.loadingTerminalId);
        ps.setString(9, "");
        ps.setString(10, "");
        ps.executeUpdate();
        ps.close();

        //merchant_id, merchant_acc
        /*
        String merchant_acc_no = "";
        sql = "select m.acc_no from merchant m, loading_terminal l where terminal_id = ? and l.merchant_id = m.merchant_id";
        ps = con.prepareStatement(sql);
        ps.setString(1, this.loadingTerminalId);
        rs = ps.executeQuery();
        if (rs.next()) {

          merchant_acc_no = rs.getString(1);

        } else {

          throw new Exception("merchantid not found " + this.loadingTerminalId);
        }
        rs.close();
        ps.close();



        sql =
            "select balance from tsel_merchant_account where acc_no = ? for update ";
        ps = con.prepareStatement(sql);
        ps.setString(1, merchant_acc_no);
        rs = ps.executeQuery();
        if (rs.next()) {
          balance_merchant = rs.getDouble(1);
        } else {
          throw new Exception("merchant_acc_no not exist");
        }

        rs.close();
        ps.close();

        sql =
            "update tsel_merchant_account set balance=balance-? where acc_no = ?";
        ps = con.prepareStatement(sql);
        ps.setString(1, this.amount);
        ps.setString(2, merchant_acc_no);
        ps.executeUpdate();
        ps.close();

        sql = "insert into tsel_merchant_account_history values('', ?, ?, ?, ?, ?, ?, ?, now(), ?, ?, ?)";
        ps = con.prepareStatement(sql);
        ps.setString(1, this.txid);
        ps.setString(2, merchant_acc_no);
        ps.setString(3, this.cardid);
        ps.setString(4, "reload");
        ps.setString(5, this.amount);
        ps.setString(6, "0");
        ps.setDouble(7, (balance_merchant - Double.parseDouble(this.amount)));
        ps.setString(8, this.loadingTerminalId);
        ps.setString(9, "");
        ps.setString(10, "");
        ps.executeUpdate();
        ps.close();
      */


        con.commit();
        ret[0] = "00";
        ret[1] = this.pin_kartu;

      } else if (!b1) {

        ret[0] = "02";
        ret[1] = "amount_not_enough"; // amount not enough
        con.rollback();

      } else {
        ret[0] = "05";
        con.rollback();
      }

    } catch (Exception e) {

      try {
        con.rollback();
      } catch (Exception e1) {
        System.out.println("rollback_error " + e1.getMessage());
      }
      e.printStackTrace(System.out);

    } finally {
      if (con != null) {
        try {con.setAutoCommit(true);
        } catch (Exception e2) {}
      }
      if (con != null) {
        try {con.close();
        } catch (Exception ee) {}
      }
    }

    return ret;
  }



  public String[] submitRollback () {
   String ret[] = {"03", "03"};
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

   if (!this.validateTxidRollback()) {
     ret[0] = "07";
     ret[1] = "txid_not_found";
     return ret;
   }
   if (!validateCardId()) {
     ret[0] = "05";
     ret[1] = "cardid_not_valid";
     return ret;
   }

   /*
   if (!validatePin()) {
     ret[0] = "04";
     ret[1] = "pin_error";
     return ret;
   }
*/
   if (!this.validatePinKartu()) {
     ret[0] = "06";
     ret[1] = "cardid_not_found";
     return ret;
   }

   Connection con = null;

   try {
     con = DbCon.getConnection();
     double balance_tsel = 0;
     double balance_rfid = 0;
     double balance_merchant = 0;

     con.setAutoCommit(false);
     boolean b1 = true; // amount ok
     boolean b2 = true;

     String sql =
         "select balance from tsel_cust_account where acc_no = ? for update ";
     PreparedStatement ps = con.prepareStatement(sql);
     ps.setString(1, this.acc_no);
     ResultSet rs = ps.executeQuery();

     if (rs.next()) {
       balance_tsel = rs.getDouble(1);

     } else {
       throw new Exception("acc_no not exist");
     }

     rs.close();
     ps.close();

     sql = "select balance from rfid_account where card_id = ? for update ";
     ps = con.prepareStatement(sql);
     ps.setString(1, this.cardid);
     rs = ps.executeQuery();
     if (rs.next()) {
       balance_rfid = rs.getDouble(1);
     } else {
       b2 = false;
       throw new Exception("cardid not exist");
     }

     rs.close();
     ps.close();

     if (b1 && b2) {
       sql = "update tsel_cust_account set balance=balance+? , create_time=sysdate where acc_no = ?";
       ps = con.prepareStatement(sql);
       ps.setString(1, this.amount);
       ps.setString(2, this.acc_no);
       ps.executeUpdate();
       ps.close();

       sql = "update rfid_account set balance=balance-? ,create_time=sysdate where card_id = ?";
       ps = con.prepareStatement(sql);
       ps.setString(1, this.amount);
       ps.setString(2, this.cardid);
       ps.executeUpdate();
       ps.close();

       sql = "update log_reload set status='R', tx_date=sysdate where txid=?";
       ps = con.prepareStatement(sql);
       ps.setString(1, this.txid);
       ps.executeUpdate();
       ps.close();

       sql = "insert into tsel_cust_account_history values(?, ?, ?, ?, ?, ?, ?, sysdate, ?, ?, ?)";
       ps = con.prepareStatement(sql);
       ps.setString(1, this.getId(con));
       ps.setString(2, this.txid);
       ps.setString(3, this.acc_no);
       ps.setString(4, String.valueOf(UssdTx.OFFLINE_RELOAD_ROLLBACK));
       ps.setString(5, "0" );
       ps.setString(6, this.amount);
       ps.setDouble(7, (balance_tsel + Double.parseDouble(this.amount)));
       ps.setString(8, this.loadingTerminalId);
       ps.setString(9, "");
       ps.setString(10, "");
       ps.executeUpdate();
       ps.close();

       sql = "insert into rfid_account_history values('', ?, ?, ?, ?, ?, ?, ?, sysdate, ?, ?, ?)";
       ps = con.prepareStatement(sql);
       ps.setString(1, this.txid);
       ps.setString(2, this.acc_no);
       ps.setString(3, this.cardid);
       ps.setString(4, String.valueOf(UssdTx.OFFLINE_RELOAD_ROLLBACK));
       ps.setString(5, this.amount);
       ps.setString(6, "0");
       ps.setDouble(7, (balance_rfid - Double.parseDouble(this.amount)));
       ps.setString(8, this.loadingTerminalId);
       ps.setString(9, "");
       ps.setString(10, "");
       ps.executeUpdate();
       ps.close();



       con.commit();
       ret[0] = "00";
       ret[1] = this.pin_kartu;

     } else if (!b1) {

       ret[0] = "02";
       ret[1] = "amount_not_enough"; // amount not enough
       con.rollback();

     } else {
       ret[0] = "05";
       ret[1] = "account_not_found";
       con.rollback();
     }

   } catch (Exception e) {

     try {
       con.rollback();
     } catch (Exception e1) {
       System.out.println("rollback_error " + e1.getMessage());
     }
     e.printStackTrace(System.out);

   } finally {
     if (con != null) {
       try {con.setAutoCommit(true);
       } catch (Exception e2) {}
     }
     if (con != null) {
       try {con.close();
       } catch (Exception ee) {}
     }
   }

   return ret;
 }




 public boolean validateTxidRollback(){
 boolean b = false;
 Connection con = null;
  try {
    con = DbCon.getConnection();
    String sql =
        "select txid from log_reload where txid= ? and status = '0'";
    PreparedStatement ps = con.prepareStatement(sql);
    ps.setString(1, this.txid);

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











  public boolean validateTxid() {
    boolean b = true;
    Connection con = null;
    try {
      con = DbCon.getConnection();
      String sql =
          "select txid from log_reload where txid= ?";
      PreparedStatement ps = con.prepareStatement(sql);
      ps.setString(1, this.txid);

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

  public boolean validatePinKartu() {
    boolean b = false;
    Connection con = null;
    try {
      con = DbCon.getConnection();
      String sql =
          "select pin_kartu from rfid_card where card_id = ?";
      PreparedStatement ps = con.prepareStatement(sql);
      ps.setString(1, this.cardid);
      ResultSet rs = ps.executeQuery();

      if (rs.next()) {
        b = true;
        this.pin_kartu = rs.getString(1);

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


  public boolean validatePin() {
    boolean b = false;
    boolean b1 = false;
    Connection con = null;
    String pin_cust = "";
    String msisdn_cust = "";

    try {
      con = DbCon.getConnection();
      String sql = "select c.pin, c.acc_no, c.msisdn from customer c, rfid_account r where r.card_id = ? and  r.acc_no = c.acc_no";
      PreparedStatement ps = con.prepareStatement(sql);
      ps.setString(1, this.cardid);


      ResultSet rs = ps.executeQuery();

      if (rs.next()) {
        this.acc_no = rs.getString(2);
        pin_cust = rs.getString(1);
        msisdn_cust = rs.getString(3);
        b1 = true;
      }
      rs.close();
      ps.close();

      this.cust_msisdn = msisdn_cust;

      if(b1){

        sql = "select * from (select pin from pin_sms where msisdn = ? and pin = ? order by s_time desc) where rownum = 1";
        ps = con.prepareStatement(sql);
        ps.setString(1, msisdn_cust);
        ps.setString(2, pin_cust);
        rs = ps.executeQuery();

        if(rs.next()) b = true;
        rs.close();
        ps.close();

        sql = "delete from pin_sms where msisdn = ?";
        ps = con.prepareStatement(sql);
        ps.setString(1, msisdn_cust);
        ps.executeUpdate();
        ps.close();


      }







    } catch (Exception e) {
      e.printStackTrace(System.out);

    } finally {
      if (con != null) {try {con.close();
      } catch (Exception ee) {}

      }
    }

    return b;
  }
  /*
  public boolean validatePin() {
   boolean b = false;
   Connection con = null;
   try {
     con = DbCon.getConnection();
     String sql = "select c.pin, c.acc_no from customer c, rfid_account r where r.card_id = ? and  r.acc_no = c.acc_no and c.pin = ? ";
     PreparedStatement ps = con.prepareStatement(sql);
     ps.setString(1, this.cardid);
     ps.setString(2, this.pin);

     ResultSet rs = ps.executeQuery();

     if (rs.next()) {
       b = true;
       this.acc_no = rs.getString(2);
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

  */


  public boolean validateCardId() {
    boolean b = false;
    Connection con = null;
    try {
      con = DbCon.getConnection();
      String sql = "select card_id, acc_no from rfid_account where card_id = ? ";
      PreparedStatement ps = con.prepareStatement(sql);
      ps.setString(1, this.cardid);
      ResultSet rs = ps.executeQuery();

      if (rs.next()) {
        b = true;
        this.acc_no = rs.getString(2);

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

  public boolean validateLoginPass() {
    boolean b = false;

    Connection con = null;
    try {
      con = DbCon.getConnection();
      String sql = "select m.login from merchant m, loading_terminal l where l.terminal_id = ? and m.login = ? and m.password= ? and m.merchant_id = l.merchant_id";
      PreparedStatement ps = con.prepareStatement(sql);
      ps.setString(1, this.loadingTerminalId);
      ps.setString(2, this.login);
      ps.setString(3, Util.encMy(this.password));
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


  private boolean validateInput() {
    boolean b = true;
    if (this.cardid == null ||
        this.cardid.length() < 1) {
      b = false;
    }
    if (this.amount == null ||
        !Pattern.compile("\\d+").matcher(this.amount).matches()) {
      b = false;
    }
    if (this.pin == null) {
      b = false;
    }
    if (this.txid == null || this.txid.length() < 1) {
      b = false;
    }
    if (this.login == null || this.login.length() < 1) {
      b = false;
    }
    if (this.password == null || this.password.length() < 1) {
      b = false;
    }
   if (this.loadingTerminalId == null || this.loadingTerminalId.length() < 1) {
      b = false;

    }
    return b;
  }

  public void setCardid(String cardid) {
    this.cardid = cardid;
  }

  public void setTxid(String txid) {
    this.txid = txid;
  }

  public void setAmount(String amount) {
    this.amount = amount;
  }

  public void setPin(String pin) {
    this.pin = pin;
  }

  public void setLogin(String login) {
    this.login = login;
  }

  public void setPassword(String password) {
    this.password = password;
  }

  public void setPin_kartu(String pin_kartu) {
    this.pin_kartu = pin_kartu;
  }

  public void setLoadingTerminalId(String loadingTerminalId) {
    this.loadingTerminalId = loadingTerminalId;
  }

  public void setCust_msisdn(String cust_msisdn) {
    this.cust_msisdn = cust_msisdn;
  }


  public String getCardid() {
    return cardid;
  }

  public String getTxid() {
    return txid;
  }

  public String getAmount() {
    return amount;
  }

  public String getPin() {
    return pin;
  }

  public String getLogin() {
    return login;
  }

  public String getPassword() {
    return password;
  }

  public String getPin_kartu() {
    return pin_kartu;
  }

  public String getLoadingTerminalId() {
    return loadingTerminalId;
  }

  public String getCust_msisdn() {
    return cust_msisdn;
  }


  public Reload() {
  }


  public static void main(String[] args) {
    Reload reload1 = new Reload();
  }

}
