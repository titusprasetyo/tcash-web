package tsel_tunai;

import java.sql.*;
import java.util.regex.*;
import java.text.*;



public class CashIn {
  private String amount;
  private String userlogin;
  private String loadingTerminalId;
  private String msisdn;
  SimpleDateFormat sdf2 = new SimpleDateFormat("ddMMyyHHmmss");

  public boolean validateInput() {
    boolean b = true;

    if (msisdn == null || !msisdn.startsWith("62")) {
      b = false;
    }
    if (amount == null || !Pattern.compile("\\d+").matcher(this.amount).matches()) {
      b = false;

    }

    if(userlogin == null || userlogin.length() < 1) b = false;

    if(this.loadingTerminalId == null || this.loadingTerminalId.length() < 1) b = false;

    return b;
  }

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


  public String[] send() {
    String ret[] = {"0", "internal_problem"};

    if (!this.validateInput()) {
      ret[1] = "input_error";
      return ret;
    }

    Connection con = null;
    try {

      con = DbCon.getConnection();
      con.setAutoCommit(false);
      String sql = "select c.acc_no, t.status from customer c, tsel_cust_account t where c.msisdn = ? and t.acc_no = c.acc_no";
      PreparedStatement ps = con.prepareStatement(sql);
      ps.setString(1, this.msisdn);
      ResultSet rs = ps.executeQuery();
      String acc_no = "";
      String status = "";

      boolean b1 = false;
      boolean b2 = false;
      boolean b3 = false;
      if (rs.next()) {
        acc_no = rs.getString(1);
        b1 = true;
        status = rs.getString(2);
        if (status != null && status.equals("1")) {
          b2 = true;
        } else {
          ret[1] = "account_not_active";
        }
      }

      rs.close();
      ps.close();

      double balance_cust = 0;
      double balance_merchant = 0;


      if (b1 && b2) {
        sql = "select * from tsel_cust_account where acc_no = ? for update";
        ps = con.prepareStatement(sql);
        ps.setString(1, acc_no);
        rs = ps.executeQuery();
        if (rs.next()) {
          b3 = true;
          balance_cust = rs.getDouble("balance");
        } else {
          throw new Exception("acc_no not found " + msisdn + " accno:" + acc_no);
        }
        rs.close();
        ps.close();

        if (b3) {
          sql =
              "update tsel_cust_account set balance=balance+? where acc_no = ?";
          ps = con.prepareStatement(sql);
          ps.setString(1, this.amount);
          ps.setString(2, acc_no);
          ps.executeUpdate();

          String db_trxid = this.getId(con);

          //history tsel_account
          sql = "insert into tsel_cust_account_history values(?, ?, ?, ?, ?, ?, ?, sysdate, ?, ?, ?)";
          ps = con.prepareStatement(sql);
          ps.setString(1, db_trxid);
          ps.setString(2, "txid");
          ps.setString(3, acc_no);
          ps.setString(4, String.valueOf(UssdTx.TSEL_CASH_IN));
          ps.setString(5, "0");
          ps.setString(6, this.amount);
          ps.setDouble(7, (balance_cust + Double.parseDouble(this.amount)));
          ps.setString(8, this.loadingTerminalId);
          ps.setString(9, "");
          ps.setString(10, this.userlogin);
          ps.executeUpdate();
          ps.close();

          //end of history tsel_account

          //merchant_id, merchant_acc

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

      sql = "insert into tsel_merchant_account_history values(?, ?, ?, ?, ?, ?, ?, ?, sysdate, ?, ?, ?)";
      ps = con.prepareStatement(sql);
      ps.setString(1, db_trxid);
      ps.setString(2, "txid");
      ps.setString(3, merchant_acc_no);
      ps.setString(4, this.msisdn);
      ps.setString(5, String.valueOf(UssdTx.TSEL_CASH_IN));
      ps.setString(6, this.amount);
      ps.setString(7, "0");
      ps.setDouble(8, (balance_merchant - Double.parseDouble(this.amount)));
      ps.setString(9, this.loadingTerminalId);
      ps.setString(10, "");
      ps.setString(11, this.userlogin);
      ps.executeUpdate();
      ps.close();
    //end of merchant_account history
    con.commit();
    ret[0] = "1";
    ret[1] = "Success";





        } else {
          con.rollback();
        }

      } else {
        if (!b1) {
          ret[1] = "account_not_found";
        }
        con.rollback();
      }

    } catch (Exception e) {
      e.printStackTrace(System.out);
      try {con.rollback();
      } catch (Exception e2) {}

    } finally {
      if (con != null) {
        try {con.setAutoCommit(true);
        } catch (Exception e4) {}
      }
      if (con != null) {
        try {con.close();
        } catch (Exception e3) {}
      }
    }

    return ret;
  }

  public void setMsisdn(String msisdn) {
    this.msisdn = msisdn;
  }

  public void setAmount(String amount) {
    this.amount = amount;
  }

  public void setUserlogin(String userlogin) {
    this.userlogin = userlogin;
  }

  public void setLoadingTerminalId(String loadingTerminalId) {
    this.loadingTerminalId = loadingTerminalId;
  }

  public String getMsisdn() {
    return msisdn;
  }

  public String getAmount() {
    return amount;
  }

  public String getUserlogin() {
    return userlogin;
  }

  public String getLoadingTerminalId() {
    return loadingTerminalId;
  }


  public CashIn() {
  }

  public static void main(String[] args) {
    CashIn cashIn1 = new CashIn();
  }

}
