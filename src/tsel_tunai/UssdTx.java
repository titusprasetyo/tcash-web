package tsel_tunai;

import java.sql.*;
import java.text.*;
import java.util.regex.*;

public class UssdTx {

  static NumberFormat formatter = new DecimalFormat("###,###,###");
  SimpleDateFormat sdf = new SimpleDateFormat("dd-MM-yyyy HH:mm:ss");

  SimpleDateFormat sdf2 = new SimpleDateFormat("ddMMyyHHmmss");

  SimpleDateFormat sdf3 = new SimpleDateFormat("yyyyMMdd");

  private String cust_acc;
  private String amount;
  private String trx_id;
  private String merchant_id;
  private String merchant_acc;
  private String msg;
  private String trx_tipe = "0";
  private String merchant_msisdn;
  private String merchant_name;
  private String terminal_id;
  private String input_custPin;
  private String cust_pin = "";
  //wd 180413
  private String isExecuted = "0";

  private String merchant_trxid;
  private String note;

  private String cust_msisdn;

  private String cust_acc_status;
  private String merchant_acc_status;
  private double merchant_acc_balance;
  private double cust_acc_balance;


  public static final int TSEL_CASH_IN = 1;
	public static final int USSD_PAYMENT = 2;
	public static final int USSD_CASHIN = 3;
	public static final int USSD_CASHOUT = 4;
	public static final int OFFLINE_RELOAD = 5;
	public static final int OFFLINE_RELOAD_ROLLBACK = 6;
	public static final int BONUS_CASHIN = 7;
	public static final int MERCHANT_DEPOSIT = 8;

	public static final int OFFLINE_CASHOUT = 9;
	public static final int OFFLINE_CASHOUT_ROLLBACK = 10;

	public static final int AIRTIME_TOPUP = 11;
	public static final int AIRTIME_TOPUP_ROLLBACK = 12;

	public static final int P2P_TRANSFER = 13;
	
	public static final int USSD_CASHIN_INT = 14;
	
	public static final int P2P_TRANSFER_INT = 15;
	
	public static final int MONTHLY_CHARGE_DEBT = 99;
	
	public static final int MERCHANT_OL_CREDIT = 100;
  
  public static final int MERCHANT_CASHOUT = 101;


  public static final String TSEL_CUST_ACC_ACTIVE = "1";
  public static final String TSEL_MERCHANT_ACC_ACTIVE = "1";


  boolean doSendNotif = true;


  String notif_message = "";


  public static String getTxtipe(int i) {
		String ret = "UNKNOWN";
		switch (i) {

		case 1:

			//ret = "TSEL_CASH_IN";
			ret = "Tsel Cash in";
			break;
		case 2:

			//ret = "USSD_PAYMENT";
			ret = "Pembelian";
			break;
		case 3:

			//ret = "USSD_CASHIN";
			ret = "Cash in";
			break;

		case 4:

			//ret = "USSD_CASHOUT";
			ret = "Cash out";
			break;

		case 5:

			//ret = "OFFLINE_RELOAD";
			ret = "Reload";
			break;

		case 6:

			//ret = "OFFLINE_RELOAD_ROLLBACK";
			ret = "Reload_rollback";
			break;

		case 7:

			//ret = "BONUS_CASHIN";
			ret = "Bonus_topup";
			break;

		case 8:

			//ret = "Merchant_CASHIN";
			ret = "Merchant_deposit";
			break;

		case 9:

			//ret = "Offline Cash out";
			ret = "Offline Cash Out";
			break;

		case 10:

			//ret = "Rollback Offline Cash out";
			ret = "Offline Cash Out Rollback";
			break;

		case 11:

			//ret = "Airtime Top Up";
			ret = "Top Up Pulsa";
			break;

		case 12:

			//ret = "Reversal Airtime Top Up";
			ret = "Rollback Top Up Pulsa";
			break;

		case 13:

			//ret = "BONUS_CASHIN";
			ret = "P2P Transfer";
			break;
			
		case 14:

			//ret = "BONUS_CASHIN";
			ret = "Cashin.Int";
			break;
			
		case 15:

			//ret = "BONUS_CASHIN";
			ret = "ITransfer";
			break;
		
		case 99:
			
			ret = "Monthly Fee - Debt";
			break;
					
		case 100:

			//ret = "BONUS_CASHIN";
			ret = "Merchant OL Credit";
			break;
			
		case 101:

			//ret = "BONUS_CASHIN";
			ret = "Merchant Cashout";
			break;
		}

		return ret;
	}



  public boolean validateInputPaymentConfirm() {
    boolean b = true;
    if (this.trx_id == null ||
        !Pattern.compile("\\d+").matcher(this.trx_id).matches()) {
      b = false;
      return b;

    }

    return b;

  }

  public boolean validateCekPayment() {
    boolean b = true;
    if (this.merchant_trxid == null ||
        !Pattern.compile("\\d+").matcher(this.merchant_trxid).matches()) {
      b = false;
      return b;

    }

    if (this.cust_msisdn == null ||
        !Pattern.compile("\\d+").matcher(this.cust_msisdn).matches()) {
      b = false;
      return b;

    }

    return b;

  }


  public boolean validateInputPaymentPos() {
    boolean b = true;

    if (amount == null || !Pattern.compile("\\d+").matcher(this.amount).matches()) {
      b = false;
      return b;

    }

    if (this.cust_msisdn == null ||
        !Pattern.compile("\\d+").matcher(this.cust_msisdn).matches()) {
      b = false;
      return b;

    }

    System.out.println("validate_input_ok merchant_msisdn:" +
                       this.merchant_msisdn + " cust_msisdn" + this.cust_msisdn +
                       " amount:" + this.amount);

    return b;
  }

  public boolean validateCustPin() {
    boolean b = false;
    if (this.cust_pin.equals(this.input_custPin)) {
      b = true;
    }
    return b;
  }

  public boolean validateCustBalance() {
    boolean b = false;

    if (Double.parseDouble(this.amount) <= this.cust_acc_balance) {
      b = true;
    }

    return b;
  }


  public boolean validateMerchantBalance() {
    boolean b = false;

    if (Double.parseDouble(this.amount) <= this.merchant_acc_balance) {
      b = true;
    }

    return b;
  }


