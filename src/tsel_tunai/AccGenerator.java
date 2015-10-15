package tsel_tunai;

import java.sql.*;
import java.util.*;



public class AccGenerator {

  static Random rand = new Random();

  private String generateRandAcc() throws Exception {
    String ret = null;


   // Random integers
   int i = rand.nextInt();
   // Continually call nextInt() for more random integers ...

   // Random integers that range from from 0 to n
   int n = 999998;
   i = rand.nextInt(n + 1);

   ret = String.valueOf(i);
   int le = 6-ret.length();
   for (int x=0; x<le; x++){
     ret = ret+"0";
   }

   i = rand.nextInt(n + 1);

   String tmp1 = String.valueOf(i);
   int le2 = 6-tmp1.length();
   for (int x=0; x<le2 ; x++){
     tmp1 = tmp1+"0";
   }


   return ret+tmp1;

   }


  public AccGenerator() {
    try {

      Connection con = DbCon.createDBConnection("jdbc:mysql://10.2.224.106/tsel_tunai?user=apps&password=aplikasi");
//      DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
//      Connection con = DriverManager.getConnection("jdbc:oracle:thin:@10.2.224.244:1521:OPTUNAI","tunai", "tunai123");
      String sql = "insert into acc_no values(?, ?)";
      PreparedStatement ps = con.prepareStatement(sql);
      for(int i=0; i<10000000; i++){
        String acc_no = this.generateRandAcc();
        ps.setString(1, acc_no);
        ps.setString(2, "0");
        try {
          ps.executeUpdate();
        }catch(Exception e2){ System.out.println("fail_create acc"); }

        System.out.println(i+" "+acc_no+" "+acc_no.length());
      }

    }catch(Exception e){
      e.printStackTrace(System.out);
    }

  }
  public static void main(String[] args) throws Exception  {
    AccGenerator accGenerator1 = new AccGenerator();
  }

}
