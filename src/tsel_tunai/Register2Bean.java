package tsel_tunai;

import java.sql.*;
import java.util.*;
import java.util.regex.*;
import java.text.*;

import org.apache.commons.dbutils.DbUtils;
import org.apache.commons.dbutils.QueryRunner;


public class Register2Bean {

  private String sample = "Start value";
  private String msisdn;
  private String card_num;
  private String card_id;
  private String name;
  private String address;
  private String city;
  private String zip;
  private String phone_num;
  private String ktp_num;
  private String cust_pin;

  private String birthdate;
  private String birthplace;
  private String mother;
  private int service_tipe;
  private int cust_limit = 2000000;

  public static final int FULL_SERVICE = 1;
  public static final int BASIC_SERVICE = 2;


  String acc_no = "";

  private Connection con;

  SimpleDateFormat sdf2 = new SimpleDateFormat("yyMMddHHmmss");
  static Random rand = new Random();

  public boolean validateInputRegSms() {
    boolean ret = true;
    if (this.msisdn == null || !this.msisdn.startsWith("628")) {
      ret = false;
    }

    if (this.birthdate == null || this.birthdate.length() < 10) {
      ret = false;
    }
    return ret;
  }

  public boolean validateInputReg() {
    boolean ret = true;
    if (this.name == null || this.name.length() < 2) {
      ret = false;
    }
    if (this.msisdn == null || !this.msisdn.startsWith("628")) {
      ret = false;
    }

    if (this.ktp_num == null || this.ktp_num.length() < 4) {
      ret = false;
    }

    if (this.address == null || this.address.length() < 2) {
      ret = false;
    }
    if (this.city == null || this.city.length() < 2) {
      ret = false;
    }
    if (this.birthplace == null || this.birthplace.length() < 2) {
      ret = false;

    }
    if (this.birthdate == null || this.birthdate.length() < 10) {
      ret = false;

    }
    System.out.println("validateInputReg name:" + this.name + " msisdn:" +
                       this.msisdn +
                       " ktp_num :" + this.ktp_num + " address:" + this.address +
                       " bdate:" + this.birthdate + " bplace :" +
                       this.birthplace + " result:" + ret);
    return ret;
  }


  public boolean checkInput() {
    boolean ret = true;
    if (this.name == null || this.name.length() < 2) {
      ret = false;
    }
    if (this.msisdn == null || !this.msisdn.startsWith("628")) {
      ret = false;
    }
    if (this.card_num == null ||
        !Pattern.compile("\\d+").matcher(this.card_num).matches()) {
      ret = false;
    }
    if (this.ktp_num == null || this.ktp_num.length() < 4) {
      ret = false;
    }
    System.out.println("name:" + this.name + " msisdn:" + this.msisdn +
                       " cek result:" + ret);
    return ret;
  }

  public void sendSms(String msisdn, String msg, String source) {
    Connection co = null;
    try {

      co = DbCon.getConnection();
      String sql =
          "insert into notif(msisdn, msg, source, s_time) values(?, ?, ?, sysdate)";
      PreparedStatement ps = co.prepareStatement(sql);
      ps.setString(1, msisdn);
      ps.setString(2, msg);
      ps.setString(3, source);
      ps.executeUpdate();
      ps.close();

    } catch (Exception e) {

      System.out.println("send_notif fail msisdn:" + msisdn + " msg:" + msg +
                         " err:" + e.getMessage());

    } finally {
      try {co.close();
      } catch (Exception ee) {}
    }

  }

  public void sendNotif(String msisdn, String pin, String accno) {

    Connection co = null;
    try {

      co = DbCon.getConnection();
      String sql =
          "insert into notif(msisdn, msg, source, s_time) values(?, ?, ?, sysdate)";
      PreparedStatement ps = co.prepareStatement(sql);
      ps.setString(1, msisdn);
      ps.setString(2, "Registrasi Telkomsel Tunai, Silakan reply \"Y\" untuk mengaktifkan account Anda ");
      ps.setString(3, "2274");
      ps.executeUpdate();
      ps.close();

    } catch (Exception e) {

      System.out.println("send_notif fail msisdn:" + msisdn + " accno:" + accno +
                         " err:" + e.getMessage());

    } finally {
      try {co.close();
      } catch (Exception ee) {}
    }
  }

