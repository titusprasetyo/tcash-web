package tsel_tunai;

import java.io.*;
import java.util.*;
import java.security.*;
import java.text.*;


public class LogTest {

  String cardid = "";
  String sequence = "";
  String ev = "";
  String sh = "";
  String r_v = "";

  String sh_msg = "";
  boolean valid = false;
  String timestamp = "";

  SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
  static long l2000 = Long.parseLong("946659600000");

  public void calculateThn70() throws Exception {

    java.util.Date d2 = sdf.parse("2000-01-01 00:00:00");
    long l1 = d2.getTime();
    System.out.println(l1);
    this.l2000 = l1;



  }


  public LogTest(String f) {
    try {

      BufferedReader br = new BufferedReader(new FileReader(f));
      String s = "";
      String dat = null;
      while((s = br.readLine()) != null){
        System.out.println("data :"+s);
        dat = s;
      }

      String temp1 = dat.substring(0, 48);
      System.out.println(temp1.length());

      for(int i=1; i<= temp1.length(); i++){
        if((i%3) == 0){
          int r = Integer.parseInt(temp1.substring(i-3, i));
          //System.out.print(" r :"+r+ " ");
          String t2 = Integer.toHexString(r).toUpperCase();
          if(t2.length() < 2) t2 = "0"+t2;
          //System.out.println(t2);
          this.cardid = this.cardid+t2;
        }

      }

      temp1 = dat.substring(69, 78);

      for(int i=1; i<= temp1.length(); i++){
        if((i%3) == 0){
          int r = Integer.parseInt(temp1.substring(i - 3, i));
          //System.out.print(" r :"+r+ " ");
          String t2 = Integer.toHexString(r).toUpperCase();
          if (t2.length() < 2) t2 = "0" + t2;
          this.ev = this.ev + t2;
        }

      }

      System.out.println("cardid:"+this.cardid);
      this.ev = String.valueOf(HexUtils.convertToInt("00"+this.ev)[0]);
      System.out.println("ev :"+this.ev);

      temp1 = dat.substring(78, 108);

      for(int i=1; i<= temp1.length(); i++){
       if((i%3) == 0){
         int r = Integer.parseInt(temp1.substring(i - 3, i));
         //System.out.print(" r :"+r+ " ");
         String t2 = Integer.toHexString(r).toUpperCase();
         if (t2.length() < 2) t2 = "0" + t2;
         this.sh = this.sh + t2;
       }

     }

     System.out.println("sh :"+this.sh);

     temp1 = dat.substring(0,78);

     for(int i=1; i<= temp1.length(); i++){
       if((i%3) == 0){
         int r = Integer.parseInt(temp1.substring(i - 3, i));
         //System.out.print(" r :"+r+ " ");
         String t2 = Integer.toHexString(r).toUpperCase();
         if (t2.length() < 2) t2 = "0" + t2;
         this.r_v = this.r_v + t2;
       }

     }

     //System.out.println("r_v :"+this.r_v);
     this.r_v = this.r_v + "F660CADD6A0CB6D1C304C64D4A9489B5";

     String sh_rv = this.doDigest(HexUtils.convertToByte(this.r_v));
     System.out.println("sh_rv :"+sh_rv);


     if(sh_rv.length() == 40){

       this.sh_msg = sh_rv.substring(20, 40);
       if(this.sh_msg.equals(this.sh)) this.valid = true;

     }

     System.out.println("sh_msg after digest :"+this.sh_msg+ " valid:"+valid);


     //this.calculateThn70();
     System.out.println("l2000 :"+l2000);
     temp1 = dat.substring(54, 66);

     for(int i=1; i<= temp1.length(); i++){
       if((i%3) == 0){
         int r = Integer.parseInt(temp1.substring(i - 3, i));
         //System.out.print(" r :"+r+ " ");
         String t2 = Integer.toHexString(r).toUpperCase();
         if (t2.length() < 2) t2 = "0" + t2;
         this.timestamp = this.timestamp + t2;
       }

     }
     System.out.println("hex timestamp :"+this.timestamp);
     /*
     int detik_from_2000 = HexUtils.convertToInt(this.timestamp)[0];
     long l_temp = (long) detik_from_2000;
     */
    long l_temp = this.byteArrayToLong(HexUtils.convertToByte("00000000"+this.timestamp));
      l_temp = l_temp * 1000;
     System.out.println("ms detik from 2000:"+l_temp);

     java.util.Date dMsg = new java.util.Date((l_temp+this.l2000));
     this.timestamp = sdf.format(dMsg);
     System.out.println("timestamp tx:"+this.timestamp);



    }catch(Exception ee){
      ee.printStackTrace(System.out);
    }
  }

  public static long byteArrayToLong(byte[] bytes) {
                long result = 0;
                result = result | (0xFF00000000000000L & (((long) bytes[0]) << 56));
                result = result | (0x00FF000000000000L & (((long) bytes[1]) << 48));
                result = result | (0x0000FF0000000000L & (((long) bytes[2]) << 40));
                result = result | (0x000000FF00000000L & (((long) bytes[3]) << 32));
                result = result | (0x00000000FF000000L & (((long) bytes[4]) << 24));
                result = result | (0x0000000000FF0000L & (((long) bytes[5]) << 16));
                result = result | (0x000000000000FF00L & (((long) bytes[6]) << 8));
                result = result | (0x00000000000000FFL & (((long) bytes[7])));
                return result;
        }



  public String doDigest(byte input []) throws Exception {
    String ret = "";

    MessageDigest md = MessageDigest.getInstance("SHA1");
    md.update(input);
    byte[] output = md.digest();
    ret = bytesToHex(output);

    return ret;
  }

  public static String bytesToHex(byte[] b) {
        char hexDigit[] = {'0', '1', '2', '3', '4', '5', '6', '7',
                           '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'};
        StringBuffer buf = new StringBuffer();
        for (int j=0; j<b.length; j++) {
           buf.append(hexDigit[(b[j] >> 4) & 0x0f]);
           buf.append(hexDigit[b[j] & 0x0f]);
        }
        return buf.toString();
     }



  public static void main(String[] args)throws Exception {
    //LogTest logTest1 = new LogTest("c:/work/telkomsel_tunai/log.txt");
    String msg = "*501*123435343434343434#";
    String temp [] = msg.split("\\*");
    System.out.println(temp.length+" "+temp[2]);
    String data = temp[2].replaceAll("#", "");
    System.out.println(data);

  }

}
