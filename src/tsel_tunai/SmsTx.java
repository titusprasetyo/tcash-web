package tsel_tunai;

import java.sql.*;
import java.text.*;
import java.util.regex.*;


public class SmsTx {

  static NumberFormat formatter = new DecimalFormat("###,###,###");
  SimpleDateFormat sdf = new SimpleDateFormat("dd-MM-yyyy HH:mm:ss");

  SimpleDateFormat sdf2 = new SimpleDateFormat("ddMMyyHHmmss");
  private String cust_acc;
  private String cust_pin;
  private String cust_msisdn;
  private String input_custPin;
  Connection con = null;

  public boolean validateCustPin() {
  boolean b = false;
  if (this.cust_pin.equals(this.input_custPin)) {
    b = true;
  }
  return b;
}


  public boolean validateCust() {
  boolean b = false;
  con = null;
  try {
    con = DbCon.getConnection();
    String sql = "select acc_no, pin from customer where msisdn = ?";
    PreparedStatement ps = con.prepareStatement(sql);
    ps.setString(1, this.cust_msisdn);

    ResultSet rs = ps.executeQuery();

    if (rs.next()) {
      cust_acc = rs.getString(1);
      cust_pin = Util.decMy(rs.getString(2));
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


public void reserveBalance() throws Exception {

  String sql = "";

}

public String [] doRecharge(){
  String ret [] = { "00", "internal_problem" };
  try {



  }catch(Exception e){
    e.printStackTrace();
    try { con.rollback(); } catch(Exception e2){}

  } finally{

  }

  return ret;
}


  public SmsTx() {
  }
  public static void main(String[] args) {
    SmsTx smsTx1 = new SmsTx();
  }

}