  public boolean validateMsisdnB0() {
    boolean b = false;
    Connection c = null;
    try {

      c = DbCon.getConnection();
      String sql = "select * from msisdn_b0 where msisdn = ?";
      PreparedStatement ps = c.prepareStatement(sql);
      ps.setString(1, this.msisdn);
      ResultSet rs = ps.executeQuery();
      if (rs.next()) {
        b = true;
        this.name = rs.getString("name");
        this.address = rs.getString("address");
        this.city = rs.getString("city");
        this.zip = rs.getString("zipcode");
        this.phone_num = rs.getString("phone_num");
        this.ktp_num = rs.getString("ktp_no");
      }

      rs.close();
      ps.close();

    } catch (Exception e) {
      e.printStackTrace(System.out);
    } finally {
      if (c != null) {
        try {c.close();
        } catch (Exception e2) {}
      }
    }

    return b;
  }

  public String[] resetCustPin(String cmsisdn) {
    String ret[] = {"0", "internal_problem"};
    boolean b = false;

    try {
      con = DbCon.getConnection();
      String sql =
          "select acc_no, pin, service_type from customer where msisdn = ?";
      PreparedStatement ps = con.prepareStatement(sql);
      ps.setString(1, cmsisdn);

      ResultSet rs = ps.executeQuery();
      boolean b2 = false;
      String serv_tipe = "";
      if (rs.next()) {
        serv_tipe = rs.getString(3);
        b = true;

      } else {
        ret[0] = "2";
        ret[1] = "cust_not_found";
      }

      rs.close();
      ps.close();

      if (b) {
        if (Integer.parseInt(serv_tipe) == Register2Bean.FULL_SERVICE) {
          String pin = this.generatePin();
          sql = "update customer set pin = ? where msisdn = ?";
          ps = con.prepareStatement(sql);
          ps.setString(1, Util.encMy(pin));
          ps.setString(2, cmsisdn);
          ps.executeUpdate();
          ps.close();
          ret[0] = "1";
          ret[1] = pin;
        } else {
          ret[0] = "3";
          ret[1] = "Not allowed for Basic Service";
        }

      }

    } catch (Exception e) {
      e.printStackTrace(System.out);

    } finally {
      if (con != null) {try {con.close();
      } catch (Exception ee) {}

      }
    }

    return ret;
  }


  public boolean cekAccNo(String acc, Connection con)throws Exception {
    boolean b = true;
    String sql = "select acc_no from tsel_cust_account where acc_no = ?";
    PreparedStatement ps = con.prepareStatement(sql);
    ps.setString(1, acc);
    ResultSet rs = ps.executeQuery();
    if(rs.next())b = false;
    rs.close();
    ps.close();

    return b;
  }
  public String[] createAccountSms() {
    String ret[] = {"0", "internal_problem"};
    if (!this.validateInputRegSms()) {
      ret[0] = "4";
      ret[1] = "input_error";
      return ret;
    }

    if (!this.validateMsisdn()) {
      ret[0] = "2";
      ret[1] = this.cust_pin; //"msisdn_already_exist";
      return ret;
    }

    con = null;

    try {

      con = DbCon.getConnection();
      con.setAutoCommit(false);
      this.acc_no = null;

      boolean b_acc = false;

      for(int i=0; i<3; i++){
        this.acc_no = this.getAccNo();
        if(this.cekAccNo(this.acc_no, con)) {
          b_acc = true;
          break;
        }
      }

      if (!b_acc || (this.acc_no == null)) {
        System.out.println("get acc_no fail :" + this.msisdn);
        ret[0] = "0";
        ret[1] = "get_accno_fail";
        con.rollback();
        con.setAutoCommit(true);
        con.close();
        return ret;
      }

      boolean b_exist = false;
      String sql = "select msisdn from msisdn_trxid where msisdn = ?";
      PreparedStatement ps = con.prepareStatement(sql);
      ps.setString(1, msisdn);
      ResultSet rs = ps.executeQuery();
      if (rs.next()) {
        b_exist = true;
      }
      rs.close();
      ps.close();

      if (!b_exist) {
        sql = "insert into msisdn_trxid values(?, ?, sysdate, ?, ?, ?)";
        ps = con.prepareStatement(sql);
        ps.setString(1, this.msisdn);
        ps.setString(2, "0");
        ps.setString(3, "0");
        ps.setString(4, String.valueOf(this.cust_limit));
        ps.setString(5, "0|");
        ps.executeUpdate();
        ps.close();
      }

      String cust_infoid = null;
      String cust_id = null;
      cust_infoid = this.saveCustInfoOnline();
      String pin = this.generatePin();
      String pin_enc = Util.encMy(pin);
      this.createTselAcc();
      cust_id = this.saveCust(cust_infoid, pin_enc);

      this.con.commit();
      ret[0] = "1";
      ret[1] = pin;

    } catch (Exception e) {
      e.printStackTrace(System.out);
      try {con.rollback();
      } catch (Exception e2) {}

    } finally {
      if (con != null) {
        try {
          con.setAutoCommit(true);
          con.close();
        } catch (Exception ee) {}
      }
    }
    return ret;

  }


