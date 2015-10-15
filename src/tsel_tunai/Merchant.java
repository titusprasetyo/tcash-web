package tsel_tunai;

import java.sql.*;
import java.util.regex.*;
import java.text.*;

public class Merchant
{
	private String name;
	private String address;
	private String city;
	private String zipcode;
	private String msisdn;
	private String phonenum;
	private String login;
	private String password;
	private String ktpno;
	private String npwp;
	private String bankName;
	private String bankAccNo;
	private String bankAccHolder;
	private String tselBankAcc;
	private String merchant_type;
	private String keyMerchant;
	private Connection con;
	
	SimpleDateFormat sdf2 = new SimpleDateFormat("yyMMddHHmmss");
	
	public String getId() throws Exception
	{
		String ret = sdf2.format(new java.util.Date());
		String sql = "select seq_id.nextval from dual";
		Statement st = con.createStatement();
		ResultSet rs = st.executeQuery(sql);

		if(rs.next()) ret = ret + rs.getString(1);
		else
			throw new Exception("fail get id from oracle seq_id");
		rs.close();
		st.close();
		
		return ret;
	}
	
	public String[] create()
	{
		String [] ret = {"0", "internal_problem"};
		String [] retValidate = this.arrValidateInput();
		if(retValidate != null)
		{
			ret[1] = retValidate[1];
			return ret;
		}
		
		if(!this.validateLogin())
		{
			ret[1] = "login_already_exist";
			return ret;
		}
		
		con = null;
		String merchant_info_id  = null;
		
		try
		{
			con = DbCon.getConnection();
			con.setAutoCommit(false);
			merchant_info_id = this.getId();
			String sql = "insert into merchant_info(MERCHANT_INFO_ID,NAME,ADDRESS,CITY,ZIPCODE,PHONE_NUM,MSISDN,KTP_NO,CREATE_TIME,NPWP,BANK_NAME,BANK_ACC_NO,BANK_ACC_HOLDER,TSEL_BANK_ACC) values(?, ?, ?, ?, ?, ?, ?, ?, sysdate, ?, ?, ?, ?, ?)";
			PreparedStatement ps = con.prepareStatement(sql);
			ps.setString(1, merchant_info_id);
			ps.setString(2, this.name);
			ps.setString(3, this.address);
			ps.setString(4, this.city);
			ps.setString(5, this.zipcode);
			ps.setString(6, this.phonenum);
			ps.setString(7, this.msisdn);
			ps.setString(8, this.ktpno);
			ps.setString(9, this.npwp);
			ps.setString(10, this.bankName);
			ps.setString(11, this.bankAccNo);
			ps.setString(12, this.bankAccHolder);
			ps.setString(13, this.tselBankAcc);
			ps.executeUpdate();
			ps.close();
			
			String myPin = this.generatePin();
			String acc_no = this.getAccNo();
			String merchant_id = null;
			merchant_id = this.getId();
			
			sql = "insert into merchant(MERCHANT_ID,MERCHANT_INFO_ID,ACC_NO,LOGIN,PASSWORD,MSISDN,KEYMERCHANT,STATUS,L_UPDATE) values(?, ?, ?, ?, ?, ?, ?, ?, sysdate)";
			ps = con.prepareStatement(sql);
			ps.setString(1, merchant_id);
			ps.setString(2, merchant_info_id);
			ps.setString(3, acc_no);
			ps.setString(4, this.login);
			ps.setString(5, Util.encMy(myPin));
			ps.setString(6, this.msisdn);
			ps.setString(7, this.keyMerchant);
			ps.setString(8, "A");
			ps.executeUpdate();
			ps.close();
			
			sql = "insert into tsel_merchant_account(ACC_NO,DESCRIPTION,BALANCE,CREATE_TIME,STATUS,TYPE) values(?, ?, ?, sysdate, '1', ?)";
			ps = con.prepareStatement(sql);
			ps.setString(1, acc_no);
			ps.setString(2, this.name);
			ps.setString(3, "0");
			ps.setString(4, merchant_type);
			ps.executeUpdate();
			ps.close();
			
			sql = "select count(*) from merchant where to_char(l_update,'YYMMDD')=to_char(sysdate, 'YYMMDD')";
			ps = con.prepareStatement(sql);
			ResultSet rs = ps.executeQuery();
			
			String counter="";

			if (rs.next()) {
				if (rs.getDouble(1) < 10) counter = "0";
				counter = counter + rs.getString(1);
			} else counter="01";
			rs.close();
			ps.close();

			sql = "insert into merchant_virtual_id (MERCHANT_ID, MERCHANT_VIRTUAL_ID, MERCHANT_NAME, STATUS) values(?, to_char(sysdate,'yymmdd') || ?, ?, '1')";
			ps = con.prepareStatement(sql);
			ps.setString(1, merchant_id);
			ps.setString(2, counter);	
			ps.setString(3, this.name);		
			ps.executeUpdate();
			ps.close();
			con.commit();
			
			ret[0] = "1";
			ret[1] = myPin;
		}
		catch(Exception e)
		{
			try
			{
				con.rollback();
			}
			catch(Exception e1)
			{
				System.out.println("rollback_error: " + e1.getMessage());
			}
			e.printStackTrace(System.out);
		}
		finally
		{
			if(con != null)
			{
				try
				{
					con.setAutoCommit(true);
					con.close();
					con = null;
				}
				catch(Exception e2)
				{
				}
			}
		}
		
		return ret;
	}
	
