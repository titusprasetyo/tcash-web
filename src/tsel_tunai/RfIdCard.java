package tsel_tunai;

import java.sql.*;

public class RfIdCard {

  private String msisdn = null;
  private String card_num = null;
  private String acc_no;
  private String card_id;
  private String err_msg;


  public boolean isValid(){
    boolean b = false;
    Connection con = null;
    try {

      con = DbCon.getConnection();
      String sql = "select * from rfid_account where card_fisik_num = ?";
      PreparedStatement ps = con.prepareStatement(sql);
      ps.setString(1, this.card_num);
      ResultSet rs = ps.executeQuery();
      boolean b1 = false;

      if(rs.next()){
        this.card_id = rs.getString("card_id");
        this.acc_no = rs.getString("acc_no");
        b1 = true;
      } else {
        this.err_msg = "card not found";
      }

      rs.close();
      ps.close();

      if(b1){
        sql = "select msisdn from customer where acc_no = ?";
        ps = con.prepareStatement(sql);
        ps.setString(1, this.acc_no);
        rs = ps.executeQuery();

        if(rs.next()){
          this.msisdn = rs.getString(1);
          b = true;
        } else {
          this.err_msg = "msisdn not found";
        }

      }






    }catch(Exception e){
      e.printStackTrace(System.out);
    } finally{
      try {

        if(con != null) con.close();

      }catch(Exception e2){}
    }


    return b;
  }

  public void setMsisdn(String msisdn) {
    this.msisdn = msisdn;
  }

  public void setCard_num(String card_num) {
    this.card_num = card_num;
  }

  public void setErr_msg(String err_msg) {
    this.err_msg = err_msg;
  }

  public void setAcc_no(String acc_no) {
    this.acc_no = acc_no;
  }

  public void setCard_id(String card_id) {
    this.card_id = card_id;
  }

  public String getMsisdn() {
    return msisdn;
  }

  public String getCard_num() {
    return card_num;
  }

  public String getErr_msg() {
    return err_msg;
  }

  public String getCard_id() {
    return card_id;
  }

  public RfIdCard() {
  }
  public static void main(String[] args) {
    RfIdCard rfIdCard1 = new RfIdCard();
  }

}