  public boolean validateCust() {
    boolean b = false;
    Connection con = null;
    try {
      con = DbCon.getConnection();
      //String sql = "select acc_no, pin from customer c, tsel_cust_account t where msisdn = ?";
      String sql = "select c.acc_no, c.pin, t.status, t.balance from customer c, tsel_cust_account t where msisdn = ? and c.acc_no = t.acc_no";
      PreparedStatement ps = con.prepareStatement(sql);
      ps.setString(1, this.cust_msisdn);

      ResultSet rs = ps.executeQuery();

      if (rs.next()) {
        this.cust_acc = rs.getString(1);
        //this.cust_pin = rs.getString(2);
        this.cust_pin = Util.decMy(rs.getString(2));
        this.cust_acc_status = rs.getString(3);
        this.cust_acc_balance = rs.getDouble(4);
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

  public boolean addBonusBalance(String am) {
    boolean b = true;
    Connection con = null;

    this.amount = am;
    if (!this.validateCust()) {
      System.out.print("bonus_balance fail :" + this.cust_msisdn);
      b = false;
      return b;
    }

    try {

      con = DbCon.getConnection();
      con.setAutoCommit(false);

      this.trx_id = this.getMerchantTrxid();

      String sql =
          "select balance from tsel_cust_account where acc_no = ? for update";
      PreparedStatement ps = con.prepareStatement(sql);
      ps.setString(1, this.cust_acc);
      ResultSet rs = ps.executeQuery();
      double balance_cust = 0;
      if (rs.next()) {

        balance_cust = rs.getDouble(1);

      } else {
        throw new Exception("account_not_found :" + this.cust_msisdn);
      }

      rs.close();
      ps.close();

      double balance_cust_new = balance_cust + Double.parseDouble(this.amount);

      sql = "update tsel_cust_account set balance =  ? where acc_no = ?";
      ps = con.prepareStatement(sql);
      ps.setDouble(1, balance_cust_new);
      ps.setString(2, this.cust_acc);

      ps.executeUpdate();

      ps.close();

      //history tsel_account
      sql = "insert into tsel_cust_account_history values('', ?, ?, ?, ?, ?, ?, sysdate, ?, ?, ?)";
      ps = con.prepareStatement(sql);
      ps.setString(1, this.trx_id);
      ps.setString(2, this.cust_acc);

      ps.setString(3, String.valueOf(UssdTx.BONUS_CASHIN));

      ps.setString(4, "0");
      ps.setString(5, this.amount);
      ps.setDouble(6, balance_cust_new);
      ps.setString(7, "");
      ps.setString(8, "0"); //terminal_id
      ps.setString(9, "");
      ps.executeUpdate();
      ps.close();
      con.commit();
      b = true;

    } catch (Exception e) {
      e.printStackTrace(System.out);
      try {con.rollback();
      } catch (Exception e2) {}
    } finally {
      if (con != null) {
        try {con.close();
        } catch (Exception e3) {}
      }
    }

    return b;
  }


  public boolean validateMerchant() {
    boolean b = false;

    Connection con = null;
    try {
      con = DbCon.getConnection();
      String sql = "select m.merchant_id, m.acc_no, i.description, i.terminal_id from merchant m, reader_terminal i where i.msisdn = ? and m.merchant_id = i.merchant_id ";
      PreparedStatement ps = con.prepareStatement(sql);
      ps.setString(1, this.merchant_msisdn);

      ResultSet rs = ps.executeQuery();

      if (rs.next()) {
        this.merchant_id = rs.getString(1);
        this.merchant_acc = rs.getString(2);
        this.merchant_name = rs.getString(3);
        this.terminal_id = rs.getString(4);

      }
      rs.close();
      ps.close();

      sql =
          "select status , balance from tsel_merchant_account where acc_no = ?";
      ps = con.prepareStatement(sql);
      ps.setString(1, this.merchant_acc);
      rs = ps.executeQuery();
      if (rs.next()) {
        b = true;
        this.merchant_acc_status = rs.getString(1);
        this.merchant_acc_balance = rs.getDouble(2);

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


  public String getMerchantTrxid() throws Exception {
    String ret = "";
    boolean fail = false;

    Connection con = null;
    try {
      con = DbCon.getConnection();
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

    } catch (Exception e) {

      e.printStackTrace(System.out);
      fail = true;

    } finally {
      if (con != null) {
        try {con.close();
        } catch (Exception e2) {}
      }
    }

    if (fail) {
      throw new Exception("getMerchantTrxid fail");
    }

    return ret;
  }


  /*
    public String getId() throws Exception {
      String ret = "";
      boolean fail = false;

      Connection con = null;
      try {
        con = DbCon.getConnection();
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

      } catch (Exception e) {

        e.printStackTrace(System.out);
        fail = true;

      } finally {
        if (con != null) {
          try {con.close();
          } catch (Exception e2) {}
        }
      }

      if (fail) {
        throw new Exception("getMerchantTrxid fail");
      }

      return ret;
    }
   */

  public static String getPayTermDesc(String termid) {
    String ret = "";

    Connection con = null;
    try {

      con = DbCon.getConnection();
      String sql =
          "select description from reader_terminal where terminal_id = ?";
      PreparedStatement ps = con.prepareStatement(sql);
      ps.setString(1, termid);
      ResultSet rs = ps.executeQuery();

      if (rs.next()) {
        ret = rs.getString(1);
      }

      rs.close();
      ps.close();

    } catch (Exception e) {
      e.printStackTrace(System.out);

    } finally {
      if (con != null) {
        try {con.close();
        } catch (Exception e2) {}
      }
    }
    return ret;

  }


  public String[] doPaymentTx(Connection con, String db_id) throws Exception {
    String ret[] = {"04", "internal_problem"};

    String sql =
        "select balance, status from tsel_cust_account where acc_no = ? for update";
    PreparedStatement ps = con.prepareStatement(sql);
    ps.setString(1, this.cust_acc);
    ResultSet rs = ps.executeQuery();
    double balance_cust = 0;
    if (rs.next()) {

      balance_cust = rs.getDouble(1);
      this.cust_acc_status = rs.getString(2);

    } else {
      ret[0] = "07";
      ret[1] = "account_not_found";
      throw new Exception("account_not_found :" + this.cust_msisdn);
    }

    rs.close();
    ps.close();



    boolean b2 = true;

    if ((balance_cust - Double.parseDouble(this.amount)) < 0) {
      b2 = false;
      ret[0] = "08";
      ret[1] = "cust_balance_not_enough";

      sql =
          "update log_ussd set status='3', confirm_time=sysdate, note = ? where id = ?";
      ps = con.prepareStatement(sql);
      ps.setString(1, "cust_balance_not_enough");
      ps.setString(2, db_id);
      ps.executeUpdate();
      ps.close();
      con.commit();

    } else {
      /*start_tx*/

      double bal_new = balance_cust - Double.parseDouble(this.amount);

      //balance tsel_account
      sql = "update tsel_cust_account set balance =  ? where acc_no = ?";
      ps = con.prepareStatement(sql);
      ps.setDouble(1, bal_new);
      ps.setString(2, this.cust_acc);

      ps.executeUpdate();

      ps.close();

      //history tsel_account
      sql = "insert into tsel_cust_account_history values(?, ?, ?, ?, ?, ?, ?, sysdate, ?, ?, ?)";
      ps = con.prepareStatement(sql);
      ps.setString(1, db_id);
      ps.setString(2, this.trx_id);
      ps.setString(3, this.cust_acc);
      /*
             if (this.trx_tipe.equals("1")) {
        ps.setString(4, String.valueOf(UssdTx.USSD_PAYMENT));
             } else {
        ps.setString(4, String.valueOf(UssdTx.USSD_CASHOUT));
             }*/
      ps.setString(4, this.trx_tipe);
      ps.setString(5, this.amount);
      ps.setString(6, "0");
      ps.setDouble(7, bal_new);
      ps.setString(8, "");
      ps.setString(9, this.terminal_id);
      ps.setString(10, this.merchant_name);
      ps.executeUpdate();
      ps.close();

      //merchant_account
      sql =
          "select balance, status from tsel_merchant_account where acc_no = ? for update ";
      ps = con.prepareStatement(sql);
      ps.setString(1, this.merchant_acc);
      rs = ps.executeQuery();
      double balance_merchant = 0;
      if (rs.next()) {
        balance_merchant = rs.getDouble(1);
        this.merchant_acc_status = rs.getString(2);

      } else {
        throw new Exception("merchant_acc_no not exist");
      }

      sql =
          "update tsel_merchant_account set balance=balance+? where acc_no = ?";
      ps = con.prepareStatement(sql);
      ps.setString(1, this.amount);
      ps.setString(2, this.merchant_acc);
      ps.executeUpdate();
      ps.close();

      sql = "insert into tsel_merchant_account_history values(?, ?, ?, ?, ?, ?, ?, ?, sysdate, ?, ?, ?)";
      ps = con.prepareStatement(sql);
      ps.setString(1, db_id);
      ps.setString(2, this.trx_id);
      ps.setString(3, this.merchant_acc);
      ps.setString(4, this.cust_msisdn);
      /*
             if (this.trx_tipe.equals("1")) {
        ps.setString(5, String.valueOf(UssdTx.USSD_PAYMENT));
             } else {
        ps.setString(5, String.valueOf(UssdTx.USSD_CASHOUT));
             }*/
      ps.setString(5, this.trx_tipe);
      ps.setString(6, "0");
      ps.setString(7, this.amount);
      ps.setDouble(8, (balance_merchant + Double.parseDouble(this.amount)));
      ps.setString(9, "");
      ps.setString(10, this.terminal_id);
      ps.setString(11, this.merchant_name);
      ps.executeUpdate();
      ps.close();

      sql =
          "update log_ussd set status='2', tx_time=sysdate, note = ? where id = ?";
      ps = con.prepareStatement(sql);
      ps.setString(1, "tx_success");
      ps.setString(2, db_id);
      ps.executeUpdate();
      ps.close();

      String tgl = sdf.format(new java.util.Date());
      String amount_msg = formatter.format(Double.parseDouble(this.amount));
      String hist_msg = this.getTxtipe(Integer.parseInt(this.trx_tipe))+" Rp."+amount_msg+" "+tgl;
      this.updateLasTxHist(this.cust_msisdn, hist_msg, con);




      con.commit();
      ret[0] = "00";
      ret[1] = "Success";

      String sms = "Anda telah melakukan pembayaran di " +
                   this.merchant_name +
                   " sebesar Rp." +
                   formatter.format(Double.parseDouble(this.amount)) +
                   " pada tanggal " +
                   tgl + " (" + db_id + ")";

      if (Integer.parseInt(this.trx_tipe) == UssdTx.USSD_CASHOUT) {

        sms = "Anda telah melakukan penarikan tunai di " +
              this.merchant_name +
              " sebesar Rp." +
              formatter.format(Double.parseDouble(this.amount)) +
              " pada tanggal " +
              tgl + " (" + db_id + ")";

      }
      this.note = sms;
      this.sendNotif(this.cust_msisdn, "2828", sms);

      /*end_tx*/
    }

    return ret;
  }


  public boolean validateCustLimit(Connection con) throws Exception {
    boolean bo = false;
    String sql = "select id, to_char(l_update, 'YYYYMMDD'), tot_amount, limit from msisdn_trxid where msisdn = ? for update";
    PreparedStatement ps = con.prepareStatement(sql);
    ps.setString(1, this.cust_msisdn);

    double tot_amount_today = 0;
    String last_tx_date = "";
    double last_amount = 0;
    double cust_limit = 0;

    ResultSet rs = ps.executeQuery();
    int l_trxid = 0;
    if (rs.next()) {

      /* cek limit */
      last_tx_date = rs.getString(2);
      last_amount = rs.getDouble(3);
      cust_limit = rs.getDouble(4);

      if (last_tx_date.equals(sdf3.format(new java.util.Date())))
          tot_amount_today = last_amount + Double.parseDouble(this.amount);
      else tot_amount_today = Double.parseDouble(this.amount);
    }

    rs.close();
    ps.close();

    if(tot_amount_today <= cust_limit) {
      bo = true;
      sql = "update msisdn_trxid set id = ?, l_update = sysdate, tot_amount = ? where msisdn = ?";
      ps = con.prepareStatement(sql);
      ps.setString(1, this.trx_id);
      ps.setDouble(2, tot_amount_today);
      ps.setString(3, this.cust_msisdn);
      ps.executeUpdate();
      ps.close();

    }
    return bo;
  }

  public String[] doCekPayment() {

    String ret[] = {"04", "internal_problem"};

    if (!this.validateCekPayment()) {
      ret[0] = "05";
      ret[1] = "input_error";
      return ret;
    }

    if (!this.validateMerchant()) {
      ret[0] = "03";
      ret[1] = "merchant_not_found";
      return ret;
    }

    if (!this.validateCust()) {
      ret[0] = "02";
      ret[1] = "cust_not_registered";
      return ret;
    }

    Connection con = null;
    try {

      con = DbCon.getConnection();
      con.setAutoCommit(false);

      //String sql = "select * from log_ussd where msisdn = ? and ref_num = ? and (unix_timestamp(  )  - unix_timestamp(s_time ) < 7200) order by s_time desc ";
      //String sql = "select * from log_ussd where id = ? and msisdn = ? limit 1";
      String sql =
          "select * from log_ussd where id = ? and payment_terminal_id = ? and (((sysdate - confirm_time) * (86400)) < 1800 ) for update ";
      PreparedStatement ps = con.prepareStatement(sql);
      ps.setString(1, this.merchant_trxid);
      //ps.setString(2, this.cust_msisdn);
      ps.setString(2, this.terminal_id);

      ResultSet rs = ps.executeQuery();
      String db_id = "";
      String status = "";

      boolean b = true;
      String db_custMsisdn = "";

      if (rs.next()) {
        db_id = rs.getString("id");
        status = rs.getString("status");
        this.amount = rs.getString("amount");
        this.terminal_id = rs.getString("payment_terminal_id");
        this.merchant_acc = rs.getString("merchant_acc");
        this.trx_tipe = rs.getString("trx_tipe");
        this.trx_id = rs.getString("ref_num");
        this.note = rs.getString("note");
        db_custMsisdn = rs.getString("msisdn");

      } else {
        b = false;

      }

      rs.close();
      ps.close();


      if(!this.validateCustLimit(con)){
        ret[0] = "15";
        ret[1] = "cust_tx over limit";
        con.rollback();
        con.close();
        return ret;
      }

      if(!db_custMsisdn.equals(this.cust_msisdn)){
        throw new Exception("not_valid cust_msisdn "+this.cust_msisdn);
      }

      int i_trx_tipe = Integer.parseInt(this.trx_tipe);
      boolean b2 = false;
      if (i_trx_tipe == UssdTx.USSD_CASHOUT) {
        b2 = true;
      }
      if (i_trx_tipe == UssdTx.USSD_PAYMENT) {
        b2 = true;

      }
      System.out.println("merchant_check_payment trx_tipe:" + this.trx_tipe +
                         " id:" + db_id + " status:" + status + " amount:" +
                         amount + " terminal_id:" + terminal_id +
                         " merchant_acc:" + merchant_acc);

      if (b && b2) {
        if (status.equals("1")) {

          String r2[] = this.doPaymentTx(con, db_id);
          ret[0] = r2[0];
          ret[1] = r2[1];

        } else if (status.equals("0")) {

          ret[0] = "04";
          ret[1] = "not_confirm";
          con.rollback();

        } else if (status.equals("2")) {
          ret[0] = "00";
          ret[1] = "Success";
          con.rollback();

        } else if (status.equals("3")) {
          ret[0] = "05";
          ret[1] = "not_enough_credit";
          con.rollback();

        } else {
          ret[0] = "06";
          ret[1] = "undefined_error";
          con.rollback();
        }
      } else {

        ret[0] = "01";
        ret[1] = "trx_id not_found";
        con.rollback();

      }

    } catch (Exception e) {

      e.printStackTrace(System.out);
      try {con.rollback();
      } catch (Exception e2) {}

    } finally {

      if (con != null) {
        try {con.setAutoCommit(true);
        } catch (Exception e3) {}
        try {con.close();
        } catch (Exception ee) {}
      }
    }
    System.out.println("merchant cek_payment merchant_msisdn:" +
                       this.merchant_msisdn + " cust_msisdn:" +
                       this.cust_msisdn + " trx_id:" + this.merchant_trxid +
                       " result:" +
                       ret[0] + ":" + ret[1]);
    return ret;

  }


  public String[] doCashinPos() {

    String ret[] = {"04", "internal_problem"};

    if (!this.validateInputPaymentPos()) {
      ret[0] = "05";
      ret[1] = "input_error";
      return ret;
    }

    if (!this.validateMerchant()) {
      ret[0] = "03";
      ret[1] = "merchant_not_found";


      return ret;
    }

    if (!this.merchant_acc_status.equals(UssdTx.TSEL_MERCHANT_ACC_ACTIVE)) {
      ret[0] = "13";
      ret[1] = "merchant_acc not active";
      return ret;

    }


    if (!this.validateCust()) {
      ret[0] = "02";
      ret[1] = "cust_not_registered";



      return ret;
    }

    if (!this.cust_acc_status.equals(UssdTx.TSEL_CUST_ACC_ACTIVE)) {
      ret[0] = "12";
      ret[1] = "cust_acc not active";
      return ret;
    }


    if (!this.validateMerchantBalance()) {
      ret[0] = "01";
      ret[1] = "merchant_balance_not_enough";
      return ret;
    }

    Connection con = null;
    try {

      this.merchant_trxid = this.getMerchantTrxid();

      con = DbCon.getConnection();
      con.setAutoCommit(false);

      String sql =
          "select balance, status from tsel_merchant_account where acc_no = ? for update";
      PreparedStatement ps = con.prepareStatement(sql);
      ps.setString(1, this.merchant_acc);
      ResultSet rs = ps.executeQuery();
      double balance_merchant = 0;
      if (rs.next()) {

        balance_merchant = rs.getDouble(1);
        this.merchant_acc_status = rs.getString(2);

      } else {
        ret[0] = "07";
        ret[1] = "merchant account_not_found";

        throw new Exception(" merchant account_not_found :" + this.merchant_acc);
      }

      rs.close();
      ps.close();

      double bal_merchant_new = balance_merchant -
                                Double.parseDouble(this.amount);
      boolean b1 = false;
      if (bal_merchant_new >= 0) {
        b1 = true;

      }
      if (b1) {

        //start cashin


        //trx_id first
        sql = "select id from msisdn_trxid where msisdn = ? for update";
        ps = con.prepareStatement(sql);
        ps.setString(1, this.cust_msisdn);

        rs = ps.executeQuery();
        int l_trxid = 0;
        if (rs.next()) {

          l_trxid = rs.getInt(1);
          if (l_trxid < 9999) {
            this.trx_id = String.valueOf((l_trxid + 1));
          } else {
            this.trx_id = "1";
          }

        } else {
          throw new Exception("msisdn_trxid not found :" + this.cust_msisdn);
        }
        rs.close();
        ps.close();

        sql = "update msisdn_trxid set id = ? where msisdn = ?";
        ps = con.prepareStatement(sql);
        ps.setString(1, this.trx_id);
        ps.setString(2, this.cust_msisdn);
        ps.executeUpdate();
        ps.close();

        //balance tsel_account

        sql =
            "select balance, status from tsel_cust_account where acc_no = ? for update";
        ps = con.prepareStatement(sql);
        ps.setString(1, this.cust_acc);
        rs = ps.executeQuery();
        double balance_cust = 0;
        if (rs.next()) {

          balance_cust = rs.getDouble(1);
          this.cust_acc_status = rs.getString(2);

        } else {
          ret[0] = "07";
          ret[1] = "account_not_found";

          throw new Exception("account_not_found :" + this.cust_msisdn);
        }

        rs.close();
        ps.close();

        double balance_cust_new = balance_cust + Double.parseDouble(this.amount);

        if (balance_cust_new > 1000000) {
          System.out.println("balance " + this.cust_msisdn +" over_limit 1 jt");
          ret[0] = "11";
          ret[1] = "balance_over_limit";
          con.rollback();
          con.close();
          return ret;

        }

        sql = "update tsel_cust_account set balance =  ? where acc_no = ?";
        ps = con.prepareStatement(sql);
        ps.setDouble(1, balance_cust_new);
        ps.setString(2, this.cust_acc);

        ps.executeUpdate();

        ps.close();

        //history tsel_account
        sql = "insert into tsel_cust_account_history values(?, ?, ?, ?, ?, ?, ?, sysdate, ?, ?, ?)";
        ps = con.prepareStatement(sql);
        ps.setString(1, this.merchant_trxid);
        ps.setString(2, this.trx_id);
        ps.setString(3, this.cust_acc);

        ps.setString(4, String.valueOf(UssdTx.USSD_CASHIN));

        ps.setString(5, "0");
        ps.setString(6, this.amount);
        ps.setDouble(7, balance_cust_new);
        ps.setString(8, "");
        ps.setString(9, this.terminal_id);
        ps.setString(10, this.merchant_name);
        ps.executeUpdate();
        ps.close();

        //merchant_account

        sql =
            "update tsel_merchant_account set balance=balance-? where acc_no = ?";
        ps = con.prepareStatement(sql);
        ps.setString(1, this.amount);
        ps.setString(2, this.merchant_acc);
        ps.executeUpdate();
        ps.close();

        sql = "insert into tsel_merchant_account_history values(?, ?, ?, ?, ?, ?, ?, ?, sysdate, ?, ?, ?)";
        ps = con.prepareStatement(sql);
        ps.setString(1, this.merchant_trxid);
        ps.setString(2, this.trx_id);
        ps.setString(3, this.merchant_acc);
        ps.setString(4, this.cust_msisdn);
        ps.setString(5, String.valueOf(UssdTx.USSD_CASHIN));

        ps.setString(6, this.amount);
        ps.setString(7, "0");
        ps.setDouble(8, (balance_merchant - Double.parseDouble(this.amount)));
        ps.setString(9, "");
        ps.setString(10, this.terminal_id);
        ps.setString(11, this.merchant_name);
        ps.executeUpdate();
        ps.close();

        //now insert to log_ussd

        sql =
            "insert into log_ussd values(?, ?, ? ,?, ?, ?, ?, ?, ?, sysdate, '', ?, ?, '', '')";
        ps = con.prepareStatement(sql);
        ps.setString(1, this.merchant_trxid);
        ps.setString(2, this.trx_id);
        ps.setString(3, this.cust_msisdn);
        ps.setString(4, this.cust_acc);
        ps.setString(5, this.amount);
        ps.setString(6, this.merchant_id);
        ps.setString(7, this.terminal_id);
        ps.setString(8, "");
        ps.setString(9, this.merchant_acc);
        //ps.setString(10, "2");
        ps.setString(10, String.valueOf(UssdTx.USSD_CASHIN));
        ps.setString(11, "1");

        ps.executeUpdate();
        ps.close();

        String tgl = sdf.format(new java.util.Date());
        String amount_msg = formatter.format(Double.parseDouble(this.amount));
        String hist_msg = this.getTxtipe(UssdTx.USSD_CASHIN)+" Rp."+amount_msg+" "+tgl;
        this.updateLasTxHist(this.cust_msisdn, hist_msg, con);

        con.commit();
        ret[0] = "00";
        ret[1] = this.merchant_trxid;

        String sms = "Anda telah melakukan pengisian di Telkomsel Tunai" +

                     " sebesar Rp." +
                     amount_msg +
                     " pada tanggal " +
                     tgl;

        this.sendNotif(this.cust_msisdn, "2828", sms);

        //end cashin

      } else {
        ret[0] = "01";
        ret[1] = "amount_not_enough";
        con.rollback();
      }

    } catch (Exception e) {
      try {con.rollback();
      } catch (Exception e2) {}
      e.printStackTrace(System.out);
    } finally {

      if (con != null) {

        try {con.setAutoCommit(true);
        } catch (Exception e3) {}
        try {con.close();
        } catch (Exception ee) {}
      }
    }

    return ret;
  }

  public String getMerchantName(String terminalid) {

    String ret = " ";

    Connection con = null;
    try {

      con = con = DbCon.getConnection();

      String sql =
          "select description from reader_terminal where terminal_id = ?";
      PreparedStatement ps = con.prepareStatement(sql);
      ps.setString(1, terminalid);

      ResultSet rs = ps.executeQuery();
      if (rs.next()) {
        ret = rs.getString(1);
      }

      rs.close();
      ps.close();

    } catch (Exception e) {
      e.printStackTrace(System.out);
    } finally {

      if (con != null) {
        try {con.close();
        } catch (Exception e2) {}
      }

    }

    return ret;

  }


  public String[] doConfirmPayment() {
    String ret[] = {"04", "internal_problem"};
    if (!this.validateInputPaymentConfirm()) {
      ret[0] = "05";
      ret[1] = "input_error";
      return ret;
    }

    if (!this.validateCust()) {
      ret[0] = "02";
      ret[1] = "cust_not_registered";
      return ret;
    }

    if (!this.validateCustPin()) {
      ret[0] = "08";
      ret[1] = "pin_error";
      return ret;
    }

    Connection con = null;
    try {

      con = DbCon.getConnection();
      con.setAutoCommit(false);

      //String sql = "select * from log_ussd where msisdn = ? and ref_num = ? and (unix_timestamp(  )  - unix_timestamp(s_time ) < 7200) order by s_time desc limit 1 for update  ";
      String sql = "select * from (select * from log_ussd where msisdn = ? and ref_num = ? and (((sysdate - s_time) * (86400)) < 1800 ) order by s_time desc) where rownum=1";
      PreparedStatement ps = con.prepareStatement(sql);
      ps.setString(1, this.cust_msisdn);
      ps.setString(2, this.trx_id);

      ResultSet rs = ps.executeQuery();
      String db_id = "";
      String status = "";

      if (rs.next()) {
        db_id = rs.getString("id");
        status = rs.getString("status");
        this.amount = rs.getString("amount");
        this.terminal_id = rs.getString("payment_terminal_id");
        this.merchant_acc = rs.getString("merchant_acc");
        this.trx_tipe = rs.getString("trx_tipe");
        this.merchant_name = this.getMerchantName(rs.getString(
            "payment_terminal_id"));

      } else {
        ret[0] = "01";
        ret[1] = "transaction_not_found";
        throw new Exception("transaction_not_found " + this.trx_id);
      }

      rs.close();
      ps.close();

      boolean b1 = false;
      if (status != null && status.equals("0")) {
        b1 = true;

      }
      if (!b1) {
        ret[0] = "06";
        ret[1] = "transaction_already_confirm";

      } else {

        sql =
            "select balance from tsel_cust_account where acc_no = ? for update";
        ps = con.prepareStatement(sql);
        ps.setString(1, this.cust_acc);
        rs = ps.executeQuery();
        double balance_cust = 0;
        if (rs.next()) {

          balance_cust = rs.getDouble(1);

        } else {
          ret[0] = "07";
          ret[1] = "account_not_found";

          throw new Exception("account_not_found :" + this.cust_msisdn);
        }

        rs.close();
        ps.close();

        boolean b2 = true;

        if ((balance_cust - Double.parseDouble(this.amount)) < 0) {
          b2 = false;
          ret[0] = "01";
          ret[1] = "cust_balance_not_enough";

          sql =
              "update log_ussd set status='3', confirm_time=sysdate, note = ? where id = ?";
          ps = con.prepareStatement(sql);
          ps.setString(1, "cust_balance_not_enough");
          ps.setString(2, db_id);
          ps.executeUpdate();
          ps.close();
          con.commit();

        } else {

          sql =
              "update log_ussd set status='1', confirm_time=sysdate, note = ? where id = ?";
          ps = con.prepareStatement(sql);
          ps.setString(1, "tx_confirmed");
          ps.setString(2, db_id);
          ps.executeUpdate();
          ps.close();
          con.commit();
          ret[0] = "00";
          ret[1] = "Success";

          String sms = "Konfirmasi pembelian Rp " +

                       formatter.format(Double.parseDouble(this.amount)) +
                       " dg no. ref: " + this.trx_id + " telah diterima tgl " +
                       sdf.format(new java.util.Date()) +
                       " Segera informasikan ke cashier utk trx. Berlaku s/d 30 menit";

          if (Integer.parseInt(this.trx_tipe) == UssdTx.USSD_CASHOUT) {

            sms = "Konfirmasi penarikan tunai Rp " +

                  formatter.format(Double.parseDouble(this.amount)) +
                  " dg no. ref: " + this.trx_id + " telah diterima tgl " +
                  sdf.format(new java.util.Date()) +
                  " Segera informasikan ke cashier utk trx. Berlaku s/d 30 menit";
          }
          this.notif_message = sms;
          if(this.doSendNotif) this.sendNotif(this.cust_msisdn, "2828", sms);

        }

      }

    } catch (Exception e) {
      try {con.rollback();
      } catch (Exception e2) {}
      e.printStackTrace(System.out);

    } finally {

      if (con != null) {
        try {con.setAutoCommit(true);
        } catch (Exception e3) {}

        try {con.close();
        } catch (Exception ee) {}

      }
    }

    return ret;
  }

  public String [] doMerchantDeposit(String deposit_id){
    String ret[] = {"04", "internal_problem"};
    Connection con = null;
    try {

      con = DbCon.getConnection();
      con.setAutoCommit(false);

      String sql = "select merchant_id, amount, entry_login, is_executed from merchant_deposit where deposit_id = ? for update";
      PreparedStatement ps = con.prepareStatement(sql);
      ps.setString(1, deposit_id);
      ResultSet rs = ps.executeQuery();

      String entry_login = "";
      if(rs.next()){
        this.merchant_id = rs.getString(1);
        this.amount = rs.getString(2);
        entry_login = rs.getString(3);
        this.isExecuted = rs.getString(4);

      }
//wd
      if(isExecuted.equalsIgnoreCase("2")){
    	  ret[0] = "99";
          ret[1] = "is executed";
          return ret;
      }
      
      rs.close();
      ps.close();

      sql = "select acc_no from merchant where merchant_id = ?";
      ps = con.prepareStatement(sql);
      ps.setString(1, this.merchant_id);
      rs = ps.executeQuery();
      boolean b_found1 = false;
      if(rs.next()){
        this.merchant_acc = rs.getString(1);
        b_found1 = true;
      }

      rs.close();
      ps.close();

      if(!b_found1) throw new Exception("doMerchantDeposit err, merchant_acc not found :"+this.merchant_acc);

      double balance_merchant = 0;
      sql = "select balance from tsel_merchant_account where acc_no = ? for update";
      ps = con.prepareStatement(sql);
      ps.setString(1, this.merchant_acc);
       rs = ps.executeQuery();
      boolean b_found = false;
      if(rs.next()){
        balance_merchant = rs.getDouble(1);
        b_found = true;
      }

      rs.close();
      ps.close();

      sql = "update MERCHANT_DEPOSIT set IS_EXECUTED='1' where DEPOSIT_ID = ? ";
      ps = con.prepareStatement(sql);
      ps.setString(1, deposit_id);
      ps.executeUpdate();
      ps.close();
      
      if(!b_found) throw new Exception("doMerchantDeposit err, merchant_acc not found :"+this.merchant_acc);

      sql = "update tsel_merchant_account set balance = balance + ? where acc_no = ?";
      ps = con.prepareStatement(sql);
      ps.setString(1, this.amount);
      ps.setString(2, this.merchant_acc);

      ps.executeUpdate();
      ps.close();

      sql = "insert into tsel_merchant_account_history values(?, ?, ?, ?, ?, ?, ?, ?, sysdate, ?, ?, ?)";
      ps = con.prepareStatement(sql);
      ps.setString(1, this.getMerchantTrxid());
      ps.setString(2, "0");
      ps.setString(3, this.merchant_acc);
      ps.setString(4, "DEPOSIT");
      ps.setString(5, String.valueOf(UssdTx.MERCHANT_DEPOSIT));
      ps.setString(6, "0");
      ps.setString(7, this.amount);
      ps.setDouble(8, (balance_merchant + Double.parseDouble(this.amount)));
      ps.setString(9, this.terminal_id);
      ps.setString(10, "1");
      ps.setString(11, entry_login);
      ps.executeUpdate();
      ps.close();


//      sql = "update MERCHANT_DEPOSIT set IS_EXECUTED='1' where DEPOSIT_ID = ? ";
//      ps = con.prepareStatement(sql);
//      ps.setString(1, deposit_id);
//      ps.executeUpdate();
//      ps.close();


      con.commit();
      ret[0] = "00";
      ret[1] = "success";




    } catch (Exception e) {
      e.printStackTrace(System.out);
      try { con.rollback(); } catch(Exception e2){}
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
  
  public String [] doMerchantDepositFinance(String deposit_id){
	    String ret[] = {"04", "internal_problem"};
	    Connection con = null;
	    try {

	      con = DbCon.getConnection();
	      con.setAutoCommit(false);

	      String sql = "select merchant_id, amount, entry_login, is_executed from merchant_deposit where deposit_id = ? for update";
	      PreparedStatement ps = con.prepareStatement(sql);
	      ps.setString(1, deposit_id);
	      ResultSet rs = ps.executeQuery();

	      String entry_login = "";
	      if(rs.next()){
	        this.merchant_id = rs.getString(1);
	        this.amount = rs.getString(2);
	        entry_login = rs.getString(3);
	        this.isExecuted = rs.getString(4);

	      }
	      
	      //wd
	      if(isExecuted.equalsIgnoreCase("2")){
	    	  ret[0] = "99";
	          ret[1] = "is executed";
	          return ret;
	      }
	      
	      rs.close();
	      ps.close();

	      sql = "select acc_no from merchant where merchant_id = ?";
	      ps = con.prepareStatement(sql);
	      ps.setString(1, this.merchant_id);
	      rs = ps.executeQuery();
	      boolean b_found1 = false;
	      if(rs.next()){
	        this.merchant_acc = rs.getString(1);
	        b_found1 = true;
	      }

	      rs.close();
	      ps.close();

	      if(!b_found1) throw new Exception("doMerchantDeposit err, merchant_acc not found :"+this.merchant_acc);

	      double balance_merchant = 0;
	      sql = "select balance from tsel_merchant_account where acc_no = ? for update";
	      ps = con.prepareStatement(sql);
	      ps.setString(1, this.merchant_acc);
	       rs = ps.executeQuery();
	      boolean b_found = false;
	      if(rs.next()){
	        balance_merchant = rs.getDouble(1);
	        b_found = true;
	      }

	      rs.close();
	      ps.close();

	      sql = "update MERCHANT_DEPOSIT set IS_EXECUTED='2' where DEPOSIT_ID = ? ";
	      ps = con.prepareStatement(sql);
	      ps.setString(1, deposit_id);
	      ps.executeUpdate();
	      ps.close();
	      
	      if(!b_found) throw new Exception("doMerchantDeposit err, merchant_acc not found :"+this.merchant_acc);

	      sql = "update tsel_merchant_account set balance = balance + ? where acc_no = ?";
	      ps = con.prepareStatement(sql);
	      ps.setString(1, this.amount);
	      ps.setString(2, this.merchant_acc);

	      ps.executeUpdate();
	      ps.close();

	      sql = "insert into tsel_merchant_account_history values(?, ?, ?, ?, ?, ?, ?, ?, sysdate, ?, ?, ?)";
	      ps = con.prepareStatement(sql);
	      ps.setString(1, this.getMerchantTrxid());
	      ps.setString(2, "0");
	      ps.setString(3, this.merchant_acc);
	      ps.setString(4, "DEPOSIT");
	      ps.setString(5, String.valueOf(UssdTx.MERCHANT_DEPOSIT));
	      ps.setString(6, "0");
	      ps.setString(7, this.amount);
	      ps.setDouble(8, (balance_merchant + Double.parseDouble(this.amount)));
	      ps.setString(9, this.terminal_id);
	      ps.setString(10, "1");
	      ps.setString(11, entry_login);
	      ps.executeUpdate();
	      ps.close();


//	      sql = "update MERCHANT_DEPOSIT set IS_EXECUTED='1' where DEPOSIT_ID = ? ";
//	      ps = con.prepareStatement(sql);
//	      ps.setString(1, deposit_id);
//	      ps.executeUpdate();
//	      ps.close();


	      con.commit();
	      ret[0] = "00";
	      ret[1] = "success";




	    } catch (Exception e) {
	      e.printStackTrace(System.out);
	      try { con.rollback(); } catch(Exception e2){}
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
  
  public String [] doMerchantCashout(String cashout_id) throws Exception {
    String ret[] = {"04", "internal_problem"};
    Connection con = null;
    try {

      con = DbCon.getConnection();
      con.setAutoCommit(false);

      String sql = "select merchant_id, amount, entry_login, is_executed from merchant_cashout where cashout_id = ? for update";
      PreparedStatement ps = con.prepareStatement(sql);
      ps.setString(1, cashout_id);
      ResultSet rs = ps.executeQuery();

      String entry_login = "";
      if(rs.next()){
        this.merchant_id = rs.getString(1);
        this.amount = rs.getString(2);
        entry_login = rs.getString(3);
        this.isExecuted = rs.getString(4);
      }
      
      if(isExecuted.equalsIgnoreCase("1")){
    	  ret[0] = "99";
          ret[1] = "is executed";
          return ret;
      }

      rs.close();
      ps.close();

      sql = "select acc_no from merchant where merchant_id = ?";
      ps = con.prepareStatement(sql);
      ps.setString(1, this.merchant_id);
      rs = ps.executeQuery();
      boolean b_found1 = false;
      if(rs.next()){
        this.merchant_acc = rs.getString(1);
        b_found1 = true;
      }

      rs.close();
      ps.close();

      if(!b_found1) throw new Exception("doMerchantDeposit err, merchant_acc not found :"+this.merchant_acc);

      double balance_merchant = 0;
      sql = "select balance from tsel_merchant_account where acc_no = ? for update";
      ps = con.prepareStatement(sql);
      ps.setString(1, this.merchant_acc);
       rs = ps.executeQuery();
      boolean b_found = false;
      if(rs.next()){
        balance_merchant = rs.getDouble(1);
        b_found = true;
      }

      rs.close();
      ps.close();
      
      sql = "update MERCHANT_CASHOUT set IS_EXECUTED='1' where CASHOUT_ID = ? ";
      ps = con.prepareStatement(sql);
      ps.setString(1, cashout_id);
      ps.executeUpdate();
      ps.close();
      
      if((balance_merchant - Double.parseDouble(this.amount)) < 0 ) throw new Exception("balance merchant fail :"+balance_merchant+" debet:"+this.amount);

      if(!b_found) throw new Exception("doMerchantDeposit err, merchant_acc not found :"+this.merchant_acc);

      sql = "update tsel_merchant_account set balance = balance - ? where acc_no = ?";
      ps = con.prepareStatement(sql);
      ps.setString(1, this.amount);
      ps.setString(2, this.merchant_acc);

      ps.executeUpdate();
      ps.close();

      sql = "insert into tsel_merchant_account_history values(?, ?, ?, ?, ?, ?, ?, ?, sysdate, ?, ?, ?)";
      ps = con.prepareStatement(sql);
      ps.setString(1, this.getMerchantTrxid());
      ps.setString(2, "0");
      ps.setString(3, this.merchant_acc);
      ps.setString(4, "SETTLEMENT");
      ps.setString(5, String.valueOf(UssdTx.MERCHANT_CASHOUT));
      ps.setString(6, this.amount);
      ps.setString(7, "0");
      ps.setDouble(8, (balance_merchant - Double.parseDouble(this.amount)));
      ps.setString(9, this.terminal_id);
      ps.setString(10, "1");
      ps.setString(11, entry_login);
      ps.executeUpdate();
      ps.close();


      con.commit();
      ret[0] = "00";
      ret[1] = "success";




    } catch (Exception e) {
      e.printStackTrace(System.out);
      try { con.rollback(); } catch(Exception e2){}
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

  public String[] doPaymentPos() {
    String ret[] = {"04", "internal_problem"};

    if (!this.validateInputPaymentPos()) {
      ret[0] = "05";
      ret[1] = "input_error";
      return ret;
    }

    if (!this.validateMerchant()) {
      ret[0] = "03";
      ret[1] = "merchant_not_found";

      return ret;
    }

    if (!this.merchant_acc_status.equals(UssdTx.TSEL_MERCHANT_ACC_ACTIVE)) {
      ret[0] = "13";
      ret[1] = "merchant_acc not active";
      return ret;

    }

    if (!this.validateCust()) {
      ret[0] = "02";
      ret[1] = "cust_not_registered";

      return ret;
    }

    if (!this.cust_acc_status.equals(UssdTx.TSEL_CUST_ACC_ACTIVE)) {
      ret[0] = "12";
      ret[1] = "cust_acc not active";
      return ret;

    }

    if (!this.validateCustBalance()) {
      ret[0] = "01";
      ret[1] = "cust_balance_not_enough";

      return ret;
    }

    Connection con = null;

    try {

      this.merchant_trxid = this.getMerchantTrxid();

      con = DbCon.getConnection();
      con.setAutoCommit(false);

      String sql = "select id, to_char(l_update, 'YYYYMMDD'), tot_amount, limit from msisdn_trxid where msisdn = ? for update";
      PreparedStatement ps = con.prepareStatement(sql);
      ps.setString(1, this.cust_msisdn);

      double tot_amount_today = 0;
      String last_tx_date = "";
      double last_amount = 0;
      double cust_limit = 0;

      ResultSet rs = ps.executeQuery();
      int l_trxid = 0;
      if (rs.next()) {

        /* cek limit */
        last_tx_date = rs.getString(2);
        last_amount = rs.getDouble(3);
        cust_limit = rs.getDouble(4);

        if(last_tx_date.equals(sdf3.format(new java.util.Date()))) tot_amount_today = last_amount+Double.parseDouble(this.amount);
        else tot_amount_today = Double.parseDouble(this.amount);

        /* end_of cek limit*/
        l_trxid = rs.getInt(1);
        if (l_trxid < 9999) {
          this.trx_id = String.valueOf((l_trxid + 1));
        } else {
          this.trx_id = "1";
        }

      } else {
        throw new Exception("msisdn_trxid not found :" + this.cust_msisdn);
      }
      rs.close();
      ps.close();


      sql =
          "insert into log_ussd values(?, ?, ? ,?, ?, ?, ?, ?, ?, sysdate, '', ?, ?, '', '')";
      ps = con.prepareStatement(sql);
      ps.setString(1, this.merchant_trxid);
      ps.setString(2, this.trx_id);
      ps.setString(3, this.cust_msisdn);
      ps.setString(4, this.cust_acc);
      ps.setString(5, this.amount);
      ps.setString(6, this.merchant_id);
      ps.setString(7, this.terminal_id);
      ps.setString(8, "");
      ps.setString(9, this.merchant_acc);
      //ps.setString(10, "1");
      ps.setString(10, String.valueOf(UssdTx.USSD_PAYMENT));
      ps.setString(11, "0");

      ps.executeUpdate();
      ps.close();

      con.commit();
      ret[0] = "00";
      ret[1] = this.merchant_trxid + ":" + this.trx_id;

      String sms = "Anda akan melakukan pembayaran di " + this.merchant_name +
                   " sebesar Rp." +
                   formatter.format(Double.parseDouble(this.amount)) +
                   " pada tanggal " +
                   sdf.format(new java.util.Date()) +
                   ". Ketik *885*" + this.trx_id + "*pin# untuk konfirmasi.";
      this.sendNotif(this.cust_msisdn, "2828", sms);

    } catch (Exception e) {
      e.printStackTrace(System.out);
    } finally {
      System.out.println("paymentPOS close");
      if (con != null) {
        try {con.close();
        } catch (Exception ee) {}
      }
    }

    return ret;
  }


  public String[] doCashoutPos() {
    String ret[] = {"04", "internal_problem"};

    if (!this.validateInputPaymentPos()) {
      ret[0] = "05";
      ret[1] = "input_error";
      return ret;
    }

    if (!this.validateMerchant()) {
      ret[0] = "03";
      ret[1] = "merchant_not_found";



      return ret;
    }

    if (!this.merchant_acc_status.equals(UssdTx.TSEL_MERCHANT_ACC_ACTIVE)) {
    ret[0] = "13";
    ret[1] = "merchant_acc not active";
    return ret;
  }


    if (!this.validateCust()) {
      ret[0] = "02";
      ret[1] = "cust_not_registered";



      return ret;
    }

    if (!this.cust_acc_status.equals(UssdTx.TSEL_CUST_ACC_ACTIVE)) {
    ret[0] = "12";
    ret[1] = "cust_acc not active";
    return ret;

  }


    if (!this.validateCustBalance()) {
      ret[0] = "01";
      ret[1] = "cust_balance_not_enough";
      return ret;
    }

    Connection con = null;

    try {

      this.merchant_trxid = this.getMerchantTrxid();

      con = DbCon.getConnection();
      con.setAutoCommit(false);

      String sql = "select id from msisdn_trxid where msisdn = ? for update";
      PreparedStatement ps = con.prepareStatement(sql);
      ps.setString(1, this.cust_msisdn);

      ResultSet rs = ps.executeQuery();
      int l_trxid = 0;
      if (rs.next()) {

        l_trxid = rs.getInt(1);
        if (l_trxid < 9999) {
          this.trx_id = String.valueOf((l_trxid + 1));
        } else {
          this.trx_id = "1";
        }

      } else {
        throw new Exception("msisdn_trxid not found :" + this.cust_msisdn);
      }
      rs.close();
      ps.close();

      sql = "update msisdn_trxid set id = ? where msisdn = ?";
      ps = con.prepareStatement(sql);
      ps.setString(1, this.trx_id);
      ps.setString(2, this.cust_msisdn);
      ps.executeUpdate();
      ps.close();

      sql =
          "insert into log_ussd values(?, ?, ? ,?, ?, ?, ?, ?, ?, sysdate, '', ?, ?, '', '')";
      ps = con.prepareStatement(sql);
      ps.setString(1, this.merchant_trxid);
      ps.setString(2, this.trx_id);
      ps.setString(3, this.cust_msisdn);
      ps.setString(4, this.cust_acc);
      ps.setString(5, this.amount);
      ps.setString(6, this.merchant_id);
      ps.setString(7, this.terminal_id);
      ps.setString(8, "");
      ps.setString(9, this.merchant_acc);
      //ps.setString(10, "3");
      ps.setString(10, String.valueOf(UssdTx.USSD_CASHOUT));
      ps.setString(11, "0");

      ps.executeUpdate();
      ps.close();

      con.commit();
      ret[0] = "00";
      ret[1] = this.merchant_trxid + ":" + this.trx_id;

      String sms = "Anda akan melakukan penarikan tunai di " +
                   this.merchant_name +
                   " sebesar Rp." +
                   formatter.format(Double.parseDouble(this.amount)) +
                   " pada tanggal " +
                   sdf.format(new java.util.Date()) +
                   ". Ketik *885*" + this.trx_id + "*pin# untuk konfirmasi.";
      this.sendNotif(this.cust_msisdn, "2724", sms);

    } catch (Exception e) {
      e.printStackTrace(System.out);
    } finally {

      if (con != null) {

        try {con.setAutoCommit(true);
        } catch (Exception e3) {}

        try {con.close();
        } catch (Exception ee) {}
      }
    }

    return ret;
  }


  public void setCust_acc(String cust_acc) {
    this.cust_acc = cust_acc;
  }

  public void setCust_msisdn(String cust_msisdn) {
    this.cust_msisdn = cust_msisdn;
  }

  public void setAmount(String amount) {
    this.amount = amount;
  }

  public void setTrx_id(String trx_id) {
    this.trx_id = trx_id;
  }

  public void setMerchant_id(String merchant_id) {
    this.merchant_id = merchant_id;
  }

  public void setMerchant_acc(String merchant_acc) {
    this.merchant_acc = merchant_acc;
  }

  public void setMsg(String msg) {
    this.msg = msg;
  }

  public void setTrx_tipe(String trx_tipe) {
    this.trx_tipe = trx_tipe;
  }

  public void setMerchant_msisdn(String merchant_msisdn) {
    this.merchant_msisdn = merchant_msisdn;
  }

  public void setInput_custPin(String input_custPin) {
    this.input_custPin = input_custPin;
  }

  public void setMerchant_trxid(String merchant_trxid) {
    this.merchant_trxid = merchant_trxid;
  }

  public void setDoSendNotif(boolean doSendNotif) {
    this.doSendNotif = doSendNotif;
  }

  public String getCust_acc() {
    return cust_acc;
  }

  public String getCust_msisdn() {
    return cust_msisdn;
  }

  public String getAmount() {
    return amount;
  }

  public String getTrx_id() {
    return trx_id;
  }

  public String getMerchant_id() {
    return merchant_id;
  }

  public String getMerchant_acc() {
    return merchant_acc;
  }

  public String getMsg() {
    return msg;
  }

  public String getTrx_tipe() {
    return trx_tipe;
  }

  public String getMerchant_msisdn() {
    return merchant_msisdn;
  }

  public String getInput_custPin() {
    return input_custPin;
  }

  public String getNote() {
    return note;
  }

  public String getNotif_message() {
    return notif_message;
  }


  public UssdTx() {
  }

  public void sendNotif(String msisdn, String source, String sms) {

    Connection co = null;
    try {

      co = DbCon.getConnection();
      String sql =
          "insert into notif(msisdn, msg, source, s_time) values(?, ?, ?, sysdate)";
      PreparedStatement ps = co.prepareStatement(sql);
      ps.setString(1, msisdn);
      ps.setString(2, sms);
      ps.setString(3, source);
      ps.executeUpdate();
      ps.close();
      System.out.println("send_notif  msisdn:" + msisdn + " msg:" + sms +
                         "source:" + source);

    } catch (Exception e) {

      System.out.println("send_notif fail msisdn:" + msisdn + " msg:" + sms +
                         " err:" + e.getMessage());

    } finally {
      try {co.close();
      } catch (Exception ee) {}
    }

  }

  public static String[] getCustBalance(String msisdn, String pin) {
    String ret[] = {"0", "internal problem"};
    String msg = ret[1];

    Connection con = null;
    try {
      String cust_info_id = "";
      String acc_no = "";
      String status = "not active";

      con = DbCon.getConnection();
      String sql = "select c.acc_no, c.cust_info_id, t.status, c.pin from customer c, tsel_cust_account t where c.msisdn = ? and c.acc_no = t.acc_no";
      PreparedStatement ps = con.prepareStatement(sql);
      ps.setString(1, msisdn);
      ResultSet rs = ps.executeQuery();
      boolean b1 = false;
      boolean b2 = false;
      if (pin == null) {
        pin = "";
      }
      String pin_db = "";
      if (!rs.next()) {

        ret[0] = "2";
        ret[1] = "account_not_found";

      } else {
        b1 = true;
        acc_no = rs.getString("acc_no");
        cust_info_id = rs.getString("cust_info_id");
        status = rs.getString("status");
        pin_db = rs.getString("pin");
      }
      rs.close();
      ps.close();

      if (status != null && status.equals("1")) {
        status = "active";
      } else {
        status = "not active";

      }
      if (b1) {
        if (pin_db.equals(Util.encMy(pin))) {
          b2 = true;
        } else {
          ret[0] = "4";
        }
      }

      if (b2) {

        String balance_card = "";
        String c_time = "";
        sql = "select balance from tsel_cust_account where acc_no = ?";
        ps = con.prepareStatement(sql);
        ps.setString(1, acc_no);
        rs = ps.executeQuery();

        if (rs.next()) {
          balance_card = rs.getString(1);
          ret[0] = "1";
          ret[1] = formatter.format(Double.parseDouble(balance_card));
        } else {
          ret[0] = "2";
          ret[1] = "account_not_found";
        }
        rs.close();
        ps.close();

      }

    } catch (Exception e) {

      e.printStackTrace(System.out);

    } finally {

      try {con.close();
      } catch (Exception e2) {}
    }
    return ret;
  }

  public void updateLasTxHist(String msisdn, String txt, Connection con)throws Exception {

    String sql = "select hist_msg from msisdn_trxid where msisdn = ? for update";
    PreparedStatement ps = con.prepareStatement(sql);
    ps.setString(1, msisdn);
    ResultSet rs = ps.executeQuery();
    boolean bo = false;
    String s = "";
    if(rs.next()){
      bo = true;
      s = rs.getString(1);
    }

    rs.close();
    ps.close();
    if(!bo) throw new Exception("tx_hist not found "+msisdn);

    String tmp[] = s.split("\\|");

    int len = Integer.parseInt(tmp[0]);
    int len_new = len+1;

    String s_new="";
    String s_old="";
    String s2 [] = new String[len];
    if(len == 5) len = 4;
    for(int i=1; i<=len; i++){
      s_old = s_old+"|"+tmp[i];
    }

    if(len_new > 5) len_new = 5;

    s_new = len_new+"|"+txt+s_old;
    sql = "update msisdn_trxid set hist_msg = ? where msisdn = ?";
    ps = con.prepareStatement(sql);
    ps.setString(1, s_new);
    ps.setString(2, msisdn);
    ps.executeUpdate();
    ps.close();


  }

  public static void main(String[] args) {
    UssdTx ussdTx1 = new UssdTx();
  }

}