	private String getAccNo()
	{
		String ret = null;
		Connection c = null;
		
		try
		{
			c = DbCon.getConnection();
			c.setAutoCommit(false);
			String sql = "select * from acc_no where status='0' and rownum = 1 for update";
			Statement st = c.createStatement();
			ResultSet rs = st.executeQuery(sql);
			String acc_no = "";
			if (rs.next())
			{
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
		}
		catch(Exception e)
		{
			e.printStackTrace(System.out);
			try
			{
				c.rollback();
			}
			catch(Exception ee)
			{
				System.out.println("rollback_error: " + ee.getMessage());
				ee.printStackTrace(System.out);
			}
		}
		finally
		{
			if(c != null)
			{
				try
				{
					c.setAutoCommit(true);
					c.close();
					c = null;
				}
				catch(Exception ee)
				{
				}
			}
		}
		
		return ret;
	}
	
	public boolean validateLogin()
	{
		boolean b = true;
		con = null;
		try
		{
			con = DbCon.getConnection();
			String sql = "select login from merchant where login = ?";
			PreparedStatement ps = con.prepareStatement(sql);
			ps.setString(1, this.login);
			ResultSet rs = ps.executeQuery();
			if (rs.next())
				b = false;
			
			rs.close();
			ps.close();
		}
		catch(Exception e)
		{
			e.printStackTrace(System.out);
		}
		finally
		{
			if(con != null)
			{
				try
				{
					con.close();
					con = null;
				}
				catch(Exception ee)
				{
				}
			}
		}
		
		return b;
	}
	
	private String generatePin() throws Exception
	{
		String ret = null;
		/*
		ret = String.valueOf(Math.random());
		ret = ret.substring(ret.length() - 5, ret.length());
		*/
		ret = Util.generateRandomInt();
		
		return ret;
	}
	
	public boolean validateInput()
	{
		boolean b = true;
		
		if(this.name == null || (this.name.length() < 1))
		{
			b = false;
			System.out.println("name");
		}
		if(this.address == null || (this.address.length() < 1))
		{
			b = false;
			System.out.println("addr");
		}
		if(this.city == null || (this.city.length() < 1))
		{
			b = false;
			System.out.println("city");
		}
		if(this.msisdn == null || !this.msisdn.startsWith("62"))
		{
			b = false;
			System.out.println("msisdn");
		}
		if(this.ktpno == null || (!Pattern.compile("\\d+").matcher(this.ktpno).matches()))
		{
			b = false;
			System.out.println("ktp_fail");
		}
		if(this.npwp == null || (!Pattern.compile("\\d+").matcher(this.npwp).matches()))
		{
			b = false;
			System.out.println("npwp");
		}
		if(this.login == null || this.login.length() < 3)
		{
			b = false;
			System.out.println("login");
		}
		if(this.bankName == null || this.bankName.length() < 1)
		{
			b = false;
			System.out.println("bankName");
		}
		if(this.bankAccNo == null || (!Pattern.compile("\\d+").matcher(this.bankAccNo).matches()))
		{
			b = false;
			System.out.println("bankAccNo");
		}
		if(this.bankAccHolder == null || this.bankAccHolder.length() < 1)
		{
			b = false;
			System.out.println("bankAccHolder");
		}
		if(this.tselBankAcc == null || (!Pattern.compile("\\d+").matcher(this.tselBankAcc).matches()))
		{
			b = false;
			System.out.println("tselBankAcc");
		}
		if(this.keyMerchant == null || (this.keyMerchant.length() < 2))
			b = false;
		
		System.out.println(b);
		return b;
	}
	
	public String [] arrValidateInput()
	{
		String [] retval = new String[2];
		retval[0] = "1";
		
		if(this.name == null || (this.name.length() < 1))
		{
			retval[1] = "Nama tidak boleh kosong";
			return retval;
		}
		if(this.address == null || (this.address.length() < 1))
		{
			retval[1] = "Alamat tidak boleh kosong";
			return retval;
		}
		if(this.city == null || (this.city.length() < 1))
		{
			retval[1] = "Kota tidak boleh kosong";
			return retval;
		}
		if(this.msisdn == null || !this.msisdn.startsWith("62"))
		{
			retval[1] = "MSISDN tidak boleh kosong dan harus diawali dengan 62";
			return retval;
		}
		if(this.ktpno == null || (!Pattern.compile("\\d+").matcher(this.ktpno).matches()))
		{
			retval[1] = "Nomor KTP tidak boleh kosong dan harus terdiri dari angka saja";
			return retval;
		}
		if(this.npwp == null || (!Pattern.compile("\\d+").matcher(this.npwp).matches()))
		{
			retval[1] = "Nomor NPWP tidak boleh kosong dan harus terdiri dari angka saja";
			return retval;
		}
		if(this.login == null || this.login.length() < 3)
		{
			retval[1] = "Login tidak boleh kosong, dan tidak boleh dipakai sebelumnyam serta minimal terdiri dari tiga karakter";
			return retval;
		}
		if(this.bankName == null || this.bankName.length() < 1)
		{
			retval[1] = "Nama bank tidak boleh kosong";
			return retval;
		}
		if(this.bankAccNo == null || (!Pattern.compile("\\d+").matcher(this.bankAccNo).matches()))
		{
			retval[1] = "Nomor rekening bank tidak boleh kosong dan harus terdiri dari angka saja";
			return retval;
		}
		if(this.bankAccHolder == null || this.bankAccHolder.length() < 1)
		{
			retval[1] = "Nama pemegang rekening bank tidak boleh kosong";
			return retval;
		}
		if(this.tselBankAcc == null || (!Pattern.compile("\\d+").matcher(this.tselBankAcc).matches()))
		{
			retval[1] = "Nomor rekening bank TSEL tidak boleh kosong dan harus terdiri dari angka saja";
			return retval;
		}
		if(this.keyMerchant == null || (this.keyMerchant.length() < 2))
		{
			retval[1] = "Key Merchant tidak boleh kosong, dan minimal terdiri dari 2 karakter";
			return retval;
		}
		
		return null;
	}
	
	public void setName(String name)
	{
		this.name = name;
	}
	
	public void setAddress(String address)
	{
		this.address = address;
	}
	
	public void setZipcode(String zipcode)
	{
		this.zipcode = zipcode;
	}
	
	public void setPhonenum(String phonenum)
	{
		this.phonenum = phonenum;
	}
	
	public void setKtpno(String ktpno)
	{
		this.ktpno = ktpno;
	}
	
	public void setMsisdn(String msisdn)
	{
		this.msisdn = msisdn;
	}
	
	public void setLogin(String login)
	{
		this.login = login;
	}
	
	public void setPassword(String password)
	{
		this.password = password;
	}
	
	public void setCity(String city)
	{
		this.city = city;
	}
	
	public void setNpwp(String npwp)
	{
		this.npwp = npwp;
	}
	
	public void setKeyMerchant(String keyMerchant)
	{
		this.keyMerchant = keyMerchant;
	}
	
	public void setBankName(String bankName)
	{
		this.bankName = bankName;
	}
	
	public void setBankAccNo(String bankAccNo)
	{
		this.bankAccNo = bankAccNo;
	}
	
	public void setBankAccHolder(String bankAccHolder)
	{
		this.bankAccHolder = bankAccHolder;
	}
	
	public void setTselBankAcc(String tselBankAcc)
	{
		this.tselBankAcc = tselBankAcc;
	}

	public void setMerchantType(String merchant_type)
	{
		this.merchant_type = merchant_type;
	}

	
	public String getName()
	{
		return name;
	}
	
	public String getAddress()
	{
		return address;
	}
	
	public String getZipcode()
	{
		return zipcode;
	}
	
	public String getPhonenum()
	{
		return phonenum;
	}
	
	public String getKtpno()
	{
		return ktpno;
	}
	
	public String getMsisdn()
	{
		return msisdn;
	}
	
	public String getLogin()
	{
		return login;
	}
	
	public String getPassword()
	{
		return password;
	}
	
	public String getCity()
	{
		return city;
	}
	
	public String getNpwp()
	{
		return npwp;
	}
	
	public String getBankName()
	{
		return bankName;
	}
	
	public String getBankAccNo()
	{
		return bankAccNo;
	}
	
	public String getBankAccHolder()
	{
		return bankAccHolder;
	}
	
	public String getTselBankAcc()
	{
		return tselBankAcc;
	}
	
	public Merchant() 
	{
	}
	
	public static void main(String [] args)
	{
		Merchant merchant1 = new Merchant();
	}
}
