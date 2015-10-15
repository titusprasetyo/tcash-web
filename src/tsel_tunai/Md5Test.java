package tsel_tunai;

import java.math.*;
import java.security.*;
import javax.crypto.*;
import java.security.spec.*;
import javax.crypto.spec.*;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

public class Md5Test {

  static byte[] salt = {
            (byte)0xA9, (byte)0x9B, (byte)0xC8, (byte)0x32,
            (byte)0x56, (byte)0x35, (byte)0xE3, (byte)0x03
        };

  static int iterationCount = 3;
  static String passPhrase = "daniel_keren";

  public static void main(String[] args) {
    //System.out.println(getMd5Digest("dodol123"));
    for (int i=0; i<100; i++) {
      String s = encMy("dodol123dfsadfdsafsdaf");
      System.out.println(i+" enc :" + s);
      s = decMy(s);
      System.out.println(i+" dec :" + s);
    }

  }



  public static String encMy(String str){
    String ret = null;

    Cipher ecipher;
    Cipher dcipher;

    try {
                // Create the key
                KeySpec keySpec = new PBEKeySpec(passPhrase.toCharArray(), salt, iterationCount);
                SecretKey key = SecretKeyFactory.getInstance(
                    "PBEWithMD5AndDES").generateSecret(keySpec);
                ecipher = Cipher.getInstance(key.getAlgorithm());
                dcipher = Cipher.getInstance(key.getAlgorithm());

                // Prepare the parameter to the ciphers
                AlgorithmParameterSpec paramSpec = new PBEParameterSpec(salt, iterationCount);

                // Create the ciphers
                ecipher.init(Cipher.ENCRYPT_MODE, key, paramSpec);
                //dcipher.init(Cipher.DECRYPT_MODE, key, paramSpec);
                byte[] utf8 = str.getBytes("UTF8");

              // Encrypt
              byte[] enc = ecipher.doFinal(utf8);

              // Encode bytes to base64 to get a string
              return new sun.misc.BASE64Encoder().encode(enc);


            } catch (Exception e) {
              e.printStackTrace(System.out);
            }
            return ret;

  }


  public static String decMy(String str){
    String ret = null;


    Cipher dcipher;

    try {
                // Create the key
                KeySpec keySpec = new PBEKeySpec(passPhrase.toCharArray(), salt, iterationCount);
                SecretKey key = SecretKeyFactory.getInstance(
                    "PBEWithMD5AndDES").generateSecret(keySpec);

                dcipher = Cipher.getInstance(key.getAlgorithm());

                // Prepare the parameter to the ciphers
                AlgorithmParameterSpec paramSpec = new PBEParameterSpec(salt, iterationCount);

                // Create the ciphers
                //ecipher.init(Cipher.ENCRYPT_MODE, key, paramSpec);
                dcipher.init(Cipher.DECRYPT_MODE, key, paramSpec);
                byte[] dec = new sun.misc.BASE64Decoder().decodeBuffer(str);

                 // Decrypt
                 byte[] utf8 = dcipher.doFinal(dec);

                 // Decode using utf-8
                 return new String(utf8, "UTF8");



            } catch (Exception e) {
              e.printStackTrace(System.out);
            }
            return ret;

  }



  static String getMd5Digest(String input) {
    try {
      MessageDigest md = MessageDigest.getInstance("MD5");
      byte[] messageDigest = md.digest(input.getBytes());
      BigInteger number = new BigInteger(1, messageDigest);
      return number.toString(16).toUpperCase();
    } catch (NoSuchAlgorithmException e) {
      throw new RuntimeException(e);
    }
  }


}
