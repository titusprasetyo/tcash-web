package tsel_tunai;

import java.sql.*;
import java.math.*;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

import java.security.*;
import javax.crypto.*;
import java.security.spec.*;
import javax.crypto.spec.*;

import java.net.*;
import org.apache.commons.httpclient.*;
import org.apache.commons.httpclient.methods.*;
import org.apache.commons.httpclient.protocol.*;

import com.telkomsel.itvas.database.MysqlFacade;

import java.util.*;
import java.io.*;

public class Util {

	static byte[] salt = { (byte) 0xA9, (byte) 0x9B, (byte) 0xC8, (byte) 0x32,
			(byte) 0x56, (byte) 0x35, (byte) 0xE3, (byte) 0x03 };

	static int iterationCount = 3;
	static String passPhrase = "daniel_keren";

	static Random rand = new Random();

	public static String encMy(String str) throws Exception {
		String ret = null;

		Cipher ecipher;

		// Create the key
		KeySpec keySpec = new PBEKeySpec(passPhrase.toCharArray(), salt,
				iterationCount);
		SecretKey key = SecretKeyFactory.getInstance("PBEWithMD5AndDES")
				.generateSecret(keySpec);
		ecipher = Cipher.getInstance(key.getAlgorithm());

		// Prepare the parameter to the ciphers
		AlgorithmParameterSpec paramSpec = new PBEParameterSpec(salt,
				iterationCount);

		// Create the ciphers
		ecipher.init(Cipher.ENCRYPT_MODE, key, paramSpec);
		//dcipher.init(Cipher.DECRYPT_MODE, key, paramSpec);
		byte[] utf8 = str.getBytes("UTF8");

		// Encrypt
		byte[] enc = ecipher.doFinal(utf8);

		// Encode bytes to base64 to get a string
		return new sun.misc.BASE64Encoder().encode(enc);

	}

	public static String decMy(String str) throws Exception {

		Cipher dcipher;

		// Create the key
		KeySpec keySpec = new PBEKeySpec(passPhrase.toCharArray(), salt,
				iterationCount);
		SecretKey key = SecretKeyFactory.getInstance("PBEWithMD5AndDES")
				.generateSecret(keySpec);

		dcipher = Cipher.getInstance(key.getAlgorithm());

		// Prepare the parameter to the ciphers
		AlgorithmParameterSpec paramSpec = new PBEParameterSpec(salt,
				iterationCount);

		// Create the ciphers
		//ecipher.init(Cipher.ENCRYPT_MODE, key, paramSpec);
		dcipher.init(Cipher.DECRYPT_MODE, key, paramSpec);
		byte[] dec = new sun.misc.BASE64Decoder().decodeBuffer(str);

		// Decrypt
		byte[] utf8 = dcipher.doFinal(dec);

		// Decode using utf-8
		return new String(utf8, "UTF8");

	}

	public Util() {
	}

	public static String[] getHttp(String surl, int ti) {
		String ret[] = new String[3];
		ret[0] = "NOK";
		ret[1] = "-1";

		org.apache.commons.httpclient.HttpClient client = new org.apache.commons.httpclient.HttpClient();

		client.setConnectionTimeout(ti);
		client.setTimeout(ti);

		GetMethod method = new GetMethod(surl);
		method.setHttp11(false);
		// Provide custom retry handler is necessary
		DefaultMethodRetryHandler retryhandler = new DefaultMethodRetryHandler();
		retryhandler.setRequestSentRetryEnabled(false);
		//retryhandler.setRetryCount(3);
		method.setMethodRetryHandler(retryhandler);

		try {
			// Execute the method.
			int statusCode = client.executeMethod(method);
			ret[2] = String.valueOf(statusCode);

			if ((statusCode == HttpStatus.SC_OK) || (statusCode == 202)) {

				ret[0] = "OK";
				ret[1] = method.getResponseBodyAsString();

			} else {

				ret[0] = "NOK";
				ret[1] = method.getStatusLine().toString() + " "
						+ method.getResponseBodyAsString();

			}

		} catch (Exception e) {

			ret[1] = e.getMessage();
			System.out.println("cek_ars fail " + surl + " " + e.getMessage());

		} finally {
			// Release the connection.
			method.releaseConnection();
		}

		return ret;

	}

	public static int getMsisdnType(String msisdn) {
		int ret = -1;

		if (msisdn.startsWith("62852")) {
			ret = 1;
			return ret;
		}

		String r[] = getHttp("http://10.2.224.101:5001/?msisdn=" + msisdn, 5000);

		if (r[0].equals("OK")) {

			String tmp[] = r[1].split("subscriberType=");

			if (tmp.length >= 2) {
				if (tmp[1].length() == 2) {
					String ctipe = tmp[1].substring(0, 1);
					try {
						ret = Integer.parseInt(ctipe);
					} catch (Exception e) {
						e.printStackTrace(System.out);
					}
				}
			}
		}

		return ret;
	}

