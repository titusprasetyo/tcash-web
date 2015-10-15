package tsel_tunai;

import java.sql.*;
import java.text.*;
import java.util.regex.*;


public class Customer {

  private String name;
  private String address;
  private String zip;
  private String city;
  private String id_num;
  private String mother;
  private String phone_num;
  private String birthplace;
  private String birthdate;
  private String msisdn;
  private String tsel_cust_acc;
  private String cust_id;
  private String cust_info_id;
  private String service_type;


  static SimpleDateFormat sdf = new SimpleDateFormat("dd-MM-yyyy");

  public String getMother() {
    return mother;
  }

  public String getTsel_cust_acc() {
    return tsel_cust_acc;
  }

  public String getCity() {
    return city;
  }

  public String getName() {
    return name;
  }

  public String getId_num() {
    return id_num;
  }

  public String getZip() {
    return zip;
  }

  public String getPhone_num() {
    return phone_num;
  }

  public String getBirthdate() {
    return birthdate;
  }

  public String getAddress() {
    return address;
  }

  public String getCust_id() {
    return cust_id;
  }

  public String getBirthplace() {
    return birthplace;
  }

  public String getCust_info_id() {
    return cust_info_id;
  }

  public void setMsisdn(String msidn) {
    this.msisdn = msidn;
  }

  public void setMother(String mother) {
    this.mother = mother;
  }

  public void setTsel_cust_acc(String tsel_cust_acc) {
    this.tsel_cust_acc = tsel_cust_acc;
  }

  public void setCity(String city) {
    this.city = city;
  }

  public void setName(String name) {
    this.name = name;
  }

  public void setId_num(String id_num) {
    this.id_num = id_num;
  }

  public void setZip(String zip) {
    this.zip = zip;
  }

  public void setPhone_num(String phone_num) {
    this.phone_num = phone_num;
  }

  public void setBirthdate(String birthdate) {
    this.birthdate = birthdate;
  }

  public void setAddress(String address) {
    this.address = address;
  }

  public void setCust_id(String cust_id) {
    this.cust_id = cust_id;
  }

  public void setBirthplace(String birthplace) {
    this.birthplace = birthplace;
  }

  public void setCust_info_id(String cust_info_id) {
    this.cust_info_id = cust_info_id;
  }

  public void setService_type(String service_type) {
    this.service_type = service_type;
  }

  public String getMsisdn() {
    return msisdn;
  }

  public String getService_type() {
    return service_type;
  }


  public Customer() {
  }

  public String[] getCustInfo(String msisdn) {

    String ret[] = {"00", "internal_problem"};
    Connection con = null;

    try {
      this.setMsisdn(msisdn);
      con = DbCon.getConnection();
      String sql = "select * from customer c, customer_info ci where msisdn = ? and c.cust_info_id = ci.cust_info_id ";
      PreparedStatement ps = con.prepareStatement(sql);
      ps.setString(1, msisdn);
      ResultSet rs = ps.executeQuery();

      if (rs.next()) {

        this.setName(rs.getString("name"));
        this.setAddress(rs.getString("address"));
        this.setCity(rs.getString("city"));
        this.setZip(rs.getString("zipcode"));
        this.setPhone_num(rs.getString("phone_num"));

        Date da = rs.getDate("birthdate");
        if (da != null) {
          this.setBirthdate(sdf.format(da));
        } else {
          this.setBirthdate("dd-mm-yyyy");
        }

        this.setBirthplace(rs.getString("birthcity"));
        this.setId_num(rs.getString("ktp_no"));
        this.setMother(rs.getString("mother"));
        this.setService_type(rs.getString("service_type"));

        this.setCust_id(rs.getString("cust_id"));
        this.setCust_info_id(rs.getString("cust_info_id"));
        ret[0] = "01";

      } else {
        ret[0] = "02";
        ret[1] = "customer_not_found";
      }

      rs.close();
      ps.close();

    } catch (Exception e) {
      e.printStackTrace(System.out);
    } finally {
      if (con != null) {
        try {
          con.close();
          System.out.println("getCustInfo : con_close");
        } catch (Exception e2) {}
      }
    }

    return ret;
  }

  public String[] updateCustData(String cust_msisdn) {
    String ret[] = {"00", "internal_problem"};
    Connection con = null;

    try {

      con = DbCon.getConnection();
      con.setAutoCommit(false);

      /*
      String r[] = this.getCustInfo(cust_msisdn);
      if (!r[0].equals("01")) {
        throw new Exception("fail getCustInfo :" + cust_msisdn);
      }
      }
     */
      String sql =
          "update customer_info set name = ?, address = ?, city = ?, zipcode = ?,  "
          + " phone_num = ?, ktp_no = ?, create_time = sysdate, birthdate = to_date(?, 'DD-MM-YYYY'), "
          + " birthcity = ?, mother = ? where cust_info_id = ?";
      System.out.println("updateCustInfo name:" + name + " address:" + address +
                         " city:" + city + " zip:" + zip + " phone_num:" +
                         phone_num+" birthdate:"+this.birthdate+" cust_info_id:"+this.cust_info_id);
      PreparedStatement ps = con.prepareStatement(sql);
      ps.setString(1, this.name);
      ps.setString(2, this.address);
      ps.setString(3, this.city);
      ps.setString(4, this.zip);
      ps.setString(5, this.phone_num);
      ps.setString(6, this.id_num);
      ps.setString(7, this.birthdate);
      ps.setString(8, this.birthplace);
      ps.setString(9, this.mother);
      ps.setString(10, this.cust_info_id);
      ps.executeUpdate();
      ps.close();

      sql = "update customer set service_type = ? where cust_id = ?";
      ps = con.prepareStatement(sql);
      ps.setString(1, this.service_type);
      ps.setString(2, this.cust_id);
      ps.executeUpdate();
      ps.close();

      con.commit();

      ret[0] = "01";
      ret[1] = this.cust_info_id;

    } catch (Exception e) {

      e.printStackTrace(System.out);
      try {con.rollback();
      } catch (Exception e3) {}

    } finally {
      if (con != null) {

        try {
          con.setAutoCommit(true);
          con.close();
          System.out.println("updateCustInfo : con_close");
        } catch (Exception e2) {}
      }
    }
    return ret;
  }

  public static void main(String[] args) {
    Customer customer1 = new Customer();
  }

}