  public String[] createAccountOnline() {

    String ret[] = {"0", "internal_problem"};
    if (!this.validateInputReg()) {
      ret[0] = "4";
      ret[1] = "input_error";
      return ret;
    }

    if (!this.validateMsisdn()) {
      ret[0] = "2";
      ret[1] = this.cust_pin; //"msisdn_already_exist";
      return ret;
    }

    con = null;

    try {

      con = DbCon.getConnection();
      con.setAutoCommit(false);

      this.acc_no = this.getAccNo();
      if (this.acc_no == null) {
        throw new Exception("get acc_no fail :" + this.msisdn);
      }

      boolean b_exist = false;
      String sql = "select msisdn from msisdn_trxid where msisdn = ?";
      PreparedStatement ps = con.prepareStatement(sql);
      ps.setString(1, msisdn);
      ResultSet rs = ps.executeQuery();
      if (rs.next()) {
        b_exist = true;
      }
      rs.close();
      ps.close();

      if (!b_exist) {
        sql = "insert into msisdn_trxid values(?, ?, sysdate, ?, ?, ?)";
        ps = con.prepareStatement(sql);
        ps.setString(1, this.msisdn);
        ps.setString(2, "0");
        ps.setString(3, "0");
        ps.setString(4, String.valueOf(this.cust_limit));
        ps.setString(5, "0|");
        ps.executeUpdate();
        ps.close();
      }

      String cust_infoid = null;
      String cust_id = null;
      cust_infoid = this.saveCustInfoOnline();
      String pin = this.generatePin();
      String pin_enc = Util.encMy(pin);
      this.createTselAcc();
      cust_id = this.saveCust(cust_infoid, pin_enc);

      this.con.commit();
      ret[0] = "1";
      ret[1] = pin;
      //this.sendNotif(this.msisdn, pin, this.acc_no);

    } catch (Exception e) {
      e.printStackTrace(System.out);
      try {con.rollback();
      } catch (Exception e2) {}

    } finally {
      if (con != null) {
        try {
          con.setAutoCommit(true);
          con.close();
        } catch (Exception ee) {}
      }
    }
    return ret;
  }