	public static int getCustServiceType(String msisdn) {
		int ret = 0;

		Connection co = null;
		try {

			co = MysqlFacade.getConnection();
			String sql = "select service_type from customer where msisdn = ?";
			PreparedStatement ps = co.prepareStatement(sql);
			ps.setString(1, msisdn);
			ResultSet rs = ps.executeQuery();
			if (rs.next()) {
				ret = Integer.parseInt(rs.getString(1));
			}

			rs.close();
			ps.close();

		} catch (Exception e) {

			e.printStackTrace(System.out);
		} finally {
			try {
				co.close();
			} catch (Exception ee) {
			}
		}

		return ret;
	}

	public static boolean allowMsisdn(String msisdn) {

		boolean bo = false;
		String url = "http://10.2.224.101:7001/postpaid/msisdn_allow.jsp?msisdn="
				+ msisdn;
		String r[] = getHttp(url, 5000);

		if (r[0].equals("OK")) {
			if (r[1] != null)
				r[1] = r[1].replaceAll("\n", "");
			if (r[1].equals("1"))
				bo = true;

		}

		System.out.println("ret:" + r[1] + "==end==");
		return bo;

	}

	public static void sendNotif(String msisdn, String msg, String source) {

		Connection co = null;
		try {

			co = MysqlFacade.getConnection();
			String sql = "insert into notif(msisdn, msg, source, s_time) values(?, ?, ?, sysdate)";
			PreparedStatement ps = co.prepareStatement(sql);
			ps.setString(1, msisdn);
			ps.setString(2, msg);
			ps.setString(3, source);
			ps.executeUpdate();
			ps.close();

		} catch (Exception e) {

			System.out.println("send_notif fail msisdn:" + msisdn + " msg:"
					+ msg + " err:" + e.getMessage());

		} finally {
			try {
				co.close();
			} catch (Exception ee) {
			}
		}
	}

	public static String[] getPostpaidData(String msisdn) {
		String ret[] = new String[10];
		ret[0] = "-1";

		String url = "http://10.2.224.101:7001/postpaid/data.jsp?msisdn="
				+ msisdn;
		String r[] = getHttp(url, 5000);

		if (r[0].equals("OK")) {
			if (r[1] != null)
				r[1] = r[1].replaceAll("\n", " ");
			String tmp[] = r[1].split("\\|");
			System.out.println(tmp.length);
			if (tmp.length >= 8) {

				ret[0] = "1";
				ret[1] = tmp[0]; //name
				ret[2] = tmp[1]; //address
				ret[3] = tmp[2]; // city
				ret[4] = tmp[3]; //zip
				ret[5] = tmp[6]; //phone_num
				ret[6] = tmp[5]; //ktp_num
				ret[7] = tmp[7]; //birthdate
				ret[8] = ""; //birthplace
				ret[9] = tmp[4]; //mom

			}

		}

		return ret;
	}

	public static String[] getPrepaidData(String msisdn) {
		String ret[] = new String[10];
		ret[0] = "-1";
		String url = "http://10.2.248.52:7777/pls/prereg/prepaid.getprofile?p_msisdn="
				+ msisdn;
		String r[] = getHttp(url, 5000);

		if (r[0].equals("OK")) {
			if (r[1] != null)
				r[1] = r[1].replaceAll("\n", " ");
			String tmp[] = r[1].split("\\|");
			System.out.println(tmp.length);
			if (tmp.length >= 18) {
				if (tmp[11] != null && (tmp[11].length() > 0)) { //simpatizone & g_asik

					if (tmp[15] != null && tmp[15].length() > 1) { //ktp_num or registrasi prabayar
						ret[0] = "1";
						ret[1] = tmp[3]; //name
						ret[2] = tmp[7]; //address
						ret[3] = tmp[8]; // city
						ret[4] = tmp[9]; //zip
						ret[5] = ""; //phone_num
						ret[6] = tmp[15]; //ktp_num
						ret[7] = tmp[4]; //birthdate
						ret[8] = tmp[5]; //birthplace
						ret[9] = tmp[11]; //mom
					}
				}
			}

		}

		return ret;
	}

	public static String getMd5Digest(String input) {
		try {
			MessageDigest md = MessageDigest.getInstance("MD5");
			byte[] messageDigest = md.digest(input.getBytes());
			BigInteger number = new BigInteger(1, messageDigest);
			return number.toString(16).toUpperCase();
		} catch (NoSuchAlgorithmException e) {
			throw new RuntimeException(e);
		}
	}

	public static String generateRandomInt() {
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

		return ret;
	}

	public static void main(String[] args) {
		//int r = Util.getMsisdnType("6285216097223");
		String ret[] = Util.getPrepaidData("6285216097221");
		for (int i = 0; i < ret.length; i++) {
			System.out.println(i + " :" + ret[i]);
		}

		System.out.println(Util.allowMsisdn("62814444"));

		for (int i = 0; i < 100000; i++) {
			System.out.println(i + " " + Util.generateRandomInt());
		}

		//Util.getPrepaidData("628128028286"); //simpatizone

	}

}