  public String[] createAccount() {
    String ret[] = {"0", "internal_problem"};
    if (!this.checkInput()) {
      ret[1] = "input_error";
      return ret;
    }

    if (!this.validateMsisdn()) {
      ret[1] = "msisdn_already_exist";
      return ret;
    }

    con = null;
    boolean b1 = false;
    boolean b2 = false;
    String acc_no = null;

    try {
      con = DbCon.getConnection();
      con.setAutoCommit(false);
      //reserve card_num
      int ret_card_num = this.reserveCardnum();
      switch (ret_card_num) {
      case 1:
        b1 = true;
        break;
      case 2:
        ret[1] = "card_not_exist";
        break;
      case 3:
        ret[1] = "card_already_used";
        break;
      default:
        ret[1] = "check_card_num fail";

      }

      //get Acc_no
      if (b1) {

        acc_no = this.getAccNo();
        if (acc_no != null && acc_no.length() > 1) {
          b2 = true;
        } else {
          ret[1] = "get_account fail";

        }
      }

      String cust_infoid = null;
      String cust_id = null;

      if (b1 && b2) { // acc_no & card_num ok

        boolean b_exist = false;
        String sql = "select msisdn from msisdn_trxid where msisdn = ?";
        PreparedStatement ps = con.prepareStatement(sql);
        ps.setString(1, msisdn);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
          b_exist = true;
        }
        rs.close();
        ps.close();

        if (!b_exist) {
          sql = "insert into msisdn_trxid values(?, ?, sysdate, ?, ?, ?)";
          ps = con.prepareStatement(sql);
          ps.setString(1, this.msisdn);
          ps.setString(2, "0");
          ps.setString(3, "0");
          ps.setString(4, String.valueOf(this.cust_limit));
          ps.setString(5, "0|");
          ps.executeUpdate();
          ps.close();
        }

        cust_infoid = this.saveCustInfoOnline();
        String pin = this.generatePin();
        String pin_enc = Util.encMy(pin);
        this.createTselAcc();
        cust_id = this.saveCust(cust_infoid, pin_enc);

        this.createRfidAcc();
        con.commit();
        ret[0] = "1";
        ret[1] = pin;
        //this.sendNotif(this.msisdn, pin, this.acc_no);

      } else {
        con.rollback();

      }

    } catch (Exception e) {

      try {
        con.rollback();
      } catch (Exception e2) {
        System.out.println("rollback_error " + e2.getMessage());
      }
      e.printStackTrace(System.out);

    } finally {
      if (con != null) {
        try {
          con.setAutoCommit(true);
          con.close();
        } catch (Exception ee) {}
      }

    }

    return ret;
  }

  private void createTselAcc() throws Exception {

    String sql = "insert into tsel_cust_account values(?, ? ,?, sysdate, '1')";
    PreparedStatement ps = con.prepareStatement(sql);
    ps.setString(1, this.acc_no);
    ps.setString(2, "");
    ps.setString(3, "0");
    ps.executeUpdate();
    ps.close();
    ps = null;

  }

  private void createRfidAcc() throws Exception {
    String sql = "insert into rfid_account values(?, ? ,?, ?, sysdate, '0')";
    PreparedStatement ps = con.prepareStatement(sql);
    ps.setString(1, this.card_id);
    ps.setString(2, this.card_num);
    ps.setString(3, this.acc_no);
    ps.setString(4, "0");
    ps.executeUpdate();
    ps.close();
    ps = null;

  }

  private String generatePin() throws Exception {
    String ret = null;
    ret = Util.generateRandomInt();
    return ret;
  }

  private String saveCust(String cust_infoid, String pin) throws Exception {
    String cust_id = null;
    cust_id = this.getId();
    String sql = "insert into customer values(? , ?, ?, ?, ?, sysdate, ?)";
    PreparedStatement ps = con.prepareStatement(sql);
    ps.setString(1, cust_id);
    ps.setString(2, cust_infoid);
    ps.setString(3, this.acc_no);
    ps.setString(4, this.msisdn);
    ps.setString(5, pin);
    ps.setString(6, String.valueOf(this.service_tipe));

    ps.executeUpdate();

    ps.close();

    return cust_id;
  }

  private String saveCustInfo() throws Exception {

    String cust_infoid = null;
    String sql =
        "insert into customer_info values('', ?, ?, ?, ?, ?, ?, now(), '', ?)";
    PreparedStatement ps = con.prepareStatement(sql,
                                                Statement.
                                                RETURN_GENERATED_KEYS);
    ps.setString(1, this.name);
    ps.setString(2, this.address);
    ps.setString(3, this.city);
    ps.setString(4, this.zip);
    ps.setString(5, this.phone_num);
    ps.setString(6, this.ktp_num);
    ps.setString(7, this.mother);
    ps.executeUpdate();
    ResultSet rs = ps.getGeneratedKeys();
    if (rs.next()) {
      cust_infoid = rs.getString(1);
    }
    rs.close();
    ps.close();

    return cust_infoid;
  }

  public String getId() throws Exception {
    String ret = null;
    String sql = "select seq_id.nextval from dual";
    Statement st = con.createStatement();
    ResultSet rs = st.executeQuery(sql);
    if (rs.next()) {

      ret = sdf2.format(new java.util.Date()) + rs.getString(1);

    } else {
      throw new Exception("fail get id from oracle seq_id");
    }
    rs.close();
    st.close();

    return ret;
  }

  private String saveCustInfoOnline() throws Exception {

    String cust_infoid = this.getId();
    String sql =
        "insert into customer_info values(? , ?, ?, ?, ?, ?, ?, sysdate, to_date(?, 'YYYY-MM-DD'), ?, 'sms', ?)";
    PreparedStatement ps = con.prepareStatement(sql);
    ps.setString(1, cust_infoid);
    ps.setString(2, this.name);
    ps.setString(3, this.address);
    ps.setString(4, this.city);
    ps.setString(5, this.zip);
    ps.setString(6, this.phone_num);
    ps.setString(7, this.ktp_num);
    ps.setString(8, this.birthdate);
    ps.setString(9, this.birthplace);
    ps.setString(10, this.mother);
    ps.executeUpdate();
    ps.close();

    return cust_infoid;
  }


  private String saveCustInfoSms() throws Exception {

    String cust_infoid = null;
    String sql =
        "insert into customer_info values('', ?, ?, ?, ?, ?, ?, now(), 'sms', ?)";
    PreparedStatement ps = con.prepareStatement(sql,
                                                Statement.
                                                RETURN_GENERATED_KEYS);
    ps.setString(1, this.name);
    ps.setString(2, this.address);
    ps.setString(3, this.city);
    ps.setString(4, this.zip);
    ps.setString(5, this.phone_num);
    ps.setString(6, this.ktp_num);
    ps.setString(7, this.mother);
    ps.executeUpdate();
    ResultSet rs = ps.getGeneratedKeys();
    if (rs.next()) {
      cust_infoid = rs.getString(1);
    }
    rs.close();
    ps.close();

    return cust_infoid;
  }


  public boolean validateMsisdn() {
    boolean b = true;
    Connection c = null;
    try {

      c = DbCon.getConnection();
      String sql = "select msisdn, pin from customer where msisdn = ?";
      PreparedStatement ps = c.prepareStatement(sql);
      ps.setString(1, this.msisdn);
      ResultSet rs = ps.executeQuery();
      if (rs.next()) {
        b = false;
        //this.cust_pin = rs.getString(2);
        this.cust_pin = Util.decMy(rs.getString(2));
      }

      rs.close();
      ps.close();

    } catch (Exception e) {
      e.printStackTrace(System.out);
    } finally {
      if (c != null) {
        try {c.close();
        } catch (Exception e2) {}
      }
    }

    return b;
  }

  private String getAccNo() {
    String ret = null;

    // Random integers
    int i = rand.nextInt();
    // Continually call nextInt() for more random integers ...

    // Random integers that range from from 0 to n
    int n = 999998;
    i = rand.nextInt(n + 1);

    ret = String.valueOf(i);
    int le = 6 - ret.length();
    for (int x = 0; x < le; x++) {
      ret = ret + "0";
    }

    i = rand.nextInt(n + 1);

    String tmp1 = String.valueOf(i);
    int le2 = 6 - tmp1.length();
    for (int x = 0; x < le2; x++) {
      tmp1 = tmp1 + "0";
    }

    ret = ret + tmp1;

    return ret;
  }
  
  public String[] changeMsisdn(String oldMsisdn, String newMsisdn, String operator) {
	  Connection conn = null;
	  try {
		conn = DbCon.getConnection();
		String q = "UPDATE customer SET msisdn=? WHERE msisdn=?";
		QueryRunner qr = new QueryRunner();
		qr.update(conn, q, new Object[] {newMsisdn, oldMsisdn});
		
		q = "INSERT INTO change_msisdn_history (old_msisdn, new_msisdn, ts, operator) VALUES (?,?,sysdate,?)";
		qr.update(conn, q, new Object[] {newMsisdn, oldMsisdn, operator});
		return new String[] {"1", "Success"};
	} catch (Exception e) {
		e.printStackTrace();
		return new String[] {"0", "SystemError"};
	} finally {
		DbUtils.closeQuietly(conn);
	}
  }


  /*
       private String getAccNo() {
    String ret = null;
    Connection c = null;
    try {

      c = DbCon.getConnection();
      c.setAutoCommit(false);
      String sql =
          "select * from acc_no where status='0' and rownum = 1 for update";
      Statement st = c.createStatement();
      ResultSet rs = st.executeQuery(sql);

      if (rs.next()) {
        acc_no = rs.getString("acc_no");
        ret = acc_no;
      }

      rs.close();
      st.close();

      sql = "update acc_no set status='1' where acc_no = ?";
      PreparedStatement ps = c.prepareStatement(sql);
      ps.setString(1, acc_no);
      ps.executeUpdate();
      ps.close();
      c.commit();

    } catch (Exception e) {
      e.printStackTrace(System.out);
      try {
        c.rollback();
      } catch (Exception ee) {
        System.out.println("rollback_error :" + ee.getMessage());
        ee.printStackTrace(System.out);
      }
    } finally {
      if (c != null) {
        try {
          c.setAutoCommit(true);
          c.close();
        } catch (Exception ee) {}
      }
      c = null;
    }

    return ret;
       }
   */
  private int reserveCardnum() throws Exception {
    int ret = 0; //0=fail 1=success 2=card_not_exist 3=already_used
    String sql =
        "select * from rfid_card where card_fisik_num = ? for update";
    PreparedStatement ps = con.prepareStatement(sql);
    ps.setString(1, this.card_num);
    ResultSet rs = ps.executeQuery();
    if (rs.next()) {
      if (rs.getString("status").equals("0")) {
        ret = 1;
        this.card_id = rs.getString("card_id");
      } else {
        ret = 3;
      }

    } else {
      ret = 2;
    }
    rs.close();
    ps.close();

    if (ret == 1) {

      sql = "update rfid_card set status = '1' where card_fisik_num = ?";
      ps = con.prepareStatement(sql);
      ps.setString(1, this.card_num);
      ps.executeUpdate();
      ps.close();
    }
    rs = null;
    ps = null;

    return ret;
  }


  //Access sample property
  public String getSample() {
    return sample;
  }

  public String getMsisdn() {
    return msisdn;
  }

  public String getCard_num() {
    return card_num;
  }

  public String getAddress() {
    return address;
  }

  public String getCity() {
    return city;
  }

  public String getZip() {
    return zip;
  }

  public String getKtp_num() {
    return ktp_num;
  }

  public String getPhone_num() {
    return phone_num;
  }

  public String getName() {
    return name;
  }

  public String getBirthdate() {
    return birthdate;
  }

  public String getBirthplace() {
    return birthplace;
  }

  public String getMother() {
    return mother;
  }

  public int getService_tipe() {
    return service_tipe;
  }

  public int getCust_limit() {
    return cust_limit;
  }


  //Access sample property

  public void setSample(String newValue) {
    if (newValue != null) {
      sample = newValue;
    }
  }

  public void setMsisdn(String msisdn) {
    this.msisdn = msisdn;
  }

  public void setCard_num(String card_num) {
    this.card_num = card_num;
  }

  public void setAddress(String address) {
    this.address = address;
  }

  public void setCity(String city) {
    this.city = city;
  }

  public void setZip(String zip) {
    this.zip = zip;
  }

  public void setKtp_num(String ktp_num) {
    this.ktp_num = ktp_num;
  }

  public void setPhone_num(String phone_num) {
    this.phone_num = phone_num;
  }

  public void setName(String name) {
    this.name = name;
  }

  public void setBirthdate(String birthdate) {
    this.birthdate = birthdate;
  }

  public void setBirthplace(String birthplace) {
    this.birthplace = birthplace;
  }

  public void setMother(String mother) {
    this.mother = mother;
  }

  public void setService_tipe(int service_tipe) {
    this.service_tipe = service_tipe;
  }

  public void setCust_limit(int cust_limit) {
    this.cust_limit = cust_limit;
  }

}
